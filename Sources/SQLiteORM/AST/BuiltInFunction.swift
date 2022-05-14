import Foundation

public enum BuiltInFunction {
    case abs(x: Expression)
    case changes
    case char(arguments: [Expression])
    case coalesce(arguments: [Expression])
    case format(arguments: [Expression])
    case glob(x: Expression, y: Expression)
    case hex(x: Expression)
    case ifnull(x: Expression, y: Expression)
    case iif(x: Expression, y: Expression, z: Expression)
    case instr(x: Expression, y: Expression)
    case lastInsertRowid
    case length(x: Expression)
    case like2(x: Expression, y: Expression)
    case like3(x: Expression, y: Expression, z: Expression)
    case likelihood(x: Expression, y: Expression)
    case likely(x: Expression)
    case loadExtension1(x: Expression)
    case loadExtension2(x: Expression, y: Expression)
    case lower(x: Expression)
    case ltrim1(x: Expression)
    case ltrim2(x: Expression, y: Expression)
    case max(arguments: [Expression])
    case min(arguments: [Expression])
    case nullif(x: Expression, y: Expression)
    case printf(argruments: [Expression])
    case random
    case randomblob(x: Expression)
    case replace(x: Expression, y: Expression, z: Expression)
    case round1(x: Expression)
    case round2(x: Expression, y: Expression)
    case rtrim1(x: Expression)
    case rtrim2(x: Expression, y: Expression)
    case sign(x: Expression)
    case soundex(x: Expression)
    case sqliteCompileOptionGet(x: Expression)
    case sqliteCompileOptionUsed(x: Expression)
    case sqliteOffset(x: Expression)
    case sqliteSourceId
    case sqliteVersion
    case substr3(x: Expression, y: Expression, z: Expression)
    case substr2(x: Expression, y: Expression)
    case substring3(x: Expression, y: Expression, z: Expression)
    case substring2(x: Expression, y: Expression)
    case totalChanges
    case trim1(x: Expression)
    case trim2(x: Expression, y: Expression)
    case typeof(x: Expression)
    case unicode(x: Expression)
    case unlikely(x: Expression)
    case upper(x: Expression)
    case zeroblob(x: Expression)
    
    fileprivate var name: String {
        switch self {
        case .abs: return "ABS"
        case .changes: return "CHANGES"
        case .char: return "CHAR"
        case .coalesce: return "COALESCE"
        case .format: return "FORMAT"
        case .glob: return "GLOB"
        case .hex: return "HEX"
        case .ifnull: return "IFNULL"
        case .iif: return "IIF"
        case .instr: return "INSTR"
        case .lastInsertRowid: return "LAST_INSERT_ROWID"
        case .length: return "LENGTH"
        case .like2, .like3: return "LIKE"
        case .likelihood: return "LIKELIHOOD"
        case .likely: return "LIKELY"
        case .loadExtension1, .loadExtension2: return "LOAD_EXTENSION"
        case .lower: return "LOWER"
        case .ltrim1, .ltrim2: return "LTRIM"
        case .max: return "MAX"
        case .min: return "MIN"
        case .nullif: return "NULLIF"
        case .printf: return "PRINTF"
        case .random: return "RANDOM"
        case .randomblob: return "RANDOMBLOB"
        case .replace: return "REPLACE"
        case .round1, .round2: return "ROUND"
        case .rtrim1, .rtrim2: return "RTRIM"
        case .sign: return "SIGN"
        case .soundex: return "SOUNDEX"
        case .sqliteCompileOptionGet: return "SQLITE_COMPILEOPTION_GET"
        case .sqliteCompileOptionUsed: return "SQLITE_COMPILEOPTION_USED"
        case .sqliteOffset: return "SQLITE_OFFSET"
        case .sqliteSourceId: return "SQLITE_SOURCE_ID"
        case .sqliteVersion: return "SQLITE_VERSION"
        case .substr3, .substr2: return "SUBSTR"
        case .substring3, .substring2: return "SUBSTRING"
        case .totalChanges: return "TOTAL_CHANGES"
        case .trim1, .trim2: return "TRIM"
        case .typeof: return "TYPEOF"
        case .unicode: return "UNICODE"
        case .unlikely: return "UNLIKELY"
        case .upper: return "UPPER"
        case .zeroblob: return "ZEROBLOB"
        }
    }
    
    fileprivate var arguments: [Expression] {
        switch self {
        case .abs(let x):
            return [x]
        case .changes:
            return []
        case .char(let arguments):
            return arguments
        case .coalesce(let arguments):
            return arguments
        case .format(let arguments):
            return arguments
        case .glob(let x, let y):
            return [x, y]
        case .hex(let x):
            return [x]
        case .ifnull(let x, let y):
            return [x, y]
        case .iif(let x, let y, let z):
            return [x, y, z]
        case .instr(let x, let y):
            return [x, y]
        case .lastInsertRowid:
            return []
        case .length(let x):
            return [x]
        case .like2(let x, let y):
            return [x, y]
        case .like3(let x, let y, let z):
            return [x, y, z]
        case .likelihood(let x, let y):
            return [x, y]
        case .likely(let x):
            return [x]
        case .loadExtension1(let x):
            return [x]
        case .loadExtension2(let x, let y):
            return [x, y]
        case .lower(let x):
            return [x]
        case .ltrim1(let x):
            return [x]
        case .ltrim2(let x, let y):
            return [x, y]
        case .max(let arguments):
            return arguments
        case .min(let arguments):
            return arguments
        case .nullif(let x, let y):
            return [x, y]
        case .printf(let argruments):
            return argruments
        case .random:
            return []
        case .randomblob(let x):
            return [x]
        case .replace(let x, let y, let z):
            return [x, y, z]
        case .round1(let x):
            return [x]
        case .round2(let x, let y):
            return [x, y]
        case .rtrim1(let x):
            return [x]
        case .rtrim2(let x, let y):
            return [x, y]
        case .sign(let x):
            return [x]
        case .soundex(let x):
            return [x]
        case .sqliteCompileOptionGet(let x):
            return [x]
        case .sqliteCompileOptionUsed(let x):
            return [x]
        case .sqliteOffset(let x):
            return [x]
        case .sqliteSourceId, .sqliteVersion:
            return []
        case .substr3(let x, let y, let z):
            return [x, y, z]
        case .substr2(let x, let y):
            return [x, y]
        case .substring3(let x, let y, let z):
            return [x, y, z]
        case .substring2(let x, let y):
            return [x, y]
        case .totalChanges:
            return []
        case .trim1(let x):
            return [x]
        case .trim2(let x, let y):
            return [x, y]
        case .typeof(let x):
            return [x]
        case .unicode(let x):
            return [x]
        case .unlikely(let x):
            return [x]
        case .upper(let x):
            return [x]
        case .zeroblob(let x):
            return [x]
        }
    }
}

extension BuiltInFunction: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let arguments = self.arguments
        var result = "\(self.name)("
        for (i, argument) in arguments.enumerated() {
            result += try argument.serialize(with: serializationContext)
            if i < arguments.count - 1 {
                result += ", "
            }
        }
        result += ")"
        return result
    }
}

extension BuiltInFunction: Expression {
    
}

extension BuiltInFunction: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        self.arguments.forEach(routine)
    }
}
