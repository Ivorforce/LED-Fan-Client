//
//  WeakBox.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 21.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

final class WeakBox<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
        self.value = value
    }
}
