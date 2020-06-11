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
    weak var server: Server?

    var screenMode: ScreenMode? = nil {
        didSet { artnetProvider.net = screenMode?.net ?? 0 }
    }

    let artnetProvider = ArtnetProvider()
    var capturer: ImageCapture = ImageProviderView.captureMethods[0] {
        didSet {
            objectWillChange.send()
            oldValue.stop()
            capturer.start()
        }
    }
    
    var connection: NWConnection?
    var timer: Timer?
    
    var fps: Double = 30 {
        didSet { _flushTimer() }
    }
        
    var isSending = false {
        didSet {
            self.objectWillChange.send()
            _connect()
        }
    }
    
    init() {
        capturer.start()
    }
    
    func _connect() {
        guard let server = server, isSending else {
            connection?.cancel()
            connection = nil
            _flushTimer()

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
        guard let connection = connection, connection.state == .ready else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        timer = Timer(timeInterval: .seconds(1.0 / fps), repeats: true) { _ in
            guard let screenMode = self.screenMode else {
                return
            }

            let image = self.capturer.grab()
            let payload = screenMode.pack(image: image)
            let packets = self.artnetProvider.pack(payload: payload)
            for packet in packets {
                connection.send(content: packet, completion: NWConnection.SendCompletion.idempotent)
            }
        }
        // We're in an operation queue, scheduledTimer silently doesn't work
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    deinit {
        timer?.invalidate()
        connection?.cancel()
    }
}
