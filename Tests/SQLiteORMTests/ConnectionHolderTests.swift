import XCTest
@testable import SQLiteORM

class ConnectionHolderTests: XCTestCase {
    let dbPointer = OpaquePointer(bitPattern: 1)!
    let filename = ""
    var apiProvider: SQLiteApiProviderMock!
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
    }
    
    override func tearDownWithError() throws {
        self.apiProvider = nil
    }
    
    func testIncrement() throws {
        let connectionHolder = ConnectionHolderImpl(filename: self.filename, apiProvider: self.apiProvider)
        self.apiProvider.sqlite3OpenDbToAssign = dbPointer
        self.apiProvider.sqlite3OpenToReturn = self.apiProvider.SQLITE_OK
        try connectionHolder.increment()
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls.first!.callType {
        case .sqlite3Open(_, _):
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
    
    func testIncrementWithSQLiteError() throws {
        let connectionHolder = ConnectionHolderImpl(filename: self.filename, apiProvider: self.apiProvider)
        self.apiProvider.sqlite3OpenDbToAssign = dbPointer
        self.apiProvider.sqlite3OpenToReturn = 1
        do {
            try connectionHolder.increment()
            XCTAssert(false)
        }catch SQLiteORM.Error.sqliteError(let code, _) {
            XCTAssertEqual(code, 1)
        }catch{
            XCTAssert(false)
        }
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls.first!.callType {
        case .sqlite3Open(let filename, _):
            let nsFilename = NSString(string: self.filename)
            XCTAssertEqual(strcmp(nsFilename.utf8String, filename), 0)
        default:
            XCTAssert(false)
        }
    }
    
    func testIncrementWithDbNil() throws {
        let connectionHolder = ConnectionHolderImpl(filename: self.filename, apiProvider: self.apiProvider)
        do {
            try connectionHolder.increment()
            XCTAssert(false)
        }catch SQLiteORM.Error.databaseIsNull {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls.first!.callType {
        case .sqlite3Open(let filename, _):
            let nsFilename = NSString(string: self.filename)
            XCTAssertEqual(strcmp(nsFilename.utf8String, filename), 0)
        default:
            XCTAssert(false)
        }
    }
    
    func testErrorMessageWithDbNil() {
        let errorString = NSString(string: "error")
        self.apiProvider.sqlite3ErrmsgToReturn = errorString.utf8String
        let connectionHolder = ConnectionHolderImpl(filename: self.filename, apiProvider: self.apiProvider)
        let errorMessage = connectionHolder.errorMessage
        XCTAssertEqual(errorMessage, "")
    }
}
