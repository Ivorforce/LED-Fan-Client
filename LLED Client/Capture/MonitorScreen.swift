//
//  MonitorScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa

class MonitorScreen : ImageCapture {
    override var name: String { "Capture Screen" }
    
    var enforceSquare: Bool = true
    
    override func grab() -> NSImage {
        guard let screen = NSScreen.main else {
            print("No screen found lol")
            return NSImage()
        }
        
        var rect = screen.frame
        
        if enforceSquare {
            let size = min(rect.size.width, rect.size.height)
            rect = NSRect(
                x: rect.minX + (rect.size.width - size) / 2,
                y: rect.minY + (rect.size.height - size) / 2,
                width: size,
                height: size
            )
        }
        
        guard let cgImage = CGWindowListCreateImage(rect, .optionOnScreenOnly, .zero, .nominalResolution) else {
            print("Failed to create screen image!")
            return NSImage()
        }
        
        let image = NSImage()
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        
        return image;
    }
}
