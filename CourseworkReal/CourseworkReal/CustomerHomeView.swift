import SwiftUI

struct CustomerHomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            RewardsView()
                .tabItem { Label("Rewards", systemImage: "gift") }

            ProfileView()
                .environmentObject(appState)
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
