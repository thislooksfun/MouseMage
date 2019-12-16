//
//  Packet.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol Packet {
  /// The ID number of the packet
  var id: UInt8 { get }
  
  /// The (optional) payload of the packet
  var payload: Data { get }
  
  /// The size of the payload (in bytes)
  static var payloadSize: UInt { get }
  
  /// Create an instance of this packet from a payload
  ///
  /// - Parameter payload: The payload from which to construct this packet
  ///
  /// - Returns: `nil` if the data was invaid, otherwise a `Packet` instance
  init?(payload: Data)
}

extension Packet {
  // Stub with empty data
  var payload: Data { Data() }
}

extension GCDAsyncSocket {
  /// Send a packet via this socket
  ///
  /// - Parameter to: The socket to which to send the packet
  func send(_ p: Packet) {
    let len = 1 + p.payload.count
    var data = Data(count: len)
    data.set(p.id, at: 0)
    data.set(p.payload, at: 1)
    
    write(data, withTimeout: -1, tag: Int(p.id))
  }
}


// MARK: - Client
// Packets coming FROM the remote client TO the server
protocol ClientPacket: Packet {
  static var type: ClientPacketType { get }
}
extension ClientPacket {
  var id: UInt8 { Self.type.rawValue }
}


// MARK: - Server
// Packets going TO the remote client FROM the server
protocol ServerPacket: Packet {
  static var type: ServerPacketType { get }
}
extension ServerPacket {
  var id: UInt8 { Self.type.rawValue }
}
