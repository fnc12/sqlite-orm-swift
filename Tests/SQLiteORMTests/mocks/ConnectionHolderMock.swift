import Foundation
@testable import SQLiteORM

class ConnectionHolderMock: Mock<ConnectionHolderCallType> {
    var dbMaybe: OpaquePointer?
    var apiProvider: SQLiteApiProvider
    var filename: String
    var errorMessage: String = ""

    init(dbMaybe: OpaquePointer?, apiProvider: SQLiteApiProvider, filename: String) {
        self.dbMaybe = dbMaybe
        self.apiProvider = apiProvider
        self.filename = filename
        super.init()
    }
}

enum ConnectionHolderCallType: Equatable {
    case increment
    case decrementUnsafe
    case decrement
}

extension ConnectionHolderMock: ConnectionHolder {
    func increment() -> Result<Void, Error> {
        let call = self.makeCall(with: .increment)
        self.calls.append(call)
        return .success(())
    }

    func decrementUnsafe() {
        let call = self.makeCall(with: .decrementUnsafe)
        self.calls.append(call)
    }

    func decrement() -> Result<Void, Error> {
        let call = self.makeCall(with: .decrement)
        self.calls.append(call)
        return .success(())
    }
    
    func createConnectionRef() -> Result<SafeConnectionRef, Error> {
        fatalError()
    }
}
