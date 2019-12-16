//
//  ServerAuthBeginPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// Payload structure
// +----------------------+
// | code: UInt16: 2bytes |
// +----------------------+
struct AuthBeginPacket: ServerPacket {
  static let type = ServerPacketType.authBegin
  static let payloadSize: UInt = 2
  
  var code: UInt16
  
  var payload: Data {
    withUnsafeBytes(of: code) { Data($0) }
  }
  
  init(code: UInt16) {
    self.code = code
  }
  
  init?(payload: Data) {
    guard payload.count == 2 else { return nil }
    
    code = payload.get(from: 0)!
  }
}
