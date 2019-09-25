// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Cluster/Membership.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

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
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum ProtoClusterMemberReachability: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unspecified // = 0
  case reachable // = 1
  case unreachable // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .unspecified
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unspecified
    case 1: self = .reachable
    case 2: self = .unreachable
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unspecified: return 0
    case .reachable: return 1
    case .unreachable: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ProtoClusterMemberReachability: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [ProtoClusterMemberReachability] = [
    .unspecified,
    .reachable,
    .unreachable,
  ]
}

#endif  // swift(>=4.2)

enum ProtoClusterMemberStatus: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unspecified // = 0
  case joining // = 1
  case up // = 2
  case down // = 3
  case leaving // = 4
  case removed // = 5
  case UNRECOGNIZED(Int)

  init() {
    self = .unspecified
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unspecified
    case 1: self = .joining
    case 2: self = .up
    case 3: self = .down
    case 4: self = .leaving
    case 5: self = .removed
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unspecified: return 0
    case .joining: return 1
    case .up: return 2
    case .down: return 3
    case .leaving: return 4
    case .removed: return 5
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ProtoClusterMemberStatus: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [ProtoClusterMemberStatus] = [
    .unspecified,
    .joining,
    .up,
    .down,
    .leaving,
    .removed,
  ]
}

#endif  // swift(>=4.2)

struct ProtoClusterMembership {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var members: [ProtoClusterMember] {
    get {return _storage._members}
    set {_uniqueStorage()._members = newValue}
  }

  var leader: ProtoClusterMember {
    get {return _storage._leader ?? ProtoClusterMember()}
    set {_uniqueStorage()._leader = newValue}
  }
  /// Returns true if `leader` has been explicitly set.
  var hasLeader: Bool {return _storage._leader != nil}
  /// Clears the value of `leader`. Subsequent reads from it will return its default value.
  mutating func clearLeader() {_uniqueStorage()._leader = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct ProtoClusterMember {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var node: ProtoUniqueNode {
    get {return _storage._node ?? ProtoUniqueNode()}
    set {_uniqueStorage()._node = newValue}
  }
  /// Returns true if `node` has been explicitly set.
  var hasNode: Bool {return _storage._node != nil}
  /// Clears the value of `node`. Subsequent reads from it will return its default value.
  mutating func clearNode() {_uniqueStorage()._node = nil}

  var status: ProtoClusterMemberStatus {
    get {return _storage._status}
    set {_uniqueStorage()._status = newValue}
  }

  var reachability: ProtoClusterMemberReachability {
    get {return _storage._reachability}
    set {_uniqueStorage()._reachability = newValue}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// TODO: MembershipGossip?
/// TODO restructure that it should be more about who saw what node in what state, not the ClusterEvents, as the "from" status does not matter
struct ProtoClusterMembershipGossip {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// origin of the gossip
  var from: ProtoUniqueNode {
    get {return _storage._from ?? ProtoUniqueNode()}
    set {_uniqueStorage()._from = newValue}
  }
  /// Returns true if `from` has been explicitly set.
  var hasFrom: Bool {return _storage._from != nil}
  /// Clears the value of `from`. Subsequent reads from it will return its default value.
  mutating func clearFrom() {_uniqueStorage()._from = nil}

  /// TODO: Something else, "membership diff"?
  var members: [ProtoClusterMember] {
    get {return _storage._members}
    set {_uniqueStorage()._members = newValue}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ProtoClusterMemberReachability: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "CLUSTER_MEMBER_REACHABILITY_UNSPECIFIED"),
    1: .same(proto: "CLUSTER_MEMBER_REACHABILITY_REACHABLE"),
    2: .same(proto: "CLUSTER_MEMBER_REACHABILITY_UNREACHABLE"),
  ]
}

extension ProtoClusterMemberStatus: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "CLUSTER_MEMBER_STATUS_UNSPECIFIED"),
    1: .same(proto: "CLUSTER_MEMBER_STATUS_JOINING"),
    2: .same(proto: "CLUSTER_MEMBER_STATUS_UP"),
    3: .same(proto: "CLUSTER_MEMBER_STATUS_DOWN"),
    4: .same(proto: "CLUSTER_MEMBER_STATUS_LEAVING"),
    5: .same(proto: "CLUSTER_MEMBER_STATUS_REMOVED"),
  ]
}

extension ProtoClusterMembership: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "ClusterMembership"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "members"),
    2: .same(proto: "leader"),
  ]

  fileprivate class _StorageClass {
    var _members: [ProtoClusterMember] = []
    var _leader: ProtoClusterMember? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _members = source._members
      _leader = source._leader
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeRepeatedMessageField(value: &_storage._members)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._leader)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._members.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._members, fieldNumber: 1)
      }
      if let v = _storage._leader {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ProtoClusterMembership, rhs: ProtoClusterMembership) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._members != rhs_storage._members {return false}
        if _storage._leader != rhs_storage._leader {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtoClusterMember: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "ClusterMember"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "node"),
    2: .same(proto: "status"),
    3: .same(proto: "reachability"),
  ]

  fileprivate class _StorageClass {
    var _node: ProtoUniqueNode? = nil
    var _status: ProtoClusterMemberStatus = .unspecified
    var _reachability: ProtoClusterMemberReachability = .unspecified

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _node = source._node
      _status = source._status
      _reachability = source._reachability
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularMessageField(value: &_storage._node)
        case 2: try decoder.decodeSingularEnumField(value: &_storage._status)
        case 3: try decoder.decodeSingularEnumField(value: &_storage._reachability)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._node {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if _storage._status != .unspecified {
        try visitor.visitSingularEnumField(value: _storage._status, fieldNumber: 2)
      }
      if _storage._reachability != .unspecified {
        try visitor.visitSingularEnumField(value: _storage._reachability, fieldNumber: 3)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ProtoClusterMember, rhs: ProtoClusterMember) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._node != rhs_storage._node {return false}
        if _storage._status != rhs_storage._status {return false}
        if _storage._reachability != rhs_storage._reachability {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ProtoClusterMembershipGossip: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "ClusterMembershipGossip"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "from"),
    2: .same(proto: "members"),
  ]

  fileprivate class _StorageClass {
    var _from: ProtoUniqueNode? = nil
    var _members: [ProtoClusterMember] = []

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _from = source._from
      _members = source._members
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularMessageField(value: &_storage._from)
        case 2: try decoder.decodeRepeatedMessageField(value: &_storage._members)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._from {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_storage._members.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._members, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ProtoClusterMembershipGossip, rhs: ProtoClusterMembershipGossip) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._from != rhs_storage._from {return false}
        if _storage._members != rhs_storage._members {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
