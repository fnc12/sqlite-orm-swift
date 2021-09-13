import Foundation

public enum SyncSchemaResult {
    
    /**
     *  created new table, table with the same tablename did not exist
     */
    case newTableCreated
    
    /**
     *  table schema is the same as storage, nothing to be done
     */
    case alredyInSync
    
    /**
     *  removed excess columns in table (than storage) without dropping a table
     */
    case oldColumnsRemoved
    
    /**
     *  lacking columns in table (than storage) added without dropping a table
     */
    case newColumnsAdded
    
    /**
     *  both old_columns_removed and new_columns_added
     */
    case newColumnsAddedAndOldColumnsRemoved
    
    /**
     *  old table is dropped and new is recreated. Reasons :
     *      1. delete excess columns in the table than storage if preseve = false
     *      2. Lacking columns in the table cannot be added due to NULL and DEFAULT constraint
     *      3. Reasons 1 and 2 both together
     *      4. data_type mismatch between table and storage.
     */
    case droppedAndRecreated
    
    var description: String {
        switch self {
        case .newTableCreated: return "new table created"
        case .alredyInSync: return "table and storage is already in sync."
        case .oldColumnsRemoved: return "old excess columns removed"
        case .newColumnsAdded: return "new columns added"
        case .newColumnsAddedAndOldColumnsRemoved: return "old excess columns removed and new columns added"
        case .droppedAndRecreated: return "old table dropped and recreated"
        }
    }
}
