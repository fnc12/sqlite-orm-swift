import XCTest
import SQLiteORM_Swift

func compareUnordered<T>(_ lhs: Array<T>, _ rhs: Array<T>) -> Bool where T: Equatable {
    guard lhs.count == rhs.count else {
        return false
    }
    for item in lhs {
        guard rhs.contains(where: { $0 == item }) else {
            return false
        }
    }
    return true
}

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
    
    override func setUpWithError() throws {
        storage = try Storage(filename: "",
                              tables: Table<User>(name: "users",
                                                  columns:
                                                    Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                    Column(name: "name", keyPath: \User.name, constraints: notNull())))
    }

    override func tearDownWithError() throws {
        storage = nil
    }

    func testGetAllThrowTypeIsNotMapped() throws {
        try storage.syncSchema(preserve: true)
        
        do {
            var visits: [Visit] = try storage.getAll()
            XCTAssert(false)
            visits.removeAll()
        }catch SQLiteORM_Swift.Error.typeIsNotMapped {
            XCTAssert(true)
        }catch{
            XCTAssert(false)
        }
    }
    
    func testGet() throws {
        do {
            let _: User? = try storage.get(id: 1)
            XCTAssert(false)
        }catch SQLiteORM_Swift.Error.sqliteError(_, _) {
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
        remove(storage.filename)
        try storage.syncSchema(preserve: true)
        
        var bebeRexha = User(id: 0, name: "Bebe Rexha")
        let bebeRexhaId = try storage.insert(object: bebeRexha)
        
        XCTAssertEqual(bebeRexhaId, 1)
        
        bebeRexha.id = Int(bebeRexhaId)
        
        var allUsers: [User] = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])
        
        var arianaGrande = User(id: 0, name: "Ariana Grande")
        let arianaGrandeId = try storage.insert(object: arianaGrande)
        
        XCTAssertEqual(arianaGrandeId, 2)
        
        arianaGrande.id = Int(arianaGrandeId)
        
        allUsers = try storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
    }

}
