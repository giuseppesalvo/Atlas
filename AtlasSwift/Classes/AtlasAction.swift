//
//  AsyncAction.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

public typealias AtlasActionCompletition<T> = (_ state: T) -> Void

public protocol AtlasAction {
    associatedtype StateType
    func handle(state: StateType, completition: @escaping AtlasActionCompletition<StateType>)
}
