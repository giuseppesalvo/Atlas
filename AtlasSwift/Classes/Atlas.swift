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

public class Atlas<T> {
    
    private(set) public var state: T
    
    private var listeners: Set<AtlasSubscriberBox> = []
    
    // Serial queue for the state updates
    private let queue: DispatchQueue = DispatchQueue(label: "atlas.store.queue.\(T.self).\(UUID().uuidString)")
    
    // The semaphore is needed to ensure that queue blocks will be dispatched strictly in the right order
    // Without the semaphore, the order is not always right
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public typealias CompletitionHandler = (_ state: T) -> Void
    
    public init(state: T) {
        guard Mirror(reflecting: state).displayStyle == .struct else {
            fatalError("The state should be a struct")
        }
        self.state = state
    }
    
    // Useful if we need to perform an action for every update
    // Example: save state history
    func setState(_ state: T) {
        self.state = state
    }
    
    /**
     * Trigger state changes on a subscriber
     *
     */
    private func updateListener(box: AtlasSubscriberBox, prevState: T?, newState: T) {
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
    private func updateListeners(prevState: T?, newState: T) {
        for box in listeners {
            updateListener(box: box, prevState: prevState, newState: newState)
        }
    }
    
    
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
    public func unsubscribe<S: AtlasSubscriber>(_ subscriber: S) where S.StateType == T {
        if let index = self.listeners.index(where: { $0.value === subscriber }) {
            self.listeners.remove(at: index)
        }
    }
    
    /**
     * Dispatching a synchronous action
     *
     */
    public func dispatch<A: AtlasAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        queue.async {
            self.semaphore.wait()
            let oldState = self.state
            let newState = action.handle(state: oldState)
            self.setState(newState)
            self.semaphore.signal()
            completition?(self.state)
            self.updateListeners(prevState: oldState, newState: self.state)
        }
    }
    
    /**
     * Dispatching an asynchronous action
     *
     */
    public func dispatch<A: AtlasAsyncAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        let block = { (_ state: T) -> Void in
            let oldState = self.state
            self.setState(state)
            self.semaphore.signal()
            completition?(self.state)
            self.updateListeners(prevState: oldState, newState: self.state)
        }
        
        queue.async {
            self.semaphore.wait()
            action.handle(state: self.state, completition: block)
        }
    }
    
    /**
     * Thread unsafe dispatch async action
     * Here the semaphore will not be used
     * So, multiple actions dispatched sequentially using this function, will have the same state
     */
    public func dispatchUnsafe<A: AtlasAsyncAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        let block = { (_ state: T) -> Void in
            let oldState = self.state
            self.state = state
            completition?(self.state)
            self.updateListeners(prevState: oldState, newState: self.state)
        }
        
        queue.async {
            action.handle(state: self.state, completition: block)
        }
    }
    
    /**
     * Dispatching a group of actions
     *
     */
    public func dispatch<A: AtlasActionGroup>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        queue.async {
            action.handle(store: self) {
                completition?(self.state)
            }
        }
    }
}
