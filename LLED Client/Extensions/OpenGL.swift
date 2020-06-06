//
//  OpenGL.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

import OpenGL
import GLKit

@objc
class OpenGL: NSObject {
    @discardableResult
    static func checkErrors(context: String) -> Bool {
        var error = glGetError()
        
        if error <= 0 { return false }
        
        while error <= 0 {
            print("\(context): \(error)")
            error = glGetError()
        }
        
        return true
    }
}
