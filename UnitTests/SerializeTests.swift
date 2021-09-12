import XCTest
@testable import SQLiteORM_Swift

class SerializeTests: XCTestCase {
    
    struct User {
        var id = 0
        var name = ""
        var rating = 0.0
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAnyColumn() {
        struct TestCase {
            let anyColumn: AnyColumn
            let expected: String
        }
        let testCases = [
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id),
                     expected: "id INTEGER"),
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id, constraints: primaryKey()),
                     expected: "id INTEGER PRIMARY KEY"),
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id, constraints: primaryKey().autoincrement()),
                     expected: "id INTEGER PRIMARY KEY AUTOINCREMENT"),
            TestCase(anyColumn: Column(name: "identifier", keyPath: \User.id, constraints: notNull()),
                     expected: "identifier INTEGER NOT NULL"),
            
            TestCase(anyColumn: Column(name: "name", keyPath: \User.name),
                     expected: "name TEXT"),
            TestCase(anyColumn: Column(name: "first_name", keyPath: \User.name, constraints: notNull()),
                     expected: "first_name TEXT NOT NULL"),
            TestCase(anyColumn: Column(name: "name", keyPath: \User.name, constraints: unique()),
                     expected: "name TEXT UNIQUE"),
            
            TestCase(anyColumn: Column(name: "rating", keyPath: \User.rating),
                     expected: "rating REAL"),
        ]
        for testCase in testCases {
            let value = serialize(column: testCase.anyColumn)
            XCTAssertEqual(value, testCase.expected)
        }
    }

    func testOrder() {
        struct TestCase {
            let order: Order
            let expected: String
        }
        let testCases = [
            TestCase(order: .asc, expected: "ASC"),
            TestCase(order: .desc, expected: "DESC"),
        ]
        for testCase in testCases {
            let value = serialize(order: testCase.order)
            XCTAssertEqual(value, testCase.expected)
        }
    }
    
    func testConflictClause() {
        struct TestCase {
            let conflictClause: ConflictClause
            let expected: String
        }
        let testCases = [
            TestCase(conflictClause: .rollback, expected: "ON CONFLICT ROLLBACK"),
            TestCase(conflictClause: .abort, expected: "ON CONFLICT ABORT"),
            TestCase(conflictClause: .fail, expected: "ON CONFLICT FAIL"),
            TestCase(conflictClause: .ignore, expected: "ON CONFLICT IGNORE"),
            TestCase(conflictClause: .replace, expected: "ON CONFLICT REPLACE"),
        ]
        for testCase in testCases {
            let value = serialize(conflictClause: testCase.conflictClause)
            XCTAssertEqual(value, testCase.expected)
        }
    }
    
    func testColumnConstraint() {
        struct TestCase {
            let columnConstraint: ColumnConstraint
            let expected: String
        }
        let testCases = [
            TestCase(columnConstraint: .primaryKey(order: nil, conflictClause: nil, autoincrement: false),
                     expected: "PRIMARY KEY"),
            TestCase(columnConstraint: .primaryKey(order: nil, conflictClause: nil, autoincrement: true),
                     expected: "PRIMARY KEY AUTOINCREMENT"),
            TestCase(columnConstraint: .primaryKey(order: .asc, conflictClause: nil, autoincrement: false),
                     expected: "PRIMARY KEY ASC"),
            TestCase(columnConstraint: .primaryKey(order: .asc, conflictClause: nil, autoincrement: true),
                     expected: "PRIMARY KEY ASC AUTOINCREMENT"),
            
            TestCase(columnConstraint: .notNull(conflictClause: nil),
                     expected: "NOT NULL"),
            TestCase(columnConstraint: .notNull(conflictClause: .rollback),
                     expected: "NOT NULL ON CONFLICT ROLLBACK"),
            TestCase(columnConstraint: .notNull(conflictClause: .abort),
                     expected: "NOT NULL ON CONFLICT ABORT"),
            TestCase(columnConstraint: .notNull(conflictClause: .fail),
                     expected: "NOT NULL ON CONFLICT FAIL"),
            TestCase(columnConstraint: .notNull(conflictClause: .ignore),
                     expected: "NOT NULL ON CONFLICT IGNORE"),
            TestCase(columnConstraint: .notNull(conflictClause: .replace),
                     expected: "NOT NULL ON CONFLICT REPLACE"),
        ]
        for testCase in testCases {
            let result = serialize(columnConstraint: testCase.columnConstraint)
            XCTAssertEqual(result, testCase.expected)
        }
    }

}
