//
//  ServerFinder.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

class ServerFinder: NSObject, NetServiceBrowserDelegate, ObservableObject {
  private let browser = NetServiceBrowser()
  
  @Published
  private(set) var services = [NetService]()
  
  func start() {
    // Reset array
    services = []
    // Start the search
    browser.delegate = self
    browser.searchForServices(ofType: "_remote-mouse-control._tcp", inDomain: "")
  }
  
  func stop() {
    browser.stop()
  }
  
  // MARK: - NetServiceBrowserDelegate
  func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
    print("Will search")
  }
  func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
    print("Did stop search")
  }
  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    print("Did not search: \(errorDict)")
  }
  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    services.append(service)
  }
  func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
    print("Removing service \(service.name)")
    services = services.filter { $0 != service }
  }
}

extension NetService: Identifiable {
  public var id: String { name }
}
