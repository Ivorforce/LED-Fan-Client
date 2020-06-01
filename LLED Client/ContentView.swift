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
        case .noConnection, .invalidURL:
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
    
    var body: some View {
        VStack() {
            HStack() {
                Text("Server IP: ")
                    .fixedSize()
                
                TextField("...", text: $serverInfo.urlString)
                    .frame(minWidth: 100, minHeight: 100)
                
                stateView
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
