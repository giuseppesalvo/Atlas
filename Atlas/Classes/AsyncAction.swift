//
//  AsyncAction.swift
//  Habit
//
//  Created by Seth on 25/08/18.
//  Copyright © 2018 Giuseppe Salvo. All rights reserved.
//

import Foundation

public protocol AsyncAtlasAction {
    associatedtype StateType
    func handle(state: StateType, completition: @escaping (_ state: StateType) -> Void)
}
