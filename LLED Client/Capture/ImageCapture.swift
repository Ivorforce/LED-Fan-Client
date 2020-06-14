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
    
    var imageResource = BufferedResource<NSImage>(limit: 2)
    
    func start() {}
    func stop() {}
}

class ActiveImageCapture: ImageCapture {
    var timer: Timer?
    
    override func start() {
        timer = Timer.scheduledTimer(withTimeInterval: .seconds(1 / 30), repeats: true) { _ in
            self.imageResource.push(self.grab())
        }
    }
    
    override func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func grab() -> NSImage { return NSImage() }
}
