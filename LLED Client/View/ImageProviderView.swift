//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct CaptureSyphonView: View {
    @ObservedObject var syphon: SyphonScreen
    
    static func syphonableName(dict: [String: Any]) -> String {
        if let name = dict[SyphonServerDescriptionNameKey] as? String, !name.isEmpty {
            return name
        }
        if let appName = dict[SyphonServerDescriptionAppNameKey] as? String, !appName.isEmpty {
            return appName
        }
        
        return dict[SyphonServerDescriptionUUIDKey] as? String ?? "Unknown Syphonable"
    }
    
    var body: some View {
        guard let servers = SyphonServerDirectory.shared()?.servers as? [[String: Any]] else {
            return AnyView(Text("Failed to connect to Syphon"))
        }
        
        guard !servers.isEmpty else {
            return AnyView(Text("No servers found!"))
        }
        
        var serverDict: [String: [String: Any]] = [:]
        for server in servers {
            if let serverID = server[SyphonServerDescriptionUUIDKey] as? String {
                serverDict[serverID] = server
            }
        }
        
        let picker = Picker(selection: $syphon.captureID, label:
            Text("Syphonable").frame(width: 150, alignment: .leading)
        ) {
            ForEach(serverDict.keys.sorted(), id: \.self) { serverID in
                HStack {
                    (serverDict[serverID]?[SyphonServerDescriptionIconKey] as? NSImage).map {
                        Image(nsImage: $0)
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    Text(Self.syphonableName(dict: serverDict[serverID]!))
                }
                    .tag(serverID)
            }
        }
        
        return AnyView(picker)
    }
}

struct ImageCapturePreview: View {
    // TODO Observation never stops
    @ObservedObject var image: ImagePool.State
        
    init(pool: ImagePool) {
        image = pool.observedState(info: .init(delay: .seconds(0.1), priority: 10, size: NSSize(width: 100, height: 100)))
    }
    
    var body: some View {
        Image(nsImage: image.state?.nsImageRepresentation ?? NSImage())
            .resizable()
            .scaledToFit()
    }
}

struct ImageProviderView: View {
    static let captureMethods = [
        MonitorScreenAVFoundation(),
        SyphonScreen(),
        MonitorScreenSimple()
    ]
        
    @ObservedObject var pool: ImagePool
    @State var showPreview = false
    
    let captureSyphonView: CaptureSyphonView
    
    init(pool: ImagePool) {
        self.pool = pool
        captureSyphonView = CaptureSyphonView(syphon: Self.captureMethods[1] as! SyphonScreen)
    }
            
    var methodView: some View {
        switch pool.capturer {
        case is SyphonScreen:
            return AnyView(captureSyphonView)
        default:
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        VStack {
            HStack {
                // TODO For some reason, the binding itself doesn't cause a redraw
                Picker(selection: $pool.capturer, label:
                    Text("Capture Method").frame(width: 150, alignment: .leading)
                ) {
                    ForEach(Self.captureMethods, id: \.name) { method in
                        Text(method.name).tag(method)
                    }
                }
                
                Image(systemName: NSImage.quickLookTemplateName)
                    .onHover { self.showPreview = $0 }
                    .popover(isPresented: $showPreview, arrowEdge: .trailing) {
                        ImageCapturePreview(pool: self.pool)
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
            }
            
            methodView
        }
    }
    
    var isReady: Bool {
        return true
    }
}

//struct ImageProviderView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageProviderView()
//    }
//}
