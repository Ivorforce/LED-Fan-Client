//
//  ImageScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 28.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ImageScreen : ActiveImageCapture, ObservableObject {
    override var name: String { "Picture" }
   
    static let demoImages: [(String, NSImage)] = [
        ("Demo", NSImage(named: "demo-test")!),
        ("Segments", NSImage(named: "demo-segments")!),
        ("Ring", NSImage(named: "demo-fade")!),
        ("Color-Reel", NSImage(named: "demo-colors")!)
    ]

    var image: NSImage? {
        didSet { objectWillChange.send() }
    }
     
    var demoImage: String? {
        didSet {
            image = Self.demoImages.first { $0.0 == demoImage }?.1
            objectWillChange.send()
        }
    }
    
    override init() {
        (demoImage, image) = Self.demoImages.first!
    }
    
    override func grab() -> LLAnyImage? {
        return image.map(LLNSImage.init)
    }
}
