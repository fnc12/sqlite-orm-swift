import XCTest
@testable import SQLiteORM

class ConstructableFromSQLiteValueTests: XCTestCase {
    
    func testInt() {
        let values = [
            1,
            2,
            10,
            -5,
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.integer = intValue
            let value = Int(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testIntOptional() {
        let values: [Int?] = [
            1,
            2,
            10,
            -5,
            nil,
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            if let intValue {
                valueMock.integer = intValue
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<Int>(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testUInt() {
        let values = [
            UInt(1),
            UInt(2),
            UInt(10),
            UInt(500),
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.integer = Int(intValue)
            let value = UInt(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testUIntOptional() {
        let values: [UInt?] = [
            UInt(1),
            UInt(2),
            UInt(10),
            UInt(500),
            nil,
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            if let intValue {
                valueMock.integer = Int(intValue)
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<UInt>(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testInt64() {
        let values = [
            Int64(1),
            Int64(2),
            Int64(10),
            Int64(-500),
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.integer = Int(intValue)
            let value = Int64(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testInt64Optional() {
        let values: [Int64?] = [
            Int64(1),
            Int64(2),
            Int64(10),
            Int64(-500),
            nil,
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            if let intValue {
                valueMock.integer = Int(intValue)
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<Int64>(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testUInt64() {
        let values = [
            UInt64(1),
            UInt64(2),
            UInt64(10),
            UInt64(500),
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.integer = Int(intValue)
            let value = UInt64(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testUInt64Optional() {
        let values: [UInt64?] = [
            UInt64(1),
            UInt64(2),
            UInt64(10),
            UInt64(500),
            nil,
        ]
        for intValue in values {
            let valueMock = SQLiteValueMock()
            if let intValue {
                valueMock.integer = Int(intValue)
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<UInt64>(sqliteValue: valueMock)
            XCTAssertEqual(value, intValue)
        }
    }
    
    func testDouble() {
        let values = [
            Double(1.5),
            Double(3.141592654),
            Double(2.71),
            Double(-500),
        ]
        for doubleValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.double = doubleValue
            let value = Double(sqliteValue: valueMock)
            XCTAssertEqual(value, doubleValue)
        }
    }
    
    func testDoubleOptional() {
        let values: [Double?] = [
            Double(1.5),
            Double(3.141592654),
            Double(2.71),
            Double(-500),
            nil,
        ]
        for doubleValue in values {
            let valueMock = SQLiteValueMock()
            if let doubleValue {
                valueMock.double = doubleValue
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<Double>(sqliteValue: valueMock)
            XCTAssertEqual(value, doubleValue)
        }
    }
    
    func testFloat() {
        let values = [
            Float(1.5),
            Float(3.141592654),
            Float(2.71),
            Float(-500),
        ]
        for floatValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.double = Double(floatValue)
            let value = Float(sqliteValue: valueMock)
            XCTAssertEqual(value, floatValue)
        }
    }
    
    func testFloatOptional() {
        let values: [Float?] = [
            Float(1.5),
            Float(3.141592654),
            Float(2.71),
            Float(-500),
            nil,
        ]
        for floatValue in values {
            let valueMock = SQLiteValueMock()
            if let floatValue {
                valueMock.double = Double(floatValue)
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<Float>(sqliteValue: valueMock)
            XCTAssertEqual(value, floatValue)
        }
    }
    
    func testString() {
        let values = [
            "Inna",
            "Ava Max",
            "Rita Ora",
            "Alexandra Stan",
            "Dua Lipa",
        ]
        for stringValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.text = stringValue
            let value = String(sqliteValue: valueMock)
            XCTAssertEqual(value, stringValue)
        }
    }
    
    func testStringOptional() {
        let values: [String?] = [
            "Inna",
            "Ava Max",
            "Rita Ora",
            "Alexandra Stan",
            "Dua Lipa",
            nil,
        ]
        for stringValue in values {
            let valueMock = SQLiteValueMock()
            if let stringValue {
                valueMock.text = stringValue
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<String>(sqliteValue: valueMock)
            XCTAssertEqual(value, stringValue)
        }
    }
    
    func testBool() {
        let values = [
            true,
            false,
        ]
        for boolValue in values {
            let valueMock = SQLiteValueMock()
            valueMock.integer = boolValue ? 1 : 0
            let value = Bool(sqliteValue: valueMock)
            XCTAssertEqual(value, boolValue)
        }
    }
    
    func testBoolOptional() {
        let values: [Bool?] = [
            true,
            false,
            nil,
        ]
        for boolValue in values {
            let valueMock = SQLiteValueMock()
            if let boolValue {
                valueMock.integer = boolValue ? 1 : 0
                valueMock.isNull = false
            } else {
                valueMock.isNull = true
            }
            let value = Optional<Bool>(sqliteValue: valueMock)
            XCTAssertEqual(value, boolValue)
        }
    }
}
