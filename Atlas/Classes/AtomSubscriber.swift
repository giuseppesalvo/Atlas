//
//  AtomSubscriber.swift
//  Habit
//
//  Created by Seth on 26/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

public class AtlasAtomSubscriber<T>: AtlasSubscriber {
    
    let store: Atlas<T>
    let callback: (_ state: T) -> Void
    
    init(store: Atlas<T>, callback: @escaping (_ state: T) -> Void) {
        self.store    = store
        self.callback = callback
        store.subscribe(self)
    }
    
    public func newState(_ state: T) {
        callback(state)
    }
}
