//
//  Thread.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class AsyncTimer {
    var stopped = false
    
    var timeInterval: TimeInterval
    var fun: () -> Void
    
    init(timeInterval: TimeInterval, fun: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.fun = fun
    }
    
    static func scheduledTimer(withTimeInterval timeInterval: TimeInterval, fun: @escaping () -> Void) -> AsyncTimer {
        let timer = AsyncTimer(timeInterval: timeInterval, fun: fun)
        
        DispatchQueue.global(qos: .background).async { [weak timer] in
            var time = DispatchTime.now()

            while !(timer?.stopped ?? true) {
                fun()
                
                // Only keep it retained for the duration of the delay block
                guard let timer = timer else {
                    return
                }
                
                guard timer.timeInterval > 0 else {
                    continue
                }
                
                let endTime = DispatchTime.now()
                let executionTime: UInt64 = endTime.uptimeNanoseconds - time.uptimeNanoseconds
                let requiredDelay = timer.timeInterval - TimeInterval(executionTime) / 1000 / 1000 / 1000
                
                if requiredDelay > 0 && !timer.stopped {
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
