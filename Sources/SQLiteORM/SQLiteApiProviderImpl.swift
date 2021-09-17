import Foundation
import SQLite3

final class SQLiteApiProviderImpl: SQLiteApiProvider {
    
    func sqlite3ValueType(_ value: OpaquePointer!) -> Int32 {
        return sqlite3_value_type(value)
    }
    
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>! {
        return sqlite3_value_text(value)
    }
    
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32 {
        return sqlite3_value_int(value)
    }
    
    func sqlite3ValueDouble(_ value: OpaquePointer!) -> Double {
        return sqlite3_value_double(value)
    }
    
    func sqlite3BindNull(_ pStmt: OpaquePointer!, _ idx: Int32) -> Int32 {
        return sqlite3_bind_null(pStmt, idx)
    }
    
    func sqlite3BindDouble(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Double) -> Int32 {
        return sqlite3_bind_double(pStmt, idx, value)
    }
    
    func sqlite3BindInt(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Int32) -> Int32 {
        return sqlite3_bind_int(pStmt, idx, value)
    }
    
    func sqlite3BindText(_ pStmt: OpaquePointer!,
                         _ idx: Int32,
                         _ value: UnsafePointer<CChar>!,
                         _ len: Int32,
                         _ dtor: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32 {
        return sqlite3_bind_text(pStmt, idx, value, len, dtor)
    }
    
    static let shared = SQLiteApiProviderImpl()
    
    func sqlite3ColumnInt(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        return sqlite3_column_int(pStmt, iCol)
    }
    
    func sqlite3ColumnDouble(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Double {
        return sqlite3_column_double(pStmt, iCol)
    }
    
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        return sqlite3_column_text(pStmt, iCol)
    }
    
    func sqlite3ColumnType(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32 {
        return sqlite3_column_type(pStmt, iCol)
    }
    
    func sqlite3ColumnValue(_ pStmt: OpaquePointer!, _ iCol: Int32) -> OpaquePointer! {
        return sqlite3_column_value(pStmt, iCol)
    }
    
    func sqlite3ColumnCount(_ pStmt: OpaquePointer!) -> Int32 {
        return sqlite3_column_count(pStmt)
    }
    
    func sqlite3Step(_ pStmt: OpaquePointer!) -> Int32 {
        return sqlite3_step(pStmt)
    }
    
    func sqlite3Finalize(_ pStmt: OpaquePointer!) {
        sqlite3_finalize(pStmt)
    }
    
    func sqlite3Exec(_ db: OpaquePointer!,
                     _ sql: UnsafePointer<CChar>!,
                     _ callback: ExecCallback!,
                     _ data: UnsafeMutableRawPointer!,
                     _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32 {
        return sqlite3_exec(db, sql, callback, data, errmsg)
    }
    
    func sqlite3PrepareV2(_ db: OpaquePointer!,
                          _ zSql: UnsafePointer<CChar>!,
                          _ nByte: Int32,
                          _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!,
                          _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32 {
        return sqlite3_prepare_v2(db, zSql, nByte, ppStmt, pzTail)
    }
    
    func sqlite3LastInsertRowid(_ ppDb: OpaquePointer!) -> SQLiteApiProvider.Int64 {
        return sqlite3_last_insert_rowid(ppDb)
    }
    
    func sqlite3Close(_ ppDb: OpaquePointer!) -> Int32 {
        return sqlite3_close(ppDb)
    }
    
    func sqlite3Errmsg(_ ppDb: OpaquePointer!) -> UnsafePointer<CChar>! {
        return sqlite3_errmsg(ppDb)
    }
    
    func sqlite3Open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32 {
        return sqlite3_open(filename, ppDb)
    }
    
    let SQLITE_INTEGER: Int32 = SQLite3.SQLITE_INTEGER
    let SQLITE_FLOAT: Int32 = SQLite3.SQLITE_FLOAT
    let SQLITE_BLOB: Int32 = SQLite3.SQLITE_BLOB
    let SQLITE_NULL: Int32 = SQLite3.SQLITE_NULL
    let SQLITE_TEXT: Int32 = SQLite3.SQLITE_TEXT
    
    let SQLITE_ROW: Int32 = SQLite3.SQLITE_ROW
    let SQLITE_DONE: Int32 = SQLite3.SQLITE_DONE
    let SQLITE_OK: Int32 = SQLite3.SQLITE_OK
    
    let SQLITE_STATIC: DestructorType = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT: DestructorType = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
}
