//
//  ServerConnection.swift
//  MouseMage
//
//  Created by thislooksfun on 12/10/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class ServerConnection: NSObject, ObservableObject, NetServiceDelegate, GCDAsyncSocketDelegate {
  
  @Published
  var state = ConnectionState.disconnected
  
  @Published
  var error = ""
  
  @Published
  var remote: Remote?
  
  
  var serviceName: String { service.name }
  
  private var socket: GCDAsyncSocket?
  
  private let service: NetService
  
  init(service: NetService) {
    self.service = service
  }
  
  func connect() {
    DispatchQueue.main.async { self.state = .resolving }
    service.delegate = self
    service.resolve(withTimeout: 0)
  }
  
  private func error(reason: String) {
    DispatchQueue.main.async {
      self.error = reason
      self.state = .errored
    }
  }
  
  private func connected(to sock: GCDAsyncSocket) {
    DispatchQueue.main.async {
      self.remote = Remote(socket: sock)
      self.state = .connected
    }
  }
  
  
  // MARK: - NetServiceDelegate
  func netServiceDidResolveAddress(_ sender: NetService) {
    print("Resolved")
    DispatchQueue.main.async { self.state = .connecting }
    
    guard let addresses = service.addresses else {
      error(reason: "No addresses to connect to!")
      return
    }
    
    let queue = DispatchQueue(label: "com.thislooksfun.mouse-mage.socket", qos: .default)
    socket = GCDAsyncSocket(delegate: self, delegateQueue: queue)
    
    guard let socket = socket else {
      fatalError("Logic error!")
    }
    
    var connected = false
    for addr in addresses {
      do {
        try socket.connect(toAddress: addr)
        connected = true
        break
      } catch {
        print(error)
      }
    }
    
    guard connected else {
      error(reason: "Unable to connect")
      return
    }
  }
  
  func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
    error(reason: "Unable to resolve address: \(errorDict)")
  }
  
  func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
    connected(to: sock)
  }
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    connected(to: sock)
  }
  
  enum ConnectionState {
    case disconnected
    case errored
    case resolving
    case connecting
    case connected
  }
  
}
