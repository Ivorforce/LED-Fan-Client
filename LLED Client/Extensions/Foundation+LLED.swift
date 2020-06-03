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
