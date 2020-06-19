//
//  ServerAssemblyView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

extension ReadyTask {
    var stateView: some View {
        switch state {
        case .failure, .none:
            return AnyView(Image(systemName: NSImage.statusUnavailableName))
        case .inProgress:
            return AnyView(ProgressIndicator(configuration: { view in
                view.style = .spinning
                view.controlSize = .small
                view.startAnimation(self)
            }))
        case .success:
            return AnyView(Image(systemName: NSImage.statusAvailableName))
        }
    }
}

struct MiniatureServerView: View {
    @State var server: Server
    @State var isExpanded = false
    
    var body: some View {
        HStack {
            Text(server.urlString)
            
            Button(action: {
                self.isExpanded.toggle()
            }) {
                Image(systemName: NSImage.quickLookTemplateName)
            }
                .popover(isPresented: $isExpanded, arrowEdge: .trailing) {
                    ServerView(server: self.server)
                        .padding()
                }
        }
    }
}

struct ServerAssemblyView: View {
    @ObservedObject var assembly: ServerAssembly
    @ObservedObject var scan: ReadyTask
    
    init(assembly: ServerAssembly) {
        self.assembly = assembly
        self.scan = assembly.scan
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Servers").frame(width: 150, alignment: .leading)
                Spacer()
                Button(action: {
                    self.scan.start()
                }) {
                    Image(systemName: NSImage.refreshTemplateName)
                }
                
                scan.stateView
            }
            
            ForEach(assembly.available, id: \.urlString) { server in
                MiniatureServerView(server: server)
            }
        }
    }
}

struct ServerAssemblyView_Previews: PreviewProvider {
    static var previews: some View {
        ServerAssemblyView(assembly: ServerAssembly())
    }
}
