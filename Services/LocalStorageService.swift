import Foundation

class LocalStorageService {
    private let key = "color_codes"
    
    func saveColorCodes(_ codes: [ColorCode]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(codes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadColorCodes() -> [ColorCode] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([ColorCode].self, from: data)) ?? []
    }
}
