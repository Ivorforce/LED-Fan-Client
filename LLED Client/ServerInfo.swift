//
//  ServerInfo.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 02.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Cocoa

class ServerInfo: ObservableObject {
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
    
    var url: URL? { URL(string: "http://\(urlString)") }

    var state: State = .invalidURL {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    func connect() {
        guard let url = url else {
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
        return false
    }
}
