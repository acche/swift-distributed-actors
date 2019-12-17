// ==== ------------------------------------------------------------------ ====
// === DO NOT EDIT: Generated by GenActors                     
// ==== ------------------------------------------------------------------ ====

// ==== ------------------------------------------------------------------ ====
// === DO NOT EDIT: Generated by GenActors                     
// ==== ------------------------------------------------------------------ ====

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//sa
//===----------------------------------------------------------------------===//

import DistributedActors
import XPCActorable

// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated XPCEchoServiceProtocolStub messages 

/// DO NOT EDIT: Generated XPCEchoServiceProtocolStub messages
extension XPCEchoServiceProtocolStub {

    public enum Message { 
        case xPCEchoServiceProtocol(/*TODO: MODULE.*/GeneratedActor.Messages.XPCEchoServiceProtocol) 
    }
    
    /// Performs boxing of GeneratedActor.Messages.XPCEchoServiceProtocol messages such that they can be received by Actor<XPCEchoServiceProtocolStub>
    public static func _boxXPCEchoServiceProtocol(_ message: GeneratedActor.Messages.XPCEchoServiceProtocol) -> XPCEchoServiceProtocolStub.Message {
        .xPCEchoServiceProtocol(message)
    } 
    
}
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated XPCEchoServiceProtocolStub behavior

extension XPCEchoServiceProtocolStub {

    public static func makeBehavior(instance: XPCEchoServiceProtocolStub) -> Behavior<Message> {
        fatalError("Behavior STUB for XPCActorableProtocol. Not intended to be instantiated.")
    }
}
