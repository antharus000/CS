import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let role = appState.userRole {
                if role == "admin" {
                    AdminHomeView()
                } else {
                    CustomerHomeView()
                }
            } else {
                AuthView()
            }
        }
        .onAppear { checkSession() }
    }

    func checkSession() {
        if let uid = Auth.auth().currentUser?.uid {
            Task {
                let role = try? await FirebaseService.shared.getUserRole(uid: uid)
                appState.userRole = role ?? "customer"
                isLoading = false
            }
        } else {
            isLoading = false
        }
    }
}
