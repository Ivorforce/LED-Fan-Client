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
    @State var showPreview = false
        
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
            HStack {
                Picker(selection: $capturer, label: Text("Capture Method")) {
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
