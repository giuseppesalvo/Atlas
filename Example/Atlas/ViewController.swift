//
//  ViewController.swift
//  Atlas
//
//  Created by Giuseppe on 08/26/2018.
//  Copyright (c) 2018 Giuseppe. All rights reserved.
//

import Cocoa
import Atlas

class ViewController: NSViewController {

    @IBOutlet var count: NSTextField!
    
    @IBAction func increment(_ sender: Any) {
        store.dispatch(Increment())
    }

    @IBAction func decrement(_ sender: Any) {
        store.dispatch(Decrement())
    }
}

extension ViewController: AtlasSubscriber {
    override func viewWillAppear() {
        super.viewWillAppear()
        store.subscribe(self)
    }
    
    func newState(_ state: CountState) {
        count.stringValue = String(state.count)
    }
}

