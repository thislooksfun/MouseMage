//
//  Trackpad.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import SwiftUI

struct Trackpad: View {
  
  let mouse: RemoteMouse
  private let generator = UISelectionFeedbackGenerator()
  
  // Mouse buttons
  @State private var buttons = MouseButtons()
  
  // Trackpad
  @State private var trackpadLastDragPos: CGPoint?
  @State private var trackpadLastDragTrans: CGSize?
  
  // Scroll wheel
  @State private var scrollwheelLastDragPos: CGPoint?
  
  
  var trackpadDrag: some Gesture {
    DragGesture(minimumDistance: 1)
      .onChanged { value in
        let lastPos = self.trackpadLastDragPos ?? value.startLocation
        let delta = value.location - lastPos
        self.mouse.move(by: delta)
        self.trackpadLastDragPos = value.location
      }.onEnded { _ in
        self.trackpadLastDragPos = nil
      }
  }
  
  var leftMouseDrag: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        self.buttons.left.down(self.mouse)
      }.onEnded { _ in
        self.buttons.left.up(self.mouse)
      }
  }
  
  var rightMouseDrag: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        self.buttons.right.down(self.mouse)
      }.onEnded { _ in
        self.buttons.right.up(self.mouse)
      }
  }
  
  var scrollwheelDrag: some Gesture {
    DragGesture(minimumDistance: 1)
      .onChanged { value in
        let lastPos = self.scrollwheelLastDragPos ?? value.startLocation
        let delta = value.location - lastPos
        self.mouse.scroll(dy: Int32(delta.y * -8), dx: 0)
        self.scrollwheelLastDragPos = value.location
        
        let lastTrans = self.trackpadLastDragTrans ?? CGSize.zero
        let lastStep = Int(lastTrans.height / 10)
        let step = Int(value.translation.height / 10)
        if lastStep != step {
          self.generator.selectionChanged()
        }
        self.trackpadLastDragTrans = value.translation
      }.onEnded { _ in
        self.scrollwheelLastDragPos = nil
      }
   }
  
  var body: some View {
    GeometryReader { geom in
      VStack {
        // Trackpad
        Rectangle()
          .fill(Color("padBackground"))
          .gesture(self.trackpadDrag)
          .onTapGesture{ self.buttons.left.click(self.mouse) }
        
        // Buttons
        HStack(spacing: 5) {
          // Left click
          ZStack {
            Rectangle()
              .fill(Color("padBackground"))
              .gesture(self.leftMouseDrag)
              .aspectRatio(1, contentMode: .fit)
            
            Text("L")
              .font(.largeTitle)
              .foregroundColor(Color("padLabel"))
          }
          
          // Scroll wheel
          Rectangle()
            .fill(Color("padBackground"))
            .gesture(self.scrollwheelDrag)
            .onTapGesture { self.buttons.middle.click(self.mouse) }
            .aspectRatio(1 / 2, contentMode: .fit)
            .frame(width: (geom.size.width - 10) / 5)
          
          // Right click
          ZStack {
            Rectangle()
              .fill(Color("padBackground"))
              .gesture(self.rightMouseDrag)
              .aspectRatio(1, contentMode: .fit)
          
            Text("R")
              .font(.largeTitle)
              .foregroundColor(Color("padLabel"))
          }
        }
      }
    }
  }
}


fileprivate struct MouseButtons {
  var left = MouseButton(code: 0)
  var right = MouseButton(code: 1)
  var middle = MouseButton(code: 2)
}

fileprivate struct MouseButton {
  private let generator = UISelectionFeedbackGenerator()
  let code: UInt8
  var down = false
  var lastClick = ClickState(click: 0, at: 0)
  
  mutating func click(_ mouse: RemoteMouse) {
    didClick()
    mouse.click(button: code, number: lastClick.click)
    generator.selectionChanged()
  }
  
  mutating func down(_ mouse: RemoteMouse) {
    guard !down else { return }
    
    didClick()
    mouse.buttonDown(code, number: lastClick.click)
    generator.selectionChanged()
    down = true
  }
  
  mutating func up(_ mouse: RemoteMouse) {
    guard down else { return }
    
    mouse.buttonUp(code, number: lastClick.click)
    generator.selectionChanged()
    down = false
  }
  
  mutating func didClick() {
    let now = Date().timeIntervalSince1970
    let deltaTime = now - lastClick.at
    var click: UInt8 = 1
    if deltaTime < 0.25 {
      click += lastClick.click
    }
    if click > 3 {
      click = 1
    }
    
    lastClick = ClickState(click: click, at: now)
  }
}

fileprivate struct ClickState {
  let click: UInt8
  let at: TimeInterval
}
