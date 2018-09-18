import XCTest
import AtlasSwift

struct CountState {
    var count: Int
}

struct Increment: AtlasAction {
    func handle(state: CountState, completition: @escaping AtlasActionCompletition<CountState>) {
        var newState = state
        newState.count += 1
        completition(newState)
    }
}

struct Decrement: AtlasAction {
    func handle(state: CountState, completition: @escaping AtlasActionCompletition<CountState>) {
        var newState = state
        newState.count -= 1
        completition(newState)
    }
}

struct IncrementAsync: AtlasAction {
    func handle(state: CountState, completition: @escaping AtlasActionCompletition<CountState>){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var newState = state
            newState.count += 1
            completition(newState)
        }
    }
}

struct CountOperation: AtlasActionGroup {
    func handle(store: Atlas<CountState>, completition: @escaping AtlasActionGroupCompletition) {
        store.dispatch(Increment())
        store.dispatch(Increment())
        store.dispatch(Increment())
        store.dispatch(Increment())
        // Since the store internal queue is serial, this callback will be the real end of the actionGroup
        store.dispatch(Decrement()) { _ in
            completition()
        }
    }
}

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialization() {
        let store = Atlas(state: CountState(
            count: 0
        ))
        XCTAssert(store.state.count == 0, "Count should be 0")
    }
    
    func testSyncAction() {
        let store = Atlas(state: CountState(
            count: 0
        ))
        var expectations: [XCTestExpectation] = []
        for i in 1..<100 {
            let expectation = XCTestExpectation(description: "Testing action with \(i)")
            store.dispatch(Increment()) { state in
                XCTAssert(state.count == i, "Count should be \(i)")
                expectation.fulfill()
            }
            expectations.append(expectation)
        }
        wait(for: expectations, timeout: 10.0)
    }
    
    func testAsyncAction() {
        let store = Atlas(state: CountState(
            count: 0
        ))
        let expectation = XCTestExpectation(description: "Testing asyncronous action")
        store.dispatch(IncrementAsync()) { state in
            XCTAssert(state.count == 1, "Count should be 1")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testActionGroup() {
        let store = Atlas(state: CountState(
            count: 0
        ))
        let expectation = XCTestExpectation(description: "Testing asyncronous action")
        store.dispatch(CountOperation()) { state in
            XCTAssertEqual(state.count, 3, "Count should be 3")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

