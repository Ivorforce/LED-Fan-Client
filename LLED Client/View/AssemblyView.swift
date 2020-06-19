//
//  AssemblyView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct AssemblyView: View {
    @ObservedObject var assembly: Assembly

    let imageProviderView: ImageProviderView
    let serversView: ServerAssemblyView

    init() {
        let assembly = Assembly(capturer: ImageProviderView.captureMethods[0])
        self.assembly = assembly
        imageProviderView = ImageProviderView(pool: assembly.pool)
        serversView = ServerAssemblyView(assembly: assembly.servers)
        
        assembly.servers.scan.start()
    }
    
    var body: some View {
        VStack {
            imageProviderView
            serversView
        }.padding()
    }
}
