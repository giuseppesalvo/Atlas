# Atlas Swift Store

Atlas is a redux store for your swift apps without the reducer layer

[![Version](https://img.shields.io/cocoapods/v/AtlasSwift.svg?style=flat)](https://cocoapods.org/pods/AtlasSwift)
[![License](https://img.shields.io/cocoapods/l/AtlasSwift.svg?style=flat)](https://cocoapods.org/pods/AtlasSwift)
[![Platform](https://img.shields.io/cocoapods/p/AtlasSwift.svg?style=flat)](https://cocoapods.org/pods/AtlasSwift)

## Installation

Atlas is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AtlasSwift'
```

## How it works

**there are only 2 components**

- state
- actions

### Initializing

```swift

// The state should be always a struct, to ensure immutability
struct CountState {
    var count: Int
}

let store = Atlas(initialState: CountState(
    count: 0
))

```

### Actions

**Synchronous**

```swift

struct Increment: AtlasAction {
    func handle(state: CountState) -> CountState {
        var newState = state
        newState.count += 1
        return state
    }
}

store.dispatch(Increment()) { state in
    print("done! ", state.count)
}

```

**Asynchronous**

```swift

struct Increment: AtlasAsyncAction {
    func handle(state: CountState, completition: @escaping (_ state: CountState) -> Void) {
        YourApi.doSomething { result in
            var newState   = state
            newState.count = result
            completition(newState)
        }
    }
}

store.dispatch(Increment()) { state in
    print("done! ", state.count)
}

```

**Actions group**

```swift

struct CounterAction: AtlasActionGroup {
    func handle(state: CountState, completition: @escaping (_ state: CountState) -> Void) {
        store.dispatch(Increment())
        store.dispatch(Increment())
        // Since the store internal queue is serial, this callback will be the real end of the actionGroup
        store.dispatch(Decrement()) { _ in
            completition()
        }
    }
}

store.dispatch(CounterAction()) { state in
    print("done! ", state.count)
}

```

### Subscription

```swift

class YourController: UIViewController, AtlasSubscriber {

    override func viewDidAppear() {
        super.viewDidAppear()
        store.subscribe(self)
    }
    
    // There is no need to unsubscribe your objects. Everything is managed with weak vars
    override func viewWillDisappear() {
        super.viewWillDisappear()
        store.unsubscribe(self)
    }
    
    func newState(_ state: CountState) {
        print("count state changed!")
    }
}

```

### Subscribe to multiple stores

```swift

class YourController: UIViewController, AtlasSubscriber {

    var countSubscriber : AtlasAtomSubscriber<CountState>!
    var todoSubscriber  : AtlasAtomSubscriber<TodoState>!

    func viewDidLoad() {
        super.viewDidLoad()
        countSubscriber = AtlasAtomSubscriber(store: countStore, callback: self.newCountState)
        todoSubscriber  = AtlasAtomSubscriber(store: todoStore, callback: self.newTodoState)
    }
    
    func newCountState(_ state: CountState) {
        print("count state changed!")
    }
    
    func newTodoState(_ state: TodoState) {
        print("todo state changed!")
    }

}

```

You can subscribe also with a block

```swift

let countSubscriber = AtlasAtomSubscriber(store: countStore) { [weak self] state in
    print("new count state", state)
}

```

Notes
- Atlas uses a serial queue to dispatch every action, so you can be sure that your actions will be exectuted in the invokation order
- The dispatch function is async, to avoid deadlocks. To track its end, you can use the completition argument
- The subcribe function also have a second argument "queue", to subscribe a class on a specific queue

### That's all!

Inspired by ReSwift and Redux

## License

Atlas is available under the MIT license. See the LICENSE file for more info.
