//
//  MoveMousePacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

// Payload structure
// +---------------------------+-------------------------+-------------------------+
// | relative: boolean: 1 byte | x: 64bit double: 8bytes | y: 64bit double: 8bytes |
// +---------------------------+-------------------------+-------------------------+
struct MoveMousePacket: ClientPacket {
  static var type = ClientPacketType.moveMouse
  static let payloadSize: UInt = 17
  
  let relative: Bool
  let x: Double
  let y: Double
  
  var payload: Data {
    var p = Data(count: 17)
    p[0] = relative ? 1 : 0
    p.set(x, at: 1)
    p.set(y, at: 9)
    return p
  }
  
  init?(payload: Data) {
    guard payload.count == 17 else { return nil }
    
    relative = payload[0] == 1
    x = payload.get(from: 1)!
    y = payload.get(from: 9)!
  }
  
  init(x: Double, y: Double, relative: Bool) {
    self.relative = relative
    self.x = x
    self.y = y
  }
  init(x: CGFloat, y: CGFloat, relative: Bool) {
    self.init(x: Double(x), y: Double(y), relative: relative)
  }
  init(_ p: CGPoint, relative: Bool) {
    self.init(x: p.x, y: p.y, relative: relative)
  }
  init(to pnt: CGPoint) {
    self.init(pnt, relative: false)
  }
  init(by pnt: CGPoint) {
    self.init(pnt, relative: true)
  }
}
