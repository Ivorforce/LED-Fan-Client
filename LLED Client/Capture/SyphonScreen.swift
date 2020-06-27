//
//  SyphonScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

import OpenGL
import GLKit

@available(*, deprecated, message: "OpenGL deprecated")
class SyphonScreen : ActiveImageCapture, ObservableObject {
    var captureID: String = "" {
        didSet {
            objectWillChange.send()
        }
    }
        
    internal var _currentDescription: [String: Any]?
    
    var syphon: SyphonClient?
    var downloader: OpenGLDownloader?
    
    let changeResource = BufferedResource<Bool>(limit: 1)
    
    override init() {
        downloader = OpenGLDownloader()
        downloader?.prepareOpenGL()
        super.init()
    }
    
    override func start(delay: TimeInterval, desiredSize: NSSize) {
        // Clean up, then re-setup
        super.start(delay: delay, desiredSize: desiredSize)

        guard let description = SyphonServerDirectory.shared()?.server(withID: captureID) else {
            stop()
            return
        }
        
        let currentCaptureID = _currentDescription?[SyphonServerDescriptionUUIDKey] as? String
        guard currentCaptureID != captureID else {
            return // No change
        }
        
        guard let downloader = downloader else {
            print("Failed to start! Need error message support lol")
            return
        }
        syphon = SyphonClient(serverDescription: description, context: downloader.openGLContext.cglContextObj, options: nil) { syphon in
            self.changeResource.offer { true }
        }
    }
    
    override func grab() -> LLAnyImage? {
        guard let syphon = syphon, let frame = syphon.newFrameImage(), let downloader = downloader else {
            return nil
        }

        guard self.changeResource.pop(timeout: .now() + .seconds(1)) != nil else {
            return nil
        }
        
        downloader.image = frame
        guard let image = downloader.downloadImage()?.takeUnretainedValue() else {
            return nil
        }
        return LLCGImage(image: image)
    }
    
    override func stop() {
        super.stop()
        
        syphon?.stop()
        syphon = nil
    }
    
    override var name: String { "Capture Syphon" }
}
