//
//  State.swift
//  Habit
//
//  Created by Seth on 12/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

/**
 * Atlas store
 *
 */

public typealias AtlasDispatchCompletition<T> = (_ state: T) -> Void

public class Atlas<T> {
    
    private(set) public var state: T
    
    private var listeners: Set<AtlasSubscriberBox> = []
    
    private let guards: [AtlasAnyGuard]
    
    // Serial queue for the state updates
    private let queue: DispatchQueue = DispatchQueue(label: "atlas.store.queue.\(T.self).\(UUID().uuidString)")
    
    // The semaphore is needed to ensure that queue blocks will be dispatched strictly in the right order
    // Without the semaphore, the order is not always right
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public init(state: T, guards: [AtlasAnyGuard] = []) {
        guard Mirror(reflecting: state).displayStyle == .struct else {
            fatalError("The state should be a struct")
        }
        self.state  = state
        self.guards = guards
    }
}

// MARK: State management

extension Atlas {
    // Useful if we need to perform an action for every update
    // Example: save state history
    func setState(_ state: T) {
        self.state = state
    }
}

// MARK: Subscribers management

extension Atlas {
    
    /**
     * Trigger state changes on a subscriber
     *
     */
    private func updateListener(
        box: AtlasSubscriberBox,
        prevState: T?,
        newState: T
    ) {
        box.queue.async {
            guard let subscriber = box.value else { return }
            if subscriber.defaultShouldUpdate(prevState: prevState, newState: newState) {
                subscriber.defaultNewState(self.state)
            }
        }
    }
    
    /**
     * Triggering all subscribers
     *
     */
    private func updateListeners(
        prevState: T?,
        newState: T
    ) {
        for box in listeners {
            updateListener(box: box, prevState: prevState, newState: newState)
        }
    }
}
    

// MARK: Subscription

extension Atlas {
    
    /**
     * Subscribing a class
     *
     */
    public func subscribe<S: AtlasSubscriber>(
        _ subscriber: S, queue: DispatchQueue = .main
    ) where S.StateType == T {
        let box = AtlasSubscriberBox(value: subscriber, queue: queue)
        listeners.update(with: box)
        updateListener(box: box, prevState: nil, newState: self.state)
    }
    
    /**
     * Unsubscribing a class
     *
     */
    public func unsubscribe<S: AtlasSubscriber>(
        _ subscriber: S
    ) where S.StateType == T {
        if let index = self.listeners.index(where: { $0.value === subscriber }) {
            self.listeners.remove(at: index)
        }
    }
  
}

// MARK: Guards

extension Atlas {
    func guardsWillUpdate<A: AtlasAction>(state: T, action: A) where A.StateType == T {
        for g in guards {
            queue.async{ g.defaultWillUpdate(state: state, action: action) }
        }
    }
    
    func guardsDidUpdate<A: AtlasAction>(state: T, action: A) where A.StateType == T {
        for g in guards {
            queue.async{ g.defaultDidUpdate(state: state, action: action) }
        }
    }
}

// MARK: Dispatch funcs

extension Atlas {
    
    /**
     * Dispatching an action
     *
     */
    public func dispatch<A: AtlasAction>(
        _ action: A,
        completition: AtlasDispatchCompletition<T>? = nil
    ) where A.StateType == T {
        queue.async {
            self.guardsWillUpdate(state: self.state, action: action)
            self.semaphore.wait()
            action.handle(state: self.state) { state in
                let oldState = self.state
                self.setState(state)
                self.semaphore.signal()
                completition?(self.state)
                self.updateListeners(prevState: oldState, newState: self.state)
                self.guardsDidUpdate(state: self.state, action: action)
            }
        }
    }
    
    /**
     * Thread unsafe dispatch action
     * Here the semaphore will not be used
     * So, multiple actions dispatched sequentially using this function, will have the same state
     */
    public func dispatchUnsafe<A: AtlasAction>(
        _ action: A,
        completition: AtlasDispatchCompletition<T>? = nil
    ) where A.StateType == T {
        queue.async {
            self.guardsWillUpdate(state: self.state, action: action)
            action.handle(state: self.state) { state in
                let oldState = self.state
                self.state = state
                completition?(self.state)
                self.updateListeners(prevState: oldState, newState: self.state)
                self.guardsWillUpdate(state: self.state, action: action)
            }
        }
    }
    
    /**
     * Dispatching a group of actions
     *
     */
    public func dispatch<A: AtlasActionGroup>(
        _ action: A,
        completition: AtlasDispatchCompletition<T>? = nil
    ) where A.StateType == T {
        queue.async {
            action.handle(store: self) {
                completition?(self.state)
            }
        }
    }
}
