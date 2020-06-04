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
        
    init() {
        connect()
    }
    
    var urlString: String = UserDefaults.standard.string(forKey: "server") ?? "" {
        didSet {
            UserDefaults.standard.set(urlString, forKey: "server")
            connect()
        }
    }
    
    var serverInfo: [String: Any] = [:]
    
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

        let task = URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            DispatchQueue.main.sync {
                guard
                    let data = data,
                    let json =  try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    self._interpret(info: json)
                else {
                    self.state = .noConnection
                    return
                }
                
                self.state = .connected
            }
        }

        task.resume()
    }
        
    func _interpret(info: [String: Any]) -> Bool {
        guard info.keys.contains("cartesian") else {
            return false
        }
        
        serverInfo = info;
        return true
    }
    
    func endpoint(mode: ScreenMode.Type) -> VideoEndpoint? {
        guard
            let info = serverInfo[mode.key] as? [String: Any],
            let screenMode = mode.parse(info)
        else {
            return nil
        }

        return VideoEndpoint(screenMode: screenMode, server: self)
    }
    
    var rotationSpeed: Double = 0.0 {
        didSet {
            rest(["speed"])?.setVariable(["speed-control": rotationSpeed])
        }
    }
    
    func reboot() { rest(["reboot"])?.post() }
    func ping() { rest(["ping"])?.post() }
    func update() { rest(["update"])?.post() }
}
