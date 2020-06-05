//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

extension CaptureSyphon : ObservableObject {
    var observedCaptureID : String {
        set {
            captureID = newValue
            self.objectWillChange.send()
        }
        get { captureID }
    }
}

struct CaptureSyphonView: View {
    @ObservedObject var syphon: CaptureSyphon
    
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
        
        let picker = Picker(selection: $syphon.observedCaptureID, label:
            Text("Syphonable").frame(width: 150, alignment: .leading)
        ) {
            ForEach(serverDict.keys.sorted(), id: \.self) { serverID in
                HStack {
                    (serverDict[serverID]?[SyphonServerDescriptionIconKey] as? NSImage).map {
                        Image(nsImage: $0)
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    Text(serverDict[serverID]?[SyphonServerDescriptionNameKey] as? String ?? "Unknown Syphonable")
                }
                    .tag(serverID)
            }
        }
        
        return AnyView(picker)
    }
}

struct ImageProviderView: View {
    static let captureMethods = [
        CaptureScreen(),
        CaptureSyphon()
    ]
    
    @State var capturer: ImageCapture = Self.captureMethods[0]
    @State var showPreview = false
    
    let captureSyphonView: CaptureSyphonView
    
    init() {
        captureSyphonView = CaptureSyphonView(syphon: Self.captureMethods[1] as! CaptureSyphon)
    }
            
    var methodView: some View {
        switch capturer {
        case is CaptureSyphon:
            return AnyView(captureSyphonView)
        case is CaptureScreen:
            return AnyView(EmptyView())
        default:
            fatalError()
        }
    }

    var body: some View {
        VStack {
            HStack {
                Picker(selection: $capturer, label:
                    Text("Capture Method").frame(width: 150, alignment: .leading)
                ) {
                    ForEach(Self.captureMethods, id: \.description) { method in
                        Text(method.name()).tag(method)
                    }
                }
                
                Image(systemName: NSImage.quickLookTemplateName)
                    .onHover { isHovering in self.showPreview = isHovering }
                    .popover(isPresented: $showPreview, arrowEdge: .trailing) {
                        Image(nsImage: self.capturer.grab()) // TODO Show live
                            .resizable()
                            .scaledToFit()
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

struct ImageProviderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageProviderView()
    }
}
