//
//  ScrollPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

// Payload structure
// +-------------------+-------------------+
// | dy: Int32: 4bytes | dx: Int32: 4bytes |
// +-------------------+-------------------+
struct ScrollPacket: ClientPacket {
  static var type = ClientPacketType.scroll
  static let payloadSize: UInt = 8
  
  let dy: Int32
  let dx: Int32
  
  var payload: Data {
    var d = Data(count: 8)
    d.set(dy, at: 0)
    d.set(dx, at: 4)
    return d
  }
  
  init(dy: Int32, dx: Int32) {
    self.dy = dy
    self.dx = dx
  }
  
  init?(payload: Data) {
    guard payload.count == 8 else { return nil }
    
    dy = payload.get(from: 0)!
    dx = payload.get(from: 4)!
  }
}
