//
//  Foundation+LLED.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 02.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

extension Image {
    init(systemName: String) {
        self = Image(nsImage: NSImage(named: systemName)!)
    }
}

extension TimeInterval {
    static func seconds(_ seconds: Double) -> TimeInterval {
        return seconds
    }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
    }
    
    func toRGB() -> Data {
        let bmp = self.representations[0] as! NSBitmapImageRep
        var data: UnsafeMutablePointer<UInt8> = bmp.bitmapData!
        var pixels: Data = Data()

        for _ in 0 ..< bmp.pixelsHigh {
            for _ in 0 ..< bmp.pixelsWide {
                let r = data.pointee
                data = data.advanced(by: 1)
                let g = data.pointee
                data =  data.advanced(by: 1)
                let b = data.pointee
                data = data.advanced(by: 1)
                pixels.append(contentsOf: [r, g, b])
            }
        }

        return pixels
    }
}
