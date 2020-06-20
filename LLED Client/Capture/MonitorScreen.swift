//
//  MonitorScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa

class MonitorScreen : ActiveImageCapture {
    override var name: String { "Capture Screen" }
        
    override func grab(desiredSize: NSSize) -> NSImage {
        guard let screen = NSScreen.main else {
            print("No screen found lol")
            return NSImage()
        }
        
        let rect = desiredSize.centeredFit(bounds: screen.frame)
        
        guard let cgImage = CGWindowListCreateImage(rect, .optionOnScreenOnly, .zero, .nominalResolution) else {
            print("Failed to create screen image!")
            return NSImage()
        }
        
        let image = NSImage()
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        
        return image.resized(to: desiredSize) ?? image
    }
}
