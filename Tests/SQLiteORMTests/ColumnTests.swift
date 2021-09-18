import XCTest
@testable import SQLiteORM

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
    
    var sqliteValueMock: SQLiteValueMock!
    var binderMock: BinderMock!
    
    override func setUpWithError() throws {
        self.intColumn = Column(name: "id", keyPath: \User.id)
        self.stringColumn = Column(name: "name", keyPath: \User.name)
        self.intOptionalColumn = Column(name: "identifier", keyPath: \User.idMaybe)
        self.stringOptionalColumn = Column(name: "name", keyPath: \User.nameMaybe)
        self.sqliteValueMock = .init()
        self.binderMock = .init()
    }
    
    override func tearDownWithError() throws {
        self.binderMock = nil
        self.sqliteValueMock = nil
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
        self.sqliteValueMock.integer = 5
        self.sqliteValueMock.isNull = false
        user.idMaybe = nil
        try self.intOptionalColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.idMaybe, 5)
        
        //  bind nil as int optional
        self.sqliteValueMock = .init()
        self.sqliteValueMock.isNull = true
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
        self.sqliteValueMock.text = "The Offspring"
        self.sqliteValueMock.isNull = false
        user.nameMaybe = nil
        try self.stringOptionalColumn.assign(object: &user, sqliteValue: self.sqliteValueMock)
        XCTAssertEqual(user.nameMaybe, "The Offspring")
    }
    
    func testAssignThrowUnknownType() throws {
        var visit = Visit()
        do {
            try self.intOptionalColumn.assign(object: &visit, sqliteValue: self.sqliteValueMock)
            XCTAssert(false)
        }catch SQLiteORM.Error.unknownType {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testBind() throws {
        for value in 0..<10 {
            
            //  bind int
            self.binderMock = .init()
            var user = User()
            user.id = value
            _ = try self.intColumn.bind(binder: self.binderMock, object: user)
            XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindInt(value: value))])
            
            //  bind nullable int
            self.binderMock = .init()
            user.idMaybe = value
            _ = try self.intOptionalColumn.bind(binder: self.binderMock, object: user)
            XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindInt(value: value))])
            
            //  bind null as int
            self.binderMock = .init()
            user.idMaybe = nil
            _ = try self.intOptionalColumn.bind(binder: self.binderMock, object: user)
            XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindNull)])

        }
        
        //  bind string
        self.binderMock = .init()
        var user = User(id: 0, name: "Rachel")
        _ = try self.stringColumn.bind(binder: self.binderMock, object: user)
        XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindText(value: "Rachel"))])
        
        //  bind nullable string
        self.binderMock = .init()
        user.nameMaybe = "One"
        _ = try self.stringOptionalColumn.bind(binder: self.binderMock, object: user)
        XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindText(value: "One"))])
        
        //  bind null as string
        self.binderMock = .init()
        user.nameMaybe = nil
        _ = try self.stringOptionalColumn.bind(binder: self.binderMock, object: user)
        XCTAssertEqual(self.binderMock.calls, [BinderMock.Call(id: 0, callType: .bindNull)])
    }
    
    func testBindThrowUnknownType() throws {
        let visit = Visit(id: 10)
        do {
            _ = try self.intColumn.bind(binder: self.binderMock, object: visit)
            XCTAssert(false)
        }catch SQLiteORM.Error.unknownType{
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        
    }
}
