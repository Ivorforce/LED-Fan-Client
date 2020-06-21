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
        willSet { objectWillChange.send() }
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
    
    var desiredSize: NSSize {
        return NSSize(
            width: available.compactMap(\.screenMode).map(\.requiredSize.width).max() ?? 100,
            height: available.compactMap(\.screenMode).map(\.requiredSize.height).max() ?? 100
        )
    }
    
    func distribute(image: LLAnyImage) -> [Server: Data] {
        let desiredSize = self.desiredSize
        
        guard let image = image.size != desiredSize
            ? image.resized(to: desiredSize)
            : image
        else {
            print("Failed to resize image for assembly!")
            return [:]
        }
                
        var dict: [Server: Data] = [:]
        for server in available {
            guard let screenMode = server.screenMode else {
                continue
            }
            
            // Crop here when required
            dict[server] = screenMode.pack(image: image)
        }
        return dict
    }
    
    func scan() {
        guard artpoll.state == .done else {
            return
        }
        
        available = []
        artpoll.start()
    }
}
