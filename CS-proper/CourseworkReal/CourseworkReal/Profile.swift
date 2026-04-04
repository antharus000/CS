import SwiftUI
import FirebaseAuth

struct Profile: View {
    @EnvironmentObject var appState: AppState
    @State private var account: AccountModel?
//this section is for when a customer view's their own account details
//this just shows a basic logout and their email they are logged in as.
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)

                if let account = account {
                    Text(account.username)
                        .font(.title).bold()
                    Text("Signed in as: \(Auth.auth().currentUser?.email ?? "")")
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
//checks the database for the users infomation and loads the users data
    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            account = try? await FirebaseService.shared.getAccount(uid: uid)
        }
    }
}
