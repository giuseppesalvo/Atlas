//
//  Store.swift
//  Atlas_Example
//
//  Created by Seth on 26/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AtlasSwift

let CountStore = Atlas(
    state  : CountState(value: 0),
    guards : [LoggerGuard()]
)

// MARK: CountState

struct CountState {
    let value: Int
}

// MARK: Guards

struct LoggerGuard: AtlasGuard {
    func shouldUpdate<A: AtlasAction>(state: CountState, action: A) -> Bool {
        return true
    }
    func willUpdate<A: AtlasAction>(state: CountState, action: A) {
        print("will update!", state.value)
    }
    func didUpdate<A: AtlasAction>(state: CountState, action: A) {
        print("update!", state.value)
    }
}

// MARK: Actions

struct Increment: AtlasAction {
    var value: Int
    func handle(state: CountState, context: AtlasActionContext<CountState> ) {
        context.complete(CountState(
            value: state.value + value
        ))
    }
}

struct Decrement: AtlasAction {
    func handle(state: CountState, context: AtlasActionContext<CountState> ) {
        context.complete(CountState(
            value: state.value - 1
        ))
    }
}
