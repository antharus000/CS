import SwiftUI
import FirebaseAuth

struct Rewards: View {
    @State private var reward: RewardModel?
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if isLoading {
                    ProgressView()
                } else if let reward = reward {
                    VStack(spacing: 5) {
                        Text("Coffee Stamps")
                            .font(.headline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(0..<10, id: \.self) { index in
                                Image(systemName: index < (reward.coffeeCount % 10) ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(index < (reward.coffeeCount % 10) ? .brown : .gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

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
            .navigationTitle("My Rewards")
            .onAppear { loadRewards() }
        }
    }

    func loadRewards() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            reward = try? await FirebaseService.shared.getRewards(accountID: uid)
            isLoading = false
        }
    }
}
