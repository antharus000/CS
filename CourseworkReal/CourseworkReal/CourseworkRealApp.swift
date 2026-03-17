import SwiftUI
import FirebaseCore

@main
struct CourseworkRealApp: App {
    @StateObject var appState = AppState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
