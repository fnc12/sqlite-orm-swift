import XCTest
@testable import SQLiteORM

class StatementTests: XCTestCase {
    let pointer = OpaquePointer(bitPattern: 1)!
    
    var statement: StatementImpl!
    var apiProvider: SQLiteApiProviderMock!
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.statement = StatementImpl(stmt: self.pointer, apiProvider: self.apiProvider)
    }

    override func tearDownWithError() throws {
        self.statement = nil
        self.apiProvider = nil
    }
    
    func testBindText() {
        struct TestCase {
            let value: String
            let index: Int
        }
        let testCases = [
            TestCase(value: "ototo", index: 0),
            TestCase(value: "nana", index: 1),
            TestCase(value: "darkman", index: 2),
            TestCase(value: "let it rain", index: 3),
            TestCase(value: "you", index: 4),
            TestCase(value: "remember the time", index: 5),
        ]
        for (index, testCase) in testCases.enumerated() {
            XCTAssertEqual(self.apiProvider.calls, [])
            _ = self.statement.bindText(value: testCase.value, index: testCase.index)
            let nsValue = NSString(string: testCase.value)
            let expectedCallType = SQLiteApiProviderCallType.sqlite3BindText(self.pointer, Int32(testCase.index), nsValue.utf8String, -1,
                                                                             self.apiProvider.SQLITE_TRANSIENT)
            let expectedCalls = [SQLiteApiProviderCall(id: index, callType: expectedCallType)]
            XCTAssertEqual(self.apiProvider.calls, expectedCalls)
            self.apiProvider.calls.removeAll()
        }
    }
    
    func testBindInt() {
        struct TestCase {
            let value: Int
            let index: Int
        }
        let testCases = [
            TestCase(value: 10, index: 0),
            TestCase(value: 50, index: 1),
            TestCase(value: 45, index: 2),
            TestCase(value: 124, index: 3),
            TestCase(value: 436, index: 4),
            TestCase(value: -5, index: 5),
            TestCase(value: -90, index: 6),
            TestCase(value: 314, index: 7),
        ]
        for (index, testCase) in testCases.enumerated() {
            XCTAssertEqual(self.apiProvider.calls, [])
            _ = self.statement.bindInt(value: testCase.value, index: testCase.index)
            let expectedCalls = [SQLiteApiProviderCall(id: index,
                                                       callType: .sqlite3BindInt(self.pointer, Int32(testCase.index), Int32(testCase.value)))]
            XCTAssertEqual(self.apiProvider.calls, expectedCalls)
            self.apiProvider.calls.removeAll()
        }
    }
    
    func testColumnInt() {
        for index in 0..<10 {
            XCTAssertEqual(self.apiProvider.calls, [])
            _ = self.statement.columnInt(index: index)
            XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: index, callType: .sqlite3ColumnInt(self.pointer, Int32(index)))])
            self.apiProvider.calls.removeAll()
        }
    }
    
    func testColumnText() {
        struct TestCase {
            let stringToReturn: String
        }
        let testCases = [
            TestCase(stringToReturn: "ototo"),
            TestCase(stringToReturn: "love"),
            TestCase(stringToReturn: "knock"),
            TestCase(stringToReturn: "oops"),
            TestCase(stringToReturn: "wow none"),
        ]
        for (index, testCase) in testCases.enumerated() {
            let nsStringToReturn = NSString(string: testCase.stringToReturn)
            XCTAssertEqual(self.apiProvider.calls, [])
            let cStringArrayPointer: UnsafePointer<CChar> = nsStringToReturn.utf8String!
            cStringArrayPointer.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UnsafePointer<CChar>>.size) {
                self.apiProvider.sqlite3ColumnTextToReturn = $0
            }
            
            let text = self.statement.columnText(index: index)
            XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: index, callType: .sqlite3ColumnText(self.pointer, Int32(index)))])
            XCTAssertEqual(text, testCase.stringToReturn)
            self.apiProvider.calls.removeAll()
        }
    }
    
    func testColumnValue() {
        let opaquePointerToReturn = OpaquePointer(bitPattern: 2)
        self.apiProvider.sqlite3ColumnValueToReturn = opaquePointerToReturn
        for columnIndex in 0..<10 {
            XCTAssertEqual(self.apiProvider.calls, [])
            let sqliteValue = self.statement.columnValue(columnIndex: columnIndex)
            XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: columnIndex,
                                                                          callType: .sqlite3ColumnValue(self.pointer, Int32(columnIndex)))])
            XCTAssertEqual((sqliteValue as! SQLiteValueImpl).handle, opaquePointerToReturn)
            XCTAssert((sqliteValue as! SQLiteValueImpl).apiProvider === self.apiProvider)
            self.apiProvider.calls.removeAll()
        }
    }
    
    func testColumnCount() {
        XCTAssertEqual(self.apiProvider.calls, [])
        _ = self.statement.columnCount()
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: 0, callType: .sqlite3ColumnCount(self.pointer))])
    }
    
    func testStep() {
        XCTAssertEqual(self.apiProvider.calls, [])
        _ = self.statement.step()
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: 0, callType: .sqlite3Step(self.pointer))])
    }
    
    func testDeinit() {
        var newStatement: Statement? = StatementImpl(stmt: self.pointer, apiProvider: self.apiProvider)
        _ = newStatement    //  to erase warning
        XCTAssertEqual(self.apiProvider.calls, [])
        
        newStatement = nil
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: 0, callType: .sqlite3Finalize(self.pointer))])
    }
}