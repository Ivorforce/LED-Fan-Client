//
//  ImagePool.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 19.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

protocol ResourcePoolObserverInfoProtocol {
    static func merge(_ lhs: Self, rhs: Self) -> Self
}

class ResourcePoolObserverInfo: ResourcePoolObserverInfoProtocol {
    let delay: TimeInterval
    let priority: Int
    
    init(delay: TimeInterval, priority: Int) {
        self.delay = delay
        self.priority = priority
    }
    
    static func merge(_ lhs: ResourcePoolObserverInfo, rhs: ResourcePoolObserverInfo) -> Self {
        return (lhs.priority < rhs.priority ? lhs : rhs) as! Self
    }
}

class ResourcePool<Resource, ObserverInfo: ResourcePoolObserverInfo>: ObservableObject {
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
            
            guard let info = observers.map(\.info).reduce(ObserverInfo.merge) as? ObserverInfo else {
                // Observers may have peaced out in the meantime
                
                self.timer?.invalidate()
                self.timer = nil
                self._stop()
                return
            }
                        
            let resource = self.resource
            
            let delay = info.delay
            self._start(info: info)
            self.timer = AsyncTimer.scheduledTimer(withTimeInterval: 0) {
                guard let resource = resource.pop(timeout: .now() + delay) else {
                    return
                }
                
                for observer in observers {
                    observer.fun(resource)
                }
            }
        }
    }
    
    func _start(info: ObserverInfo) {
        
    }
    
    func _stop() {
        
    }
    
    func observedState(info: ObserverInfo) -> State {
        let token = ObservationToken(pool: self)
        let state = State(token: token)
        
        self._observers.append(.init(id: token.id, info: info) {
            state.state = $0
        })
        self._flushTimer()
        return state
    }
    
    func observe(info: ObserverInfo, fun: @escaping (Resource) -> Void) -> ObservationToken {
        let token = ObservationToken(pool: self)
        self._observers.append(.init(id: token.id, info: info, fun: fun))
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
        let info: ObserverInfo
        
        let fun: (Resource) -> Void
        
        init(id: UUID, info: ObserverInfo, fun: @escaping (Resource) -> Void) {
            self.id = id
            self.info = info
            self.fun = fun
        }
    }
}
