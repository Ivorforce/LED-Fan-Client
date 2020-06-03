//
//  ScreenMode.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

protocol ScreenMode {
    static var key: String { get }
    static var name: String { get }
    static func parse(_ dict: [String: Any]) -> Self?

    var description: String { get }
}

struct Cartesian: ScreenMode {
    static var key: String { "cartesian" }
    static var name: String { "Cartesian" }

    static func parse(_ dict: [String : Any]) -> Self? {
        guard let width = dict["width"] as? Int, let height = dict["height"] as? Int else {
            return nil
        }
        
        return Cartesian(width: width, height: height)
    }
    
    let width: Int
    let height: Int

    var description: String {
        "Size: \(width)x\(height)"
    }
}
