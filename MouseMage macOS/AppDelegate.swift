//
//  AppDelegate.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Cocoa
import SwiftUI
import ApplicationServices

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var statusItem: NSStatusItem!
  let server = Server()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard checkAccess() else {
      fatalError("Enable access in System Preferences, then rerun.")
    }
    
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    guard let button = statusItem.button else {
      print("status bar item failed. Try removing some menu bar item.")
      NSApp.terminate(nil)
      return
    }
    
    button.title = "MM"
    button.target = self
    button.action = #selector(displayMenu)
    
    Mouse.tap()
    server.start()
  }
  
  @objc
  private func displayMenu() {
    print("Displaying menu!")
    
    DispatchQueue.main.asyncAfter(deadline: .now()) { Mouse.shared.move(to: CGPoint(x: 400, y: 327)) }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { Mouse.buttonDown(0) }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { Mouse.shared.move(to: CGPoint(x: 600, y: 327)) }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { Mouse.buttonUp(0) }
  }
  
  // Ripped off from https://stackoverflow.com/questions/40144259/modify-accessibility-settings-on-macos-with-swift
  // You need accessibility access to tap key events.
  public func checkAccess() -> Bool{
      //get the value for accesibility
      let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
      //set the options: false means it wont ask
      //true means it will popup and ask
      let options = [checkOptPrompt: true]
      //translate into boolean value
      let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
      return accessEnabled
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}
