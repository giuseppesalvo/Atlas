//
//  AtlasGuard.swift
//  AtlasSwift
//
//  Created by Seth on 18/09/18.
//

// Type erasure
public protocol AtlasAnyGuard {
    func defaultShouldUpdate<A: AtlasAction>(state: Any, action: A) -> Bool
    func defaultWillUpdate<A: AtlasAction>(state: Any, action: A)
    func defaultDidUpdate<A: AtlasAction>(state: Any, action: A)
}

public protocol AtlasGuard: AtlasAnyGuard {
    associatedtype StateType
    func shouldUpdate<A: AtlasAction>(state: StateType, action: A) -> Bool
    func willUpdate<A: AtlasAction>(state: StateType, action: A)
    func didUpdate<A: AtlasAction>(state: StateType, action: A)
}

public extension AtlasGuard {
   
    func defaultShouldUpdate<A: AtlasAction>(state: Any, action: A) -> Bool {
        if let tState = state as? StateType {
            return shouldUpdate(state: tState, action: action)
        }
        return true
    }
    
    func defaultWillUpdate<A: AtlasAction>(state: Any, action: A) {
        if let tState = state as? StateType {
            willUpdate(state: tState, action: action)
        }
    }
    
    func defaultDidUpdate<A: AtlasAction>(state: Any, action: A) {
        if let tState = state as? StateType {
            didUpdate(state: tState, action: action)
        }
    }
    
    func willUpdate<A: AtlasAction>(state: StateType, action: A) {}
    
    func didUpdate<A: AtlasAction>(state: StateType, action: A) {}
   
    func shouldUpdate<A: AtlasAction>(state: StateType, action: A) -> Bool {
        return true
    }
}
