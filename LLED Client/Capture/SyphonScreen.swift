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
class SyphonScreen : OpenGLScreen {
    var captureID: String = "" {
        didSet {
            objectWillChange.send()
            _flushCapture()
        }
    }
        
    internal var _currentDescription: [String: Any]?
    
    var syphon: SyphonClient?
    
    override func stop() {
        super.stop()
        
        syphon?.stop()
        syphon = nil
    }
    
    func _flushCapture() {
        guard let description = SyphonServerDirectory.shared()?.server(withID: captureID) else {
            stop()
            return
        }
        
        let currentCaptureID = _currentDescription?[SyphonServerDescriptionUUIDKey] as? String
        guard currentCaptureID != captureID else {
            return // No change
        }

        // Clean up, then re-setup
        stop()
        
        guard let oglContext = Self.createOpenGLContext(attributes: Self.defaultPixelFormatAttributes()) else {
            return // Can't render.....
        }
        
        self.oglContext = oglContext
        oglContext.makeCurrentContext()
        
        syphon = SyphonClient(serverDescription: description, context: oglContext.cglContextObj, options: nil) { syphon in
            self.downloadCurrentTexture()
        }
    }
            
    func downloadCurrentTexture() {
        guard let syphon = syphon, let frame = syphon.newFrameImage() else {
            return
        }
        
        imageResource.offer {
            downloadTexture(textureID: frame.textureName, textureSize: frame.textureSize)
        }
    }
    
    override var name: String { "Capture Syphon" }
}
