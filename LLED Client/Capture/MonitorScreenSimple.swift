//
//  MonitorScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa

class MonitorScreenSimple : ActiveImageCapture {
    override var name: String { "Capture Screen (Alternate)" }
        
    var captureRect: NSRect?
    
    override func start(delay: TimeInterval, desiredSize: NSSize) {
        super.start(delay: delay, desiredSize: desiredSize)
        
        captureRect = NSScreen.main.map { desiredSize.centeredFit(bounds: $0.frame) }
    }
    
    override func grab() -> NSImage {
        guard let captureRect = captureRect else {
            return NSImage()
        }
        
        guard let cgImage = CGWindowListCreateImage(captureRect, .optionOnScreenOnly, .zero, .nominalResolution) else {
            print("Failed to create screen image!")
            return NSImage()
        }
        
        let image = NSImage()
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        
        return image
    }
}
