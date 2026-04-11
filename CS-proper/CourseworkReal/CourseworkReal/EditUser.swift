import SwiftUI
import FirebaseAuth


// Allows an admin to view and modify a specific customer account.
//  Toggle account active/inactive
//  Update username
//  Manually set coffeeCount and rewardBalance
// Guards prevent an admin editing their own account (SC 12: fraud prevention)
// and enforce the valid range of coffeeCount (0-9).
struct AdminEditUserView: View {
    let account: AccountModel

    @State private var username: String = ""
    @State private var coffeeCount: String = ""
    @State private var rewardBalance: String = ""
    @State private var reward: RewardModel? = nil
    @State private var successMessage = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    // Check whether the currently signed-in admin is viewing their own account.
    // Admins must not be able to award themselves rewards (SC 12).
    private var isOwnAccount: Bool {
        Auth.auth().currentUser?.uid == account.accountID
    }

    var body: some View {
        Form {

            
            // If an admin navigates to their own account, show a clear
            // notice and block all edit actions
            if isOwnAccount {
                Section {
                    Label(
                        "You cannot edit your own account. Contact another admin.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundColor(.orange)
                }
            }

            // Account Info (read-only)
            Section(header: Text("Account Info")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(account.email).foregroundColor(.gray)
                }
                HStack {
                    Text("Role")
                    Spacer()
                    Text(account.accountID == Auth.auth().currentUser?.uid ? "Admin (you)" : "Customer")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    Text(account.status ? "Active" : "Inactive")
                        .foregroundColor(account.status ? .green : .red)
                }

                // Disable toggle if this is the admin's own account
                if !isOwnAccount {
                    Button(account.status ? "Deactivate Account" : "Activate Account") {
                        toggleStatus()
                    }
                    .foregroundColor(account.status ? .red : .green)
                }
            }

            // Username Edit
            if !isOwnAccount {
                Section(header: Text("Edit Username")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)

                    Button("Save Username") {
                        saveUsername()
                    }
                    // Disabled while loading or if the field is blank
                    .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }

                // Rewards Edit
                // coffeeCount is validated to 0-9 inclusive before writing.
                // The iteration 1 known bug (count could exceed 9 without
                // triggering a reward) is fixed here with an explicit range check.
                Section(header: Text("Edit Rewards")) {
                    HStack {
                        Text("Coffee Count (0–9)")
                        Spacer()
                        TextField("0", text: $coffeeCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }

                    HStack {
                        Text("Reward Balance")
                        Spacer()
                        TextField("0", text: $rewardBalance)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }

                    Button("Save Rewards") {
                        saveRewards()
                    }
                    .disabled(isLoading)
                }
            }

            // error and success message
            if !successMessage.isEmpty {
                Section {
                    Text(successMessage).foregroundColor(.green)
                }
            }
            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
        }
        .navigationTitle(account.username)
        .onAppear { loadData() }
    }

    
    // Pre-fills editable fields with current Firestore values.
    func loadData() {
        username = account.username
        Task {
            if let r = try? await FirebaseService.shared.getRewardsByAccountID(accountID: account.accountID) {
                reward = r
                coffeeCount   = "\(r.coffeeCount)"
                rewardBalance = "\(r.rewardBalance)"
            } else {
                coffeeCount   = "0"
                rewardBalance = "0"
            }
        }
    }

    
    func saveUsername() {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Username cannot be blank."
            return
        }
        isLoading = true
        errorMessage = ""
        successMessage = ""
        Task {
            do {
                try await FirebaseService.shared.updateUsername(
                    accountID: account.accountID,
                    newUsername: trimmed
                )
                successMessage = "Username updated successfully."
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

   
  
    //  both fields are valid integers
    //  coffeeCount is in range 0-9 (fixes the iteration 1 known bug
    //    where count could exceed 9 without triggering a reward reset)
    //  rewardBalance is not negative
    func saveRewards() {
        guard let coffee  = Int(coffeeCount),
              let balance = Int(rewardBalance) else {
            errorMessage = "Please enter valid whole numbers."
            return
        }

        // coffeeCount must be 0-9 inclusive
        guard coffee >= 0, coffee <= 9 else {
            errorMessage = "Coffee count must be between 0 and 9."
            return
        }

        // rewardBalance must not be negative
        guard balance >= 0 else {
            errorMessage = "Reward balance cannot be negative."
            return
        }

        isLoading = true
        errorMessage = ""
        successMessage = ""
        Task {
            do {
                try await FirebaseService.shared.updateRewards(
                    accountID:     account.accountID,
                    coffeeCount:   coffee,
                    rewardBalance: balance
                )
                successMessage = "Rewards updated successfully."
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
                    accountID:     account.accountID,
                    currentStatus: account.status
                )
                successMessage = "Account status updated."
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
