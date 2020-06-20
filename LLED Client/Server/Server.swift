//
//  ServerInfo.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 02.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa

class Server: ObservableObject {
    enum State {
        case invalidURL, noConnection, connecting, connected
    }
    
    enum Mode: Int {
        case cartesian
        
        var type: ScreenMode.Type {
            switch self {
            case .cartesian:
                return Cartesian.self
            }
        }
    }
    
    init(address: String = "") {
        urlString = address

        connect()
    }
    
    var urlString: String {
        didSet {
            connect()
        }
    }
    
    var serverInfo: [String: Any] = [:]
    var screenMode: ScreenMode?
    
    let artnet = ArtnetProvider()
    
    var url: URL? {
        urlString != "" ? URL(string: "http://\(urlString)") : nil
    }
    
    func rest(_ paths: [String]) -> REST? {
        guard var url = self.url else {
            return nil
        }
        for path in paths { url.appendPathComponent(path) }
        return REST(url)
    }

    var state: State = .invalidURL {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    func connect() {
        guard let url = url?.appendingPathComponent("i") else {
            state = .invalidURL
            return
        }
        
        state = .connecting

        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.main.sync {
                guard
                    let data = data,
                    let json =  try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    self?._interpret(info: json) ?? false
                else {
                    self?.state = .noConnection
                    return
                }
                
                self?.state = .connected
            }
        }

        task.resume()
    }
        
    func _interpret(info: [String: Any]) -> Bool {
        guard info.keys.contains("cartesian") else {
            return false
        }
        
        serverInfo = info;
        _flushEndpoint()
        return true
    }
    
    var endpoints: [Mode] {
        return [.cartesian]
    }
    
    var endpoint: Mode? = .cartesian {
        didSet {
            self.objectWillChange.send()
            _flushEndpoint()
        }
    }
    
    func _flushEndpoint() {
        guard let type = endpoint?.type, let info = serverInfo[type.key] as? [String: Any], let mode = type.parse(info) else {
            screenMode = nil
            return
        }
        
        screenMode = mode
    }
    
    var rotationSpeed: Double = 0.0 {
        didSet {
            self.objectWillChange.send()
            rest(["speed"])?.setVariable(["speed-control": rotationSpeed])
        }
    }
    
    func reboot() { rest(["reboot"])?.post() }
    func ping() { rest(["ping"])?.post() }
    func update() { rest(["checkupdate"])?.post() }

    func pair(ssid: String, password: String) { rest(["wifi/connect"])?.post([
        "ssid": ssid,
        "password": password
    ]) }
    func pair() { rest(["wifi/pair"])?.post() }
}

extension Server: Hashable {
    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.urlString == rhs.urlString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlString)
    }
}
