//
//  RemoteMouse.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CoreGraphics
import CocoaAsyncSocket

/// Control a remote mouse
class RemoteMouse: MouseControl {
  
  private let sensitivity: CGFloat = 1.1
  
  /// The socket to which to send the mouse control packets
  private let sock: GCDAsyncSocket
  
  init(sock: GCDAsyncSocket) {
    self.sock = sock
  }
  
  func move(to point: CGPoint) {
    sock.send(MoveMousePacket(to: point))
  }
  
  func move(by delta: CGPoint) {
    sock.send(MoveMousePacket(by: delta * velocity(for: delta) * sensitivity))
  }
  
  func scroll(dy: Int32, dx: Int32) {
    sock.send(ScrollPacket(dy: dy, dx: dx))
  }
  
  func buttonDown(_ button: UInt8, number: UInt8) {
    sock.send(ButtonPacket(btn: button, down: true, click: number))
  }
  
  func buttonUp(_ button: UInt8, number: UInt8) {
    sock.send(ButtonPacket(btn: button, down: false, click: number))
  }
  
  func click(button: UInt8, number: UInt8) {
    sock.send(ClickPacket(btn: button, click: number))
  }
  
  private func velocity(for delta: CGPoint) -> CGFloat {
    let ad = delta.length
    let min: CGFloat = 3
    
    if ad < min {
      return 1
    }
    
    return 1 + pow(1.075, ad - min)
  }
}
