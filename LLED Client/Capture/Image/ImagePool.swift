//
//  ImagePool.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 20.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

class ImagePool: ResourcePool<LLAnyImage, ImagePoolObserverInfo> {
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
