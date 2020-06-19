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

    var _imageProviderView: ImageProviderView! = nil
    var imageProviderView: ImageProviderView { _imageProviderView }

    init() {
        assembly = Assembly(capturer: ImageProviderView.captureMethods[0])
        _imageProviderView = ImageProviderView(pool: assembly.pool)
    }
    
    var body: some View {
        VStack {
            imageProviderView
        }.padding()
    }
}
