//
//  TimedBool.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

class TimedBool: ObservableObject {
    var value: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    func activate(for timeInterval: TimeInterval) {
        value = true
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            self.value = false
        }
    }
}
