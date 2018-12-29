import XCTest
import AtlasSwift

struct CountState {
    var count: Int
}

struct Increment: AtlasAction {
    func handle(state: CountState, context: AtlasActionContext<CountState>) {
        var newState = state
        newState.count += 1
        context.complete(newState)
    }
}

public enum TestActionError: Error {
    case increment
}

struct IncrementWithError: AtlasAction {
    func handle(state: CountState, context: AtlasActionContext<CountState>) {
        context.error( TestActionError.increment )
    }
}

struct Decrement: AtlasAction {
    func handle(state: CountState, context: AtlasActionContext<CountState>) {
        var newState = state
        newState.count -= 1
        context.complete(newState)
    }
}

struct IncrementAsync: AtlasAction {
    func handle(state: CountState, context: AtlasActionContext<CountState>){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var newState = state
            newState.count += 1
            context.complete(newState)
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
            store.dispatch(Increment()) { (_, state) in
                XCTAssert(state.count == i, "Count should be \(i)")
                expectation.fulfill()
            }
            expectations.append(expectation)
        }
        wait(for: expectations, timeout: 10.0)
    }
    
    func testActionError() {
        let store = Atlas(state: CountState(
            count: 0
        ))
        var expectations: [XCTestExpectation] = []
        for i in 1..<100 {
            let expectation = XCTestExpectation(description: "Testing action with \(i)")
            store.dispatch(IncrementWithError()) { (error, state) in
                if let err = error, case TestActionError.increment = err {
                    XCTAssert(true, "Error should be of type: \(TestActionError.increment)")
                } else {
                    XCTAssert(false, "Error should be of type: \(TestActionError.increment)")
                }
                
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
        store.dispatch(IncrementAsync()) { (_, state) in
            XCTAssert(state.count == 1, "Count should be 1")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

