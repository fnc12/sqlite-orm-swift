import XCTest
@testable import SQLiteORM

class StorageCoreAggregateFunctionsTests: XCTestCase {
    struct Unknown {
        var value = Double(0)
    }

    func testTotal() throws {
        try testCase(#function, routine: {
            struct TotalTest {
                var value: Int = 0
                var nullableValue: Int? = 0
                var unknown = 0
            }
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<TotalTest>(name: "total_test",
                                                                            columns:
                                                                                Column(name: "value", keyPath: \TotalTest.value),
                                                                            Column(name: "null_value", keyPath: \TotalTest.nullableValue))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    switch storageCore.total(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("error columnNotFound", routine: {
                    switch storageCore.total(\TotalTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedResult: Double = 0
                var result: Double = -1
                var expectedApiCalls = [SQLiteApiProviderMock.Call]()
                try section("with constraints", routine: {
                    expectedResult = 0
                    expectedApiCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"value\") FROM total_test WHERE (total_test.\"value\" < 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.total(\TotalTest.value, [where_(lesserThan(lhs: \TotalTest.value, rhs: 10))]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.total(\TotalTest.value, [where_(\TotalTest.value < 10)]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("not nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = 0
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(TotalTest(value: 1)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 1
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(TotalTest(value: 2)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(TotalTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 5
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.total(\TotalTest.value, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = 0
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"null_value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(TotalTest(value: 0, nullableValue: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 3
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"null_value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(TotalTest(value: 0, nullableValue: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(TotalTest(value: 0, nullableValue: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT TOTAL(\"null_value\") FROM total_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.total(\TotalTest.nullableValue, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
            })
        })
    }

    func testSum() throws {
        try testCase(#function, routine: {
            struct SumTest {
                var value: Int = 0
                var nullableValue: Int? = 0
                var unknown = 0
            }
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<SumTest>(name: "sum_test",
                                                                          columns:
                                                                            Column(name: "value", keyPath: \SumTest.value),
                                                                          Column(name: "null_value", keyPath: \SumTest.nullableValue))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    switch storageCore.sum(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("error columnNotFound", routine: {
                    switch storageCore.sum(\SumTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedResult: Double?
                var result: Double?
                var expectedApiCalls = [SQLiteApiProviderMock.Call]()
                try section("with constraints", routine: {
                    expectedResult = nil
                    expectedApiCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"value\") FROM sum_test WHERE (sum_test.\"value\" > 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.sum(\SumTest.value, [where_(greaterThan(lhs: \SumTest.value, rhs: 10))]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.sum(\SumTest.value, [where_(\SumTest.value > 10)]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("not nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(SumTest(value: 1)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 1
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(SumTest(value: 2)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(SumTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 5
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.sum(\SumTest.value, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"null_value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(SumTest(value: 0, nullableValue: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 3
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"null_value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(SumTest(value: 0, nullableValue: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(SumTest(value: 0, nullableValue: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT SUM(\"null_value\") FROM sum_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.sum(\SumTest.nullableValue, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
            })
        })
    }

    func testMin() throws {
        try testCase(#function, routine: {
            struct MinTest {
                var value: Int = 0
                var nullableValue: Int? = 0
                var unknown = 0
            }
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<MinTest>(name: "min_test",
                                                                          columns:
                                                                            Column(name: "value", keyPath: \MinTest.value),
                                                                          Column(name: "null_value", keyPath: \MinTest.nullableValue))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    switch storageCore.min(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("error columnNotFound", routine: {
                    switch storageCore.min(\MinTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedResult: Int?
                var result: Int?
                var expectedApiCalls = [SQLiteApiProviderMock.Call]()
                try section("with constraints", routine: {
                    expectedResult = nil
                    expectedApiCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"value\") FROM min_test WHERE (min_test.\"value\" <= 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.min(\MinTest.value, [where_(lesserOrEqual(lhs: \MinTest.value, rhs: 10))]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.min(\MinTest.value, [where_(\MinTest.value <= 10)]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("not nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(MinTest(value: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(MinTest(value: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(MinTest(value: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 4
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.min(\MinTest.value, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"null_value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(MinTest(value: 0, nullableValue: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"null_value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(MinTest(value: 0, nullableValue: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(MinTest(value: 0, nullableValue: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 4
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MIN(\"null_value\") FROM min_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.min(\MinTest.nullableValue, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
            })
        })
    }

    func testMax() throws {
        try testCase(#function, routine: {
            struct MaxTest {
                var value: Int = 0
                var nullableValue: Int? = 0
                var unknown = 0
            }
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<MaxTest>(name: "max_test",
                                                                          columns:
                                                                            Column(name: "value", keyPath: \MaxTest.value),
                                                                          Column(name: "null_value", keyPath: \MaxTest.nullableValue))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    switch storageCore.max(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("error columnNotFound", routine: {
                    switch storageCore.max(\MaxTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedResult: Int?
                var result: Int?
                var expectedApiCalls = [SQLiteApiProviderMock.Call]()
                try section("with constraints", routine: {
                    expectedResult = nil
                    expectedApiCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"value\") FROM max_test WHERE (max_test.\"value\" >= 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.max(\MaxTest.value, [where_(greaterOrEqual(lhs: \MaxTest.value, rhs: 10))]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.max(\MaxTest.value, [where_(\MaxTest.value >= 10)]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("not nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(MaxTest(value: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(MaxTest(value: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(MaxTest(value: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 6
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.max(\MaxTest.value, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
                try section("nullable field", routine: {
                    try section("no rows", routine: {
                        expectedResult = nil
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"null_value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("1 row", routine: {
                        switch storageCore.replaceInternal(MaxTest(value: 0, nullableValue: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 10
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"null_value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("2 rows", routine: {
                        switch storageCore.replaceInternal(MaxTest(value: 0, nullableValue: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(MaxTest(value: 0, nullableValue: 6)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = 6
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT MAX(\"null_value\") FROM max_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueInt(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.max(\MaxTest.nullableValue, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                    XCTAssertEqual(result, expectedResult)
                    XCTAssertEqual(apiProvider.calls, expectedApiCalls)
                })
            })
        })
    }

    func testGroupConcat() throws {
        try testCase(#function, routine: {
            struct GroupConcatTest {
                var value = Int(0)
                var unknown = Int(0)
            }
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<GroupConcatTest>(name: "group_concat_test",
                                                                                  columns: Column(name: "value", keyPath: \GroupConcatTest.value, constraints: primaryKey()))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    switch storageCore.count(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("error columnNotFound", routine: {
                    switch storageCore.count(\GroupConcatTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedResult = [String?]()
                var result: String?
                var expectedApiCalls = [SQLiteApiProviderMock.Call]()
                try section("with constraints", routine: {
                    expectedResult = [nil]
                    expectedApiCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\") FROM group_concat_test WHERE (group_concat_test.\"value\" == 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.groupConcat(\GroupConcatTest.value, [where_(equal(lhs: \GroupConcatTest.value, rhs: 10))]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.groupConcat(\GroupConcatTest.value, [where_(\GroupConcatTest.value == 10)]) {
                        case .success(let value):
                            result = value
                        case .failure(let error):
                            throw error
                        }
                    })
                })
                try section("1 argument", routine: {
                    try section("no rows", routine: {
                        expectedResult = [nil]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\") FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("one row", routine: {
                        switch storageCore.replaceInternal(GroupConcatTest(value: 1)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = ["1"]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\") FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("two rows", routine: {
                        switch storageCore.replaceInternal(GroupConcatTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(GroupConcatTest(value: 5)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = ["3,5", "5,3"]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\") FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.groupConcat(\GroupConcatTest.value, []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                })
                try section("2 arguments", routine: {
                    try section("no rows", routine: {
                        expectedResult = [nil]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\", '-') FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("one row", routine: {
                        switch storageCore.replaceInternal(GroupConcatTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = ["3"]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\", '-') FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("two rows", routine: {
                        switch storageCore.replaceInternal(GroupConcatTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(GroupConcatTest(value: 5)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedResult = ["3-5", "5-3"]
                        expectedApiCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT GROUP_CONCAT(\"value\", '-') FROM group_concat_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.groupConcat(\GroupConcatTest.value, separator: "-", []) {
                    case .success(let value):
                        result = value
                    case .failure(let error):
                        throw error
                    }
                })
                XCTAssert(expectedResult.contains(result))
                XCTAssertEqual(apiProvider.calls, expectedApiCalls)
            })
        })
    }

    func testCount() throws {
        struct CountTest: Initializable {
            var value: Double?
            var unknown: Double?
        }
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<CountTest>(name: "count_test",
                                                                            columns: Column(name: "value", keyPath: \CountTest.value))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error", routine: {
                try section("notMappedType", routine: {
                    switch storageCore.count(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
                try section("columnNotFound", routine: {
                    switch storageCore.count(\CountTest.unknown, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                })
            })
            try section("no error", routine: {
                let db = storageCore.connection.dbMaybe!
                var expectedCount = 0
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                var count = 0
                try section("with constraints", routine: {
                    expectedCount = 0
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(\"value\") FROM count_test WHERE (count_test.\"value\" != 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.count(\CountTest.value, [where_(notEqual(lhs: \CountTest.value, rhs: 10))]) {
                        case .success(let value):
                            count = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.count(\CountTest.value, [where_(\CountTest.value != 10)]) {
                        case .success(let value):
                            count = value
                        case .failure(let error):
                            throw error
                        }
                    })
                })
                try section("without constraints", routine: {
                    try section("no rows", routine: {
                        expectedCount = 0
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(\"value\") FROM count_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("one row with null", routine: {
                        switch storageCore.replaceInternal(CountTest(value: nil)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedCount = 0
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(\"value\") FROM count_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("three rows without null", routine: {
                        switch storageCore.replaceInternal(CountTest(value: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(CountTest(value: 20)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(CountTest(value: 30)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedCount = 3
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(\"value\") FROM count_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.count(\CountTest.value, []) {
                    case .success(let value):
                        count = value
                    case .failure(let error):
                        throw error
                    }
                })
                XCTAssertEqual(count, expectedCount)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            })
        })
    }

    func testCountAll() throws {
        struct CountTest: Initializable {
            var value = Double(0)
        }
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<CountTest>(name: "count_test",
                                                                            columns: Column(name: "value", keyPath: \CountTest.value))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error notMapedType", routine: {
                switch storageCore.count(all: Unknown.self, []) {
                case .success(_):
                    XCTAssert(false)
                case .failure(let error):
                    switch error {
                    case SQLiteORM.Error.typeIsNotMapped:
                        XCTAssert(true)
                    default:
                        XCTAssert(false)
                    }
                }
            })
            try section("no error", routine: {
                var expectedCount = 0
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                let db = storageCore.connection.dbMaybe!
                var count = 0
                try section("with constraints", routine: {
                    expectedCount = 0
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(*) FROM count_test WHERE (count_test.\"value\" != 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore))
                    ]
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.count(all: CountTest.self, [where_(notEqual(lhs: \CountTest.value, rhs: 10))]) {
                        case .success(let value):
                            count = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.count(all: CountTest.self, [where_(\CountTest.value != 10)]) {
                        case .success(let value):
                            count = value
                        case .failure(let error):
                            throw error
                        }
                    })
                })
                try section("without constraints", routine: {
                    try section("no rows", routine: {
                        expectedCount = 0
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(*) FROM count_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    try section("3 rows", routine: {
                        switch storageCore.replaceInternal(CountTest(value: 1)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(CountTest(value: 2)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(CountTest(value: 3)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedCount = 3
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT COUNT(*) FROM count_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3Step(.ignore)),
                            .init(id: 4, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    apiProvider.resetCalls()
                    switch storageCore.count(all: CountTest.self, []) {
                    case .success(let value):
                        count = value
                    case .failure(let error):
                        throw error
                    }
                })
                XCTAssertEqual(count, expectedCount)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            })
        })
    }

    func testAvg() throws {
        struct AvgTest: Initializable {
            var value = Double(0)
            var unused = Double(0)
        }
        try testCase(#function) {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storageCore = try StorageCoreImpl(filename: "",
                                                  apiProvider: apiProvider,
                                                  tables: [Table<AvgTest>(name: "avg_test",
                                                                          columns: Column(name: "value", keyPath: \AvgTest.value))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            try section("error") {
                try section("columnNotFound") {
                    switch storageCore.avg(\AvgTest.unused, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.columnNotFound:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                }
                try section("notMapedType") {
                    switch storageCore.avg(\Unknown.value, []) {
                    case .success(_):
                        XCTAssert(false)
                    case .failure(let error):
                        switch error {
                        case SQLiteORM.Error.typeIsNotMapped:
                            XCTAssert(true)
                        default:
                            XCTAssert(false)
                        }
                    }
                }
            }
            try section("no error") {
                let db = storageCore.connection.dbMaybe!
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                var expectedResult: Double?
                var avgValue: Double?
                try section("with constraints", routine: {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT AVG(\"value\") FROM avg_test WHERE (avg_test.\"value\" < 10)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore))
                    ]
                    expectedResult = nil
                    apiProvider.resetCalls()
                    try section("function", routine: {
                        switch storageCore.avg(\AvgTest.value, [where_(lesserThan(lhs: \AvgTest.value, rhs: 10))]) {
                        case .success(let value):
                            avgValue = value
                        case .failure(let error):
                            throw error
                        }
                    })
                    try section("operator", routine: {
                        switch storageCore.avg(\AvgTest.value, [where_(\AvgTest.value < 10)]) {
                        case .success(let value):
                            avgValue = value
                        case .failure(let error):
                            throw error
                        }
                    })
                })
                try section("without constraints", routine: {
                    try section("insert nothing") {
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT AVG(\"value\") FROM avg_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3Step(.ignore)),
                            .init(id: 5, callType: .sqlite3Finalize(.ignore))
                        ]
                        expectedResult = nil
                    }
                    try section("insert something", routine: {
                        switch storageCore.replaceInternal(AvgTest(value: 1)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(AvgTest(value: 4)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        switch storageCore.replaceInternal(AvgTest(value: 10)) {
                        case .success():
                            break
                        case .failure(let error):
                            throw error
                        }
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT AVG(\"value\") FROM avg_test", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                            .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                            .init(id: 5, callType: .sqlite3Step(.ignore)),
                            .init(id: 6, callType: .sqlite3Finalize(.ignore))
                        ]
                        expectedResult = Double(1 + 4 + 10) / 3
                    })
                    apiProvider.resetCalls()
                    switch storageCore.avg(\AvgTest.value, []) {
                    case .success(let value):
                        avgValue = value
                    case .failure(let error):
                        throw error
                    }
                })
                XCTAssertEqual(avgValue, expectedResult)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            }
        }
    }
}
