//
//  LLEDExtensions.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 21.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func lled(label: String, qos: DispatchQoS = .default) -> DispatchQueue {
        return DispatchQueue(label: "de.ivorius.lled.\(label)", qos: qos)
    }
}
