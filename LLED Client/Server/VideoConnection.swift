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
    
    var observerToken: ResourcePool<NSImage>.ObservationToken?
    
    init(assembly: Assembly) {
        self.assembly = assembly
    }
    
    func _flush() {
        objectWillChange.send()
        observerToken?.invalidate()
        
        guard isSending else {
            connections.values.forEach { $0.cancel() }
            connections = [:]
            return
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
        
        observerToken = assembly.pool.observe(delay: .seconds(1 / fps)) { image in
            for (server, connection) in self.connections {
                guard let screenMode = server.screenMode else {
                    print("Lost screen mode for server \(server)")
                    continue
                }
                
                let payload = screenMode.pack(image: image)
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
