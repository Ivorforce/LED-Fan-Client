//
//  ImageCapture.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ImageCapture: NSObject {
    var name: String { return "Unknown Capture Device" }
    
    func grab() -> NSImage { return NSImage() }
    
    func start() {}
    func stop() {}
}
