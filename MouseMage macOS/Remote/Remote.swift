//
//  Remote.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

/// Controls the connection to a remote client
class Remote: RemoteConnection {
  
  private var authenticated = false
  private var secure = false
  
  internal override func sizeOf(packetID id: UInt8) -> UInt {
    guard let pt = ClientPacketType(rawValue: id) else {
      fatalError("Unsupported packet type \(String(format:"%02X", id))")
    }
    
    switch pt {
    case .requestAuth: return RequestAuthPacket.payloadSize
    case .moveMouse: return MoveMousePacket.payloadSize
    case .button: return ButtonPacket.payloadSize
    case .scroll: return ScrollPacket.payloadSize
    case .click: return ClickPacket.payloadSize
    }
  }
  
  internal override func handle(payload: Data, for packetID: UInt8) {
    guard let pt = ClientPacketType(rawValue: packetID) else {
      fatalError("Unsupported packet type \(String(format:"%02X", packetID))")
    }
    
    handle(payload: payload, for: pt)
  }
  
  private func handle(payload: Data, for pt: ClientPacketType) {
    // Only accept packets once secure, dump any others
    guard secure else { return }
    
    guard pt != .requestAuth else {
      // Special case
      auth()
      return
    }
    
    guard authenticated else {
      socket.send(AuthRequiredPacket())
      return
    }
    
    switch pt {
    case .requestAuth:
      // Handled specially above
      break
    
    case .moveMouse:
      let pkt = MoveMousePacket(payload: payload)!
      let pnt = CGPoint(x: pkt.x, y: pkt.y)
      if pkt.relative {
        Mouse.shared.move(by: pnt)
      } else {
        Mouse.shared.move(to: pnt)
      }
      
    case .scroll:
      let pkt = ScrollPacket(payload: payload)!
      Mouse.shared.scroll(dy: pkt.dy, dx: pkt.dx)
    
    case .button:
      let pkt = ButtonPacket(payload: payload)!
      if pkt.down {
        Mouse.shared.buttonDown(pkt.btn, number: pkt.click)
      } else {
        Mouse.shared.buttonUp(pkt.btn, number: pkt.click)
      }
    
    case .click:
      let pkt = ClickPacket(payload: payload)!
      Mouse.shared.click(button: pkt.btn, number: pkt.click)
    }
  }
  
  func auth() {
    let code = UInt16.random(in: 0...9999)
    socket.send(AuthBeginPacket(code: code))

    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Authorize remote"
      alert.informativeText = "Do you want to allow this remote app to control your computer? Code: \(code)"
      alert.alertStyle = .warning
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")

      var pkt: ServerPacket
      if alert.runModal() == .alertFirstButtonReturn {
        self.authenticated = true
        pkt = AuthGrantedPacket()
      } else {
        self.authenticated = false
        pkt = AuthDeniedPacket()
      }

      self.socket.send(pkt)
    }

    print("Auth code: \(code)")
  }
  
  // MARK: - GCDAsyncSocketDelegate
  func socketDidSecure(_ sock: GCDAsyncSocket) {
    print("Socket secured!")
    secure = true
    sock.send(ServerReadyPacket())
  }
  
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    if let e = err {
      print("Socket disconnected with error")
      print(e)
    } else {
      print("Socket disconnected without error")
    }
  }
  
}
