//
//  Endpoint.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class Endpoint: ObservableObject {
    let screenMode: ScreenMode
    let address: URL
    
    init(screenMode: ScreenMode, address: URL) {
        self.screenMode = screenMode
        self.address = address
    }
    
    var isSending = false {
        didSet {
            _connect()
        }
    }
    
    func _connect() {
        if !isSending {
            return
        }
    }
}
