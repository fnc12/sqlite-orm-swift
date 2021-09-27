import XCTest
@testable import SQLiteORM

class StorageAggregateFunctionsTests: XCTestCase {
    struct AvgTest: Initializable {
        var value = Double(0)
        var unused = Double(0)
    }
    
    struct Unknown {
        var value = Double(0)
    };
    
    var storage: Storage!
    var apiProvider: SQLiteApiProviderMock!
    let filename = ""
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.apiProvider.forwardsCalls = true
        self.storage = try Storage(filename: self.filename,
                                   apiProvider: self.apiProvider,
                                   tables: [Table<AvgTest>(name: "avg_test",
                                                           columns: Column(name: "value", keyPath: \AvgTest.value))])
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.apiProvider = nil
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
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        var count = try self.storage.count(\AvgTest.value)
        let db = self.storage.connection.dbMaybe!
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(value) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore)),
        ])
        
        try self.storage.replace(object: AvgTest(value: 1))
        count = try self.storage.count(\AvgTest.value)
        XCTAssertEqual(count, 1)
    }
    
    func testCountAll() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        var count = try self.storage.count(all: AvgTest.self)
        
        let db = self.storage.connection.dbMaybe!
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT COUNT(*) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore)),
        ])
        
        try self.storage.replace(object: AvgTest(value: 1))
        count = try self.storage.count(all: AvgTest.self)
        XCTAssertEqual(count, 1)
    }
    
    func testCountAllNotMappedType() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        do {
            _ = try self.storage.count(all: Unknown.self)
            XCTAssert(false)
        }catch SQLiteORM.Error.typeIsNotMapped{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testAvgColumnNotFound() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        do {
            _ = try self.storage.avg(\AvgTest.unused)
            XCTAssert(false)
        }catch SQLiteORM.Error.columnNotFound{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testAvgNotMappedType() throws {
        try self.storage.syncSchema(preserve: false)
        self.apiProvider.resetCalls()
        do {
            _ = try self.storage.avg(\Unknown.value)
            XCTAssert(false)
        }catch SQLiteORM.Error.typeIsNotMapped{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testAvgComplex() throws {
        try self.storage.syncSchema(preserve: false)
        try self.storage.replace(object: AvgTest(value: 1))
        try self.storage.replace(object: AvgTest(value: 4))
        try self.storage.replace(object: AvgTest(value: 10))
        
        let db = self.storage.connection.dbMaybe!
        
        self.apiProvider.resetCalls()
        let avgValue = try self.storage.avg(\AvgTest.value)
        XCTAssertEqual(avgValue, Double(1 + 4 + 10) / 3)
        XCTAssertEqual(self.apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT AVG(value) FROM avg_test", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnDouble(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore)),
        ])
    }
}
