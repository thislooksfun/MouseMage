//
//  Mouse.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

import Foundation
import CoreGraphics

/// Common set of mouse controls
protocol MouseControl {
  
//  /// Get the current position of the mouse.
//  static var location: CGPoint {
//    CGEvent.init(source: nil)!.location
//  }
  
  /// Move the mouse to a specified point
  ///
  /// - Parameter to: The point to which to move the mouse.
  func move(to point: CGPoint)
  
  /// Move the mouse by a certain offset
  ///
  /// - Parameter by: The amount to offset the position of the mouse.
  func move(by delta: CGPoint)
  
  /// Scrolls the mouse
  ///
  /// - Parameters:
  ///   - dy: The amount to scroll in the y direction (positive = up).
  ///   - dx: The amount to scroll in the x direction (positive = left).
  func scroll(dy: Int32, dx: Int32)
  
  /// Depresses a button
  ///
  /// - Parameters:
  ///   - button: The number of the button to press (0-31)
  ///   - number: The number of the click (1-3)
  func buttonDown(_ button: UInt8, number: UInt8)
  
  /// Releases a button
  ///
  /// - Parameters:
  ///   - button: The number of the button to release (0-31)
  ///   - number: The number of the click (1-3)
  func buttonUp(_ button: UInt8, number: UInt8)
  
  /// Clicks a button
  ///
  /// - Parameters:
  ///   - button: The number of the button to click (0-31)
  ///   - number: The number of the click (1-3)
  func click(button: UInt8, number: UInt8)
}
