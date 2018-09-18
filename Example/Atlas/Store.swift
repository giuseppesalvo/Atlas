//
//  Store.swift
//  Atlas_Example
//
//  Created by Seth on 26/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AtlasSwift

var store = Atlas(
    state: State(
        count: CountState(value: 0)
    ),
    guards: [LoggerGuard()]
)

// MARK: State

struct State {
    var count: CountState
}

struct CountState {
    var value: Int
}

// MARK: Guards

struct LoggerGuard: AtlasGuard {
    func willUpdate<A: AtlasAction>(state: State, action: A) {
        print("will update!", state.count)
    }
    func didUpdate<A: AtlasAction>(state: State, action: A) {
        print("update!", state.count)
    }
}

// MARK: Actions

struct Increment: AtlasAction {
    func handle(state: State, completition: @escaping AtlasActionCompletition<State>) {
        var newState = state
        newState.count.value += 1
        completition(newState)
    }
}

struct Decrement: AtlasAction {
    func handle(state: State, completition: @escaping AtlasActionCompletition<State>) {
        var newState = state
        newState.count.value -= 1
        completition(newState)
    }
}
