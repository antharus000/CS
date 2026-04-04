//
//  AdminEditUserView.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import SwiftUI

struct AdminEditUserView: View {
    let account: AccountModel

    @State private var username: String = ""
    @State private var coffeeCount: String = ""
    @State private var rewardBalance: String = ""
    @State private var reward: RewardModel? = nil
    @State private var successMessage = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        Form {
            Section(header: Text("Account Info")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(account.email)
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Status")
                    Spacer()
                    Text(account.status ? "Active" : "Inactive")
                        .foregroundColor(account.status ? .green : .red)
                }

                Button(account.status ? "Deactivate Account" : "Activate Account") {
                    toggleStatus()
                }
                .foregroundColor(account.status ? .red : .green)
            }

            Section(header: Text("Edit Username")) {
                TextField("Username", text: $username)
                    .autocapitalization(.none)

                Button("Save Username") {
                    saveUsername()
                }
                .disabled(username.isEmpty || isLoading)
            }

            Section(header: Text("Edit Rewards")) {
                HStack {
                    Text("Coffee Count")
                    Spacer()
                    TextField("0", text: $coffeeCount)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                HStack {
                    Text("Reward Balance")
                    Spacer()
                    TextField("0", text: $rewardBalance)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                Button("Save Rewards") {
                    saveRewards()
                }
                .disabled(isLoading)
            }

            if !successMessage.isEmpty {
                Section {
                    Text(successMessage)
                        .foregroundColor(.green)
                }
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(account.username)
        .onAppear { loadData() }
    }

    func loadData() {
        username = account.username
        Task {
            if let r = try? await FirebaseService.shared.getRewardsByAccountID(accountID: account.accountID) {
                reward = r
                coffeeCount = "\(r.coffeeCount)"
                rewardBalance = "\(r.rewardBalance)"
            } else {
                coffeeCount = "0"
                rewardBalance = "0"
            }
        }
    }

    func saveUsername() {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        Task {
            do {
                try await FirebaseService.shared.updateUsername(
                    accountID: account.accountID,
                    newUsername: username
                )
                successMessage = "Username updated successfully"
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func saveRewards() {
        guard let coffee = Int(coffeeCount), let balance = Int(rewardBalance) else {
            errorMessage = "Please enter valid numbers"
            return
        }
        isLoading = true
        errorMessage = ""
        successMessage = ""
        Task {
            do {
                try await FirebaseService.shared.updateRewards(
                    accountID: account.accountID,
                    coffeeCount: coffee,
                    rewardBalance: balance
                )
                successMessage = "Rewards updated successfully"
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func toggleStatus() {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        Task {
            do {
                try await FirebaseService.shared.toggleAccountStatus(
                    accountID: account.accountID,
                    currentStatus: account.status
                )
                successMessage = "Account status updated"
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
