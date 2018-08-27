//
//  Subscriber.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

public protocol AtlasAnySubscriber: class {
    func defaultNewState(_ state: Any)
}

public protocol AtlasSubscriber: AtlasAnySubscriber {
    associatedtype StateType
    func newState(_ state: StateType)
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
}
