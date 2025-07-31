import SwiftUI

struct ColorCodeView: View {
    @ObservedObject var viewModel: ColorCodeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(viewModel.isOnline ? "Online" : "Offline")
                        .foregroundColor(viewModel.isOnline ? .green : .red)
                        .padding()
                    Spacer()
                }
                Button(action: {
                    viewModel.generateRandomColor()
                }) {
                    Text("Generate Color")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.colorCodes) { code in
                            HStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: code.hex))
                                    .frame(width: 60, height: 60)
                                VStack(alignment: .leading) {
                                    Text(code.hex)
                                        .font(.headline)
                                    Text("\(code.timestamp, formatter: dateFormatter)")
                                        .font(.caption)
                                }
                                Spacer()
                                if code.isSynced {
                                    Image(systemName: "icloud").foregroundColor(.blue)
                                } else {
                                    Image(systemName: "icloud.slash").foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Color Codes")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
