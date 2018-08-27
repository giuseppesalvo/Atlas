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
    
    private let queue     : DispatchQueue     = DispatchQueue(label: "atlas.store.queue.\(T.self).\(UUID().uuidString)")
    private let semaphore : DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public typealias CompletitionHandler = (_ state: T) -> Void
    
    public init(initialState: T) {
        guard Mirror(reflecting: initialState).displayStyle == .struct else {
            fatalError("The state should be a struct")
        }
        self.state = initialState
    }
    
    /**
     * Subscribing a class
     *
     */
    public func subscribe<S: AtlasSubscriber>(_ subscriber: S, queue: DispatchQueue = .main) where S.StateType == T {
        let box = AtlasSubscriberBox(value: subscriber, queue: queue)
        self.listeners.update(with: box)
        trigger(box: box)
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
     * Trigger state changes on a subscriber
     *
     */
    private func trigger(box: AtlasSubscriberBox) {
        box.queue.async { box.value?.defaultNewState(self.state) }
    }
    
    /**
     * Triggering all subscribers
     *
     */
    private func triggerAll() {
        for box in listeners {
            self.trigger(box: box)
        }
    }
    
    /**
     * Dispatching a synchronous action
     *
     */
    public func dispatch<A: AtlasAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        queue.async {
            self.semaphore.wait()
            self.state = action.handle(state: self.state)
            self.semaphore.signal()
            self.triggerAll()
            completition?(self.state)
        }
    }
    
    /**
     * Dispatching an asynchronous action
     *
     */
    public func dispatch<A: AsyncAtlasAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        let block = { (_ state: T) -> Void in
            self.state = state
            self.semaphore.signal()
            completition?(self.state)
            self.triggerAll()
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
    public func dispatchUnsafe<A: AsyncAtlasAction>(_ action: A, completition: CompletitionHandler? = nil) where A.StateType == T {
        let block = { (_ state: T) -> Void in
            self.state = state
            completition?(self.state)
            self.triggerAll()
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
