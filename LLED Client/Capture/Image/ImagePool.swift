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
            _flushResource()
            objectWillChange.send()
        }
    }
    
    var filterResource = BufferedResource<LLAnyImage>(limit: 2)
    var filterResourceTimer: AsyncTimer?
    
    var applyContrast = true {
        willSet {
            _flushResource()
            objectWillChange.send()
        }
    }

    init(capturer: ImageCapture) {
        self.capturer = capturer
        super.init(capturer.imageResource)
    }

    func _flushResource() {
        if applyContrast {
            resource = filterResource
        }
        else {
            resource = capturer.imageResource
        }
    }
    
    override func _start(info: ImagePoolObserverInfo) {
        capturer.start(delay: info.delay, desiredSize: info.size)
        
        if applyContrast {
            filterResourceTimer = .scheduledTimer(withTimeInterval: 0, queue: .lled(label: "filter")) {
                guard
                    let source = self.capturer.imageResource.pop(timeout: .now() + info.delay),
                    let filtered = source.colorFiltered(["inputContrast": 1.5])
                else {
                    return
                }
                
                self.resource.push(filtered)
            }
        }
    }
    
    override func _stop() {
        filterResourceTimer?.invalidate()
        filterResourceTimer = nil
        
        capturer.stop()
    }
}
