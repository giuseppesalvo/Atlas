//
//  ViewController.swift
//  Atlas
//
//  Created by Giuseppe on 08/26/2018.
//  Copyright (c) 2018 Giuseppe. All rights reserved.
//

import Cocoa
import AtlasSwift

class ViewController: NSViewController {

    @IBOutlet var count: NSTextField!
    
    @IBAction func increment(_ sender: Any) {
        CountStore.dispatch( Increment(value: 4) )
    }

    @IBAction func decrement(_ sender: Any) {
        CountStore.dispatch( Decrement() )
    }
}

extension ViewController: AtlasSubscriber {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        CountStore.subscribe(self)
    }
    
    func shouldUpdate(prevState: CountState?, newState: CountState) -> Bool {
        return prevState?.value != newState.value
    }
    
    func newState(_ state: CountState) {
        count.stringValue = String(state.value)
    }
}
