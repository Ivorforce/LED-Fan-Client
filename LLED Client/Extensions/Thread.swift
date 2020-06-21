//
//  Thread.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class AsyncTimer {
    var stopped = true
    
    var timeInterval: TimeInterval
    var fun: () -> Void
    
    init(timeInterval: TimeInterval, fun: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.fun = fun
    }
    
    static func scheduledTimer(withTimeInterval timeInterval: TimeInterval, qos: DispatchQoS.QoSClass = .default, fun: @escaping () -> Void) -> AsyncTimer {
        let timer = AsyncTimer(timeInterval: timeInterval, fun: fun)
        timer.stopped = false
        
        DispatchQueue.global(qos: qos).async { [weak timer] in
            var time = DispatchTime.now()

            while !(timer?.stopped ?? true) {
                fun()
                
                let requiredTimeInterval = (timer?.stopped ?? true) ? 0 : (timer?.timeInterval ?? 0)
                guard requiredTimeInterval > 0 else {
                    time = DispatchTime.now()
                    continue
                }
                
                let endTime = DispatchTime.now()
                let executionTime: UInt64 = endTime.uptimeNanoseconds - time.uptimeNanoseconds
                let requiredDelay = requiredTimeInterval - TimeInterval(executionTime / 1000) / 1000 / 1000
                print("\(requiredTimeInterval) -> \(requiredDelay)")
                
                if requiredTimeInterval > 0 {
                    Thread.sleep(forTimeInterval: requiredDelay)
                }
                
                time = endTime
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
