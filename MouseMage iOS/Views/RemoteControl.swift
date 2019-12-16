//
//  RemoteControl.swift
//  MouseMage
//
//  Created by thislooksfun on 12/10/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import SwiftUI

struct RemoteControl: View {
  
  @ObservedObject var connection: ServerConnection
  @Binding var isActive: Bool

  var body: some View {
    ZStack {
      if connection.state == .disconnected {
        // This state is only reached when the connection has just been created and not yet connected
        Text("Loading...")
      } else if connection.state == .resolving {
        Text("Resolving...")
      } else if connection.state == .connecting {
        Text("Connecting...")
      } else if connection.state == .connected {
        RemoteInner(remote: connection.remote!, isActive: $isActive)
      } else if connection.state == .errored {
        HStack {
          Text("Error")
          Text("\(connection.error)")
        }
      }
    }
      // Meta info
      .navigationBarTitle(Text(connection.serviceName), displayMode: .inline)
      .onAppear { self.connection.connect() }
//      .onDisappear { self.connection.close() }
  }
}


struct RemoteInner: View {
  
  @ObservedObject var remote: Remote
  @Binding var isActive: Bool

  var body: some View {
    ZStack {
      if remote.state == .starting {
        Text("Connecting... (2)")
      } else if remote.state == .authenticating {
        Text("Auth code: \(remote.authCode)")
      } else if remote.state == .ready {
        Trackpad(mouse: remote.mouse)
      } else if remote.state == .disconnected {
        // Automatically go back when disconnected
        Text("Disconnected!!")
          .onAppear { self.isActive = false }
      } else if remote.state == .errored {
        HStack {
          Text("Error")
          Text("\(remote.error)")
        }
      }
    }
  }
}
