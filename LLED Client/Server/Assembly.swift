//
//  Assembly.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ImagePool: ResourcePool<NSImage> {
    var capturer: ImageCapture {
        didSet {
            resource = capturer.imageResource
            objectWillChange.send()
        }
    }

    init(capturer: ImageCapture) {
        self.capturer = capturer
        super.init(capturer.imageResource)
    }
    
    override func _start() {
        capturer.start()
    }
    
    override func _stop() {
        capturer.stop()
    }
}

class Assembly: ObservableObject {
    let pool: ImagePool
    
    init(capturer: ImageCapture) {
        pool = ImagePool(capturer: capturer)
    }
}
