//
//  Assembly.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class Assembly: ObservableObject {
    let pool: ImagePool
    var servers = ServerAssembly()

    init(capturer: ImageCapture) {
        pool = ImagePool(capturer: capturer)
    }
}

class ImagePoolObserverInfo: ResourcePoolObserverInfo {
    let size: NSSize
    
    init(delay: TimeInterval, priority: Int, size: NSSize) {
        self.size = size
        super.init(delay: delay, priority: priority)
    }
}

class ImagePool: ResourcePool<NSImage, ImagePoolObserverInfo> {
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
    
    override func _start(info: ImagePoolObserverInfo) {
        capturer.start(delay: info.delay, desiredSize: info.size)
    }
    
    override func _stop() {
        capturer.stop()
    }
}
