//
//  ServerAssembly.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import Network

class ArtpollTask: DataBackgroundTask {
    var completion: ([String]) -> Void
    
    init(completion: @escaping ([String]) -> Void) {
        self.completion = completion
    }
    
    override func createConnection() -> NWConnection? {
        return ArtnetProvider.connection(host: "255.255.255.255")
    }
    
    override func execute(on connection: NWConnection) {
        completion(["192.168.2.135"]) //TODO Remove when actual reply works, lol
        
        print("Send!")
        connection.send(content: ArtnetProvider.artpoll(), completion: .idempotent)
        connection.receiveMessage { (data, context, someBool, error) in
            self.connection?.cancel()
            print("Recv!")
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("No Data")
                return
            }
            
            print(data)
        }
    }
}

class ServerAssembly: ObservableObject {
    var available: [Server] = [] {
        didSet { objectWillChange.send() }
    }
    
    var scan: ReadyTask!
    
    init() {
        scan = ReadyTask(task: ArtpollTask() { servers in
            DispatchQueue.main.async {
                self.available = servers.map { Server(address: $0) }
            }
        })
    }
}
