//
//  RollingArray.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 21.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class RollingArray<Type> {
    var buffer: [Type?]

    var head = 0
    var count = 0

    init(limit: Int) {
        buffer = .init(repeating: nil, count: limit)
    }
    
    var limit: Int {
        buffer.count
    }
    
    func clear() {
        buffer = .init(repeating: nil, count: limit)
        count = 0
    }
    
    func append(_ object: Type) {
        buffer[head] = object
        head = (head + 1) % buffer.count
        
        if count < limit {
            count += 1
        }
    }
    
    var values: [Type] {
        if head - count >= 0 {
            return buffer[head - count ..< head].compactMap { $0 }
        }
        
        let start = (head - count) + buffer.count
        return (buffer[start ..< buffer.count]
            + buffer[0 ..< head]
            ).compactMap { $0 }
    }
}
