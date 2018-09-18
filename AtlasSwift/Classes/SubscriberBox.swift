//
//  SubscriberBox.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

class AtlasSubscriberBox: Hashable {
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func == (lhs: AtlasSubscriberBox, rhs: AtlasSubscriberBox) -> Bool {
        return lhs.value === rhs.value && rhs.queue === lhs.queue
    }
    
    weak var value: AtlasAnySubscriber?
    var queue: DispatchQueue
    
    init(value: AtlasAnySubscriber, queue: DispatchQueue) {
        self.value = value
        self.queue = queue
    }
}
