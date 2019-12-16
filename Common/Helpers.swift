//
//  Helpers.swift
//  MouseMage
//
//  Created by thislooksfun on 12/8/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation
import CoreGraphics

func fsleep(_ f: Float) {
  usleep(UInt32(f * 1000000))
}

func dsleep(_ d: Double) {
  usleep(UInt32(d * 1000000))
}

func rescale(_ f: CGFloat, fromBetween inLow: CGFloat, and inHigh: CGFloat, toBetween outLow: CGFloat, and outHigh: CGFloat) -> CGFloat {
  return ((f - inLow) / (inHigh - inLow)) * (outHigh - outLow) + outLow
}

func lerp(_ f: CGFloat, from a: CGFloat, to b: CGFloat, clamp: Bool = false) -> CGFloat {
  if (clamp) {
    if f <= 0 { return a }
    if f >= 1 { return b }
  }
  return f*a + (1-f)*b
}
