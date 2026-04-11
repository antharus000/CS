import SwiftUI
// TabView provides the bottom navigation bar so Rewards and Profile
// are always reachable from any screen without navigating back.
// Additional tabs (Busyness, Promotions) will be added in later iterations.
struct CustomerView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            Rewards()
                .tabItem { Label("Rewards", systemImage: "gift") }

            Profile()
                .environmentObject(appState)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(Color.benSlate)
    }
}
