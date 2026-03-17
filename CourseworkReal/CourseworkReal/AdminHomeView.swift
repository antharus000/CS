import SwiftUI
import FirebaseAuth

struct AdminHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var accounts: [AccountModel] = []
    @State private var isLoading = true

    var body: some View {
        TabView {
            dashboardView
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }

            accountsView
                .tabItem { Label("Accounts", systemImage: "person.3") }

            adminProfileView
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }

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
            .navigationTitle("Dashboard")
            .onAppear { loadAccounts() }
        }
    }

    var accountsView: some View {
        NavigationView {
            List(accounts, id: \.accountID) { account in
                NavigationLink(destination: AdminEditUserView(account: account)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.username).font(.headline)
                        Text(account.email).font(.caption).foregroundColor(.gray)
                        Text(account.status ? "Active" : "Inactive")
                            .font(.caption2)
                            .foregroundColor(account.status ? .green : .red)
                    }
                }
            }
            .navigationTitle("All Accounts")
            .onAppear { loadAccounts() }
        }
    }

    var adminProfileView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                Text("Administrator").font(.title).bold()
                Text(Auth.auth().currentUser?.email ?? "").foregroundColor(.gray)

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
        }
    }

    func loadAccounts() {
        Task {
            accounts = (try? await FirebaseService.shared.getAllAccounts()) ?? []
            isLoading = false
        }
    }
}

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
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
