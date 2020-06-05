//
//  ServerView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ServerView: View {
    @ObservedObject var server = Server()
    
    @State var isShowingLog = false
    @State var log = ""

    var stateView: some View {
        switch server.state {
        case .invalidURL, .noConnection:
            return AnyView(Image(systemName: NSImage.statusUnavailableName))
        case .connecting:
            return AnyView(ProgressIndicator(configuration: { view in
                view.style = .spinning
                view.controlSize = .small
                view.startAnimation(self)
            }))
        case .connected:
            return AnyView(Image(systemName: NSImage.statusAvailableName))
        }
    }
    
    var isConnected: Bool { server.state == .connected }
    
    var body: some View {
        VStack {
            HStack() {
                Text("Server IP")
                    .bold()
                    .frame(width: 100)

                TextField("...", text: $server.urlString)
                    .frame(minWidth: 100)
                
                HStack {
                    stateView

                    Button(action: {
                        self.server.connect()
                    }) {
                        Image(systemName: NSImage.refreshTemplateName)
                    }
                }
                    .frame(width: 80)
                
                Image(systemName: NSImage.quickLookTemplateName)
                    .onHover { isHovering in
                        self.isShowingLog = isHovering && self.isConnected
                        self.server.rest(["log"])?.get { self.log = $0 ?? "" }
                }
                    .popover(isPresented: $isShowingLog, arrowEdge: .trailing) {
                        Text(self.log)
                            .truncationMode(.head)
                    }
            }
            
            HStack {
                Text("Actions")
                    .frame(width: 100)
                
                Button(action: { self.server.reboot() }) {
                    Text("Reboot")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected)

                Button(action: { self.server.ping() }) {
                    Text("Ping")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected)

                Button(action: { self.server.update() }) {
                    Text("Update")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected)
            }
            
            HStack {
                Text("Speed")
                    .frame(width: 100)

                Slider(value: $server.rotationSpeed, in: -1...1)
                    .disabled(!isConnected)

                Button(action: { self.server.rotationSpeed = 0 }) {
                    Text("Stop")
                }
                    .disabled(!isConnected)
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
