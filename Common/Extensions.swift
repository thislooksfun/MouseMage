//
//  Extensions.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
  static func +(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
  }
  
  static func -(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
  }
  
  static func *(a: CGPoint, b: CGFloat) -> CGPoint {
    return CGPoint(x: a.x * b, y: a.y * b)
  }
  static func *(a: CGFloat, b: CGPoint) -> CGPoint {
    return b * a
  }
  
  var length: CGFloat {
    return sqrt(pow(x, 2) + pow(y, 2))
  }
}


// Helper
extension Data {
  mutating func ensureSpace(_ len: Int, at offset: Int) {
    guard offset + len <= count else {
      self.reserveCapacity(offset + len)
      return
    }
  }
}


// Numeric types
extension Data {
  mutating func set<T>(_ t: T, at offset: Int) {
    let len = MemoryLayout.size(ofValue: t)
    ensureSpace(len, at: offset)
    Swift.withUnsafeBytes(of: t) { replaceSubrange(offset..<offset+len, with: $0) }
  }
  
  init<T>(from value: T) {
    self = Swift.withUnsafeBytes(of: value) { Data($0) }
  }

  func get<T>(from offset: Int) -> T? where T: ExpressibleByIntegerLiteral {
    var value: T = 0
    let len = MemoryLayout.size(ofValue: value)
    guard offset + len <= count else { return nil }
    _ = Swift.withUnsafeMutableBytes(of: &value, { self[offset..<offset+len].copyBytes(to: $0)} )
    return value
  }
}


// Data
extension Data {
  mutating func set(_ d: Data, at offset: Int) {
    ensureSpace(d.count, at: offset)
    replaceSubrange(offset..<offset+d.count, with: d)
  }
}


extension Data {
  var asHex: String { map { $0.asHex }.joined() }
}
extension UInt8 {
  var asHex: String { String(format: "%02hhx", self) }
}
