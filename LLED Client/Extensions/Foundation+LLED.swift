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

extension Int {
    var bytes : [UInt8] {
        return withUnsafeBytes(of: self, Array.init)
    }
    
    init(data: Data) {
        self = 0
        (data as NSData).getBytes(&self, length: data.count)
    }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else {
            return nil
        }
        
        bitmapRep.size = newSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()

        let resizedImage = NSImage(size: newSize)
        resizedImage.addRepresentation(bitmapRep)

        return resizedImage
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Data {
    func split(maxCount: Int) -> [Data] {
        withUnsafeBytes { ptrR in
            let ptr = UnsafeMutableRawPointer(mutating: ptrR.baseAddress)!

            return (0 ... (count / maxCount)).map { i in
                let pos = i * maxCount
                let subCount = Swift.min(count - pos, maxCount)
                return Data(bytesNoCopy: ptr + pos, count: subCount, deallocator: Data.Deallocator.none)
            }
        }
    }
}

extension NSSize {
    func scaleToFit(size: NSSize) -> NSSize {
        let wRatio = width / size.width
        let hRatio = height / size.height
        
        // Find ratio that is closer to fit by
        let scale = wRatio > hRatio ? (1.0 / wRatio) : (1.0 / hRatio)
        return NSSize(width: round(width * scale), height: round(height * scale))
    }
    
    func centeredFit(bounds: NSRect) -> NSRect {
        let fitSize = scaleToFit(size: bounds.size)
        
        return NSRect(
            x: round(bounds.minX + (bounds.size.width - fitSize.width) / 2),
            y: round(bounds.minY + (bounds.size.height - fitSize.height) / 2),
            width: fitSize.width,
            height: fitSize.height
        )
    }
}

extension Array {
    @inlinable func volatileMap<S>(_ fun: (Element) -> S?) -> [S]? {
        let result = compactMap { fun($0) }
        return result.count == count ? result : nil
    }
    
    @inlinable public func reduce<S>(_ nextPartialResult: (S, S) throws -> S) rethrows -> S? {
        guard let asS = volatileMap({ $0 as? S }), let first = asS.first else {
            return nil
        }
        
        return try asS.dropFirst().reduce(first, nextPartialResult)
    }
}

extension CGImage {
    func resized(to size: NSSize, quality: CGInterpolationQuality = .default) -> CGImage? {
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: 0,
                                space: colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: bitmapInfo)
        else {
            return nil
        }
        
        context.interpolationQuality = quality
        context.draw(self, in: CGRect(origin: .zero, size: size))

        return context.makeImage()
    }
}

extension NSSize {
    var simpleDescription: String {
        "\(Int(width))x\(Int(height))"
    }
}
