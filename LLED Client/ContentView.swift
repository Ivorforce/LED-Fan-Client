//
//  ContentView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 01.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static let selectableTypes: [Endpoint.Type] = [
        Cartesian.self
    ]
    
    @ObservedObject var serverInfo = ServerInfo()

    @State var selectedMode = 0

    var stateView: some View {
        switch serverInfo.state {
        case .invalidURL:
            return AnyView(Image(systemName: NSImage.statusUnavailableName))
        case .noConnection:
            return AnyView(Button(action: {
                self.serverInfo.connect()
            }) {
                Image(systemName: NSImage.refreshTemplateName)
            })
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
    
    var body: some View {
        VStack() {
            HStack() {
                Text("Server IP")
                    .bold()
                    .fixedSize()
                    .frame(minWidth: 100)

                TextField("...", text: $serverInfo.urlString)
                    .frame(minWidth: 100)
                
                stateView
                    .frame(width: 50)
            }
            
            Spacer()
                .frame(height: 20)
                .fixedSize()
            
            if serverInfo.state == .connected {
                serverInfo.endpoint(mode: Self.selectableTypes[selectedMode]).map { endpoint in
                    HStack {
                        Picker(selection: $selectedMode, label: Text("Screen Mode")) {
                            Text("Cartesian").tag(0)
                        }
                        
                        Image(systemName: NSImage.quickLookTemplateName)
                            .overlay(TooltipView(endpoint.description).withCursor())
                    }
                }
            }
        }
            .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
