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
    
    func testAvgColumnNotFound() throws {
        self.apiProvider.resetCalls()
        do {
            _ = try storage.avg(\AvgTest.unused)
            XCTAssert(false)
        }catch SQLiteORM.Error.columnNotFound{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testAvgNotMappedType() throws {
        self.apiProvider.resetCalls()
        do {
            _ = try storage.avg(\Unknown.value)
            XCTAssert(false)
        }catch SQLiteORM.Error.typeIsNotMapped{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testAvgComplex() throws {
        try storage.syncSchema(preserve: false)
        try self.storage.replace(object: AvgTest(value: 1))
        try self.storage.replace(object: AvgTest(value: 4))
        try self.storage.replace(object: AvgTest(value: 10))
        
        let db = self.storage.connection.dbMaybe!
        
        self.apiProvider.resetCalls()
        let avgValue = try self.storage.avg(\AvgTest.value)
        XCTAssertEqual(avgValue, Double(1 + 4 + 10) / 3)
        XCTAssertEqual(self.apiProvider.calls.count, 5)
        XCTAssertEqual(self.apiProvider.calls[0], .init(id: 0, callType: .sqlite3PrepareV2(db, "SELECT AVG(value) FROM avg_test", -1, ignorePointer, nil)))
        XCTAssertEqual(self.apiProvider.calls[1], .init(id: 1, callType: .sqlite3Step(ignorePointer2)))
        XCTAssertEqual(self.apiProvider.calls[2], .init(id: 2, callType: .sqlite3ColumnDouble(ignorePointer2, 0)))
        XCTAssertEqual(self.apiProvider.calls[3], .init(id: 3, callType: .sqlite3Step(ignorePointer2)))
        XCTAssertEqual(self.apiProvider.calls[4], .init(id: 4, callType: .sqlite3Finalize(ignorePointer2)))
    }
}
