import XCTest
@testable import SQLiteORM

class ConnectionRefTests: XCTestCase {
    var connectionHolderMock: ConnectionHolderMock!
    let db = OpaquePointer(bitPattern: 1)!
    var apiProvider: SQLiteApiProviderMock!
    
    let filename = "db.sqlite"
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.connectionHolderMock = .init(dbMaybe: self.db, apiProvider: self.apiProvider, filename: self.filename)
    }

    override func tearDownWithError() throws {
        self.connectionHolderMock = nil
        self.apiProvider = nil
    }
    
    func testPrepareWithNullStatementError() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        let stmt = OpaquePointer(bitPattern: 1)!
        self.apiProvider.sqlite3PrepareV2StmtToAssign = stmt
        let statement = try connectionRef.prepare(sql: sql)
        XCTAssertEqual((statement as! StatementImpl).stmt, stmt)
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls[0].callType {
        case .sqlite3PrepareV2(let db, _, _, _, _):
            XCTAssertEqual(db, self.db)
        default:
            XCTAssert(false)
        }
    }
    
    func testPrepareWithSQLiteError() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        self.apiProvider.sqlite3PrepareV2ToReturn = 1
        do {
            _ = try connectionRef.prepare(sql: sql)
            XCTAssert(false)
        }catch SQLiteORM.Error.sqliteError(let code, _){
            XCTAssertEqual(code, 1)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testPrepareDbNil() throws {
        self.connectionHolderMock = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        do {
            _ = try connectionRef.prepare(sql: sql)
            XCTAssert(false)
        }catch SQLiteORM.Error.databaseIsNull {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        XCTAssertEqual(self.apiProvider.calls, [])
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
    }
    
    func testErrorMessage() throws {
        for errorMessage in ["error", "some"] {
            self.connectionHolderMock = .init(dbMaybe: self.db, apiProvider: self.apiProvider, filename: self.filename)
            let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
            self.connectionHolderMock.errorMessage = errorMessage
            let errorMessage = connectionRef.errorMessage
            XCTAssertEqual(errorMessage, errorMessage)
            XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
            XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
            XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
        }
    }
    
    func testErrorMessageCStringNil() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
    }
    
    func testErrorMessageDbNil() throws {
        self.connectionHolderMock = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
    }
    
    func testLastInsertRowid() throws {
        XCTAssertEqual(self.apiProvider.calls, [])
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        _ = connectionRef.lastInsertRowid
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderCall(id: 0, callType: .sqlite3LastInsertRowid(self.db))])
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
    }
    
    func testDb() throws {
        let connectionRef = try ConnectionRef(connection: self.connectionHolderMock)
        let db = connectionRef.db
        XCTAssertEqual(db, self.db)
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
    }
    
    func testCtorAndDtor() throws {
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
        var connectionRef: ConnectionRef? = try ConnectionRef(connection: self.connectionHolderMock)
        _ = connectionRef
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 0)
        
        connectionRef = nil
        XCTAssertEqual(self.connectionHolderMock.incrementCallsCount, 1)
        XCTAssertEqual(self.connectionHolderMock.decrementCallsCount, 0)
        XCTAssertEqual(self.connectionHolderMock.decrementUnsafeCallsCount, 1)
    }

}
