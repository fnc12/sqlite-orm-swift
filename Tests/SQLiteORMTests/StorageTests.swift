import XCTest
@testable import SQLiteORM

class StorageTests: XCTestCase {
    struct User: Initializable, Equatable {
        var id = 0
        var name = ""
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
    
    struct Visit: Initializable {
        var id = 0
    }
    
    var storage: Storage!
    var apiProvider: SQLiteApiProviderMock!
    
    override func setUpWithError() throws {
        self.storage = try Storage(filename: "",
                                   tables: Table<User>(name: "users",
                                                       columns:
                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                        Column(name: "name", keyPath: \User.name, constraints: notNull())))
        self.apiProvider = .init()
    }

    override func tearDownWithError() throws {
        self.apiProvider = nil
        self.storage = nil
    }
    
    func testFilename() throws {
        self.apiProvider.forwardsCalls = true
        struct TestCase {
            let filename: String
        }
        let testCases = [
            TestCase(filename: "ototo"),
            TestCase(filename: ""),
            TestCase(filename: ":memory:"),
            TestCase(filename: "db.sqlite"),
            TestCase(filename: "company.db"),
        ]
        for testCase in testCases {
            let storage = try Storage(filename: testCase.filename, apiProvider: self.apiProvider, tables: [])
            XCTAssertEqual(storage.filename, testCase.filename)
        }
    }
    
    func testCtorFile() throws {
        self.apiProvider.forwardsCalls = true
        let storage = try Storage(filename: "db.sqlite",
                                  apiProvider: apiProvider,
                                  tables: [])
        _ = storage
        XCTAssertEqual(self.apiProvider.calls.count, 0)
    }
    
    func testCtorDtorInMemory() throws {
        self.apiProvider.forwardsCalls = true
        var storage: Storage? = try Storage(filename: "",
                                            apiProvider: self.apiProvider,
                                            tables: [])
        _ = storage
        XCTAssertEqual(self.apiProvider.calls.count, 1)
        switch self.apiProvider.calls[0].callType {
        case .sqlite3Open(let filename, _):
            XCTAssertEqual(filename, "")
        default:
            XCTAssert(false)
        }
        
        storage = nil
        XCTAssertEqual(self.apiProvider.calls.count, 2)
        switch self.apiProvider.calls[1].callType {
        case .sqlite3Close(_):
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testGetAllThrowTypeIsNotMapped() throws {
        try storage.syncSchema(preserve: true)
        
        do {
            var visits: [Visit] = try storage.getAll()
            XCTAssert(false)
            visits.removeAll()
        }catch SQLiteORM.Error.typeIsNotMapped {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testGet() throws {
        do {
            let _: User? = try storage.get(id: 1)
            XCTAssert(false)
        }catch SQLiteORM.Error.sqliteError(_, _) {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
        try storage.syncSchema(preserve: true)
        
        try storage.replace(object: User(id: 1, name: "Bebe Rexha"))
        let bebeRexhaMaybe: User? = try storage.get(id: 1)
        XCTAssertEqual(bebeRexhaMaybe, User(id: 1, name: "Bebe Rexha"))
        
        for id in 2..<10 {
            let user: User? = try storage.get(id: id)
            XCTAssert(user == nil)
        }
    }
    
    func testUpdate() throws {
        try storage.syncSchema(preserve: true)
        var bebeRexha = User(id: 1, name: "Bebe Rexha")
        try storage.replace(object: bebeRexha)
        var allUsers: [User] = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])
        
        bebeRexha.name = "Ariana Grande"
        try storage.update(object: bebeRexha)
        allUsers = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])
    }
    
    func testDelete() throws {
        try storage.syncSchema(preserve: true)
        
        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        let arianaGrande = User(id: 2, name: "Ariana Grande")
        try storage.replace(object: bebeRexha)
        try storage.replace(object: arianaGrande)
        var allUsers: [User] = try storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
        
        try storage.delete(object: bebeRexha)
        allUsers = try storage.getAll()
        XCTAssert(allUsers == [arianaGrande])
    }
    
    func testTableExists() throws {
        XCTAssertFalse(try storage.tableExists(with: "users"))
        XCTAssertFalse(try storage.tableExists(with: "visits"))
        
        try storage.syncSchema(preserve: true)
        
        XCTAssertTrue(try storage.tableExists(with: "users"))
        XCTAssertFalse(try storage.tableExists(with: "visits"))
    }
    
    func testReplace() throws {
        try storage.syncSchema(preserve: true)
        
        var allUsers: [User] = try storage.getAll()
        XCTAssertTrue(allUsers.isEmpty)
        
        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        try storage.replace(object: bebeRexha)
        
        allUsers = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])
        
        let arianaGrande = User(id: 2, name: "Ariana Grande")
        try storage.replace(object: arianaGrande)
        
        allUsers = try storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
    }
    
    func testInsert() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            var inMemory = false
            try section("in memory", routine: {
                inMemory = true
            })
            try section("in file", routine: {
                inMemory = false
            })
            
            let filename: String
            if inMemory {
                filename = ""
            }else{
                filename = "test_storage.sqlite"
                remove(filename)
            }
            let storage = try Storage(filename: filename,
                                      apiProvider: apiProvider,
                                      tables: [Table<User>(name: "users",
                                                           columns:
                                                            Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                            Column(name: "name", keyPath: \User.name, constraints: notNull()))])
            try storage.syncSchema(preserve: false)
            
            var bebeRexha = User(id: 0, name: "Bebe Rexha")
            apiProvider.resetCalls()
            let bebeRexhaId = try storage.insert(object: bebeRexha)
            XCTAssertEqual(bebeRexhaId, 1)
            var expectedCalls = [SQLiteApiProviderMock.Call]()
            if !inMemory {
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore)),
                ]
            }else{
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                ]
            }
            XCTAssertEqual(apiProvider.calls, expectedCalls)
            bebeRexha.id = Int(bebeRexhaId)
            
            var allUsers: [User] = try storage.getAll()
            XCTAssertEqual(allUsers, [bebeRexha])
            
            var arianaGrande = User(id: 0, name: "Ariana Grande")
            apiProvider.resetCalls()
            let arianaGrandeId = try storage.insert(object: arianaGrande)
            if !inMemory {
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore)),
                ]
            }else{
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                ]
            }
            XCTAssertEqual(apiProvider.calls, expectedCalls)
            XCTAssertEqual(arianaGrandeId, 2)
            
            arianaGrande.id = Int(arianaGrandeId)
            
            allUsers = try storage.getAll()
            XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
        })
    }
}
