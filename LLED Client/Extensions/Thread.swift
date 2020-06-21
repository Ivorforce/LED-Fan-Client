//
//  Thread.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class AsyncTimer {
    static let minSleepTime = 0.0001
    
    let dispatchQueue: DispatchQueue
    var stopped = true
    
    var timeInterval: TimeInterval
    var fun: () -> Void
    
    init(timeInterval: TimeInterval, queue: DispatchQueue?, fun: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.dispatchQueue = queue ?? DispatchQueue.global()
        self.fun = fun
    }
    
    static func scheduledTimer(withTimeInterval timeInterval: TimeInterval, queue: DispatchQueue?, fun: @escaping () -> Void) -> AsyncTimer {
        let timer = AsyncTimer(timeInterval: timeInterval, queue: queue, fun: fun)
        timer.stopped = false
        
        timer.dispatchQueue.async { [weak timer] in
            var time = DispatchTime.now()

            while !(timer?.stopped ?? true) {
                fun()
                                
                let endTime = DispatchTime.now()
                
                let requiredTimeInterval = (timer?.stopped ?? true) ? 0 : (timer?.timeInterval ?? 0)
                guard requiredTimeInterval > 0 else {
                    time = endTime
                    continue
                }

                let executionTime: UInt64 = endTime.uptimeNanoseconds - time.uptimeNanoseconds
                let requiredDelay = max(minSleepTime, requiredTimeInterval - TimeInterval(executionTime / 1000) / 1000 / 1000)
                
                Thread.sleep(forTimeInterval: requiredDelay)
                time = DispatchTime(uptimeNanoseconds: endTime.uptimeNanoseconds + UInt64(requiredDelay * 1000 * 1000) * 1000)
            }
        }
        
        return timer
    }
    
    deinit {
        invalidate()
    }
    
    func invalidate() {
        self.stopped = true
    }
}
