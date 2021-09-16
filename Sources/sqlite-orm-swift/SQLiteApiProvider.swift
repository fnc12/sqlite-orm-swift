import SQLite3

protocol SQLiteApiProvider: AnyObject {
    var SQLITE_ROW: Int32 { get }
    var SQLITE_DONE: Int32 { get }
    var SQLITE_OK: Int32 { get }
    var SQLITE_STATIC: DestructorType { get }
    var SQLITE_TRANSIENT: DestructorType { get }
    
    typealias Int64 = sqlite3_int64
    typealias DestructorType = @convention(c) (UnsafeMutableRawPointer?) -> Void
    
    /**
     *  `sqlite3_open`
     */
    func sqlite3Open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32
    
    /**
     *  `sqlite3_errmsg`
     */
    func sqlite3Errmsg(_ ppDb: OpaquePointer!) -> UnsafePointer<CChar>!
    
    /**
     *  `sqlite3_close`
     */
    func sqlite3Close(_ ppDb: OpaquePointer!) -> Int32
    
    /**
     *  `sqlite3_last_insert_rowid`
     */
    func sqlite3LastInsertRowid(_ ppDb: OpaquePointer!) -> Int64
    
    /**
     *  `sqlite3_prepare_v2`
     */
    func sqlite3PrepareV2(_ db: OpaquePointer!,
                          _ zSql: UnsafePointer<CChar>!,
                          _ nByte: Int32,
                          _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!,
                          _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32
    
    typealias ExecCallback = (@convention(c) (UnsafeMutableRawPointer?,
                                              Int32,
                                              UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
                                              UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32)
    
    /**
     *  `sqlite3_exec`
     */
    func sqlite3Exec(_ db: OpaquePointer!,
                     _ sql: UnsafePointer<CChar>!,
                     _ callback: ExecCallback!,
                     _ data: UnsafeMutableRawPointer!,
                     _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32
    
    /**
     *  `sqlite3_finalize`
     */
    func sqlite3Finalize(_ pStmt: OpaquePointer!)
    
    /**
     *  `sqlite3_step`
     */
    func sqlite3Step(_ pStmt: OpaquePointer!) -> Int32
    
    /**
     *  `sqlite3_column_count`
     */
    func sqlite3ColumnCount(_ pStmt: OpaquePointer!) -> Int32
    
    /**
     *  `sqlite3_column_value`
     */
    func sqlite3ColumnValue(_ pStmt: OpaquePointer!, _ iCol: Int32) -> OpaquePointer!
    
    /**
     *  `sqlite3_column_text`
     */
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>!
    
    /**
     *  `sqlite3_column_int`
     */
    func sqlite3ColumnInt(_ pStmt: OpaquePointer!, _ iCol: Int32) -> Int32
    
    /**
     *  `sqlite3_bind_text`
     */
    func sqlite3BindText(_ pStmt: OpaquePointer!,
                         _ idx: Int32,
                         _ value: UnsafePointer<CChar>!,
                         _ len: Int32,
                         _ dtor: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32
    
    /**
     *  `sqlite3_bind_int`
     */
    func sqlite3BindInt(_ pStmt: OpaquePointer!, _ idx: Int32, _ value: Int32) -> Int32
    
    /**
     *  `sqlite3_bind_null`
     */
    func sqlite3BindNull(_ pStmt: OpaquePointer!, _ idx: Int32) -> Int32
    
    /**
     *  `sqlite3_value_int`
     */
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32
    
    /**
     *  `sqlite3_value_text`
     */
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>!
}

final class SQLiteApiProviderImpl: SQLiteApiProvider {
    
    func sqlite3ValueText(_ value: OpaquePointer!) -> UnsafePointer<UInt8>! {
        return sqlite3_value_text(value)
    }
    
    func sqlite3ValueInt(_ value: OpaquePointer!) -> Int32 {
        return sqlite3_value_int(value)
    }
    
    func sqlite3BindNull(_ pStmt: OpaquePointer!, _ idx: Int32) -> Int32 {
        return sqlite3_bind_null(pStmt, idx)
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
    
    func sqlite3ColumnText(_ pStmt: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>! {
        return sqlite3_column_text(pStmt, iCol)
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
    
    let SQLITE_ROW: Int32 = SQLite3.SQLITE_ROW
    let SQLITE_DONE: Int32 = SQLite3.SQLITE_DONE
    let SQLITE_OK: Int32 = SQLite3.SQLITE_OK
    
    let SQLITE_STATIC: DestructorType = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT: DestructorType = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
}
