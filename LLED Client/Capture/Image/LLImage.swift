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
    func colorFiltered(_ parameters: [String: Any]) -> LLAnyImage?
    
    var nsImageRepresentation: NSImage { get }
    var rgbRepresentation: Data { get }
}

class LLCGImage: LLAnyImage {
    let image: CGImage
    
    init(image: CGImage) {
        self.image = image
    }
    
    var size: NSSize { NSSize(width: image.width, height: image.height) }
    
    func resized(to size: NSSize) -> LLAnyImage? {
        return image.resized(to: size, quality: .medium).map(LLCGImage.init)
    }
    
    func colorFiltered(_ parameters: [String : Any]) -> LLAnyImage? {
        let inputImage = CIImage(cgImage: image)
        let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

        let context = CIContext(options: nil)
        return context.createCGImage(outputImage, from: outputImage.extent).map(LLCGImage.init)
    }
    
    var nsImageRepresentation: NSImage {
        let image = NSImage()
        image.addRepresentation(NSBitmapImageRep(cgImage: self.image))
        return image
    }
    
    var rgbRepresentation: Data { nsImageRepresentation.toRGB() }
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
    
    func colorFiltered(_ parameters: [String : Any]) -> LLAnyImage? {
        guard
            let tiffdata = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffdata),
            let inputImage = CIImage(bitmapImageRep: bitmap)
        else {
           return nil
        }

        let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

        let context = CIContext(options: nil)
        return context.createCGImage(outputImage, from: outputImage.extent).map(LLCGImage.init)
    }

    var nsImageRepresentation: NSImage { image }
    
    var rgbRepresentation: Data { image.toRGB() }
}
