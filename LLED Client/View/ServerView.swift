//
//  ServerView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ServerWifiView: View {
    @ObservedObject var server = Server()

    @State var ssid: String = ""
    @State var password: String = ""
    
    @ObservedObject var isConnecting = TimedBool()

    var body: some View {
        VStack {
            Button(action: {
                self.server.pair()
                self.isConnecting.activate(for: .seconds(2))
            }) {
                Text("Pair")
            }
                .disabled(server.state != .connected || self.isConnecting.value)

            HStack {
                TextField("SSID", text: $ssid)
                SecureField("Password", text: $password)
                
                Button(action: {
                    self.server.pair(ssid: self.ssid, password: self.password)
                    self.isConnecting.activate(for: .seconds(2))
                }) {
                    Text("Connect")
                }
                    .disabled(server.state != .connected || ssid.isEmpty || self.isConnecting.value)
            }
        }
    }
}

struct ServerView: View {
    @ObservedObject var server = Server()
    
    @State var isShowingLog = false
    @State var log = ""

    @ObservedObject var isActioning = TimedBool()

    init(server: Server) {
        self.server = server
        self.wifiView = ServerWifiView(server: server)
    }
    
    let wifiView: ServerWifiView

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
                Text("Server Address")
                    .bold()
                    .frame(width: 100, alignment: .leading)

                Text(server.urlString)
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
                        if isHovering {
                            self.log = ""
                            self.server.rest(["log"])?.get { self.log = $0 ?? "" }
                        }
                }
                    .popover(isPresented: $isShowingLog, arrowEdge: .trailing) {
                        if !self.log.isEmpty {
                            Text(self.log)
                                .fixedSize()
                                .padding()
                        }
                        else {
                            ProgressIndicator { view in
                                view.style = .spinning
                                view.startAnimation(self)
                            }.padding()
                        }
                    }
            }
            
            HStack {
                Text("Actions")
                    .frame(width: 100)
                
                Button(action: {
                    self.server.reboot()
                    self.isActioning.activate(for: .seconds(2))
                }) {
                    Text("Reboot")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected || isActioning.value)

                Button(action: {
                    self.server.ping()
                    self.isActioning.activate(for: .seconds(2))
                }) {
                    Text("Ping")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected || isActioning.value)

                Button(action: {
                    self.server.update()
                    self.isActioning.activate(for: .seconds(2))
                }) {
                    Text("Update")
                }
                    .frame(maxWidth: .infinity)
                    .disabled(!isConnected || isActioning.value)
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
            
            Text("WiFi")
                .bold()
                .frame(width: 100)

            wifiView
        }
    }
}
//
//struct ServerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerView()
//    }
//}
