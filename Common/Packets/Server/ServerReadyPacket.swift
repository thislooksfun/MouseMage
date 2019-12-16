//
//  ServerReadyPacket.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// No payload
struct ServerReadyPacket: ServerPacket {
  static let type = ServerPacketType.serverReady
  static let payloadSize: UInt = 0
  
  init() {}
  init?(payload: Data) {}
}
