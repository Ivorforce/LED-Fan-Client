//
//  ArtnetProvider.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ArtnetProvider {
    static let port: UInt16 = 6454
    
    func pack(payload: Data, offset: Int = 0) -> Data {
        return payload // TODO
    }
}
