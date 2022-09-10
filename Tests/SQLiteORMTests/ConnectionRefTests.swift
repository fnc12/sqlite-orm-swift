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

    func testExec() throws {
        let sql = "BEGIN TRANSACTION"
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        switch connectionRef.exec(sql: sql) {
        case .success():
            XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(self.db, sql, nil, nil, nil))])
        case .failure(let error):
            throw error
        }
    }

    func testPrepareWithNullStatementError() throws {
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        let stmt = OpaquePointer(bitPattern: 1)!
        self.apiProvider.sqlite3PrepareV2StmtToAssign = stmt
        switch connectionRef.prepare(sql: sql) {
        case .success(let statement):
            XCTAssertEqual((statement as! StatementImpl).stmt, stmt)
            XCTAssertEqual(self.apiProvider.calls, [
                SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3PrepareV2(.value(self.db), "SELECT * FROM all_humans", -1, .ignore, nil))
            ])
        case .failure(let error):
            throw error
        }
    }

    func testPrepareWithSQLiteError() throws {
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        self.apiProvider.sqlite3PrepareV2ToReturn = 1
        switch connectionRef.prepare(sql: sql) {
        case .success(_):
            XCTAssert(false)
        case .failure(let error):
            switch error {
            case SQLiteORM.Error.sqliteError(let code, _):
                XCTAssertEqual(code, 1)
            default:
                XCTAssert(false)
            }
        }
    }

    func testPrepareDbNil() throws {
        self.connectionHolderMock = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let sql = "SELECT * FROM all_humans"
        switch connectionRef.prepare(sql: sql) {
        case .success(_):
            XCTAssert(false)
        case .failure(let error):
            switch error {
            case SQLiteORM.Error.databaseIsNull:
                XCTAssertEqual(self.apiProvider.calls, [])
                XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
            default:
                XCTAssert(false)
            }
        }
    }

    func testErrorMessage() throws {
        for errorMessage in ["error", "some"] {
            self.connectionHolderMock = .init(dbMaybe: self.db, apiProvider: self.apiProvider, filename: self.filename)
            let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
            self.connectionHolderMock.errorMessage = errorMessage
            let errorMessage = connectionRef.errorMessage
            XCTAssertEqual(errorMessage, errorMessage)
            XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
        }
    }

    func testErrorMessageCStringNil() throws {
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
    }

    func testErrorMessageDbNil() throws {
        self.connectionHolderMock = .init(dbMaybe: nil, apiProvider: self.apiProvider, filename: self.filename)
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let errorMessage = connectionRef.errorMessage
        XCTAssertEqual(errorMessage, "")
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
    }

    func testLastInsertRowid() throws {
        XCTAssertEqual(self.apiProvider.calls, [])
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        _ = connectionRef.lastInsertRowid
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3LastInsertRowid(.value(self.db)))])
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
    }

    func testDb() throws {
        let connectionRef = SafeConnectionRef(connection: self.connectionHolderMock)
        let db = connectionRef.db
        XCTAssertEqual(db, self.db)
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])
    }

    func testCtorAndDtor() throws {
        XCTAssertEqual(self.connectionHolderMock.calls, [])
        var connectionRef: SafeConnectionRef? = SafeConnectionRef(connection: self.connectionHolderMock)
        _ = connectionRef
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment)])

        connectionRef = nil
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                         ConnectionHolderMock.Call(id: 1, callType: .decrementUnsafe)])
    }

}
