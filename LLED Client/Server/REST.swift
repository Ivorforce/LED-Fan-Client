//
//  REST.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class REST {
    let baseURL: URL
    
    init(_ base: URL) {
        baseURL = base
    }
    
    func get(handler: (String?) -> Void) {
        let request = URLRequest(url: baseURL.appendingPathComponent("get"))
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        })
        task.resume()
    }

    func set(_ parameters: [String: Any]) {
        var request = URLRequest(url: baseURL.appendingPathComponent("set"))
        request.httpMethod = "POST"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        })
        task.resume()
    }
}
