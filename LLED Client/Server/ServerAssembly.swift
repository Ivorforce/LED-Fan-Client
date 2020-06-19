//
//  ServerAssembly.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class ArtpollTask: NSObject, ObservableObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {
    enum State {
        case done, inProgress
    }

    var receiveHost: (ArtnetProvider.ArtpollReply) -> Void
    var socket : GCDAsyncUdpSocket!
    
    var state: State = .done {
        didSet { objectWillChange.send() }
    }
    
    init(receiveHost: @escaping (ArtnetProvider.ArtpollReply) -> Void) {
        self.receiveHost = receiveHost
    }

    func start() {
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.socket = socket
        
        do {
            try socket.bind(toPort: ArtnetProvider.port)
            try socket.beginReceiving()
            try socket.enableBroadcast(true)
        } catch {
            print(error)
            socket.close()
            return
        }
        
        state = .inProgress

        socket.send(ArtnetProvider.artpoll(), toHost: "255.255.255.255", port: ArtnetProvider.port, withTimeout: 1000, tag: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            // Time out here at the latest
            self.state = .done
            socket.close()
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let reply = ArtnetProvider.readPacket(data) as? ArtnetProvider.ArtpollReply else {
            return
        }
        
        receiveHost(reply)
    }
    
    func cancel() {
        socket.close()
    }
}

class ServerAssembly: ObservableObject {
    var available: [Server] = [] {
        didSet { objectWillChange.send() }
    }
        
    var artpoll: ArtpollTask!
    
    init() {
        self.artpoll = ArtpollTask { artpoll in
            guard !self.available.contains(where: { $0.urlString == artpoll.host }) else {
                return
            }
            
            self.available.append(Server(address: artpoll.host))
        }
    }
    
    func scan() {
        guard artpoll.state == .done else {
            return
        }
        
        available = []
        artpoll.start()
    }
}
