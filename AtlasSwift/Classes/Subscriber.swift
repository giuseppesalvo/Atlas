//
//  Subscriber.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation


// Type erasure
public protocol AtlasAnySubscriber: class {
    func defaultNewState(_ state: Any)
    func defaultShouldUpdate(prevState: Any?, newState: Any) -> Bool
}

public protocol AtlasSubscriber: AtlasAnySubscriber {
    associatedtype StateType
    func newState(_ state: StateType)
    func shouldUpdate(prevState: StateType?, newState: StateType) -> Bool
}

public extension AtlasSubscriber {
    func defaultNewState(_ state: Any) {
        if let typedState = state as? StateType  {
            newState(typedState)
            return
        }
        print("""
            Warning: Trying to invoke newState function with a different state type:
            Expected: \(StateType.self)
            Received: \(state)
        """)
    }
    
    func defaultShouldUpdate(prevState: Any?, newState: Any) -> Bool {
        guard let tPrevState = prevState as? StateType? else {
            print("""
                Warning: Trying to invoke shouldUpdate function with a different state type:
                Expected: \(StateType.self)
                Received: \(prevState ?? "nil")
            """)
            return false
        }
        
        guard let tNewState = newState as? StateType else {
            print("""
                Warning: Trying to invoke shouldUpdate function with a different state type:
                Expected: \(StateType.self)
                Received: \(newState)
            """)
            return false
        }
        
        return shouldUpdate(prevState: tPrevState, newState: tNewState)
    }

    func shouldUpdate(prevState: StateType?, newState: StateType) -> Bool {
        return true
    }
}
