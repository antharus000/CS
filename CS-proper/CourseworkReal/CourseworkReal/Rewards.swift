import SwiftUI
import FirebaseAuth


// Data is fetched from the 'rewards' Firestore collection on appear.
struct Rewards: View {
    @State private var reward: RewardModel?
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if isLoading {
                    ProgressView()
                } else if let reward = reward {

                   
                    // 10 circles in a 5x2 grid.
                    // coffeeCount MOD 10 gives progress within the current cycle,
                    
                    VStack(spacing: 5) {
                        Text("Rewards Progress")
                            .font(.headline)
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 5),
                            spacing: 12
                        ) {
                            ForEach(0..<10, id: \.self) { index in
                                Image(
                                    systemName: index < (reward.coffeeCount % 10)
                                        ? "checkmark.circle.fill"
                                        : "checkmark.circle"
                                )
                                .font(.title2)
                                .foregroundColor(
                                    index < (reward.coffeeCount % 10)
                                        ? Color.benEspresso
                                        : Color.benStone
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Free Coffee Balance
                    VStack(spacing: 8) {
                        Text("Free Coffees Available")
                            .font(.headline)
                        Text("\(reward.rewardBalance)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.brown)
                    }

                    Text("Total coffees purchased: \(reward.coffeeCount)")
                        .font(.caption)
                        .foregroundColor(.gray)

                } else {
                    Text("No rewards found")
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Rewards")
            .onAppear { loadRewards() }
        }
    }

    // loadRewards
    // Uses the Firebase Auth UID as the Firestore document key direct lookup, no query needed.
    func loadRewards() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            reward = try? await FirebaseService.shared.getRewards(accountID: uid)
            isLoading = false
        }
    }
}
