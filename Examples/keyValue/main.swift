import Foundation
import SQLiteORM

struct KeyValue: Initializable {
    var key: String = ""
    var value: String = ""
}

let storage = try Storage(filename: "",
                                  tables: Table<KeyValue>(name: "key_value",
                                                          columns:
                                                            Column(name: "key", keyPath: \KeyValue.key, constraints: primaryKey()),
                                                            Column(name: "value", keyPath: \KeyValue.value)))
try storage.syncSchema(preserve: true)

func set(value: String, for key: String) throws {
    try storage.replace(KeyValue(key: key, value: value))
}

func getValue(for key: String) throws -> String? {
    if let keyValue: KeyValue = try storage.get(id: key) {
        return keyValue.value
    } else {
        return nil
    }
}

func storedKeysCount() throws -> Int {
    return try storage.count(all: KeyValue.self)
}

struct Keys {
    static let userId = "userId"
    static let userName = "userName"
    static let userGender = "userGender"
}

try set(value: "6", for: Keys.userId)
try set(value: "Peter", for: Keys.userName)

let userId = try getValue(for: Keys.userId)
print("userId = \(String(describing: userId))")

let userName = try getValue(for: Keys.userName)
print("userName = \(String(describing: userName))")

let userGender = try getValue(for: Keys.userGender)
print("userGender = \(String(describing: userGender))")

let keyValuesCount = try storedKeysCount()
print("keyValuesCount = \(keyValuesCount)")
