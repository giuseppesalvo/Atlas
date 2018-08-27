//
//  Store.swift
//  Atlas_Example
//
//  Created by Seth on 26/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Atlas

struct CountState {
    var count: Int
}

var store = Atlas(initialState: CountState(
    count: 0
))

struct Increment: AtlasAction {
    func handle(state: CountState) -> CountState {
        var newState = state
        newState.count += 1
        return newState
    }
}

struct Decrement: AtlasAction {
    func handle(state: CountState) -> CountState {
        var newState = state
        newState.count -= 1
        return newState
    }
}
