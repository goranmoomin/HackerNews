
import Foundation
import PromiseKit
import FirebaseDatabase

extension DatabaseQuery {

    func observeSingleEvent(of eventType: DataEventType) -> Promise<DataSnapshot> {
        let promise = Promise<DataSnapshot> { resolver in
            observeSingleEvent(of: eventType, with: { dataSnapshot in
                resolver.fulfill(dataSnapshot)
            }, withCancel: { error in
                resolver.reject(error)
            })
        }
        return promise
    }
}
