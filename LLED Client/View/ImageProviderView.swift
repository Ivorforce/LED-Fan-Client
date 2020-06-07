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

class CaptureObserver : ObservableObject {
    var capturer: ImageCapture
    var image: NSImage = NSImage() {
        didSet { objectWillChange.send() }
    }
    
    var timer: Timer?
    
    init(capturer: ImageCapture) {
        self.capturer = capturer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.image = self.capturer.grab()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct ImageCapturePreview: View {
    @ObservedObject var observer : CaptureObserver
    
    init(capturer: ImageCapture) {
        observer = CaptureObserver(capturer: capturer)
    }
    
    var body: some View {
        Image(nsImage: observer.image)
            .resizable()
            .scaledToFit()
    }
}

struct ImageProviderView: View {
    static let captureMethods = [
        MonitorScreen(),
        SyphonScreen()
    ]
    
    @State var _redrawTrigger: Bool = false
    
    @Binding var capturer: ImageCapture
    @State var showPreview = false
    
    let captureSyphonView: CaptureSyphonView
    
    init(capturer: Binding<ImageCapture>) {
        _capturer = capturer
        captureSyphonView = CaptureSyphonView(syphon: Self.captureMethods[1] as! SyphonScreen)
    }
            
    var methodView: some View {
        switch capturer {
        case is SyphonScreen:
            return AnyView(captureSyphonView)
        case is MonitorScreen:
            return AnyView(EmptyView())
        default:
            fatalError()
        }
    }

    var body: some View {
        VStack {
            HStack {
                // TODO For some reason, the binding itself doesn't cause a redraw
                Picker(selection: Binding<ImageCapture>(
                    get: { self.capturer },
                    set: { self.capturer = $0; self._redrawTrigger.toggle() }
                ), label:
                    Text("Capture Method").frame(width: 150, alignment: .leading)
                ) {
                    ForEach(Self.captureMethods, id: \.description) { method in
                        Text(method.name).tag(method)
                    }
                }
                
                Image(systemName: NSImage.quickLookTemplateName)
                    .onHover { isHovering in self.showPreview = isHovering }
                    .popover(isPresented: $showPreview, arrowEdge: .trailing) {
                        ImageCapturePreview(capturer: self.capturer)
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
