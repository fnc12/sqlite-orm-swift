import Foundation
import SQLite3
@testable import sqlite_orm_swift

class SQLiteApiProviderMock: NSObject {
    let SQLITE_ROW: Int32 = SQLite3.SQLITE_ROW
    let SQLITE_DONE: Int32 = SQLite3.SQLITE_DONE
    let SQLITE_OK: Int32 = SQLite3.SQLITE_OK
    
    let SQLITE_STATIC: DestructorType = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT: DestructorType = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var isProxy = false
    
    var calls = [SQLiteApiProviderCall]()
    var nextCallId = 0
    var sqlite3ColumnValueToReturn: OpaquePointer?
    var sqlite3ColumnTextToReturn: UnsafePointer<UInt8>?
    var sqlite3ColumnIntToReturn: Int32?
    var sqlite3ErrmsgToReturn: UnsafePointer<CChar>!
    var sqlite3PrepareV2ToReturn: Int32?
    var sqlite3PrepareV2StmtToAssign: OpaquePointer?
    
    func makeCall(callType: SQLiteApiProviderCallType) -> SQLiteApiProviderCall {
        let res = SQLiteApiProviderCall(id: self.nextCallId, callType: callType)
        self.nextCallId += 1
        return res
    }
}

extension SQLiteApiProviderMock: SQLiteApiProvider {
    func sqlite3Open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3Open(filename, ppDb))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_open(filename, ppDb)
        }else{
            return 0
        }
    }
    
    func sqlite3Errmsg(_ ppDb: OpaquePointer!) -> UnsafePointer<CChar>! {
        if self.isProxy {
            return sqlite3_errmsg(ppDb)
        }else{
            return self.sqlite3ErrmsgToReturn
        }
    }
    
    func sqlite3Close(_ ppDb: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3Close(ppDb))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_close(ppDb)
        }else{
            return 0
        }
    }
    
    func sqlite3LastInsertRowid(_ ppDb: OpaquePointer!) -> SQLiteApiProvider.Int64 {
        let call = self.makeCall(callType: .sqlite3LastInsertRowid(ppDb))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_last_insert_rowid(ppDb)
        }else{
            return 0
        }
    }
    
    func sqlite3PrepareV2(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3PrepareV2(db, zSql, nByte, ppStmt, pzTail))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_prepare_v2(db, zSql, nByte, ppStmt, pzTail)
        }else{
            if let value = self.sqlite3PrepareV2StmtToAssign {
                ppStmt.pointee = value
            }
            return self.sqlite3PrepareV2ToReturn ?? 0
        }
    }
    
    func sqlite3Exec(_ db: OpaquePointer!, _ sql: UnsafePointer<CChar>!, _ callback: ExecCallback!, _ data: UnsafeMutableRawPointer!, _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32 {
        if self.isProxy {
            return sqlite3_exec(db, sql, callback, data, errmsg)
        }else{
            return 0
        }
    }
    
    func sqlite3Finalize(_ pStmt: OpaquePointer!) {
        let call = self.makeCall(callType: .sqlite3Finalize(pStmt))
        self.calls.append(call)
        if self.isProxy {
            sqlite3_finalize(pStmt)
        }
    }
    
    func sqlite3Step(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3Step(pStmt))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_step(pStmt)
        }else{
            return 0
        }
    }
    
    func sqlite3ColumnCount(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ColumnCount(pStmt))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_column_count(pStmt)
        }else{
            return 0
        }
    }
    
    func sqlite3ColumnValue(_ pStmt: OpaquePointer!, _ iCol: Int32) -> OpaquePointer! {
        let call = self.makeCall(callType: .sqlite3ColumnValue(pStmt, iCol))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_column_value(pStmt, iCol)
        }else{
            return self.sqlite3ColumnValueToReturn
        }
    }
    
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(callType: .sqlite3ColumnText(pStmt, iCol))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_column_text(pStmt, iCol)
        }else{
            return self.sqlite3ColumnTextToReturn
        }
    }
    
    func sqlite3ColumnInt(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ColumnInt(pStmt, iCol))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_column_int(pStmt, iCol)
        }else{
            return self.sqlite3ColumnIntToReturn ?? 0
        }
    }
    
    func sqlite3BindText(_ pStmt: OpaquePointer!,
                         _ idx: Int32,
                         _ value: UnsafePointer<CChar>!,
                         _ len: Int32,
                         _ dtor: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3BindText(pStmt, idx, value, len, dtor))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_bind_text(pStmt, idx, value, len, dtor)
        }else{
            return 0
        }
    }
    
    func sqlite3BindInt(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Int32) -> Int32 {
        let call = self.makeCall(callType: .sqlite3BindInt(pStmt, idx, value))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_bind_int(pStmt, idx, value)
        }else{
            return 0
        }
    }
    
    func sqlite3BindNull(_ pStmt: OpaquePointer!, _ idx: Int32) -> Int32 {
        let call = self.makeCall(callType: .sqlite3BindNull(pStmt, idx))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_bind_null(pStmt, idx)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32 {
        let call = self.makeCall(callType: .sqlite3ValueInt(value))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_value_int(value)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(callType: .sqlite3ValueText(value))
        self.calls.append(call)
        if self.isProxy {
            return sqlite3_value_text(value)
        }else{
            return nil
        }
    }
}
