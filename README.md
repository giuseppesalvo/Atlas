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

- State
- Actions
- Guards

### Initializing

```swift

// The state should be always a struct, to ensure immutability
struct CountState {
    var count: Int
}

let store = Atlas(state: CountState(
    count: 0
))

```

### Actions

```swift

// Actions can be synchronous or asynchronous

struct Increment: AtlasAction {
    func handle(state: CountState, completition: AtlasActionCompletition<CountState>) {
        var newState   = state
        newState.count = result
        completition(newState)
    }
}

store.dispatch(Increment()) { state in
    print("done! ", state.count)
}

```

### Action Group

```swift

struct CountOperation: AtlasActionGroup {
    func handle(store: Atlas<CountState>, completition: @escaping () -> Void) {
        store.dispatch(Increment())
        store.dispatch(Increment())
        store.dispatch(Increment())
        store.dispatch(Decrement()) { _ in
            completition()
        }
    }
}

store.dispatch(CountOperation()) { state in
    print("done! ", state.count)
}

```

### Subscription

```swift

extension YourController: AtlasSubscriber {

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

### Subscriber Should Update

Avoiding unneeded updates and subscribing to a specific part of the store.
By default, the shouldUpdate function returns always true.

```swift

extension YourController: AtlasSubscriber {

    // subscription code...

    func shouldUpdate(prevState: CountState?, newState: CountState) -> Bool {
        return prevState?.count != newState.count
    }
}

```

### Guards

Guards are simple classes that track the store lifecycle
In future, they will include also a middleware-like function.

```swift

struct Logger: AtlasGuard {
    func willUpdate<A: AtlasAction>(state: State, action: A) {
        print("will update!", state.count)
    }
    func didUpdate<A: AtlasAction>(state: State, action: A) {
        print("update!", state.count)
    }
}

let store = Atlas(state: YourState(), guards: [ Logger() ])

```

This means that you can subscribe to specific parts of the store

Notes
- Atlas uses a serial queue to dispatch every action, so you can be sure that your actions will be executed in the invokation order
- The dispatch function is async, to avoid deadlocks. To track its end, you can use the completition argument
- The subcribe function also have a second argument "queue", to subscribe a class on a specific queue

### That's all!

Inspired by ReSwift and Redux

## License

Atlas is available under the MIT license. See the LICENSE file for more info.
