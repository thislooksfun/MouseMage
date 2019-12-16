//
//  ContentView.swift
//  MouseMage
//
//  Created by thislooksfun on 12/9/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @State var inDetail = false
  @ObservedObject var finder = ServerFinder()
  
  var body: some View {
    NavigationView {
      List(finder.services) { s in
        NavigationLink(destination: RemoteControl(connection: ServerConnection(service: s), isActive: self.$inDetail), isActive: self.$inDetail) {
          Text(s.name)
        }
      }
        .navigationBarTitle("Computers")
        .onAppear { self.finder.start() }
        .onDisappear { self.finder.stop() }
    }
  }
}
