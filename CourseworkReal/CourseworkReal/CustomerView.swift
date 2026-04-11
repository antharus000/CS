import SwiftUI

struct CustomerView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            Rewards()
                .tabItem { Label("Rewards", systemImage: "gift") }

            QRCodeView()                                          // NEW
                .tabItem { Label("My QR", systemImage: "qrcode") } // NEW

            Profile()
                .environmentObject(appState)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(Color.benSlate)
    }
}
