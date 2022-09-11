import Foundation

protocol StorageCore: AnyObject {
    var filename: String { get }
    
    //  aggregate functions
    func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double, Error>
    func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double?, Error>
    func min<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue
    func min<T, F>(_ columnKeyPath: KeyPath<T, F>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue
    func max<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue
    func max<T, F>(_ columnKeyPath: KeyPath<T, F>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue
    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           separator: String,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error>
    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error>
    func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Int, Error>
    func count<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Int, Error>
    func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Double?, Error>
    
    //  CRUD
    func delete<T>(_ object: T) -> Result<Void, Error>
    func update<T>(_ object: T) -> Result<Void, Error>
    func get<T>(id: [Bindable]) -> Result<T?, Error> where T: Initializable
    func insert<T>(_ object: T) -> Result<Int64, Error>
    func replace<T>(_ object: T) -> Result<Void, Error>
    
    //  non-CRUD
    func select<R1, R2, R3>(_ expression1: Expression,
                            _ expression2: Expression,
                            _ expression3: Expression,
                            _ constraints: [SelectConstraint]) -> Result<[(R1, R2, R3)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue, R3: ConstructableFromSQLiteValue
    func select<R1, R2>(_ expression1: Expression,
                        _ expression2: Expression,
                        _ constraints: [SelectConstraint]) -> Result<[(R1, R2)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue
    func select<R>(_ expression: Expression,
                   _ constraints: [SelectConstraint]) -> Result<[R], Error> where R: ConstructableFromSQLiteValue
    func update<T>(all of: T.Type, _ set: AssignList, _ constraints: [SelectConstraint]) -> Result<Void, Error>
    func delete<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Void, Error>
    func getAll<T>(_ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable
    func getAll<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable
    func forEach<T>(_ all: T.Type, _ constraints: [SelectConstraint],
                    callback: (_ object: T) -> Void) -> Result<Void, Error> where T: Initializable
    
    //  schema
    func syncSchema(preserve: Bool) -> Result<[String: SyncSchemaResult], Error>
    func tableExists(with name: String) -> Result<Bool, Error>
    
    //  transactions
    func beginTransaction() -> Result<Void, Error>
    func commit() -> Result<Void, Error>
    func rollback() -> Result<Void, Error>
}
