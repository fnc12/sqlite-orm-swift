import XCTest
@testable import sqlite_orm_swift

class ConnectionRefTests: XCTestCase {
    var connectionHolder: ConnectionHolderMock!
    let db = OpaquePointer(bitPattern: 1)!
    var apiProvider: SQLiteApiProviderMock!
    
    let filename = "db.sqlite"
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.connectionHolder = .init(dbMaybe: self.db, apiProvider: self.apiProvider, filename: self.filename)
    }

    override func tearDownWithError() throws {
        self.connectionHolder = nil
        self.apiProvider = nil
    }
    
    func testPrepareWithNullStatementError() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let sql = "SELECT * FROM all_humans"
        let stmt = OpaquePointer(bitPattern: 1)!
        self.apiProvider.sqlite3PrepareV2StmtToAssign = stmt
        let statement = try connectionRef.prepare(sql: sql)
        XCTAssertEqual(statement.stmt, stmt)
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls[0].callType {
        case .sqlite3PrepareV2(let db, _, _, _, _):
            XCTAssertEqual(db, self.db)
        default:
            XCTAssert(false)
        }
    }
    
    func testPrepareWithSQLiteError() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let sql = "SELECT * FROM all_humans"
        self.apiProvider.sqlite3PrepareV2ToReturn = 1
        do {
            _ = try connectionRef.prepare(sql: sql)
            XCTAssert(false)
        }catch sqlite_orm_swift.Error.sqliteError(let code, _){
            XCTAssertEqual(code, 1)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testPrepareDbNil() throws {
        self.connectionHolder = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let sql = "SELECT * FROM all_humans"
        do {
            _ = try connectionRef.prepare(sql: sql)
            XCTAssert(false)
        }catch sqlite_orm_swift.Error.databaseIsNull {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        XCTAssertEqual(self.apiProvider.calls, [])
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testErrorMessage() throws {
        let errorString = NSString(string: "error")
        self.apiProvider.sqlite3ErrmsgToReturn = errorString.utf8String
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "error")
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testErrorMessageCStringNil() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testErrorMessageDbNil() throws {
        self.connectionHolder = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testLastInsertRowid() throws {
        XCTAssertEqual(self.apiProvider.calls, [])
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        _ = connectionRef.lastInsertRowid
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: 0, callType: .sqlite3LastInsertRowid(self.db))])
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testDb() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolder)
        let db = connectionRef.db
        XCTAssertEqual(db, self.db)
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
    }
    
    func testCtorAndDtor() throws {
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
        var connectionRef: ConnectionRef? = try ConnectionRef(connection: self.connectionHolder)
        _ = connectionRef
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 0)
        
        connectionRef = nil
        XCTAssertEqual(self.connectionHolder.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolder.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolder.decrementUnsafeCallsCount, 1)
    }

}
