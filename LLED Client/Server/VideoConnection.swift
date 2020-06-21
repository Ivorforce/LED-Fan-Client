//
//  Endpoint.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa
import Network

class VideoConnection: ObservableObject {
    let assembly: Assembly
    
    var connections: [Server: NWConnection] = [:]
    
    var fps: Double = 30 {
        didSet { _flush() }
    }
    var isSending: Bool = false {
        didSet { _flush() }
    }
    
    var practicalFPS: Double? = nil
    
    var observerToken: ImagePool.ObservationToken?
    
    var payloadsResource = BufferedResource<[Server: Data]>(limit: 2)
    var sendTimer: AsyncTimer?
    
    let sendFPS = FPSCounter(limit: 120, updateDelay: .seconds(5))
    
    var activity: NSObjectProtocol?

    init(assembly: Assembly) {
        self.assembly = assembly
    }
    
    func _flush() {
        objectWillChange.send()
        observerToken?.invalidate()
        sendTimer?.invalidate()
        
        guard isSending else {
            connections.values.forEach { $0.cancel() }
            connections = [:]
            
            activity.map(ProcessInfo.processInfo.endActivity)
            activity = nil
            
            return
        }

        if activity == nil {
            activity = ProcessInfo.processInfo.beginActivity(
                options: [.userInitiated, .latencyCritical, .idleSystemSleepDisabled],
                reason: "Video Streaming"
            )
        }
        
        connections = [:]
        
        for server in assembly.servers.available {
            guard let connection = ArtnetProvider.connection(host: server.urlString) else {
                print("Lost connection to server: \(server)")
                continue
            }
            
            connection.start(queue: .global())
            connections[server] = connection
        }
        
        observerToken = assembly.pool.observe(info: .init(delay: .seconds(1 / fps), priority: 0, size: assembly.servers.desiredSize)) { image in
            self.payloadsResource.offer {
                self.assembly.servers.distribute(image: image)
            }
        }
        
        sendFPS.begin()
        sendTimer = AsyncTimer.scheduledTimer(withTimeInterval: 0, queue: .lled(label: "packets")) { _ in
            self.sendFPS.mark()
            
            let distribution = self.payloadsResource.pop()
            
            for (server, connection) in self.connections {
                guard let payload = distribution[server] else {
                    continue
                }
                
                let packets = server.artnet.pack(payload: payload)
                for packet in packets {
                    connection.send(content: packet, completion: NWConnection.SendCompletion.idempotent)
                }
            }
        }
    }
    
    deinit {
        isSending = false
        _flush()
    }
}
