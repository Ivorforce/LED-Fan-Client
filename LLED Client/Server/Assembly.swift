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
