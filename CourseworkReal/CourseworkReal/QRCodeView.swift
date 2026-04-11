import SwiftUI
import FirebaseAuth
import CoreImage.CIFilterBuiltins

// QRCodeView
// Generates and displays a QR code encoding the customer's Firebase UID.
// The admin scans this at the counter to add a stamp or redeem a reward.

struct QRCodeView: View {
    private let uid: String

    init() {
        self.uid = Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.benCream.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Show this at the counter")
                        .font(.subheadline)
                        .foregroundColor(Color.benSlate)

                    if let image = generateQR(from: uid) {
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    } else {
                        Text("Unable to generate QR code.")
                            .foregroundColor(.red)
                    }

                    Text("Your rewards are linked to your account.\nThis code is unique to you.")
                        .font(.caption)
                        .foregroundColor(Color.benSlate)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("My QR Code")
        }
    }

    // Renders the UID string into a UIImage using CoreImage's QR filter.
    // .none interpolation keeps the pixels crisp when scaled up.
    private func generateQR(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let ciImage = filter.outputImage,
              let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
