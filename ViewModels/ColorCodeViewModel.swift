import Foundation
import Combine

class ColorCodeViewModel: ObservableObject {
    @Published var colorCodes: [ColorCode] = []
    @Published var isOnline: Bool = false
    
    private let localStorage = LocalStorageService()
    private let firebaseService = FirebaseService()
    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        colorCodes = localStorage.loadColorCodes()
        setupNetworkMonitor()
    }
    
    func generateRandomColor() {
        let hex = String(format: "#%06X", Int.random(in: 0x000000...0xFFFFFF))
        let colorCode = ColorCode(hex: hex)
        colorCodes.append(colorCode)
        localStorage.saveColorCodes(colorCodes)
        syncIfNeeded()
    }
    
    func syncIfNeeded() {
        guard isOnline else { return }
        let unsynced = colorCodes.filter { !$0.isSynced }
        guard !unsynced.isEmpty else { return }
        firebaseService.syncColorCodes(unsynced) { [weak self] result in
            switch result {
            case .success(let syncedIDs):
                self?.colorCodes = self?.colorCodes.map { code in
                    var mutable = code
                    if syncedIDs.contains(code.id) {
                        mutable.isSynced = true
                    }
                    return mutable
                } ?? []
                self?.localStorage.saveColorCodes(self?.colorCodes ?? [])
            case .failure:
                // Will retry when network is restored
                break
            }
        }
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.$isOnline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] online in
                self?.isOnline = online
                if online {
                    self?.syncIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
}
