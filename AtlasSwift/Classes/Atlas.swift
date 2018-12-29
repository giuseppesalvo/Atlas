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

public typealias AtlasDispatchCompletition<T> = (_ error: Error?, _ state: T) -> Void

public class Atlas<T> {
    
    public var state: T
    
    private var subscribers: Set<AtlasSubscriberBox> = []
    
    private let guards: [AtlasAnyGuard]
    
    // Serial queue for the state updates
    private let queue: DispatchQueue = DispatchQueue(label: "atlas.store.queue.\(T.self).\(UUID().uuidString)")
    
    // The semaphore is needed to ensure that queue blocks will be dispatched strictly in the right order
    // Without the semaphore, the order is not always right
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public init(state: T, guards: [AtlasAnyGuard] = []) {
        self.state  = state
        self.guards = guards
        
        if Mirror(reflecting: self.state).displayStyle != .struct {
            print("Atlas Warning: The state should be always a value type, otherwise the shouldUpdate method will not work properly.\n More info here: https://developer.apple.com/swift/blog/?id=10")
        }
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
     * Triggering state changes on a SINGLE subscriber
     *
     */
    private func updateSubscriber(
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
     * Triggering state changes on ALL subscribers
     *
     */
    private func updateSubscribers(
        prevState: T?,
        newState: T
    ) {
        for box in subscribers {
            updateSubscriber(box: box, prevState: prevState, newState: newState)
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
        if subscribers.contains(where: { $0.value === subscriber }) { return }
        let box = AtlasSubscriberBox(value: subscriber, queue: queue)
        subscribers.update(with: box)
        updateSubscriber(box: box, prevState: nil, newState: self.state)
    }
    
    /**
     * Unsubscribing a class
     *
     */
    public func unsubscribe<S: AtlasSubscriber>(
        _ subscriber: S
    ) where S.StateType == T {
        if let index = self.subscribers.index(where: { $0.value === subscriber }) {
            self.subscribers.remove(at: index)
        }
    }
  
}

// MARK: Guards

extension Atlas {
    
    func guardsShouldUpdate<A: AtlasAction>(state: T, action: A) -> Bool where A.StateType == T {
        for g in guards {
            if !g.defaultShouldUpdate(state: state, action: action) {
                return false
            }
        }
        return true
    }
    
    func guardsWillUpdate<A: AtlasAction>(state: T, action: A) where A.StateType == T {
        for g in guards {
            g.defaultWillUpdate(state: state, action: action)
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
     * Dispatch an action.
     *
     */
    public func dispatch<A: AtlasAction>(
        _ action: A,
        completition: AtlasDispatchCompletition<T>? = nil
    ) where A.StateType == T {
        queue.async {
            
            guard self.guardsShouldUpdate(state: self.state, action: action) else {
                return
            }
            self.guardsWillUpdate(state: self.state, action: action)
            self.semaphore.wait()
            
            let context = AtlasActionContext<T>(
                complete: { (state) in
                    let oldState = self.state
                    self.setState(state)
                    self.semaphore.signal()
                    completition?(nil, self.state)
                    self.updateSubscribers(prevState: oldState, newState: self.state)
                    self.guardsDidUpdate(state: self.state, action: action)
                },
                error: { error in
                    self.semaphore.signal()
                    completition?(error, self.state)
                }
            )
            
            action.handle(state: self.state, context: context)
        }
    }
    
    /**
     * Thread unsafe dispatch action.
     * Here the **semaphore** will not be used.
     * So, multiple actions dispatched sequentially using this function, will have the same state.
     */
    public func dispatchUNSAFE<A: AtlasAction>(
        _ action: A,
        completition: AtlasDispatchCompletition<T>? = nil
    ) where A.StateType == T {
        queue.async {
            guard self.guardsShouldUpdate(state: self.state, action: action) else {
                return
            }
            self.guardsWillUpdate(state: self.state, action: action)
            
            let context = AtlasActionContext<T>(
                complete: { (state) in
                    let oldState = self.state
                    self.setState(state)
                    completition?(nil, self.state)
                    self.updateSubscribers(prevState: oldState, newState: self.state)
                    self.guardsWillUpdate(state: self.state, action: action)
                },
                error: { error in
                    completition?(error, self.state)
                }
            )
            
            action.handle(state: self.state, context: context)
        }
    }
}
