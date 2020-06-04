//
//  Endpoint.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa
import Network

class VideoEndpoint: ObservableObject {
    let screenMode: ScreenMode
    let server: Server

    let artnetProvider = ArtnetProvider()
    var capturer: ImageCapture = CaptureScreen()
    
    var connection: NWConnection?
    var timer: Timer?
    
    var fps: Double = 30 {
        didSet { _flushTimer() }
    }
    
    init(screenMode: ScreenMode, server: Server) {
        self.screenMode = screenMode
        self.server = server
    }
    
    var isSending = false {
        didSet {
            self.objectWillChange.send()
            _connect()
        }
    }
    
    func _connect() {
        if !isSending {
            connection?.cancel()
            connection = nil
            timer = nil
            print("End")

            return
        }

        connection = NWConnection(host: NWEndpoint.Host(server.urlString), port: NWEndpoint.Port(integerLiteral: ArtnetProvider.port), using: .udp)
        guard let connection = connection else {
            print("Failed to create connection")
            return
        }
        
        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
                case .ready:
                    self._flushTimer()
                default:
                    break
            }
        }

        connection.start(queue: .global())
    }
    
    func _flushTimer() {
        guard let connection = self.connection, connection.state == .ready else {
            timer = nil
            return
        }
        
        timer = Timer(timeInterval: .seconds(0.1), repeats: true) { _ in
            let image = self.capturer.grab()
            let payload = self.artnetProvider.pack(payload: self.screenMode.pack(image: image))
            connection.send(content: payload, completion: NWConnection.SendCompletion.idempotent)
        }
        // We're in an operation queue, scheduledTimer silently doesn't work
        RunLoop.main.add(timer!, forMode: .common)
    }
}
