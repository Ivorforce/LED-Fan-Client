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
    
    var imageResource = BufferedResource<LLAnyImage>(limit: 2)
    
    func start(delay: TimeInterval, desiredSize: NSSize) {}
    func stop() {}
}

class ActiveImageCapture: ImageCapture {
    var timer: Timer?
    
    override func start(delay: TimeInterval, desiredSize: NSSize) {
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { _ in
            let image = self.grab()
            self.imageResource.push(image, force: true)
        }
    }
    
    override func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func grab() -> LLAnyImage { return LLNSImage.none }
}
