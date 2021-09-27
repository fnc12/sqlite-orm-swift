import XCTest
@testable import SQLiteORM

class SQLiteValueTests: XCTestCase {
    let pointer = OpaquePointer(bitPattern: 1)!
    
    var apiProvider: SQLiteApiProviderMock!
    var sqliteValue: SQLiteValue!
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.sqliteValue = SQLiteValueImpl(handle: self.pointer, apiProvider: self.apiProvider)
    }

    override func tearDownWithError() throws {
        self.sqliteValue = nil
        self.apiProvider = nil
    }

    func testIsValid() {
        struct TestCase {
            let value: SQLiteValue
            let expected: Bool
        }
        let testCases = [
            TestCase(value: SQLiteValueImpl(handle: nil, apiProvider: self.apiProvider), expected: false),
            TestCase(value: SQLiteValueImpl(handle: OpaquePointer(bitPattern: 1), apiProvider: self.apiProvider), expected: true),
        ]
        for testCase in testCases {
            let value = testCase.value
            XCTAssertEqual(value.isValid, testCase.expected)
        }
    }
    
    func testInteger() {
        _ = self.sqliteValue.integer
        
        let expectedCalls = [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3ValueInt(self.pointer))]
        XCTAssertEqual(expectedCalls, self.apiProvider.calls)
    }
    
    func testText() {
        _ = self.sqliteValue.text
        
        let expectedCalls = [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3ValueText(.value(self.pointer)))]
        XCTAssertEqual(expectedCalls, self.apiProvider.calls)
    }

}
