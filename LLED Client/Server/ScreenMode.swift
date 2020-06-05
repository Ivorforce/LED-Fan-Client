//
//  ScreenMode.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import Cocoa

protocol ScreenMode {
    static var key: String { get }
    static var name: String { get }
    static func parse(_ dict: [String: Any]) -> Self?

    var description: String { get }
    var net: Int { get }

    func pack(image: NSImage) -> Data
}

struct Cartesian: ScreenMode {
    static var key: String { "cartesian" }
    static var name: String { "Cartesian" }

    static func parse(_ dict: [String : Any]) -> Self? {
        guard
            let width = dict["width"] as? Int,
            let height = dict["height"] as? Int,
            let net = dict["net"] as? Int
        else {
            return nil
        }
        
        return Cartesian(net: net, width: width, height: height)
    }
    
    let net: Int
    
    let width: Int
    let height: Int
    
    func pack(image: NSImage) -> Data {
        let resized = image.resized(to: NSSize(width: width, height: height))!
        let rgb = resized.toRGB()
        return rgb
    }

    var description: String {
        "Size: \(width)x\(height)"
    }
}
