//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

class CaptureMethodProvider: ObservableObject {
    enum Method: Int {
        case screen, syphon
    }

    @Published var selectedMode = Method.screen {
        didSet {
            self.objectWillChange.send()

            switch selectedMode {
            case .screen:
                capturer = CaptureScreen()
            case .syphon:
                capturer = CaptureSyphon()
            }
        }
    }
    
    @Published var capturer: ImageCapture? = nil
}

struct ImageProviderView: View {
    @ObservedObject var captureProvider = CaptureMethodProvider()

    var methodView: some View {
        switch captureProvider.capturer {
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
            Picker(selection: $captureProvider.selectedMode, label: Text("Capture Method")) {
                Text("Screen").tag(CaptureMethodProvider.Method.screen)
                Text("Syphon").tag(CaptureMethodProvider.Method.syphon)
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
