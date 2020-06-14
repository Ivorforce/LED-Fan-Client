//
//  BufferedResource.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 14.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class BufferedResource<Resource> {
    let limit: Int
    private var buffer: [Resource] = []

    private let bufferQueue: DispatchQueue = DispatchQueue(label: "BufferedResource")
    private let positiveSemaphore: DispatchSemaphore
    private let negativeSemaphore: DispatchSemaphore

    init(limit: Int) {
        guard limit > 0 else {
            fatalError("Positive limit required")
        }
        
        self.limit = limit
        
        positiveSemaphore = DispatchSemaphore(value: 0)
        negativeSemaphore = DispatchSemaphore(value: limit)
    }
    
    func push(_ resource: Resource, force: Bool = true) {
        if force {
            // Buffer is synced the whole way through so we're sure
            // our buffer state is intact if we time out
            guard (bufferQueue.sync {
                switch negativeSemaphore.wait(timeout: .now()) {
                case .timedOut:
                    // If we aren't allowed to push an item,
                    // instead replace the first one

                    buffer.removeFirst()
                    buffer.append(resource)
                    return false
                default:
                    // We are allowed to push!
                    return true
                }
            }) else {
                return
            }
        }
        else {
            negativeSemaphore.wait()
        }
        
        bufferQueue.sync {
            buffer.append(resource)
        }

        positiveSemaphore.signal()
    }
    
    func push(_ resource: Resource, timeout: DispatchTime) -> DispatchTimeoutResult {
        switch negativeSemaphore.wait(timeout: timeout) {
        case .success:
            bufferQueue.sync {
                buffer.append(resource)
            }

            positiveSemaphore.signal()
            return .success
        default:
            return .timedOut
        }
    }
    
    @discardableResult
    func offer(timeout: DispatchTime? = nil, _ resourceProvider: () -> Resource?) -> DispatchTimeoutResult {
        switch negativeSemaphore.wait(timeout: timeout ?? .now()) {
        case .success:
            guard let resource = resourceProvider() else {
                // Nothing provided; reset
                negativeSemaphore.signal()
                return .timedOut
            }
            
            bufferQueue.sync {
                buffer.append(resource)
            }

            positiveSemaphore.signal()
            return .success
        default:
            return .timedOut
        }
    }
    
    private func removeOne() -> Resource {
        let resource = bufferQueue.sync {
            buffer.removeFirst()
        }
        negativeSemaphore.signal()
        
        return resource
    }
    
    func pop() -> Resource {
        positiveSemaphore.wait()
        return removeOne()
    }
    
    func pop(timeout: DispatchTime) -> Resource? {
        switch positiveSemaphore.wait(timeout: timeout) {
        case .success:
            return removeOne()
        default:
            return nil
        }
    }
    
    func peek() -> Resource? {
        return buffer.first
    }
}
