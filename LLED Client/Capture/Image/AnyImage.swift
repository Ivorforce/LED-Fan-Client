//
//  AnyImage.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 20.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

protocol LLAnyImage {
    var size: NSSize { get }
    
    func resized(to: NSSize) -> LLAnyImage?
    
    var nsImageRepresentation: NSImage { get }
    var rgbRepresentation: Data { get }
}

class LLNSImage: LLAnyImage {
    static var none = LLNSImage(image: NSImage())
    
    let image: NSImage
    
    init(image: NSImage) {
        self.image = image
    }
    
    var size: NSSize { image.size }
    
    func resized(to: NSSize) -> LLAnyImage? {
        return image.resized(to: size).map(LLNSImage.init)
    }
    
    var nsImageRepresentation: NSImage { image }
    
    var rgbRepresentation: Data { image.toRGB() }
}
