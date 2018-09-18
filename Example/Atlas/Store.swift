//
//  Store.swift
//  Atlas_Example
//
//  Created by Seth on 26/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AtlasSwift

struct CountState {
    var value: Int
}

struct State {
    var count: CountState
}

var store = Atlas(state: State(
    count: CountState(value: 0)
))

struct Increment: AtlasAction {
    func handle(state: State) -> State {
        var newState = state
        newState.count.value += 1
        return newState
    }
}

struct Decrement: AtlasAction {
    func handle(state: State) -> State {
        var newState = state
        newState.count.value -= 1
        return newState
    }
}
