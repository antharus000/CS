//
//  RewardsView.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import SwiftUI
import FirebaseAuth

struct RewardsView: View {
    @State private var reward: Reward?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 30) {
            Text("Your Rewards")
                .font(.largeTitle)
                .bold()

            if isLoading {
                ProgressView()
            } else if let reward = reward {
                // Coffee stamp card
                VStack(spacing: 10) {
                    Text("Coffee Stamps")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(0..<10, id: \.self) { index in
                            Image(systemName: index < (reward.coffeeCount % 10) ? "cup.and.saucer.fill" : "cup.and.saucer")
                                .font(.title2)
                                .foregroundColor(index < (reward.coffeeCount % 10) ? .brown : .gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                VStack(spacing: 8) {
                    Text("Reward Balance")
                        .font(.headline)
                    Text("\(reward.rewardBalance)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.brown)
                    Text("free coffees available")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text("Total coffees: \(reward.coffeeCount)")
                    .font(.caption)
                    .foregroundColor(.gray)

            } else {
                Text("No rewards found")
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .onAppear { loadRewards() }
    }

    func loadRewards() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            reward = try? await FirebaseService.shared.getRewards(accountID: uid)
            isLoading = false
        }
    }
}
