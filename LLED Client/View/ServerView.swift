//
//  ServerView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ServerView: View {
    @ObservedObject var serverInfo = ServerInfo()

    var stateView: some View {
        switch serverInfo.state {
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

    var body: some View {
        HStack() {
            Text("Server IP")
                .bold()
                .fixedSize()
                .frame(minWidth: 100)

            TextField("...", text: $serverInfo.urlString)
                .frame(minWidth: 100)
            
            HStack {
                stateView

                Button(action: {
                    self.serverInfo.connect()
                }) {
                    Image(systemName: NSImage.refreshTemplateName)
                }
            }
                .frame(width: 80)
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
