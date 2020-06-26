//
//  CaptureSyphonView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 26.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

class SyphonProvider: ObservableObject {
    static func syphonableName(dict: [String: Any]) -> String {
        if let name = dict[SyphonServerDescriptionNameKey] as? String, !name.isEmpty {
            return name
        }
        if let appName = dict[SyphonServerDescriptionAppNameKey] as? String, !appName.isEmpty {
            return appName
        }
        
        return dict[SyphonServerDescriptionUUIDKey] as? String ?? "Unknown Syphonable"
    }
    
    var directory: SyphonServerDirectory
    var observation: NSKeyValueObservation?
    
    init(directory: SyphonServerDirectory) {
        self.directory = directory
        observation = directory.observe(\.servers) { (_, change) in
            self.objectWillChange.send()
        }
    }

    var servers: [[String: Any]] {
        directory.servers as? [[String: Any]] ?? []
    }
}

struct CaptureSyphonView: View {
    @ObservedObject var syphon: SyphonScreen
    @ObservedObject var syphonProvider: SyphonProvider
    
    init(syphon: SyphonScreen) {
        self.syphon = syphon
        syphonProvider = SyphonProvider(directory: .shared())
    }
        
    var body: some View {
        let servers = syphonProvider.servers
        
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
                    Text(SyphonProvider.syphonableName(dict: serverDict[serverID]!))
                }
                    .tag(serverID)
            }
        }
        
        return AnyView(picker)
    }
}
