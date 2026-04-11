import SwiftUI
import FirebaseAuth

// Initial
// Checks whether a Firebase Auth session already exists on launch
// and routes to the correct screen without requiring the user to log in again.
// Also controls the first-time tutorial (SC 14).
// Possible states:
//   isLoading == true         show spinner
//   userRole == "admin"       show AdminView
//   userRole == "customer"    show CustomerView (with tutorial if first login)
//   userRole == nil           show AuthView

struct Initial: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = true

    // true until the user completes the tutorial once.
    // writes to UserDefaults so it survives app restarts.
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let role = appState.userRole {
                if role == "admin" {
                    AdminView()
                } else {
                    // Show tutorial on first login, then CustomerView after
                    if !hasSeenTutorial {
                        TutorialView(hasSeenTutorial: $hasSeenTutorial)
                    } else {
                        CustomerView()
                    }
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

// TutorialView (SC 14)
// Shown once to new customers after their first login.
// Explains the three core features: Rewards, Busyness, and Profile.
// Once dismissed, hasSeenTutorial is set to true so it never appears again.

struct TutorialView: View {
    @Binding var hasSeenTutorial: Bool

    // Each page is a (icon, title, description) stored in a tuple
    private let pages: [(String, String, String)] = [
        (
            "gift.fill",
            "Your Rewards",
            "Every coffee earns you a stamp. Collect 10 stamps and you get a free coffee. Your progress is saved to your account so you never lose it."
        ),
        (
            "person.circle.fill",
            "Your Profile",
            "Sign in from any device and your rewards will always be up to date. Tap Profile to see your account details or sign out."
        ),
        (
            "checkmark.seal.fill",
            "You're all set!",
            "Show your QR code at the counter when you buy a coffee and the barista will scan it for you. Enjoy!"
        )
    ]

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.benCream.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Page indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.benForest : Color.benStone)
                            .frame(width: 8, height: 8)
                    }
                }

                // Tutorial page content
                VStack(spacing: 20) {
                    Image(systemName: pages[currentPage].0)
                        .font(.system(size: 64))
                        .foregroundColor(Color.benForest)

                    Text(pages[currentPage].1)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.benEspresso)
                        .multilineTextAlignment(.center)

                    Text(pages[currentPage].2)
                        .font(.system(size: 15))
                        .foregroundColor(Color.benSlate)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Next and Get Started button
                Button(action: advance) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 15, weight: .medium))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.benForest)
                        .foregroundColor(Color.benCream)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // Moves to the next page, or marks the tutorial as complete on the last page.
    func advance() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            // so the tutorial never shows again (SC 14)
            hasSeenTutorial = true
        }
    }
}
