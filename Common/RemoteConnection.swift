//
//  RemoteConnection.swift
//  MouseMage
//
//  Created by thislooksfun on 12/10/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class RemoteConnection: NSObject, GCDAsyncSocketDelegate {
  
  private let queue = DispatchQueue(label: "com.thislooksfun.mouse-mage.remote", qos: .userInitiated)
  let socket: GCDAsyncSocket
  
  /// Create a new RemoteConnection client
  ///
  /// - Parameters:
  ///   - socket: The socket to use for connection
  ///   - allowAllCerts: Whether or not to allow any certificate
  init(socket: GCDAsyncSocket, allowAllCerts: Bool) {
    self.socket = socket
    
    super.init()
    
    self.start(tlsSettings: [
      GCDAsyncSocketManuallyEvaluateTrust: NSNumber(value: allowAllCerts)
    ])
  }
  
  
  /// Create a new RemoteConnection server
  ///
  /// - Parameters:
  ///   - socket: The socket to use for connection
  ///   - identity: The SSL identity to use for authentication
  init(socket: GCDAsyncSocket, identity: SecIdentity) {
    self.socket = socket
    
    super.init()
    
    self.start(tlsSettings: [
      kCFStreamSSLPeerName as String: NSString(string: "MouseMageSecure"),
      kCFStreamSSLIsServer as String: NSNumber(value: true),
      kCFStreamSSLCertificates as String: NSArray(array: [identity])
    ])
  }
  
  
  private func start(tlsSettings opts: [String: NSObject]) {
    socket.delegate = self
    socket.delegateQueue = queue
    
    print("staring TLS")
    socket.startTLS(opts)
    print("started TLS")
    
    // Start reading data
    read(mode: .id)
  }
  
  /// Get the expected size of a packet
  ///
  /// - Parameter packetID: The ID of the packet
  ///
  /// - Returns: The expected size of the packet in bytes
  open func sizeOf(packetID: UInt8) -> UInt {
    fatalError("sizeOf(packetID:) not implemented")
  }
  
  /// Handle an incoming packet
  ///
  /// - Parameters:
  ///   - payload: The payload of the packet
  ///   - for: The ID of the packet
  open func handle(payload: Data, for packetID: UInt8) {
    fatalError("handle(payload:for:) not implemented")
  }
  
  
  
  private func read(mode: ReadMode) {
    switch mode {
    case .id:
      socket.readData(toLength: 1, withTimeout: -1, tag: -1)
    case .payload(let size, let id):
      if size > 0 {
        socket.readData(toLength: size, withTimeout: -1, tag: Int(id))
      } else {
        handle(payload: Data(), for: id)
        read(mode: .id)
      }
    }
  }
  
  enum ReadMode {
    case id
    case payload(size: UInt, for: UInt8)
  }
  
  
  // MARK: - GCDAsyncSocketDelegate
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    guard data.count > 0 else { fatalError("Logic error -- data count was 0") }
    
    if tag == -1 {
      let size = sizeOf(packetID: data[0])
      read(mode: .payload(size: size, for: data[0]))
    } else {
      handle(payload: data, for: UInt8(tag))
      read(mode: .id)
    }
  }
  func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
    // All certificates are generated at runtime by the server, so there is not really anything we can
    // conclusively verify. Besides, the point of the SSL connection in this app is to prevent injection
    // and replay attacks, as well as snooping, not to verify a connection to a specific host. That is done
    // seperately.
    completionHandler(true)
  }
  
}
