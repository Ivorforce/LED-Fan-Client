//
//  ServerAssemblyView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

extension ServerAssembly {
    var artpollStateView: some View {
        switch artpoll.state {
        case .inProgress:
            return AnyView(ProgressIndicator(configuration: { view in
                view.style = .spinning
                view.controlSize = .small
                view.startAnimation(self)
            }))
        case .done:
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
    @ObservedObject var scan: ArtpollTask
    
    @State var isShowingSummary = false
    
    init(assembly: ServerAssembly) {
        self.assembly = assembly
        self.scan = assembly.artpoll
    }
    
    var body: some View {
        VStack {            
            HStack {
                Text("Servers").frame(width: 150, alignment: .leading)
                Spacer()
                Button(action: {
                    self.assembly.scan()
                }) {
                    Image(systemName: NSImage.refreshTemplateName)
                }
                    .disabled(scan.state == .inProgress)
                
                assembly.artpollStateView
            }
                        
            if !assembly.available.isEmpty {
                HStack {
                    Text("Server Arrangement")
                    
                    Image(systemName: NSImage.quickLookTemplateName)
                        .onHover { self.isShowingSummary = $0 }
                        .popover(isPresented: $isShowingSummary, arrowEdge: .trailing) {
                            Text("Size: \(self.assembly.desiredSize.simpleDescription)")
                        }
                }

                ForEach(assembly.available, id: \.urlString) { server in
                    MiniatureServerView(server: server)
                }
            }
            else {
                Text("No servers found!")
            }
        }
    }
}

struct ServerAssemblyView_Previews: PreviewProvider {
    static var previews: some View {
        ServerAssemblyView(assembly: ServerAssembly())
    }
}
