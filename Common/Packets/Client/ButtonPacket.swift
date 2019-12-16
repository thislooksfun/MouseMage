//
//  ButtonPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/10/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// Payload structure
// +--------------+
// | data: 1byte  |
// +--------------+
//
// Data structure:
// The low 5 bits (0-4) are the button ID
// The middle bit (5) is the direction (up/down) (1 = up, 0 = down)
// The higest bits (6-7) are the click number (0-3)
struct ButtonPacket: ClientPacket {
  static var type = ClientPacketType.button
  static let payloadSize: UInt = 1
  
  private static let CLICK_DIR: UInt8 = 1 << 5
  
  let click: UInt8
  let down: Bool
  let btn: UInt8
  
  var payload: Data {
    // Only use the lowest 5 bits
    var byte: UInt8 = (click << 6) | (btn & 31)
    if !down {
      byte |= ButtonPacket.CLICK_DIR
    }
    return Data([byte])
  }
  
  init(btn: UInt8, down: Bool, click: UInt8) {
    self.click = click
    self.down = down
    self.btn = btn
  }
  
  init?(payload: Data) {
    guard payload.count == 1 else { return nil }
    
    let b = payload[0]
    
    down = b & Self.CLICK_DIR == 0
    btn = b & 31
    click = b >> 6
  }
}

