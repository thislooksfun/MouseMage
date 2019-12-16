//
//  AuthDeniedPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// No payload
struct AuthDeniedPacket: ServerPacket {
  static let type = ServerPacketType.authGranted
  static let payloadSize: UInt = 0
  
  init() {}
  init?(payload: Data) {}
}
