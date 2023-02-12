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

    var apiProvider: SQLiteApiProviderMock!

    func testEnumerated() throws {
        try testCase(#function, routine: {
            let storage = try Storage(filename: "",
                                      tables: [
                                        Table<User>(name: "users",
                                                    elements: [
                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                        Column(name: "name", keyPath: \User.name, constraints: notNull())
                                                    ])
                                        ])
            try storage.syncSchema(preserve: false)

            var expected = [User]()
            var users = [User]()

            let user1 = User(id: 1, name: "The Weeknd")
            let user2 = User(id: 2, name: "Post Malone")
            expected.append(user1)
            expected.append(user2)
            try storage.replace(user1)
            try storage.replace(user2)

            /*try section("enumerated", routine: {
                for userResult in storage.enumerated(User.self) {
                    switch userResult {
                    case .success(let user):
                        users.append(user)
                    case .failure(let error):
                        throw error
                    }
                }
            })*/
            try section("forEach", routine: {
                try storage.forEach(User.self) {
                    users.append($0)
                }
            })
            XCTAssert(compareUnordered(users, expected))
        })
    }
}
