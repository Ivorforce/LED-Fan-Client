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
class SyphonScreen : ImageCapture, ObservableObject {
    var captureID: String = "" {
        didSet {
            objectWillChange.send()
        }
    }
        
    internal var _currentDescription: [String: Any]?
    
    var syphon: SyphonClient?
    var downloader: OpenGLDownloader?
    
    override init() {
        if let oglContext = OpenGLDownloader.createOpenGLContext(attributes: OpenGLDownloader.defaultPixelFormatAttributes()) {
            downloader = OpenGLDownloader(context: oglContext)
        }

        super.init()
    }
    
    override func start(delay: TimeInterval, desiredSize: NSSize) {
        // Clean up, then re-setup
        stop()

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
        syphon = SyphonClient(serverDescription: description, context: downloader.oglContext.cglContextObj, options: nil) { syphon in
            self.downloadCurrentTexture()
        }
    }
    
    override func stop() {
        super.stop()
        
        syphon?.stop()
        syphon = nil
    }
            
    func downloadCurrentTexture() {
        guard let syphon = syphon, let frame = syphon.newFrameImage(), let downloader = downloader else {
            return
        }
        
        imageResource.offer {
            guard let image = downloader.downloadTexture(textureID: frame.textureName, textureSize: frame.textureSize) else {
                return nil
            }
            return LLCGImage(image: image)
        }
    }
    
    override var name: String { "Capture Syphon" }
}
