import SwiftUI
import FirebaseAuth

// AdminView
// Three tabs: Home (stats), Users (account list + edit), Account (sign-out).

struct AdminView: View {
    @EnvironmentObject var appState: AppState
    @State private var accounts: [AccountModel] = []
    @State private var isLoading = true

    var body: some View {
        TabView {
            dashboardView
                .tabItem { Label("Home", systemImage: "house.fill") }

            accountsView
                .tabItem { Label("Users", systemImage: "person.3") }

            adminProfileView
                .tabItem { Label("Account", systemImage: "person") }
        }
        .tint(Color.benSlate)
    }

    // Dashboard
    // Summary stat cards. Counts derived from the loaded accounts array, so no extra Firestore query is needed.
    var dashboardView: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    StatCard(title: "Total Users", value: "\(accounts.count)", icon: "person.3", color: .blue)
                    StatCard(title: "Active", value: "\(accounts.filter { $0.status }.count)", icon: "checkmark.circle", color: .green)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Home")
            .onAppear { loadAccounts() }
        }
    }

    // Users Tab
    // Full account list. Tapping a row goes to AdminEditUserView.
    var accountsView: some View {
        NavigationView {
            List(accounts, id: \.accountID) { account in
                NavigationLink(destination: AdminEditUserView(account: account)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.username).font(.headline)
                        Text(account.email).font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("All Accounts")
            .onAppear { loadAccounts() }
        }
    }

    // Admin Profile Tab
    var adminProfileView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gear")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                Text("Benugo's Staff").font(.title).bold()
                Text("Signed in as: \(Auth.auth().currentUser?.email ?? "")")

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
            .navigationTitle("Account")
        }
    }

    func loadAccounts() {
        Task {
            accounts = (try? await FirebaseService.shared.getAllAccounts()) ?? []
            isLoading = false
        }
    }
}


// Reusable metric card for the admin dashboard.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            Text(value).font(.title).bold()
            Text(title).font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(12)
    }
}

// Hex Colour Extension
// Allows initialising a Color from a hex string.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
