//
//  AsyncAction.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

public struct AtlasActionContext<S> {
    public let complete: (_ state: S) -> Void
    public let error: (_ error: Error) -> Void
}

public protocol AtlasAction {
    associatedtype StateType
    func handle(state: StateType, context: AtlasActionContext<StateType>)
}
