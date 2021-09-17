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
    var sqliteValueMock: SQLiteValueMock!
    
    override func setUpWithError() throws {
        self.intColumn = Column(name: "id", keyPath: \User.id)
        self.stringColumn = Column(name: "name", keyPath: \User.name)
        self.intOptionalColumn = Column(name: "identifier", keyPath: \User.idMaybe)
        self.stringOptionalColumn = Column(name: "name", keyPath: \User.nameMaybe)
        self.statementMock = .init()
        self.sqliteValueMock = .init()
    }
    
    override func tearDownWithError() throws {
        self.sqliteValueMock = nil
        self.statementMock = nil
        self.stringOptionalColumn = nil
        self.intOptionalColumn = nil
        self.stringColumn = nil
        self.intColumn = nil
    }
    
    func testAssign() throws {
        var user = User()
        
        //  bind int
        self.sqliteValueMock = .init()
        self.sqliteValueMock.integer = 10
        user.id = 0
        try self.intColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.id, 10)
        
        //  bind int optional
        self.sqliteValueMock = .init()
        self.sqliteValueMock.integerMaybe = 5
        user.idMaybe = nil
        try self.intOptionalColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.idMaybe, 5)
        
        //  bind nil as int optional
        self.sqliteValueMock = .init()
        self.sqliteValueMock.integerMaybe = nil
        user.idMaybe = 10
        try self.intOptionalColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.idMaybe, nil)
        
        //  bind string
        self.sqliteValueMock = .init()
        self.sqliteValueMock.text = "Keri Hilson"
        user.name = ""
        try self.stringColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.name, "Keri Hilson")
        
        //  bind string optional
        self.sqliteValueMock = .init()
        self.sqliteValueMock.textMaybe = "The Offspring"
        user.nameMaybe = nil
        try self.stringOptionalColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.nameMaybe, "The Offspring")
    }
    
    func testAssignThrowUnknownType() throws {
        var visit = Visit()
        do {
            try self.intOptionalColumn.assign(object: &visit, sqliteValue: self.sqliteValueMock)
            XCTAssert(false)
        }catch sqlite_orm_swift.Error.unknownType {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
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
    
    func testBindThrowUnknownType() throws {
        let visit = Visit(id: 10)
        do {
            _ = try self.intColumn.bind(statement: self.statementMock, object: visit, index: 1)
            XCTAssert(false)
        }catch sqlite_orm_swift.Error.unknownType{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        
    }
}
