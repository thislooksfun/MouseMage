//
//  Server.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class Server: NSObject, NetServiceDelegate, GCDAsyncSocketDelegate {
  
  private static let CERT_PASS = "MouseMage"
  
  private var socket: GCDAsyncSocket?
  private var service: NetService?
  
  private var remotes = [Remote]()
  
  private var identity: SecIdentity = {
    print("Generating identity...")
    let path = generateCert()!
    return loadIdentity(from: path)!
  }()
  
  func start() {
    guard socket == nil else {
      print("Server already started")
      return
    }
    
    try! startSocket()
    startService(forPort: Int32(socket!.localPort))
  }
  
  private func startSocket() throws {
    let queue = DispatchQueue(label: "com.thislooksfun.mouse-mage.socket", qos: .default)
    socket = GCDAsyncSocket(delegate: self, delegateQueue: queue)
    try socket!.accept(onPort: 0)
    print("Started socket on port \(socket!.localPort)")
  }
  
  private func startService(forPort port: Int32) {
    service = NetService(domain: "", type: "_remote-mouse-control._tcp.", name: "", port: port)
    service!.includesPeerToPeer = true
    service!.delegate = self
    service!.publish()
  }
  
  private static func generateCert() -> String? {
    let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    guard let appSupportURL = urls.first else { return nil }
    let supportDir = "\(appSupportURL.path)/MouseMage"
    
    try! FileManager.default.createDirectory(atPath: supportDir, withIntermediateDirectories: true, attributes: nil)
    
    bash("""
      cd "\(supportDir)"
      openssl req -x509 -newkey rsa:4096 -passout pass:"\(CERT_PASS)" -keyout key.pem -out cert.pem -days 365 -subj "/"
      openssl pkcs12 -export -in cert.pem -inkey key.pem -passin pass:"\(CERT_PASS)" -out Cert.p12 -passout pass:"\(CERT_PASS)"
      """)
    
    return "\(supportDir)/Cert.p12"
  }
  
  private static func loadIdentity(from certPath: String) -> SecIdentity? {
    guard let cert = try? Data(contentsOf: URL(fileURLWithPath: certPath)) else {
      return nil
    }
    
    return loadIdentity(from: cert)
  }
  
  private static func loadIdentity(from cert: Data) -> SecIdentity? {
    let p12 = cert as CFData
    let options = [kSecImportExportPassphrase as String: CERT_PASS] as CFDictionary

    var rawItems: CFArray?

    guard SecPKCS12Import(p12, options, &rawItems) == errSecSuccess else {
      print("Error in p12 import")
      return nil
    }

    let items = rawItems as! Array<Dictionary<String,Any>>
    let identity = items[0][kSecImportItemIdentity as String] as! SecIdentity

    return identity
  }
  
  // MARK: - NetServiceDelegate
  func netServiceDidPublish(_ sender: NetService) {
    print("Bonjour service published. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port)")
  }
  func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
    print("Unable to create socket. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port), Error \(errorDict)")
  }
  func netServiceWillPublish(_ sender: NetService) {
    print("About to publish!")
  }
  func netServiceWillResolve(_ sender: NetService) { print("will resolve") }
  func netServiceDidResolveAddress(_ sender: NetService) { print("did resolve") }
  func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) { print("did not resolve") }
  func netServiceDidStop(_ sender: NetService) { print("did stop") }
  func netService(_ sender: NetService, didUpdateTXTRecord data: Data) { print("did update TXT") }
  func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) { print("did accept connection") }
  
  // MARK: - GCDAsyncSocketDelegate
  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    print("Socket opened")
    remotes.append(Remote(socket: newSocket, identity: identity))
  }

}
