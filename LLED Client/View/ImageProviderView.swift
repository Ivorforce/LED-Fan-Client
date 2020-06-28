//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ImageCapturePreview: View {
    // TODO Observation never stops
    @ObservedObject var image: ImagePool.State
        
    init(pool: ImagePool) {
        image = ImagePool.State(
            pool: pool,
            info: .init(delay: .seconds(0.1), priority: 10, size: NSSize(width: 100, height: 100))
        )
    }
        
    var body: some View {
        Image(nsImage: image.state?.nsImageRepresentation ?? NSImage())
            .resizable()
            .scaledToFit()
            .whileActive { self.image.isObserving = $0 }
    }
}

struct ImageProviderView: View {
    static let captureMethods = [
        MonitorScreenAVFoundation(),
        SyphonScreen(),
        ImageScreen()
//        MonitorScreenSimple(),
    ]
        
    @ObservedObject var pool: ImagePool
    @State var showPreview = false
    
    let captureSyphonView: CaptureSyphonView
    let captureImageView: CaptureImageView

    init(pool: ImagePool) {
        self.pool = pool
        captureSyphonView = CaptureSyphonView(capturer: Self.captureMethods[1] as! SyphonScreen)
        captureImageView = CaptureImageView(capturer: Self.captureMethods[2] as! ImageScreen)
    }
            
    var methodView: some View {
        switch pool.capturer {
        case is SyphonScreen:
            return AnyView(captureSyphonView)
        case is ImageScreen:
            return AnyView(captureImageView)
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
            
            Toggle(isOn: $pool.applyContrast) {
                Text("Apply Image Filter")
            }
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
