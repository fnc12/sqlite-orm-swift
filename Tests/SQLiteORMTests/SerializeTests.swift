import XCTest
@testable import SQLiteORM

class SchemaProviderStub: SchemaProvider {

    enum Error: Swift.Error {
        case error
    }

    func columnName<T, F>(keyPath: KeyPath<T, F>) throws -> String {
        throw Self.Error.error
    }

    func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) throws -> String {
        throw Self.Error.error
    }

    func tableName<T>(type: T.Type) throws -> String {
        throw Self.Error.error
    }
}

class SerializeTests: XCTestCase {

    struct User {
        var id = 0
        var name = ""
        var rating = 0.0
    }

    func testKeyPath() throws {
        try testCase(#function, routine: {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id),
                                                            Column(name: "name", keyPath: \User.name),
                                                            Column(name: "rating", keyPath: \User.rating)))
            var serializationContext = SerializationContext(schemaProvider: storage)
            var string = ""
            var expected = ""
            try section("id", routine: {
                let keyPath = \User.id
                try section("with table name", routine: {
                    serializationContext = serializationContext.byIncludingTableName()
                    expected = "users.\"id\""
                })
                try section("without table name", routine: {
                    serializationContext = serializationContext.bySkippingTableName()
                    expected = "\"id\""
                })
                string = try keyPath.serialize(with: serializationContext)
            })
            try section("name", routine: {
                let keyPath = \User.name
                try section("with table name", routine: {
                    serializationContext = serializationContext.byIncludingTableName()
                    expected = "users.\"name\""
                })
                try section("without table name", routine: {
                    serializationContext = serializationContext.bySkippingTableName()
                    expected = "\"name\""
                })
                string = try keyPath.serialize(with: serializationContext)
            })
            try section("rating", routine: {
                let keyPath = \User.rating
                try section("with table name", routine: {
                    serializationContext = serializationContext.byIncludingTableName()
                    expected = "users.\"rating\""
                })
                try section("without table name", routine: {
                    serializationContext = serializationContext.bySkippingTableName()
                    expected = "\"rating\""
                })
                string = try keyPath.serialize(with: serializationContext)
            })

            XCTAssertEqual(string, expected)
        })
    }

    func testUnaryOperator() throws {
        struct TestCase {
            let value: UnaryOperator
            let expected: String
        }
        let testCases = [
            TestCase(value: binaryNot(expression: \User.id), expected: "~ users.\"id\""),
            TestCase(value: ~\User.id, expected: "~ users.\"id\""),
            TestCase(value: plus(expression: \User.id), expected: "+ users.\"id\""),
            TestCase(value: +\User.id, expected: "+ users.\"id\""),
            TestCase(value: minus(expression: \User.id), expected: "- users.\"id\""),
            TestCase(value: -\User.id, expected: "- users.\"id\""),
            TestCase(value: not(expression: \User.id), expected: "NOT users.\"id\""),
            TestCase(value: !\User.id, expected: "NOT users.\"id\"")
        ]
        for testCase in testCases {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id),
                                                            Column(name: "name", keyPath: \User.name),
                                                            Column(name: "rating", keyPath: \User.rating)))
            try storage.syncSchema(preserve: false)
            let string = try testCase.value.serialize(with: .init(schemaProvider: storage))
            XCTAssertEqual(string, testCase.expected)
        }
    }

    func testLimit() throws {
        struct TestCase {
            let value: ASTLimit
            let expected: String
        }
        let testCases = [
            TestCase(value: limit(5), expected: "LIMIT 5"),
            .init(value: limit(10, 4), expected: "LIMIT 10, 4"),
            .init(value: limit(3, offset: 10), expected: "LIMIT 3 OFFSET 10")
        ]
        for testCase in testCases {
            let schemaProviderStub = SchemaProviderStub()
            let value = try testCase.value.serialize(with: .init(schemaProvider: schemaProviderStub))
            XCTAssertEqual(value, testCase.expected)
        }
    }

    func testBinaryOperator() throws {
        struct TestCase {
            let value: BinaryOperator
            let expected: String
        }
        let testCases = [
            //  Int
            TestCase(value: equal(lhs: \User.id, rhs: 5), expected: "users.\"id\" == 5"),
            TestCase(value: \User.id == 5, expected: "users.\"id\" == 5"),
            TestCase(value: notEqual(lhs: \User.id, rhs: 10), expected: "users.\"id\" != 10"),
            TestCase(value: \User.id != 10, expected: "users.\"id\" != 10"),
            TestCase(value: greaterThan(lhs: \User.id, rhs: 3), expected: "users.\"id\" > 3"),
            TestCase(value: \User.id > 3, expected: "users.\"id\" > 3"),
            TestCase(value: greaterOrEqual(lhs: \User.id, rhs: 1), expected: "users.\"id\" >= 1"),
            TestCase(value: \User.id >= 1, expected: "users.\"id\" >= 1"),
            TestCase(value: lesserThan(lhs: \User.id, rhs: 2), expected: "users.\"id\" < 2"),
            TestCase(value: \User.id < 2, expected: "users.\"id\" < 2"),
            TestCase(value: lesserOrEqual(lhs: \User.id, rhs: 4), expected: "users.\"id\" <= 4"),
            TestCase(value: \User.id <= 4, expected: "users.\"id\" <= 4"),
            TestCase(value: equal(lhs: 5, rhs: \User.id), expected: "5 == users.\"id\""),
            TestCase(value: 5 == \User.id, expected: "5 == users.\"id\""),
            TestCase(value: notEqual(lhs: 10, rhs: \User.id), expected: "10 != users.\"id\""),
            TestCase(value: 10 != \User.id, expected: "10 != users.\"id\""),
            TestCase(value: 3 > \User.id, expected: "3 > users.\"id\""),
            TestCase(value: greaterOrEqual(lhs: 1, rhs: \User.id), expected: "1 >= users.\"id\""),
            TestCase(value: 1 >= \User.id, expected: "1 >= users.\"id\""),
            TestCase(value: lesserThan(lhs: 2, rhs: \User.id), expected: "2 < users.\"id\""),
            TestCase(value: 2 < \User.id, expected: "2 < users.\"id\""),
            TestCase(value: lesserOrEqual(lhs: 4, rhs: \User.id), expected: "4 <= users.\"id\""),
            TestCase(value: 4 <= \User.id, expected: "4 <= users.\"id\""),

            TestCase(value: conc(\User.id, "Skillet"), expected: "users.\"id\" || 'Skillet'"),
            TestCase(value: SQLiteORM.add(\User.id, 5), expected: "users.\"id\" + 5"),
            TestCase(value: \User.id + 5, expected: "users.\"id\" + 5"),
            TestCase(value: sub(\User.id, 5), expected: "users.\"id\" - 5"),
            TestCase(value: \User.id - 5, expected: "users.\"id\" - 5"),
            TestCase(value: mul(\User.id, 5), expected: "users.\"id\" * 5"),
            TestCase(value: \User.id * 5, expected: "users.\"id\" * 5"),
            TestCase(value: div(\User.id, 5), expected: "users.\"id\" / 5"),
            TestCase(value: \User.id / 5, expected: "users.\"id\" / 5"),
            TestCase(value: mod(\User.id, 5), expected: "users.\"id\" % 5"),
            TestCase(value: \User.id % 5, expected: "users.\"id\" % 5"),
            TestCase(value: and(\User.id, 5), expected: "users.\"id\" AND 5"),
            TestCase(value: \User.id && 5, expected: "users.\"id\" AND 5"),
            TestCase(value: (\User.id).and(5), expected: "users.\"id\" AND 5"),
            TestCase(value: or(\User.id, 5), expected: "users.\"id\" OR 5"),
            TestCase(value: \User.id || 5, expected: "users.\"id\" OR 5"),
            TestCase(value: (\User.id).or(5), expected: "users.\"id\" OR 5"),

            TestCase(value: conc("Skillet", \User.id), expected: "'Skillet' || users.\"id\""),
            TestCase(value: SQLiteORM.add(5, \User.id), expected: "5 + users.\"id\""),
            TestCase(value: 5 + \User.id, expected: "5 + users.\"id\""),
            TestCase(value: sub(5, \User.id), expected: "5 - users.\"id\""),
            TestCase(value: 5 - \User.id, expected: "5 - users.\"id\""),
            TestCase(value: mul(5, \User.id), expected: "5 * users.\"id\""),
            TestCase(value: 5 * \User.id, expected: "5 * users.\"id\""),
            TestCase(value: div(5, \User.id), expected: "5 / users.\"id\""),
            TestCase(value: 5 / \User.id, expected: "5 / users.\"id\""),
            TestCase(value: mod(5, \User.id), expected: "5 % users.\"id\""),
            TestCase(value: 5 % \User.id, expected: "5 % users.\"id\""),
            TestCase(value: and(5, \User.id), expected: "5 AND users.\"id\""),
            TestCase(value: 5 && \User.id, expected: "5 AND users.\"id\""),
            TestCase(value: 5.and(\User.id), expected: "5 AND users.\"id\""),
            TestCase(value: or(5, \User.id), expected: "5 OR users.\"id\""),
            TestCase(value: 5.or(\User.id), expected: "5 OR users.\"id\""),

            //  String
            TestCase(value: equal(lhs: \User.name, rhs: "Nicki"), expected: "users.\"name\" == 'Nicki'"),
            TestCase(value: \User.name == "Nicki", expected: "users.\"name\" == 'Nicki'"),
            TestCase(value: notEqual(lhs: \User.name, rhs: "Alvaro"), expected: "users.\"name\" != 'Alvaro'"),
            TestCase(value: \User.name != "Alvaro", expected: "users.\"name\" != 'Alvaro'"),
            TestCase(value: greaterThan(lhs: \User.name, rhs: "Ava Max"), expected: "users.\"name\" > 'Ava Max'"),
            TestCase(value: \User.name > "Ava Max", expected: "users.\"name\" > 'Ava Max'"),
            TestCase(value: greaterOrEqual(lhs: \User.name, rhs: "Rita Ora"), expected: "users.\"name\" >= 'Rita Ora'"),
            TestCase(value: \User.name >= "Rita Ora", expected: "users.\"name\" >= 'Rita Ora'"),
            TestCase(value: lesserThan(lhs: \User.name, rhs: "Kesha"), expected: "users.\"name\" < 'Kesha'"),
            TestCase(value: \User.name < "Kesha", expected: "users.\"name\" < 'Kesha'"),
            TestCase(value: lesserOrEqual(lhs: \User.name, rhs: "Oliver Heldens"), expected: "users.\"name\" <= 'Oliver Heldens'"),
            TestCase(value: \User.name <= "Oliver Heldens", expected: "users.\"name\" <= 'Oliver Heldens'"),
            TestCase(value: equal(lhs: "Nicki", rhs: \User.name), expected: "'Nicki' == users.\"name\""),
            TestCase(value: "Nicki" == \User.name, expected: "'Nicki' == users.\"name\""),
            TestCase(value: notEqual(lhs: "Alvaro", rhs: \User.name), expected: "'Alvaro' != users.\"name\""),
            TestCase(value: "Alvaro" != \User.name, expected: "'Alvaro' != users.\"name\""),
            TestCase(value: greaterThan(lhs: "Ava Max", rhs: \User.name), expected: "'Ava Max' > users.\"name\""),
            TestCase(value: "Ava Max" > \User.name, expected: "'Ava Max' > users.\"name\""),
            TestCase(value: greaterOrEqual(lhs: "Rita Ora", rhs: \User.name), expected: "'Rita Ora' >= users.\"name\""),
            TestCase(value: "Rita Ora" >= \User.name, expected: "'Rita Ora' >= users.\"name\""),
            TestCase(value: lesserThan(lhs: "Kesha", rhs: \User.name), expected: "'Kesha' < users.\"name\""),
            TestCase(value: "Kesha" < \User.name, expected: "'Kesha' < users.\"name\""),
            TestCase(value: lesserOrEqual(lhs: "Oliver Heldens", rhs: \User.name), expected: "'Oliver Heldens' <= users.\"name\""),
            TestCase(value: "Oliver Heldens" <= \User.name, expected: "'Oliver Heldens' <= users.\"name\""),
            TestCase(value: conc("Skillet", \User.name), expected: "'Skillet' || users.\"name\"")
        ]
        for testCase in testCases {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id),
                                                            Column(name: "name", keyPath: \User.name),
                                                            Column(name: "rating", keyPath: \User.rating)))
            try storage.syncSchema(preserve: false)
            let string = try testCase.value.serialize(with: .init(schemaProvider: storage))
            XCTAssertEqual(string, testCase.expected)
        }
    }

    func testUnaryOperatorType() {
        struct TestCase {
            let unaryOperatorType: UnaryOperatorType
            let expected: String
        }
        let testCases = [
            TestCase(unaryOperatorType: .not, expected: "NOT"),
            TestCase(unaryOperatorType: .minus, expected: "-"),
            TestCase(unaryOperatorType: .plus, expected: "+"),
            TestCase(unaryOperatorType: .tilda, expected: "~")
        ]
        for testCase in testCases {
            let description = testCase.unaryOperatorType.description
            XCTAssertEqual(description, testCase.expected)
        }
    }

    func testOrderBy() throws {
        struct TestCase {
            let expression: ASTOrderBy
            let expected: String
        }
        let testCases = [
            TestCase(expression: orderBy(\User.name), expected: "ORDER BY users.\"name\""),
            TestCase(expression: orderBy(\User.id), expected: "ORDER BY users.\"id\""),
            .init(expression: orderBy(\User.id).asc(), expected: "ORDER BY users.\"id\" ASC"),
            .init(expression: orderBy(\User.id).desc(), expected: "ORDER BY users.\"id\" DESC"),
            .init(expression: orderBy(\User.id).asc().nullsFirst(), expected: "ORDER BY users.\"id\" ASC NULLS FIRST"),
            .init(expression: orderBy(\User.id).asc().nullsLast(), expected: "ORDER BY users.\"id\" ASC NULLS LAST"),
            .init(expression: orderBy(\User.id).desc().nullsFirst(), expected: "ORDER BY users.\"id\" DESC NULLS FIRST"),
            .init(expression: orderBy(\User.id).desc().nullsLast(), expected: "ORDER BY users.\"id\" DESC NULLS LAST"),
            .init(expression: orderBy(\User.id).nullsFirst(), expected: "ORDER BY users.\"id\" NULLS FIRST"),
            .init(expression: orderBy(\User.id).nullsLast(), expected: "ORDER BY users.\"id\" NULLS LAST"),

            .init(expression: orderBy(\User.name).collate("binary"), expected: "ORDER BY users.\"name\" COLLATE binary"),
            .init(expression: orderBy(\User.id).collate("binary"), expected: "ORDER BY users.\"id\" COLLATE binary"),
            .init(expression: orderBy(\User.id).collate("binary").asc(), expected: "ORDER BY users.\"id\" COLLATE binary ASC"),
            .init(expression: orderBy(\User.id).collate("binary").desc(), expected: "ORDER BY users.\"id\" COLLATE binary DESC"),
            .init(expression: orderBy(\User.id).collate("binary").asc().nullsFirst(), expected: "ORDER BY users.\"id\" COLLATE binary ASC NULLS FIRST"),
            .init(expression: orderBy(\User.id).collate("binary").asc().nullsLast(), expected: "ORDER BY users.\"id\" COLLATE binary ASC NULLS LAST"),
            .init(expression: orderBy(\User.id).collate("binary").desc().nullsFirst(), expected: "ORDER BY users.\"id\" COLLATE binary DESC NULLS FIRST"),
            .init(expression: orderBy(\User.id).collate("binary").desc().nullsLast(), expected: "ORDER BY users.\"id\" COLLATE binary DESC NULLS LAST"),
            .init(expression: orderBy(\User.id).collate("binary").nullsFirst(), expected: "ORDER BY users.\"id\" COLLATE binary NULLS FIRST"),
            .init(expression: orderBy(\User.id).collate("binary").nullsLast(), expected: "ORDER BY users.\"id\" COLLATE binary NULLS LAST")
        ]
        for testCase in testCases {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id),
                                                            Column(name: "name", keyPath: \User.name),
                                                            Column(name: "rating", keyPath: \User.rating)))
            let string = try testCase.expression.serialize(with: .init(schemaProvider: storage))
            XCTAssertEqual(string, testCase.expected)
        }
    }

    func testWhere() throws {
        struct TestCase {
            let expression: ASTWhere
            let expected: String
        }
        let testCases = [
            TestCase(expression: where_(true), expected: "WHERE 1"),
            TestCase(expression: where_(\User.id > 5), expected: "WHERE users.\"id\" > 5")
        ]
        for testCase in testCases {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id),
                                                            Column(name: "name", keyPath: \User.name),
                                                            Column(name: "rating", keyPath: \User.rating)))
            let string = try testCase.expression.serialize(with: .init(schemaProvider: storage))
            XCTAssertEqual(string, testCase.expected)
        }
    }

    func testBinaryOperatorType() {
        struct TestCase {
            let binaryOperatorType: BinaryOperatorType
            let expected: String
        }
        let testCases = [
            TestCase(binaryOperatorType: .add, expected: "+"),
            TestCase(binaryOperatorType: .sub, expected: "-"),
            TestCase(binaryOperatorType: .mul, expected: "*"),
            TestCase(binaryOperatorType: .div, expected: "/"),
            TestCase(binaryOperatorType: .mod, expected: "%"),
            TestCase(binaryOperatorType: .equal, expected: "=="),
            TestCase(binaryOperatorType: .notEqual, expected: "!="),
            TestCase(binaryOperatorType: .lesserThan, expected: "<"),
            TestCase(binaryOperatorType: .lesserOrEqual, expected: "<="),
            TestCase(binaryOperatorType: .greaterThan, expected: ">"),
            TestCase(binaryOperatorType: .greaterOrEqual, expected: ">="),
            TestCase(binaryOperatorType: .conc, expected: "||"),
            TestCase(binaryOperatorType: .and, expected: "AND"),
            TestCase(binaryOperatorType: .or, expected: "OR")
        ]
        for testCase in testCases {
            let description = testCase.binaryOperatorType.description
            XCTAssertEqual(description, testCase.expected)
        }
    }

    func testAnyColumn() {
        struct TestCase {
            let anyColumn: AnyColumn
            let expected: String
        }
        let testCases = [
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id),
                     expected: "\"id\" INTEGER"),
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id, constraints: primaryKey()),
                     expected: "\"id\" INTEGER PRIMARY KEY"),
            TestCase(anyColumn: Column(name: "id", keyPath: \User.id, constraints: primaryKey().autoincrement()),
                     expected: "\"id\" INTEGER PRIMARY KEY AUTOINCREMENT"),
            TestCase(anyColumn: Column(name: "identifier", keyPath: \User.id, constraints: notNull()),
                     expected: "\"identifier\" INTEGER NOT NULL"),

            TestCase(anyColumn: Column(name: "name", keyPath: \User.name),
                     expected: "\"name\" TEXT"),
            TestCase(anyColumn: Column(name: "first_name", keyPath: \User.name, constraints: notNull()),
                     expected: "\"first_name\" TEXT NOT NULL"),
            TestCase(anyColumn: Column(name: "name", keyPath: \User.name, constraints: unique()),
                     expected: "\"name\" TEXT UNIQUE"),

            TestCase(anyColumn: Column(name: "rating", keyPath: \User.rating),
                     expected: "\"rating\" REAL")
        ]
        for testCase in testCases {
            let schemaProviderStub = SchemaProviderStub()
            let value = testCase.anyColumn.serialize(with: .init(schemaProvider: schemaProviderStub))
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
            TestCase(order: .desc, expected: "DESC")
        ]
        for testCase in testCases {
            let schemaProviderStub = SchemaProviderStub()
            let value = testCase.order.serialize(with: .init(schemaProvider: schemaProviderStub))
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
            TestCase(conflictClause: .replace, expected: "ON CONFLICT REPLACE")
        ]
        for testCase in testCases {
            let schemaProviderStub = SchemaProviderStub()
            let value = testCase.conflictClause.serialize(with: .init(schemaProvider: schemaProviderStub))
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
                     expected: "NOT NULL ON CONFLICT REPLACE")
        ]
        for testCase in testCases {
            let schemaProviderStub = SchemaProviderStub()
            let result = testCase.columnConstraint.serialize(with: .init(schemaProvider: schemaProviderStub))
            XCTAssertEqual(result, testCase.expected)
        }
    }

}
