import Foundation

struct ColorCode: Codable, Identifiable {
    let id: UUID
    let hex: String
    let timestamp: Date
    var isSynced: Bool
    
    init(hex: String, timestamp: Date = Date(), isSynced: Bool = false) {
        self.id = UUID()
        self.hex = hex
        self.timestamp = timestamp
        self.isSynced = isSynced
    }
}
