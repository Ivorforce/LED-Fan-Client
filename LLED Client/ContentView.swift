//
//  ContentView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 01.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var serverInfo = ServerInfo()

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
                Text("Server IP: ")
                    .fixedSize()
                
                TextField("...", text: $serverInfo.urlString)
                    .frame(minWidth: 100, minHeight: 100)
                
                stateView
                    .frame(width: 50)
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
