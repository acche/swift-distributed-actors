//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2018 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#include <math.h>
#include <stdio.h>

// TODO getting better code completion this way... works ok in xcode and friends this way too?
//#include "CMailbox.h"
#include "include/CMailbox.h"
#include "include/itoa.h"

// Implementation notes:
// State should be operated on bitwise; where the specific bits signify states like the following:
// 0 - 29 - activation count
//     30 - terminating (or terminated)
//     31 - terminated (for sure)
// Activation count is special in the sense that we use it as follows, it's value being:
// 0 - inactive, not scheduled and no messages to process
// 1 - active without(!) normal messages, only system messages are to be processed
// n - there are (n >> 1) messages to process + system messages if LSB is set
//
// Note that this implementation allows, using one load, to know:
// - if the actor is running right now (so the mailbox size will be decremented shortly),
// - current mailbox size (nr. of enqueued messages, which can be used for scheduling and/or metrics)
// - if we need to schedule it or not since it was scheduled already etc.

#define ACTIVATIONS 0b00111111111111111111111111111111

// Implementation notes about Termination:
// Termination MUST first set TERMINATING and only after add the "final" TERMINATED state.
// In other words, the only legal bit states a mailbox should observe are:
//  - 0b11.. alive,
//  -> 0b01.. terminating,
//  -> 0b11.. terminated, dead.
// Meaning that `10` is NOT legal.
#define TERMINATING 0b01000000000000000000000000000000
#define TERMINATED  0b10000000000000000000000000000000

int64_t increment_status_activations(CMailbox* mailbox);
int64_t decrement_status_activations(CMailbox* mailbox, int64_t n);
int64_t try_activate(CMailbox* mailbox);
int64_t activations(int64_t status);
int64_t message_count(int64_t status);
int64_t set_status_terminating(CMailbox* mailbox);
int64_t set_status_terminated_dead(CMailbox* mailbox);


void print_debug_status(CMailbox *mailbox, char* msg);
bool has_activations(int64_t status);
bool has_system_messages(int64_t status);

bool is_terminating(int64_t status);
bool is_terminated_dead(int64_t status);

bool internal_send_message(CMailbox* mailbox, void* envelope, bool is_system_message);

int64_t max(int64_t a, int64_t b);


CMailbox* cmailbox_create(int64_t capacity, int64_t max_run_length) {
  CMailbox* mailbox = calloc(sizeof(CMailbox), 1);
  mailbox->capacity = capacity;
  mailbox->max_run_length = max_run_length;
  mailbox->messages = cmpsc_linked_queue_create();
  mailbox->system_messages = cmpsc_linked_queue_create();

  return mailbox;
}

void cmailbox_destroy(CMailbox* mailbox) {
  free(mailbox);
}

bool cmailbox_send_message(CMailbox* mailbox, void* envelope) {
  int64_t old_status = increment_status_activations(mailbox);
  int64_t old_activations = activations(old_status);
  CMPSCLinkedQueue* queue = mailbox->messages;
  // printf("[cmailbox] enter send_message; messages in queue: %lld\n", (message_count(old_status)));

  // `>` is correct and not an one-off, since message count is `activations - 1`
  if ((old_activations > mailbox->capacity) || is_terminating(old_status)) {
    // If we passed the maximum capacity of the user queue, we can't enqueue more
    // items and have to decrement the activations count again. This is not racy,
    // because we only process messages if the queue actually contains them (does
    // not return NULL), so even if messages get processed concurrently, it's safe
    // to decrement here.
    decrement_status_activations(mailbox, 0b10);
    // TODO emit the message as ".dropped(msg)"
    return false;
  } else {
    // If the mailbox is not full, or we enqueue a system message, we insert it
    // into the queue and return whether this was the first activation, to signal
    // the need to enqueue this mailbox.
    cmpsc_linked_queue_enqueue(queue, envelope);
    return old_activations == 0;
  }
}

bool cmailbox_send_system_message(CMailbox* mailbox, void* envelope) {
  // printf("[cmailbox] send_system_message: \n");
  int64_t old_status = try_activate(mailbox); // only activation matters
  int64_t old_activations = activations(old_status);
  CMPSCLinkedQueue* queue = mailbox->system_messages; // TODO move out the if, we know into which queue we will write when we call send()

  // if (is_terminating(old_status)) {
  if (is_terminated_dead(old_status)) {
    // since we are terminating, we are already dropping all messages, including this one!
    // TODO emit the message as ".dropped(msg)"
    return false;
  } else {
    // If the mailbox is not full, or we enqueue a system message, we insert it
    // into the queue and return whether this was the first activation, to signal
    // the need to enqueue this mailbox.
    cmpsc_linked_queue_enqueue(queue, envelope);
    return old_activations == 0;
  }
}

bool cmailbox_run(CMailbox* mailbox, void* context, void* system_context, InterpretMessageCallback interpret_message) {
  int64_t status = atomic_load_explicit(&mailbox->status, memory_order_acquire);
  // print_debug_status(mailbox, "Entering run");

//  if (!has_activations(status)) { // FIXME should this not actually be a bug, because we had a spurious activation triggered?
//    return false;
//  }

  int64_t processed_activations = 0;
  // TODO: more smart scheduling decisions (smart batching), though likely better on dispatcher layer
  int64_t run_length = max(message_count(status), mailbox->max_run_length);

  // printf("[cmailbox] run_length = %lld\n", run_length);

  // only an keep_running actor shall continue running;
  // e.g. once .terminate is received, the actor should drain all messages to the dead letters queue
  bool keep_running = true; // TODO hijack the run_length, and reformulate it as "fuel", and set it to zero when we need to stop

  // run system messages ------

  if (has_system_messages(status)) {
    // printf("[cmailbox] Has system message(s)\n");
    processed_activations = 0b1; // marker value, not a counter; meaning that we did process system messages
    // we run all system messages, as they may
    void* system_message = cmpsc_linked_queue_dequeue(mailbox->system_messages);
    while (system_message != NULL && keep_running) {
      // printf("[cmailbox] Processing system message...\n");
      keep_running = interpret_message(system_context, system_message);
      system_message = cmpsc_linked_queue_dequeue(mailbox->system_messages);
    }

    // was our run was interrupted by a system message causing termination?
    if (!keep_running) {
      print_debug_status(mailbox, "before set TERMINATING");
      set_status_terminating(mailbox);
      print_debug_status(mailbox, "after set TERMINATING");
      // yes, we are terminating and need to drain messages to dead letters
      // FIXME: implement draining to dead letters
    }
  }
  // end of system messages run ------

  // while a run shall handle system messages while terminating,
  // it should NOT handle user messages while terminating:
  keep_running = keep_running && !is_terminating(status);

  // run user messages ------

  if (keep_running) {
    void* message = cmpsc_linked_queue_dequeue(mailbox->messages);
    while (message != NULL && keep_running) {
      // we need to add 2 to processed_activations because the user message count is stored
      // shifted by 1 in the status and we use the same field to clear the
      // system message bit
      processed_activations += 0b10;
      // printf("[cmailbox]Processing user message...\n");
      // TODO fix this dance
      bool is_stopped = interpret_message(context, message); // todo we can optimize the keep_running into the processed counter?
      keep_running = !is_stopped;

      // TODO optimize all this branching into riding on the processed_activations perhaps? we'll see later on -- ktoso
      if (keep_running == false) {
        printf("STOPPING BASED ON MESSAGE INTERPRETATION\n");
        print_debug_status(mailbox, "STOPPING...");
        set_status_terminating(mailbox);
        print_debug_status(mailbox, "MARKED TERMINATING");
        message = NULL; // break out of the loop
      } else if (processed_activations >= run_length) {
        message = NULL; // break out of the loop
      } else {
        // dequeue another message, if there are no more messages left, message
        // will contain NULL and terminate the loop
        message = cmpsc_linked_queue_dequeue(mailbox->messages);
      }
    }
  }

  // end of user messages run ------

  if (is_terminating(status)) {
    printf("Skipping message processing since we are terminating...!\n");
    // TODO drain them to dead letters

    // TODO drainToDeadLetters(mailbox->messages) {
    void* message = cmpsc_linked_queue_dequeue(mailbox->messages);
    while (message != NULL) {
      printf("Dropping user message, we are terminating...\n");
      processed_activations += 0b10;
      message = cmpsc_linked_queue_dequeue(mailbox->messages); // keep draining
    }
  }

  // printf("[cmailbox] ProcessedActivations %lld messages...\n", processed_activations);

  int64_t old_status = decrement_status_activations(mailbox, processed_activations);
  int64_t old_activations = activations(old_status);
  // printf("[cmailbox] Old: %lld, processed_activations: %lld\n", old_activations, processed_activations);
  print_debug_status(mailbox, "Run complete...\n");

  if (old_activations == processed_activations &&
      !cmpsc_linked_queue_is_empty(mailbox->system_messages) &&
      activations(try_activate(mailbox)) == 0) {
    // If we processed_activations all messages (including system messages) that have been
    // present when we started to process messages and there are new system
    // messages in the queue, but the mailbox has not been re-scheduled yet
    // return true to signal the queue should be re-scheduled
    print_debug_status(mailbox, "Run complete, shouldReschedule:true, pending system messages\n");
    return true;
  } else if (old_activations > processed_activations) {
    // if we could not process all messages in this run, because we had more
    // messages queued up than the maximum run length, return true to signal
    // the queue should be re-scheduled

    char msg [300];
    sprintf(msg, "Run complete, shouldReschedule:true; %lld > %lld\n", old_activations, processed_activations);
    print_debug_status(mailbox, msg);
    return true;
  }

  print_debug_status(mailbox, "Run complete, shouldReschedule:false\n");
  return false;
}

void print_debug_status(CMailbox *mailbox, char* msg) {
  #if SACT_TRACE_MAILBOX
  int64_t status = atomic_load_explicit(&mailbox->status, memory_order_acquire);

  char buffer[33];
  itoa(status, buffer, 2);

  printf("[cmailbox] "
         "%s "
         "Status now: [%lld, bin:%s], "
         "has_sys_msgs:%s, "
         "msgs:%lld, "
         "terminating:%s, "
         "dead:%s"
         "\n",
         msg,
         status, buffer,
         has_system_messages(status) ? "Y" : "N",
         message_count(status),
         is_terminating(status) ? "Y" : "N",
         is_terminated_dead(status) ? "Y" : "N"
  );
  #endif
}

int64_t try_activate(CMailbox* mailbox) {
  return atomic_fetch_or_explicit(&mailbox->status, 1, memory_order_acq_rel);
}

// TODO this is more like increment message count
int64_t increment_status_activations(CMailbox* mailbox) {
  return atomic_fetch_add_explicit(&mailbox->status, 0b10, memory_order_acq_rel);
}

int64_t decrement_status_activations(CMailbox* mailbox, int64_t n) {
  return atomic_fetch_sub_explicit(&mailbox->status, n, memory_order_acq_rel);
}

int64_t set_status_terminating(CMailbox* mailbox) {
  // printf("[cmailbox] Setting TERMINATING marker.\n");
  return atomic_fetch_or_explicit(&mailbox->status, TERMINATING, memory_order_acq_rel);
}

// intentionally spelled "_dead" to avoid typos
// TODO this should be the last write we perform
int64_t set_status_terminated_dead(CMailbox* mailbox) {
  return atomic_fetch_or_explicit(&mailbox->status, TERMINATED, memory_order_acq_rel);
}

bool has_system_messages(int64_t status) {
  return (status & 1) == 1;
}

bool has_activations(int64_t status) {
  return (status & ACTIVATIONS) != 0;
}

int64_t activations(int64_t status) {
  return status & ACTIVATIONS;
}

int64_t message_count(int64_t status) {
  int64_t count = activations(status) >> 1;
  return count > 0 ? count : 0;
}

// TODO consider "closed" wording for the mailbox; actors terminate, mailboxes "close"
bool cmailbox_is_closed(CMailbox* mailbox) {
  int64_t status = atomic_load_explicit(&mailbox->status, memory_order_acquire);
  return is_terminating(status);
}

bool is_terminating(int64_t status) {
  return (status & TERMINATING) != 0;
}

bool is_terminated_dead(int64_t status) {
  return (status & TERMINATED) != 0;
}

int64_t max(int64_t a, int64_t b) {
  return a > b ? b : a;
}
