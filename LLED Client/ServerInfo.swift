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
    
    var urlString: String = "" {
        didSet {
            self.url = URL(string: "http://\(urlString)")
        }
    }
    
    var state: State = .invalidURL {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    var url: URL? = nil {
        didSet {
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
    }
    
    func _interpret(info: [String: Any]) -> Bool {
        return false
    }
}
