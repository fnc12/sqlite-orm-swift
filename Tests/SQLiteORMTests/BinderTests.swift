import XCTest
@testable import SQLiteORM

class BinderTests: XCTestCase {

    var columnBinderMock: ColumnBinderMock!
    
    override func setUpWithError() throws {
        self.columnBinderMock = .init()
    }

    override func tearDownWithError() throws {
        self.columnBinderMock = nil
    }
    
    func testBindNull() {
        for columnIndex in 1..<10 {
            self.columnBinderMock = .init()
            let binder = BinderImpl(columnIndex: columnIndex, columnBinder: self.columnBinderMock)
            _ = binder.bindNull()
            XCTAssertEqual(self.columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindNull(index: columnIndex))])
        }
    }
    
    func testBindText() {
        for columnIndex in 1..<10 {
            for value in 0..<10 {
                self.columnBinderMock = .init()
                let binder = BinderImpl(columnIndex: columnIndex, columnBinder: self.columnBinderMock)
                let stringValue = "text\(value)"
                _ = binder.bindText(value: stringValue)
                XCTAssertEqual(self.columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindText(value: stringValue, index: columnIndex))])
            }
        }
    }
    
    func testBindDouble() {
        for columnIndex in 1..<10 {
            for value in 0..<10 {
                self.columnBinderMock = .init()
                let binder = BinderImpl(columnIndex: columnIndex, columnBinder: self.columnBinderMock)
                let doubleValue = Double(value)
                _ = binder.bindDouble(value: doubleValue)
                XCTAssertEqual(self.columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindDouble(value: doubleValue, index: columnIndex))])
            }
        }
    }

    func testBindInt() {
        for columnIndex in 1..<10 {
            for value in 0..<10 {
                self.columnBinderMock = .init()
                let binder = BinderImpl(columnIndex: columnIndex, columnBinder: self.columnBinderMock)
                _ = binder.bindInt(value: value)
                XCTAssertEqual(self.columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindInt(value: value, index: columnIndex))])
            }
        }
    }
}
