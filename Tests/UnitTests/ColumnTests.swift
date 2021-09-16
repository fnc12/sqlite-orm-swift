import XCTest
@testable import sqlite_orm_swift

class ColumnTests: XCTestCase {
    struct User {
        var id = 0
        var name = ""
        var idMaybe: Int?
        var nameMaybe: String?
    }
    struct Visit {
        var id = 0
    }
    
    var intColumn: Column<User, Int>!
    var stringColumn: Column<User, String>!
    var intOptionalColumn: Column<User, Int?>!
    var stringOptionalColumn: Column<User, String?>!
    
    var statementMock: StatementMock!
    
    override func setUpWithError() throws {
        self.intColumn = Column(name: "id", keyPath: \User.id)
        self.stringColumn = Column(name: "name", keyPath: \User.name)
        self.intOptionalColumn = Column(name: "identifier", keyPath: \User.idMaybe)
        self.stringOptionalColumn = Column(name: "name", keyPath: \User.nameMaybe)
        self.statementMock = .init()
    }
    
    override func tearDownWithError() throws {
        self.statementMock = nil
        self.stringOptionalColumn = nil
        self.intOptionalColumn = nil
        self.stringColumn = nil
        self.intColumn = nil
    }
    
    func testBind() throws {
        for index in 1..<10 {
            for value in 0..<10 {
                
                //  bind int
                self.statementMock = .init()
                var user = User()
                user.id = value
                _ = try self.intColumn.bind(statement: self.statementMock, object: user, index: index)
                XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindInt(value: value, index: index))])
                
                //  bind nullable int
                self.statementMock = .init()
                user.idMaybe = value
                _ = try self.intOptionalColumn.bind(statement: self.statementMock, object: user, index: index)
                XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindInt(value: value, index: index))])
                
                //  bind null as int
                self.statementMock = .init()
                user.idMaybe = nil
                _ = try self.intOptionalColumn.bind(statement: self.statementMock, object: user, index: index)
                XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindNull(index: index))])

            }
            
            //  bind string
            self.statementMock = .init()
            var user = User(id: 0, name: "Rachel")
            _ = try self.stringColumn.bind(statement: self.statementMock, object: user, index: index)
            XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindText(value: user.name, index: index))])
            
            //  bind nullable string
            self.statementMock = .init()
            user.nameMaybe = "One"
            _ = try self.stringOptionalColumn.bind(statement: self.statementMock, object: user, index: index)
            XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindText(value: "One", index: index))])
            
            //  bind null as string
            self.statementMock = .init()
            user.nameMaybe = nil
            _ = try self.stringOptionalColumn.bind(statement: self.statementMock, object: user, index: index)
            XCTAssertEqual(self.statementMock.calls, [StatementMock.Call(id: 0, callType: .bindNull(index: index))])
        }
    }
    
    func testBindThrowTypeMismatch() throws {
        let visit = Visit(id: 10)
        do {
            _ = try self.intColumn.bind(statement: self.statementMock, object: visit, index: 1)
        }catch sqlite_orm_swift.Error.typeMismatch{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        
    }
}
