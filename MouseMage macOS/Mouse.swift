//
//  Mouse.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CoreGraphics
import ApplicationServices

/// Control the macOS mouse with ease.
struct Mouse: MouseControl {
  
  /// The shared mouse instance
  fileprivate(set) static var shared = Self()
  
  /// Mask of buttons currently pressed
  fileprivate var buttonsDown: UInt32 = 0
  
  /// Whether or not the events have already been tapped
  private static var tapped = false
  
  /// Get the current position of the mouse.
  var location: CGPoint {
    CGEvent.init(source: nil)!.location
  }
  
  // Make this a singleton
  private init() {}
  
  func move(to point: CGPoint) {
    let e = CGEvent.init(mouseEventSource: nil, mouseType: typeForMove(), mouseCursorPosition: point, mouseButton: CGMouseButton(rawValue: buttonForMove())!)
    e?.post(tap: .cghidEventTap)
  }
  
  private func typeForMove() -> CGEventType {
    if buttonsDown == 0 { return .mouseMoved }
    if buttonsDown & (1<<0) > 0 { return .leftMouseDragged }
    if buttonsDown & (1<<1) > 0 { return .rightMouseDragged }
    return .otherMouseDragged
  }
  
  private func buttonForMove() -> UInt32 {
    // Find and return the first pressed button
    for i in 0..<32 {
      if buttonsDown & (1<<i) > 0 {
        return UInt32(i)
      }
    }
    
    // Default to 0 if no buttons pressed.
    return 0
  }
  
  func move(by delta: CGPoint) {
    move(to: location + delta)
  }
  
  func scroll(dy: Int32 = 0, dx: Int32 = 0) {
    scroll(dy: dy, dx: dx, units: .pixel)
  }
  
  /// Scrolls the mouse
  ///
  /// - Parameters:
  ///   - dy: The amount to scroll in the y direction (positive = up).
  ///   - dx: The amount to scroll in the x direction (positive = left).
  ///   - units: The units to use when scrolling.
  func scroll(dy: Int32 = 0, dx: Int32 = 0, units: CGScrollEventUnit) {
    let e = CGEvent(scrollWheelEvent2Source: nil, units: units, wheelCount: 2, wheel1: dy, wheel2: dx, wheel3: 0)
    e?.post(tap: .cghidEventTap)
  }
  
  
  func buttonDown(_ button: UInt8, number: UInt8) {
    buttonDown(UInt32(button), number: Int64(number))
  }
  func buttonDown(_ button: UInt32, number: Int64) {
    print("Mouse down: \(button) \(number)")
    guard let btn = CGMouseButton(rawValue: button) else {
      print("Invalid button \(button)")
      return
    }
    
    let e = CGEvent(mouseEventSource: nil, mouseType: eventTypeDown(from: btn), mouseCursorPosition: location, mouseButton: btn)
    e?.setIntegerValueField(.mouseEventClickState, value: number)
    e?.post(tap: .cghidEventTap)
  }
  
  func buttonUp(_ button: UInt8, number: UInt8) {
    buttonUp(UInt32(button), number: Int64(number))
  }
  func buttonUp(_ button: UInt32, number: Int64) {
    print("Mouse up: \(button) \(number)")
    guard let btn = CGMouseButton(rawValue: button) else {
      print("Invalid button \(button)")
      return
    }
    
    let e = CGEvent(mouseEventSource: nil, mouseType: eventTypeUp(from: btn), mouseCursorPosition: location, mouseButton: btn)
    e?.setIntegerValueField(.mouseEventClickState, value: number)
    e?.post(tap: .cghidEventTap)
  }
  
  func click(button: UInt8, number: UInt8) {
    click(button: UInt32(button), number: Int64(number))
  }
  func click(button: UInt32, number: Int64) {
    print("Click: \(button) \(number)")
    guard let btn = CGMouseButton(rawValue: button) else {
      print("Invalid button \(button)")
      return
    }
    
    // Mouse down
    let e = CGEvent(mouseEventSource: nil, mouseType: eventTypeDown(from: btn), mouseCursorPosition: location, mouseButton: btn)
    e?.setIntegerValueField(.mouseEventClickState, value: number)
    e?.post(tap: .cghidEventTap)
    // Mouse up
    e?.type = eventTypeUp(from: btn)
    e?.post(tap: .cghidEventTap)
  }
  
  private func eventTypeDown(from btn: CGMouseButton) -> CGEventType {
    switch btn {
    case .left: return .leftMouseDown
    case .right: return .rightMouseDown
    default: return .otherMouseDown
    }
  }
  
  private func eventTypeUp(from btn: CGMouseButton) -> CGEventType {
    switch btn {
    case .left: return .leftMouseUp
    case .right: return .rightMouseUp
    default: return .otherMouseUp
    }
  }
  
  /// Tap the event bus to listen for mouse events
  static func tap() {
    guard !tapped else { return }
    
    print("Tapping events...")
    let maskArr: [CGEventType] = [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .otherMouseDown, .otherMouseUp]
    let mask: CGEventMask = maskArr.map({ 1 << $0.rawValue }).reduce(0) { $0 | $1 }
    guard let tap = CGEvent.tapCreate(tap: .cghidEventTap, place: .tailAppendEventTap, options: .listenOnly, eventsOfInterest: mask, callback: onCGEvent(proxy:type:event:refcon:), userInfo: nil) else {
      fatalError("Unable to create tap")
    }
    
    let source = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)
    CFRunLoopRun()
    
    tapped = true
    print("Tapped!")
  }
  
}


fileprivate func onCGEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  let btn = event.getIntegerValueField(.mouseEventButtonNumber)
  
  switch type {
  // Down
  case .leftMouseDown, .rightMouseDown, .otherMouseDown:
    Mouse.shared.buttonsDown |= 1 << btn
  
  // Up
  case .leftMouseUp, .rightMouseUp, .otherMouseUp:
    Mouse.shared.buttonsDown &= ~(1 << btn)
  
  // Should never be called, but required by the compiler
  default: break
  }
  
  // Pass it on!
  return Unmanaged.passRetained(event)
}
