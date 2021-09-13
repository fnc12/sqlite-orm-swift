import Foundation
import SQLite3
@testable import sqlite_orm_swift

class SQLiteApiProviderMock: NSObject {
    let SQLITE_ROW: Int32 = SQLite3.SQLITE_ROW
    let SQLITE_DONE: Int32 = SQLite3.SQLITE_DONE
    let SQLITE_OK: Int32 = SQLite3.SQLITE_OK
    
    let SQLITE_STATIC: DestructorType = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT: DestructorType = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var calls = [SQLiteApiProviderCall]()
    var nextCallId = 0
    var sqlite3ColumnValueToReturn: OpaquePointer?
    var sqlite3ColumnTextToReturn: UnsafePointer<UInt8>?
    var sqlite3ColumnIntToReturn: Int32?
    
    func makeCall(callType: SQLiteApiProviderCallType) -> SQLiteApiProviderCall {
        let res = SQLiteApiProviderCall(id: self.nextCallId, callType: callType)
        self.nextCallId += 1
        return res
    }
}

extension SQLiteApiProviderMock: SQLiteApiProvider {
    func sqlite3Open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32 {
        return 0
    }
    
    func sqlite3Errmsg(_ ppDb: OpaquePointer!) -> UnsafePointer<CChar>! {
        return nil
    }
    
    func sqlite3Close(_ ppDb: OpaquePointer!) -> Int32 {
        return 0
    }
    
    func sqlite3LastInsertRowid(_ ppDb: OpaquePointer!) -> SQLiteApiProvider.Int64 {
        return 0
    }
    
    func sqlite3PrepareV2(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        return 0
    }
    
    func sqlite3Exec(_ db: OpaquePointer!, _ sql: UnsafePointer<CChar>!, _ callback: ExecCallback!, _ data: UnsafeMutableRawPointer!, _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32 {
        return 0
    }
    
    func sqlite3Finalize(_ pStmt: OpaquePointer!) {
        let call = self.makeCall(callType: .sqlite3Finalize(pStmt))
        self.calls.append(call)
    }
    
    func sqlite3Step(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3Step(pStmt))
        self.calls.append(call)
        return 0
    }
    
    func sqlite3ColumnCount(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ColumnCount(pStmt))
        self.calls.append(call)
        return 0
    }
    
    func sqlite3ColumnValue(_ pStmt: OpaquePointer!, _ iCol: Int32) -> OpaquePointer! {
        let call = self.makeCall(callType: .sqlite3ColumnValue(pStmt, iCol))
        self.calls.append(call)
        return self.sqlite3ColumnValueToReturn
    }
    
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(callType: .sqlite3ColumnText(pStmt, iCol))
        self.calls.append(call)
        return self.sqlite3ColumnTextToReturn
    }
    
    func sqlite3ColumnInt(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ColumnInt(pStmt, iCol))
        self.calls.append(call)
        return self.sqlite3ColumnIntToReturn ?? 0
    }
    
    func sqlite3BindText(_ pStmt: OpaquePointer!,
                         _ idx: Int32,
                         _ value: UnsafePointer<CChar>!,
                         _ len: Int32,
                         _ dtor: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3BindText(pStmt, idx, value, len, dtor))
        self.calls.append(call)
        return 0
    }
    
    func sqlite3BindInt(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Int32) -> Int32 {
        let call = self.makeCall(callType: .sqlite3BindInt(pStmt, idx, value))
        self.calls.append(call)
        return 0
    }
    
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ValueInt(value))
        self.calls.append(call)
        return 0
    }
    
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(callType: .sqlite3ValueText(value))
        self.calls.append(call)
        return nil
    }
}
