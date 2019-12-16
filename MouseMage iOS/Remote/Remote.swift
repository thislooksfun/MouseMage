//
//  Remote.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class Remote: RemoteConnection, ObservableObject {
  
  @Published
  var state = ConnectionState.starting
  
  @Published
  var authCode: UInt16 = 0
  
  @Published
  var error = ""
  
  let mouse: RemoteMouse
  
  init(socket: GCDAsyncSocket) {
    mouse = RemoteMouse(sock: socket)
    super.init(socket: socket, allowAllCerts: true)
  }
  
  private func error(reason: String) {
    DispatchQueue.main.async {
      self.state = .errored
      self.error = reason
    }
  }
  
  internal override func sizeOf(packetID id: UInt8) -> UInt {
    guard let pt = ServerPacketType(rawValue: id) else {
      fatalError("Unsupported packet type \(String(format:"%02X", id))")
    }
    
    switch pt {
    case .serverReady: return ServerReadyPacket.payloadSize
    case .authRequired: return AuthRequiredPacket.payloadSize
    case .authBegin: return AuthBeginPacket.payloadSize
    case .authGranted: return AuthGrantedPacket.payloadSize
    case .authDenied: return AuthDeniedPacket.payloadSize
    }
  }
  
  internal override func handle(payload: Data, for packetID: UInt8) {
    guard let pt = ServerPacketType(rawValue: packetID) else {
      fatalError("Unsupported packet type \(String(format:"%02X", packetID))")
    }
    
    handle(payload: payload, for: pt)
  }
  
  private func handle(payload: Data, for pt: ServerPacketType) {
    switch pt {
    case .serverReady, .authRequired:
      print("Requesting auth")
      socket.send(RequestAuthPacket())
      
    case .authBegin:
      let pkt = AuthBeginPacket(payload: payload)!
      print("Trying to auth with code \(pkt.code)")
      DispatchQueue.main.async {
        self.authCode = pkt.code
        self.state = .authenticating
      }
      
    case .authGranted:
      DispatchQueue.main.async { self.state = .ready }
    
    case .authDenied:
      error(reason: "Auth denied")
    }
  }
  
  
  // MARK: - GCDAsyncSocketDelegate
  
  func socketDidSecure(_ sock: GCDAsyncSocket) {
    print("Socket secured")
  }
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    print("Disconnected")
    DispatchQueue.main.async {
      self.state = .disconnected
    }
  }
  
  
  // MARK: - Enums
  
  enum ConnectionState {
    case starting
    case authenticating
    case errored
    case ready
    case disconnected
  }
  
}
