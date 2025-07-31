import Foundation
import FirebaseFirestore

class FirebaseService {
    private let db = Firestore.firestore()
    private let collection = "colorCodes"
    
    func syncColorCodes(_ codes: [ColorCode], completion: @escaping (Result<[UUID], Error>) -> Void) {
        let group = DispatchGroup()
        var syncedIDs: [UUID] = []
        var lastError: Error?
        for code in codes {
            group.enter()
            let doc = db.collection(collection).document(code.id.uuidString)
            doc.setData([
                "hex": code.hex,
                "timestamp": code.timestamp,
            ]) { err in
                if let err = err {
                    lastError = err
                } else {
                    syncedIDs.append(code.id)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let err = lastError {
                completion(.failure(err))
            } else {
                completion(.success(syncedIDs))
            }
        }
    }
}
