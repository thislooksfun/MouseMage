//
//  PacketTYpe.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// Packets coming FROM the remote client TO the server
enum ClientPacketType: UInt8 {
  case requestAuth
  case moveMouse
  case button
  case scroll
  case click
}

// Packets going TO the remote client FROM the server
enum ServerPacketType: UInt8 {
  case serverReady
  case authRequired
  case authBegin
  case authDenied
  case authGranted
}
