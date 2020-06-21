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
    var fun: (AsyncTimer) -> Void
    
    init(timeInterval: TimeInterval, queue: DispatchQueue?, fun: @escaping (AsyncTimer) -> Void) {
        self.timeInterval = timeInterval
        self.dispatchQueue = queue ?? DispatchQueue.global()
        self.fun = fun
    }
    
    func fire() {
        fun(self)
    }
    
    static func scheduledTimer(withTimeInterval timeInterval: TimeInterval, queue: DispatchQueue?, fun: @escaping (AsyncTimer) -> Void) -> AsyncTimer {
        let timer = AsyncTimer(timeInterval: timeInterval, queue: queue, fun: fun)
        timer.schedule()
        return timer
    }
    
    func schedule() {
        stopped = false
        let boxedTimer = WeakBox(self)
        let minSleepTime = Self.minSleepTime

        dispatchQueue.async {
            var time = DispatchTime.now()

            while !(boxedTimer.value?.stopped ?? true) {
                boxedTimer.value?.fire()
                                
                let endTime = DispatchTime.now()
                
                let requiredTimeInterval = (boxedTimer.value?.stopped ?? true) ? 0 : (boxedTimer.value?.timeInterval ?? 0)
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
    }
    
    deinit {
        invalidate()
    }
    
    func invalidate() {
        self.stopped = true
    }
}
