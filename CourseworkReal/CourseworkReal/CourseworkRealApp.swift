import SwiftUI
import FirebaseCore

@main
struct CourseworkRealApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
