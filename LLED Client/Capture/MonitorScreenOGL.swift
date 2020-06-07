//
//  MonitorScreenOGL.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 07.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import VideoToolbox

@available(*, deprecated, message: "OpenGL deprecated")
class MonitorScreenOGL : OpenGLScreen {
    var frameReader: FrameReader?
    
    override init() {
        super.init()
        _flushCapture()
    }
    
    func _flushCapture() {
        // Clean up, then re-setup
        stop()
        
        guard let oglContext = FrameReader.fullScreenOGLContext() else {
            return // Can't render.....
        }
        
        self.oglContext = oglContext

        guard let screen = NSScreen.main else {
            print("Can't find screen lol")
            return
        }
        
        let size = screen.frame.size
        frameReader = FrameReader(openGLContext: oglContext, pixelsWide: UInt32(size.width), pixelsHigh: UInt32(size.height))
    }
    
    override func grab() -> NSImage {
        guard let frameReader = frameReader else {
            print("No frame reader")
            return NSImage()
        }
        frameReader.readScreenAsyncOnSeparateThread()
        let img = frameReader.readScreenAsyncFinish() ?? NSImage()
        print(img)
        return img
    }
        
    override var name: String { "Capture Screen (OGL)" }
}
