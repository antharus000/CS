import SwiftUI
import AVFoundation

// ScanView
// Admin-only tab. Opens the device camera to scan a customer QR code.
// On a successful scan the customer's account and rewards are fetched
// from Firestore and an action sheet is presented with two options:
//   - Add Stamp   increments coffeeCount; triggers reward at 10 (test 2.3)
//   - Redeem Reward  decrements rewardBalance by 1 (disabled if balance = 0)
// Double-scan guard: if the same UID is scanned again before the sheet is
// dismissed, a confirmation alert fires instead of acting immediately (test 2.7).

struct ScanView: View {
    @State private var scannedUID: String? = nil
    @State private var lastScannedUID: String? = nil
    @State private var account: AccountModel? = nil
    @State private var reward: RewardModel? = nil
    @State private var isLoading = false
    @State private var showActionSheet = false
    @State private var showDoubleAlert = false
    @State private var resultMessage = ""
    @State private var showResult = false

    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview fills the screen
                CameraPreview(scannedUID: $scannedUID)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Scan result / loading state at the bottom
                    if isLoading {
                        ProgressView()
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }

                    if showResult {
                        Text(resultMessage)
                            .font(.subheadline)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Scan")
            .onChange(of: scannedUID) { _, uid in
                guard let uid else { return }
                handleScan(uid: uid)
            }
            // Action sheet: Add Stamp or Redeem Reward
            .confirmationDialog(
                accountTitle(),
                isPresented: $showActionSheet,
                titleVisibility: .visible
            ) {
                Button("Add Stamp") { addStamp() }

                // Redeem is disabled (destructive label used as visual hint)
                // when rewardBalance is 0 -- replaced with a disabled-style button.
                if let reward, reward.rewardBalance > 0 {
                    Button("Redeem Free Coffee", role: .destructive) { redeemReward() }
                } else {
                    Button("Redeem Free Coffee (no balance)", role: .none) { }
                        .disabled(true)
                }

                Button("Cancel", role: .cancel) {
                    // Reset so the camera will accept the next scan
                    resetScan()
                }
            }
            // Double-scan confirmation (test 2.7)
            .alert("Scan Again?", isPresented: $showDoubleAlert) {
                Button("Add Another Stamp") { addStamp() }
                if let reward, reward.rewardBalance > 0 {
                    Button("Redeem Free Coffee", role: .destructive) { redeemReward() }
                }
                Button("Cancel", role: .cancel) { resetScan() }
            } message: {
                Text("This customer was just scanned. Are they buying more than one drink?")
            }
        }
    }

    // Builds a short summary string for the confirmation dialog title.
    private func accountTitle() -> String {
        guard let account, let reward else { return "Customer" }
        return "\(account.username) — \(reward.coffeeCount)/10 stamps · \(reward.rewardBalance) free"
    }

    // Called whenever a new UID comes in from the camera.
    // Checks for double-scan before fetching from Firestore.
    private func handleScan(uid: String) {
        // Double-scan guard: same UID as the last successful scan
        if uid == lastScannedUID && showActionSheet == false {
            showDoubleAlert = true
            return
        }

        isLoading = true
        showResult = false
        Task {
            async let fetchedAccount = FirebaseService.shared.getAccount(uid: uid)
            async let fetchedReward  = FirebaseService.shared.getRewards(accountID: uid)

            account = try? await fetchedAccount
            reward  = try? await fetchedReward
            isLoading = false

            if account != nil {
                lastScannedUID = uid
                showActionSheet = true
            } else {
                // Test 2.4: unrecognised QR code
                resultMessage = "Account not found. Please check the QR code."
                showResult = true
                resetScan()
            }
        }
    }

    // Delegates to FirebaseService; handles the coffeeCount = 9 → reward case (test 2.3).
    private func addStamp() {
        guard let uid = lastScannedUID else { return }
        Task {
            do {
                let message = try await FirebaseService.shared.addStamp(accountID: uid)
                resultMessage = message
            } catch {
                resultMessage = error.localizedDescription
            }
            showResult = true
            resetScan()
        }
    }

    private func redeemReward() {
        guard let uid = lastScannedUID else { return }
        Task {
            do {
                try await FirebaseService.shared.redeemReward(accountID: uid)
                resultMessage = "Free coffee redeemed successfully."
            } catch {
                resultMessage = error.localizedDescription
            }
            showResult = true
            resetScan()
        }
    }

    // Clears the scanned UID so the camera will accept the next code.
    private func resetScan() {
        scannedUID = nil
        showActionSheet = false
    }
}


// CameraPreview
// UIViewControllerRepresentable wrapper around AVCaptureSession.
// Decodes QR codes and publishes the first valid string via the binding.

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var scannedUID: String?

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(binding: $scannedUID) }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var binding: Binding<String?>
        init(binding: Binding<String?>) { self.binding = binding }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard
                let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                let value = obj.stringValue,
                binding.wrappedValue == nil   // only fire once per scan cycle
            else { return }

            DispatchQueue.main.async {
                self.binding.wrappedValue = value
            }
        }
    }
}


// ScannerViewController
// Manages the AVCaptureSession and preview layer lifecycle.

class ScannerViewController: UIViewController {
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    private var session: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }

    private func setupSession() {
        let session = AVCaptureSession()

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(delegate, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        self.session = session
    }
}
