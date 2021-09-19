import Foundation

class Mock<T>: NSObject where T: Equatable {
    typealias Call = MockCall<T>
    
    var nextCallId = 0
    var calls = [Call]()
    
    func makeCall(with callType: T) -> Call {
        let res = Call(id: self.nextCallId, callType: callType)
        self.nextCallId += 1
        return res
    }
}
