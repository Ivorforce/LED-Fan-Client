//
//  Endpoint.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa
import Network

class Endpoint: ObservableObject {
    let screenMode: ScreenMode
    let address: String

    let artnetProvider = ArtnetProvider()
    let capturer = CaptureScreen()
    
    var connection: NWConnection?
    var timer: Timer?

    init(screenMode: ScreenMode, address: String) {
        self.screenMode = screenMode
        self.address = address
    }
    
    var isSending = false {
        didSet {
            self.objectWillChange.send()
            _connect()
        }
    }
    
    func _connect() {
        if !isSending {
            self.connection?.cancel()
            self.connection = nil
            self.timer = nil

            return
        }

        connection = NWConnection(host: NWEndpoint.Host(address), port: NWEndpoint.Port(integerLiteral: ArtnetProvider.port), using: .udp)
        
        self.connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
                case .ready:
                    print("State: Ready\n")
                    self.timer = Timer(timeInterval: .seconds(0.1), repeats: true) { _ in
                        let image = self.capturer.grab()
                        let payload = self.artnetProvider.pack(payload: self.screenMode.pack(image: image))
                        self.connection?.send(content: payload, completion: NWConnection.SendCompletion.idempotent)
                    }
                default:
                    break
            }
        }

        self.connection?.start(queue: .global())
    }
}
