//
//  ClickPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

import Foundation

// Payload structure
// +--------------+
// | data: 1byte  |
// +--------------+
//
// Data structure:
// The low 5 bits (0-4) are the button ID
// The middle bit (5) is unused
// The higest bits (6-7) are the click number (0-3)
struct ClickPacket: ClientPacket {
  static var type = ClientPacketType.click
  static let payloadSize: UInt = 1
  
  let click: UInt8
  let btn: UInt8
  
  var payload: Data {
    return Data([(click << 6) | (btn & 31)])
  }
  
  init(btn: UInt8, click: UInt8) {
    self.click = click
    self.btn = btn
  }
  
  init?(payload: Data) {
    guard payload.count == 1 else { return nil }
    
    let b = payload[0]
    
    btn = b & 31
    click = b >> 6
  }
}
