import XCTest
@testable import SQLiteORM

class BinderTests: XCTestCase {

    func testBinder() throws {
        try testCase(#function) {
            let columnBinderMock = ColumnBinderMock()
            for columnIndex in 1..<3 {
                try section("bind null \(columnIndex)") {
                    let binder = BinderImpl(columnIndex: columnIndex, columnBinder: columnBinderMock)
                    _ = binder.bindNull()
                    XCTAssertEqual(columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindNull(index: columnIndex))])
                }
                for value in 0..<3 {
                    try section("bind text \(columnIndex)_\(value)") {
                        let binder = BinderImpl(columnIndex: columnIndex, columnBinder: columnBinderMock)
                        let stringValue = "text\(value)"
                        _ = binder.bindText(value: stringValue)
                        XCTAssertEqual(columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindText(value: stringValue, index: columnIndex))])
                    }
                    try section("bind double \(columnIndex)_\(value)") {
                        let binder = BinderImpl(columnIndex: columnIndex, columnBinder: columnBinderMock)
                        let doubleValue = Double(value)
                        _ = binder.bindDouble(value: doubleValue)
                        XCTAssertEqual(columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindDouble(value: doubleValue, index: columnIndex))])
                    }
                    try section("bind int \(columnIndex)_\(value)", routine: {
                        let binder = BinderImpl(columnIndex: columnIndex, columnBinder: columnBinderMock)
                        _ = binder.bindInt(value: value)
                        XCTAssertEqual(columnBinderMock.calls, [ColumnBinderMock.Call(id: 0, callType: .bindInt(value: value, index: columnIndex))])
                    })
                }
            }
        }
    }
}
