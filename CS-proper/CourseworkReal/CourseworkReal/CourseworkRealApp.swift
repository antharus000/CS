import SwiftUI
import FirebaseCore

@main
struct CourseworkRealApp: App {
    @StateObject var appState = AppState()

    init() {
        // Reads GoogleService-Info.plist to connect to the Firebase project.
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Initial()
                .environmentObject(appState)
        }
    }
}
