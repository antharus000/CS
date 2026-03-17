import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var account: AccountModel?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)

                if let account = account {
                    Text(account.username)
                        .font(.title).bold()
                    Text(account.email)
                        .foregroundColor(.gray)
                }

                Button("Sign Out") {
                    try? Auth.auth().signOut()
                    appState.userRole = nil
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                Spacer()
            }
            .navigationTitle("Profile")
            .onAppear { loadProfile() }
        }
    }

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            account = try? await FirebaseService.shared.getAccount(uid: uid)
        }
    }
}
