import Foundation
import SQLite3
@testable import SQLiteORM

class SQLiteApiProviderMock: Mock<SQLiteApiProviderCallType> {
    let SQLITE_ROW: Int32 = SQLite3.SQLITE_ROW
    let SQLITE_DONE: Int32 = SQLite3.SQLITE_DONE
    let SQLITE_OK: Int32 = SQLite3.SQLITE_OK
    
    let SQLITE_STATIC: DestructorType = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT: DestructorType = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    let SQLITE_INTEGER: Int32 = SQLite3.SQLITE_INTEGER
    let SQLITE_FLOAT: Int32 = SQLite3.SQLITE_FLOAT
    let SQLITE_BLOB: Int32 = SQLite3.SQLITE_BLOB
    let SQLITE_NULL: Int32 = SQLite3.SQLITE_NULL
    let SQLITE_TEXT: Int32 = SQLite3.SQLITE_TEXT
    
    var forwardsCalls = false
    
    var sqlite3ColumnValueToReturn: OpaquePointer?
    var sqlite3ColumnTextToReturn: UnsafePointer<UInt8>?
    var sqlite3ColumnIntToReturn: Int32?
    var sqlite3ErrmsgToReturn: UnsafePointer<CChar>!
    var sqlite3PrepareV2ToReturn: Int32?
    var sqlite3PrepareV2StmtToAssign: OpaquePointer?
    var sqlite3OpenDbToAssign: OpaquePointer?
    var sqlite3OpenToReturn: Int32?
}

extension SQLiteApiProviderMock: SQLiteApiProvider {
    
    func sqlite3ColumnType(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        let call = self.makeCall(with: .sqlite3ColumnType(pStmt, iCol))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_column_type(pStmt, iCol)
        }else{
            return 0
        }
    }
    
    func sqlite3ColumnDouble(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Double {
        let call = self.makeCall(with: .sqlite3ColumnDouble(.value(pStmt!), iCol))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_column_double(pStmt, iCol)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueDouble(_ value: OpaquePointer!) -> Double {
        let call = self.makeCall(with: .sqlite3ValueDouble(.value(value)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_value_double(value)
        }else{
            return 0
        }
    }
    
    func sqlite3BindDouble(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Double) -> Int32 {
        let call = self.makeCall(with: .sqlite3BindDouble(pStmt, idx, value))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_bind_double(pStmt, idx, value)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueType(_ value: OpaquePointer!) -> Int32 {
        let call = self.makeCall(with: .sqlite3ValueType(.value(value)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_value_type(value)
        }else{
            return 0
        }
    }
    
    func sqlite3Open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32 {
        let filenameString = String(cString: filename)
        let call = self.makeCall(with: .sqlite3Open(filenameString, .value(ppDb)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_open(filename, ppDb)
        }else{
            if self.sqlite3OpenDbToAssign != nil {
                ppDb.pointee = self.sqlite3OpenDbToAssign
            }
            if let valueToReturn = self.sqlite3OpenToReturn {
                return valueToReturn
            }else{
                return 0
            }
        }
    }
    
    func sqlite3Errmsg(_ ppDb: OpaquePointer!) -> UnsafePointer<CChar>! {
        if self.forwardsCalls {
            return sqlite3_errmsg(ppDb)
        }else{
            return self.sqlite3ErrmsgToReturn
        }
    }
    
    func sqlite3Close(_ ppDb: OpaquePointer!) -> Int32 {
        let call = self.makeCall(with: .sqlite3Close(.value(ppDb)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_close(ppDb)
        }else{
            return 0
        }
    }
    
    func sqlite3LastInsertRowid(_ ppDb: OpaquePointer!) -> SQLiteApiProvider.Int64 {
        let call = self.makeCall(with: .sqlite3LastInsertRowid(.value(ppDb)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_last_insert_rowid(ppDb)
        }else{
            return 0
        }
    }
    
    func sqlite3PrepareV2(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        let call = self.makeCall(with: .sqlite3PrepareV2(.value(db), String(cString: zSql), nByte, .init(ppStmt!), pzTail))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_prepare_v2(db, zSql, nByte, ppStmt, pzTail)
        }else{
            if let value = self.sqlite3PrepareV2StmtToAssign {
                ppStmt.pointee = value
            }
            return self.sqlite3PrepareV2ToReturn ?? 0
        }
    }
    
    func sqlite3Exec(_ db: OpaquePointer!,
                     _ sql: UnsafePointer<CChar>!,
                     _ callback: ExecCallback!,
                     _ data: UnsafeMutableRawPointer!,
                     _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32 {
        let sqlString = String(cString: sql)
        let call = self.makeCall(with: .sqlite3Exec(db, sqlString, callback, data, errmsg))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_exec(db, sql, callback, data, errmsg)
        }else{
            return 0
        }
    }
    
    func sqlite3Finalize(_ pStmt: OpaquePointer!) {
        let call = self.makeCall(with: .sqlite3Finalize(.value(pStmt!)))
        self.calls.append(call)
        if self.forwardsCalls {
            sqlite3_finalize(pStmt)
        }
    }
    
    func sqlite3Step(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(with: .sqlite3Step(.value(pStmt!)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_step(pStmt)
        }else{
            return 0
        }
    }
    
    func sqlite3ColumnCount(_ pStmt: OpaquePointer!) -> Int32 {
        let call = self.makeCall(with: .sqlite3ColumnCount(pStmt))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_column_count(pStmt)
        }else{
            return 0
        }
    }
    
    func sqlite3ColumnValue(_ pStmt: OpaquePointer!, _ iCol: Int32) -> OpaquePointer! {
        let call = self.makeCall(with: .sqlite3ColumnValue(.value(pStmt), iCol))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_column_value(pStmt, iCol)
        }else{
            return self.sqlite3ColumnValueToReturn
        }
    }
    
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(with: .sqlite3ColumnText(.value(pStmt), iCol))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_column_text(pStmt, iCol)
        }else{
            return self.sqlite3ColumnTextToReturn
        }
    }
    
    func sqlite3ColumnInt(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        let call = self.makeCall(with: .sqlite3ColumnInt(.value(pStmt!), iCol))
        self.calls.append(call)
        if self.forwardsCalls {
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
        let call = self.makeCall(with: .sqlite3BindText(.value(pStmt), idx, String(cString: value), len, dtor))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_bind_text(pStmt, idx, value, len, dtor)
        }else{
            return 0
        }
    }
    
    func sqlite3BindInt(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Int32) -> Int32 {
        let call = self.makeCall(with: .sqlite3BindInt(pStmt, idx, value))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_bind_int(pStmt, idx, value)
        }else{
            return 0
        }
    }
    
    func sqlite3BindNull(_ pStmt: OpaquePointer!, _ idx: Int32) -> Int32 {
        let call = self.makeCall(with: .sqlite3BindNull(pStmt, idx))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_bind_null(pStmt, idx)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32 {
        let call = self.makeCall(with: .sqlite3ValueInt(.value(value)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_value_int(value)
        }else{
            return 0
        }
    }
    
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>! {
        let call = self.makeCall(with: .sqlite3ValueText(.value(value)))
        self.calls.append(call)
        if self.forwardsCalls {
            return sqlite3_value_text(value)
        }else{
            return nil
        }
    }
}
