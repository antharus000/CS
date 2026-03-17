import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        TabView {
            RewardsView()
                .tabItem {
                    Label("Rewards", systemImage: "gift")
                }

            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
