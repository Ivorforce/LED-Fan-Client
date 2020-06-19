//
//  REST.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import Network

protocol BackgroundTask {
    func start()
    func cancel()
}

class DataBackgroundTask: BackgroundTask {
    var connection: NWConnection?
    
    func createConnection() -> NWConnection? {
        return nil
    }
    
    func start() {
        connect(createConnection())
    }

    func connect(_ connection: NWConnection?) {
        self.connection = connection
        
        guard let connection = connection else {
            print("Failed to create connection")
            return
        }
        
        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
                case .ready:
                    self.execute(on: connection)
                default:
                    break
            }
        }

        connection.start(queue: .global())
    }
    
    func execute(on connection: NWConnection) {
    }
        
    func cancel() {
        connection?.cancel()
        connection = nil
    }
}

class ReadyTask: ObservableObject {
    enum State {
        case success, failure, inProgress, none
    }
    
    var task: BackgroundTask
    var state: State = .none {
        didSet { objectWillChange.send() }
    }
    
    init(task: BackgroundTask) {
        self.task = task
    }
    
    func cancel() {
        if state == .inProgress {
            task.cancel()
            state = .none
        }
    }
    
    func start() {
        cancel()
        task.start()
    }
}

class REST {
    let baseURL: URL
    
    init(_ base: URL) {
        baseURL = base
    }
    
    func get(handler: @escaping (String?) -> Void = { _ in }) {
        let request = URLRequest(url: baseURL)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { [handler] data, response, error in
            data.map { handler(String(data: $0, encoding: .utf8)) }
        })
        task.resume()
    }
    
    func getVariable(handler: @escaping (String?) -> Void) {
        REST(baseURL.appendingPathComponent("get")).get(handler: handler)
    }

    func post(_ parameters: [String: Any] = [:]) {
        var request = URLRequest(url: baseURL.appendingPathComponent("set"))
        request.httpMethod = "POST"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        })
        task.resume()
    }

    func setVariable(_ parameters: [String: Any]) {
        return REST(baseURL.appendingPathComponent("set")).post(parameters)
    }
}
