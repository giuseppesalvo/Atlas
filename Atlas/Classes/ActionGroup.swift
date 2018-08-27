//
//  ActionGroup.swift
//  Atlas
//
//  Created by Seth on 26/08/18.
//

import Foundation

public protocol AtlasActionGroup {
    associatedtype StateType
    func handle(store: Atlas<StateType>, completition: @escaping () -> Void)
}
