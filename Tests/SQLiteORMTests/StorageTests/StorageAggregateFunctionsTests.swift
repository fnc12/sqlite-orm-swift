import XCTest
@testable import SQLiteORM

class StorageAggregateFunctionsTests: XCTestCase {
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<TotalTest>(name: "total_test",
                                                                columns:
                                                                    Column(name: "value", keyPath: \TotalTest.value),
                                                                    Column(name: "null_value", keyPath: \TotalTest.nullableValue))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    do {
                        _ = try storage.total(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("error columnNotFound", routine: {
                    do {
                        _ = try storage.total(\TotalTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        result = try storage.total(\TotalTest.value, where_(lesserThan(lhs: \TotalTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        result = try storage.total(\TotalTest.value, where_(\TotalTest.value < 10))
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
                        try storage.replace(TotalTest(value: 1))
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
                        try storage.replace(TotalTest(value: 2))
                        try storage.replace(TotalTest(value: 3))
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
                    result = try storage.total(\TotalTest.value)
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
                        try storage.replace(TotalTest(value: 0, nullableValue: 3))
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
                        try storage.replace(TotalTest(value: 0, nullableValue: 4))
                        try storage.replace(TotalTest(value: 0, nullableValue: 6))
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
                    result = try storage.total(\TotalTest.nullableValue)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<SumTest>(name: "sum_test",
                                                              columns:
                                                                Column(name: "value", keyPath: \SumTest.value),
                                                                Column(name: "null_value", keyPath: \SumTest.nullableValue))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    do {
                        _ = try storage.sum(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("error columnNotFound", routine: {
                    do {
                        _ = try storage.sum(\SumTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        result = try storage.sum(\SumTest.value, where_(greaterThan(lhs: \SumTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        result = try storage.sum(\SumTest.value, where_(\SumTest.value > 10))
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
                        try storage.replace(SumTest(value: 1))
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
                        try storage.replace(SumTest(value: 2))
                        try storage.replace(SumTest(value: 3))
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
                    result = try storage.sum(\SumTest.value)
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
                        try storage.replace(SumTest(value: 0, nullableValue: 3))
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
                        try storage.replace(SumTest(value: 0, nullableValue: 4))
                        try storage.replace(SumTest(value: 0, nullableValue: 6))
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
                    result = try storage.sum(\SumTest.nullableValue)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<MinTest>(name: "min_test",
                                                              columns:
                                                                Column(name: "value", keyPath: \MinTest.value),
                                                                Column(name: "null_value", keyPath: \MinTest.nullableValue))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    do {
                        _ = try storage.min(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("error columnNotFound", routine: {
                    do {
                        _ = try storage.min(\MinTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        result = try storage.min(\MinTest.value, where_(lesserOrEqual(lhs: \MinTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        result = try storage.min(\MinTest.value, where_(\MinTest.value <= 10))
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
                        try storage.replace(MinTest(value: 10))
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
                        try storage.replace(MinTest(value: 4))
                        try storage.replace(MinTest(value: 6))
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
                    result = try storage.min(\MinTest.value)
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
                        try storage.replace(MinTest(value: 0, nullableValue: 10))
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
                        try storage.replace(MinTest(value: 0, nullableValue: 4))
                        try storage.replace(MinTest(value: 0, nullableValue: 6))
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
                    result = try storage.min(\MinTest.nullableValue)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<MaxTest>(name: "max_test",
                                                              columns:
                                                                Column(name: "value", keyPath: \MaxTest.value),
                                                                Column(name: "null_value", keyPath: \MaxTest.nullableValue))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    do {
                        _ = try storage.max(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("error columnNotFound", routine: {
                    do {
                        _ = try storage.max(\MaxTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        result = try storage.max(\MaxTest.value, where_(greaterOrEqual(lhs: \MaxTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        result = try storage.max(\MaxTest.value, where_(\MaxTest.value >= 10))
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
                        try storage.replace(MaxTest(value: 10))
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
                        try storage.replace(MaxTest(value: 4))
                        try storage.replace(MaxTest(value: 6))
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
                    result = try storage.max(\MaxTest.value)
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
                        try storage.replace(MaxTest(value: 0, nullableValue: 10))
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
                        try storage.replace(MaxTest(value: 0, nullableValue: 4))
                        try storage.replace(MaxTest(value: 0, nullableValue: 6))
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
                    result = try storage.max(\MaxTest.nullableValue)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<GroupConcatTest>(name: "group_concat_test",
                                                                      columns: Column(name: "value", keyPath: \GroupConcatTest.value, constraints: primaryKey()))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("error notMappedType", routine: {
                    do {
                        _ = try storage.count(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("error columnNotFound", routine: {
                    do {
                        _ = try storage.count(\GroupConcatTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        result = try storage.groupConcat(\GroupConcatTest.value, where_(equal(lhs: \GroupConcatTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        result = try storage.groupConcat(\GroupConcatTest.value, where_(\GroupConcatTest.value == 10))
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
                        try storage.replace(GroupConcatTest(value: 1))
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
                        try storage.replace(GroupConcatTest(value: 3))
                        try storage.replace(GroupConcatTest(value: 5))
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
                    result = try storage.groupConcat(\GroupConcatTest.value)
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
                        try storage.replace(GroupConcatTest(value: 3))
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
                        try storage.replace(GroupConcatTest(value: 3))
                        try storage.replace(GroupConcatTest(value: 5))
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
                    result = try storage.groupConcat(\GroupConcatTest.value, separator: "-")
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<CountTest>(name: "count_test",
                                                                columns: Column(name: "value", keyPath: \CountTest.value))])
            try storage.syncSchema(preserve: false)
            try section("error", routine: {
                try section("notMappedType", routine: {
                    do {
                        _ = try storage.count(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
                try section("columnNotFound", routine: {
                    do {
                        _ = try storage.count(\CountTest.unknown)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.storageCore.connection.dbMaybe!
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
                        count = try storage.count(\CountTest.value, where_(notEqual(lhs: \CountTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        count = try storage.count(\CountTest.value, where_(\CountTest.value != 10))
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
                        try storage.replace(CountTest(value: nil))
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
                        try storage.replace(CountTest(value: 10))
                        try storage.replace(CountTest(value: 20))
                        try storage.replace(CountTest(value: 30))
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
                    count = try storage.count(\CountTest.value)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<CountTest>(name: "count_test",
                                                                columns: Column(name: "value", keyPath: \CountTest.value))])
            try storage.syncSchema(preserve: false)
            try section("error notMapedType", routine: {
                do {
                    _ = try storage.count(all: Unknown.self)
                    XCTAssert(false)
                } catch SQLiteORM.Error.typeIsNotMapped {
                    XCTAssert(true)
                } catch {
                    XCTAssert(false)
                }
            })
            try section("no error", routine: {
                var expectedCount = 0
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                let db = storage.storageCore.connection.dbMaybe!
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
                        count = try storage.count(all: CountTest.self, where_(notEqual(lhs: \CountTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        count = try storage.count(all: CountTest.self, where_(\CountTest.value != 10))
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
                        try storage.replace(CountTest(value: 1))
                        try storage.replace(CountTest(value: 2))
                        try storage.replace(CountTest(value: 3))
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
                    count = try storage.count(all: CountTest.self)
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
            let storage = try Storage(filename: "",
                                      apiProvider: apiProvider,
                                      tables: [Table<AvgTest>(name: "avg_test",
                                                              columns: Column(name: "value", keyPath: \AvgTest.value))])
            try storage.syncSchema(preserve: false)
            try section("error") {
                try section("columnNotFound") {
                    do {
                        _ = try storage.avg(\AvgTest.unused)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.columnNotFound {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                }
                try section("notMapedType") {
                    do {
                        _ = try storage.avg(\Unknown.value)
                        XCTAssert(false)
                    } catch SQLiteORM.Error.typeIsNotMapped {
                        XCTAssert(true)
                    } catch {
                        XCTAssert(false)
                    }
                }
            }
            try section("no error") {
                let db = storage.storageCore.connection.dbMaybe!
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
                        avgValue = try storage.avg(\AvgTest.value, where_(lesserThan(lhs: \AvgTest.value, rhs: 10)))
                    })
                    try section("operator", routine: {
                        avgValue = try storage.avg(\AvgTest.value, where_(\AvgTest.value < 10))
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
                        try storage.replace(AvgTest(value: 1))
                        try storage.replace(AvgTest(value: 4))
                        try storage.replace(AvgTest(value: 10))
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
                    avgValue = try storage.avg(\AvgTest.value)
                })
                XCTAssertEqual(avgValue, expectedResult)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            }
        }
    }
}
