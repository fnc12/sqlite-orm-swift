import XCTest
@testable import SQLiteORM

class StorageAggregateFunctionsTests: XCTestCase {
    struct AvgTest: Initializable {
        var value = Double(0)
        var unused = Double(0)
    }
    
    struct StructWithNullable: Initializable {
        var value: Int?
    }
    
    struct Unknown {
        var value = Double(0)
    };
    
    var storage: Storage!
    var storageWithNullable: Storage!
    var apiProvider: SQLiteApiProviderMock!
    let filename = ""
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.apiProvider.forwardsCalls = true
        self.storage = try Storage(filename: self.filename,
                                   apiProvider: self.apiProvider,
                                   tables: [Table<AvgTest>(name: "avg_test",
                                                           columns: Column(name: "value", keyPath: \AvgTest.value))])
        self.storageWithNullable = try Storage(filename: self.filename,
                                               apiProvider: self.apiProvider,
                                               tables: [Table<StructWithNullable>(name: "max_test", columns: Column(name: "value", keyPath: \StructWithNullable.value))])
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.apiProvider = nil
    }
    
    func testMaxNullableNil() throws {
        
    }
    
    func testMaxNotNil() throws {
        try self.storage.syncSchema(preserve: false)
        try self.storage.replace(object: AvgTest(value: 1))
        try self.storage.replace(object: AvgTest(value: 2))
        try self.storage.replace(object: AvgTest(value: 3))
        self.apiProvider.resetCalls()
        let max = try self.storage.max(\AvgTest.value)
        XCTAssertEqual(max, 3)
    }
    
    func testMaxNil() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        let max = try self.storage.max(\AvgTest.value)
        let db = self.storage.connection.dbMaybe!
        XCTAssertEqual(max, nil)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT MAX(value) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
            .init(id: 4, callType: .sqlite3Step(.ignore)),
            .init(id: 5, callType: .sqlite3Finalize(.ignore)),
        ])
    }
    
    func testGroupConcatNotMappedType() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        do {
            _ = try self.storage.groupConcat(\Unknown.value)
            XCTAssert(false)
        }catch SQLiteORM.Error.typeIsNotMapped{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testGroupConcatColumnNotFound() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        do {
            _ = try self.storage.groupConcat(\AvgTest.unused)
            XCTAssert(false)
        }catch SQLiteORM.Error.columnNotFound{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testGroupConcat2ArgumentsNotNil() throws {
        try self.storage.syncSchema(preserve: false)
        try self.storage.replace(object: AvgTest(value: 6))
        try self.storage.replace(object: AvgTest(value: 1))
        self.apiProvider.resetCalls()
        let result = try self.storage.groupConcat(\AvgTest.value, separator: "-")
        let db = self.storage.connection.dbMaybe!
        XCTAssert(result == "6.0-1.0" || result == "1.0-6.0")
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT GROUP_CONCAT(value, '-') FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
            .init(id: 5, callType: .sqlite3Step(.ignore)),
            .init(id: 6, callType: .sqlite3Finalize(.ignore)),
        ])
    }
    
    func testGroupConcat2ArgumentsNil() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        let result = try self.storage.groupConcat(\AvgTest.value, separator: "-")
        let db = self.storage.connection.dbMaybe!
        XCTAssertEqual(result, nil)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT GROUP_CONCAT(value, '-') FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
            .init(id: 4, callType: .sqlite3Step(.ignore)),
            .init(id: 5, callType: .sqlite3Finalize(.ignore)),
        ])
    }
    
    func testGroupConcat1ArgumentNotNil() throws {
        try self.storage.syncSchema(preserve: false)
        try self.storage.replace(object: AvgTest(value: 6))
        self.apiProvider.resetCalls()
        let result = try self.storage.groupConcat(\AvgTest.value)
        let db = self.storage.connection.dbMaybe!
        
        XCTAssertEqual(result, "6.0")
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT GROUP_CONCAT(value) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
            .init(id: 4, callType: .sqlite3ValueText(.ignore)),
            .init(id: 5, callType: .sqlite3Step(.ignore)),
            .init(id: 6, callType: .sqlite3Finalize(.ignore)),
        ])
    }
    
    func testGroupConcat1ArgumentNil() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        let result = try self.storage.groupConcat(\AvgTest.value)
        let db = self.storage.connection.dbMaybe!
        
        XCTAssertEqual(result, nil)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT GROUP_CONCAT(value) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
            .init(id: 3, callType: .sqlite3ValueType(.ignore)),
            .init(id: 4, callType: .sqlite3Step(.ignore)),
            .init(id: 5, callType: .sqlite3Finalize(.ignore)),
        ])
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
                    }catch SQLiteORM.Error.typeIsNotMapped{
                        XCTAssert(true)
                    }catch{
                        XCTAssert(false)
                    }
                })
                try section("columnNotFound", routine: {
                    do {
                        _ = try storage.count(\CountTest.unknown)
                        XCTAssert(false)
                    }catch SQLiteORM.Error.columnNotFound{
                        XCTAssert(true)
                    }catch{
                        XCTAssert(false)
                    }
                })
            })
            try section("no error", routine: {
                let db = storage.connection.dbMaybe!
                var expectedCount = 0
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                try section("no rows", routine: {
                    expectedCount = 0
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(value) FROM count_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                    ]
                })
                try section("one row with null", routine: {
                    try storage.replace(object: CountTest(value: nil))
                    expectedCount = 0
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(value) FROM count_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                    ]
                })
                try section("three rows without null", routine: {
                    try storage.replace(object: CountTest(value: 10))
                    try storage.replace(object: CountTest(value: 20))
                    try storage.replace(object: CountTest(value: 30))
                    expectedCount = 3
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(value) FROM count_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                    ]
                })
                apiProvider.resetCalls()
                let count = try storage.count(\CountTest.value)
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
                }catch SQLiteORM.Error.typeIsNotMapped{
                    XCTAssert(true)
                }catch{
                    XCTAssert(false)
                }
            })
            try section("no error", routine: {
                var expectedCount = 0
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                let db = storage.connection.dbMaybe!
                try section("no rows", routine: {
                    expectedCount = 0
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(*) FROM count_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                    ]
                })
                try section("3 rows", routine: {
                    try storage.replace(object: CountTest(value: 1))
                    try storage.replace(object: CountTest(value: 2))
                    try storage.replace(object: CountTest(value: 3))
                    expectedCount = 3
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(*) FROM count_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3Step(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                    ]
                })
                apiProvider.resetCalls()
                let count = try storage.count(all: CountTest.self)
                XCTAssertEqual(count, expectedCount)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            })
        })
    }
    
    func testAvg() throws {
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
                    }catch SQLiteORM.Error.columnNotFound{
                        XCTAssert(true)
                    }catch{
                        XCTAssert(false)
                    }
                }
                try section("notMapedType") {
                    do {
                        _ = try storage.avg(\Unknown.value)
                        XCTAssert(false)
                    }catch SQLiteORM.Error.typeIsNotMapped{
                        XCTAssert(true)
                    }catch{
                        XCTAssert(false)
                    }
                }
            }
            try section("no error") {
                let db = storage.connection.dbMaybe!
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                var expectedResult: Double? = nil
                try section("insert nothing") {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT AVG(value) FROM avg_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3Step(.ignore)),
                        .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    ]
                    expectedResult = nil
                }
                try section("insert something", routine: {
                    try storage.replace(object: AvgTest(value: 1))
                    try storage.replace(object: AvgTest(value: 4))
                    try storage.replace(object: AvgTest(value: 10))
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT AVG(value) FROM avg_test", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnValue(.ignore, 0)),
                        .init(id: 3, callType: .sqlite3ValueType(.ignore)),
                        .init(id: 4, callType: .sqlite3ValueDouble(.ignore)),
                        .init(id: 5, callType: .sqlite3Step(.ignore)),
                        .init(id: 6, callType: .sqlite3Finalize(.ignore)),
                    ]
                    expectedResult = Double(1 + 4 + 10) / 3
                })
                apiProvider.resetCalls()
                let avgValue = try storage.avg(\AvgTest.value)
                XCTAssertEqual(avgValue, expectedResult)
                XCTAssertEqual(apiProvider.calls, expectedCalls)
            }
        }
    }
}
