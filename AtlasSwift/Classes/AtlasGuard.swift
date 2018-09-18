//
//  AtlasGuard.swift
//  AtlasSwift
//
//  Created by Seth on 18/09/18.
//

// Type erasure
public protocol AtlasAnyGuard {
    func defaultWillUpdate<A: AtlasAction>(state: Any, action: A)
    func defaultDidUpdate<A: AtlasAction>(state: Any, action: A)
}

public protocol AtlasGuard: AtlasAnyGuard {
    associatedtype StateType
    func willUpdate<A: AtlasAction>(state: StateType, action: A)
    func didUpdate<A: AtlasAction>(state: StateType, action: A)
}

public extension AtlasGuard {
    
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
}
