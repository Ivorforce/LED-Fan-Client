//
//  StopWatch.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 20.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class FPSCounter: StopWatch, ObservableObject {
    var updateDelay: TimeInterval
    var lastCheck = Date()
    
    var fps: Double? {
        didSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    init(limit: Int, updateDelay: TimeInterval) {
        self.updateDelay = updateDelay
        super.init(limit: limit)
    }
    
    override func begin() {
        super.begin()
        self.lastCheck = Date()
        fps = nil
    }
    
    override func mark() {
        let date = Date()
        if date.timeIntervalSince(lastCheck) > .seconds(5) {
            lastCheck = date
            
            if let diff = meanDifference() {
                fps = 1.0 / diff
            }
            else {
                fps = nil
            }
        }
        
        super.mark()
    }
}

class StopWatch {
    var startDate = Date()
    var dates: RollingArray<Date>
    
    init(limit: Int) {
        dates = .init(limit: limit)
    }
    
    func begin() {
        dates.clear()
        startDate = Date()
    }
    
    func mark() {
        dates.append(Date())
    }
    
    func meanDifference() -> TimeInterval? {
        guard dates.count >= 2 else {
            return nil
        }
        
        let dates = self.dates.values
        let sum = zip(dates[0 ..< dates.count], dates[1 ..< dates.count - 1])
            .map { $1.timeIntervalSince($0) }
            .reduce(TimeInterval(0), +)
        return sum / TimeInterval(dates.count - 1)
    }
}
