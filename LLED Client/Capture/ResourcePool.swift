//
//  ImagePool.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ResourcePool<Resource>: ObservableObject {
    var resource: BufferedResource<Resource> { didSet {
        _flushTimer()
        objectWillChange.send()
    } }
    var timer: AsyncTimer?
    
    var _observers: [Observer] = []
    
    init(_ resource: BufferedResource<Resource>) {
        self.resource = resource
    }
    
    func _flushTimer() {
        DispatchQueue.main.async {
            let observers = self._observers
            
            guard let delay = observers.map({ $0.delay }).max() else {
                self.timer?.invalidate()
                self.timer = nil
                self._stop()
                return
            }
                        
            let resource = self.resource
            
            self._start()
            self.timer = AsyncTimer.scheduledTimer(withTimeInterval: delay) {
                guard let resource = resource.pop(timeout: .now() + delay) else {
                    return
                }
                
                for observer in observers {
                    observer.fun(resource)
                }
            }
        }
    }
    
    func _start() {
        
    }
    
    func _stop() {
        
    }
    
    func observedState(delay: TimeInterval) -> State {
        let token = ObservationToken(pool: self)
        let state = State(token: token)
        
        self._observers.append(.init(id: token.id, delay: delay) {
            state.state = $0
        })
        self._flushTimer()
        return state
    }
    
    func observe(delay: TimeInterval, fun: @escaping (Resource) -> Void) -> ObservationToken {
        let token = ObservationToken(pool: self)
        self._observers.append(.init(id: token.id, delay: delay, fun: fun))
        self._flushTimer()
        return token
    }
    
    func invalidate(_ token: ObservationToken) {
        self._observers.removeAll { $0.id == token.id }
        self._flushTimer()
    }
}

extension ResourcePool {
    final class ObservationToken {
        let id = UUID()
        weak var pool: ResourcePool?
        
        init(pool: ResourcePool) {
            self.pool = pool
        }
        
        deinit {
            self.invalidate()
        }
        
        func invalidate() {
            pool?.invalidate(self)
        }
    }
    
    final class State: ObservableObject {
        var state: Resource? { didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } }
        let token: ObservationToken
        
        init(token: ObservationToken) {
            self.token = token
        }
    }
    
    final class Observer {
        let id: UUID
        let delay: TimeInterval
        let fun: (Resource) -> Void
        
        init(id: UUID, delay: TimeInterval, fun: @escaping (Resource) -> Void) {
            self.id = id
            self.delay = delay
            self.fun = fun
        }
    }
}
