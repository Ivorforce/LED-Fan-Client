//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ImageProviderView: View {
    static let captureMethods = [
        CaptureScreen(),
        CaptureSyphon()
    ]
    
    @State var capturer: ImageCapture = Self.captureMethods[0]
    
    var methodView: some View {
        switch capturer {
        case is CaptureSyphon:
            return EmptyView()
        case is CaptureScreen:
            return EmptyView()
        default:
            fatalError()
        }
    }

    var body: some View {
        VStack {
            Picker(selection: $capturer, label: Text("Capture Method")) {
                ForEach(Self.captureMethods, id: \.description) { method in
                    Text(method.name()).tag(method)
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
