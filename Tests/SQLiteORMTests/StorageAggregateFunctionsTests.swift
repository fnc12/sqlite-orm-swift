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
