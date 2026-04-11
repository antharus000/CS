import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    // Registration
    // Creates a Firebase Auth account then writes two Firestore tables:
    // one in 'accounts' and one in 'rewards', both keyed by the Auth UID.
    // role is hardcoded to "customer" -- admin promotion is done via the
    // Firebase Console only, so no user can self-promote.
    func registerUser(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        try await db.collection("accounts").document(uid).setData([
            "accountID":   uid,
            "username":    username,
            "email":       email,
            "status":      true,
            "role":        "customer",
            "createdDate": Timestamp()
        ])

        // Initialise rewards at zero
        try await db.collection("rewards").document(uid).setData([
            "rewardID":      uid,
            "accountID":     uid,
            "coffeeCount":   0,
            "rewardBalance": 0
        ])
    }

    // Role Lookup
    // Called after login so Initial.swift can direct the user correctly.
    // Defaults to "customer" if the field is missing
    func getUserRole(uid: String) async throws -> String {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        return doc.data()?["role"] as? String ?? "customer"
    }

    // Single Account Lookup
    func getAccount(uid: String) async throws -> AccountModel? {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        return AccountModel(
            accountID:   data["accountID"]   as? String ?? "",
            username:    data["username"]    as? String ?? "",
            email:       data["email"]       as? String ?? "",
            status:      data["status"]      as? Bool   ?? true,
            createdDate: (data["createdDate"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    //  Rewards Lookup (customer)
    // Used by Rewards.swift to display the signed-in customer's stamp progress.
    func getRewards(accountID: String) async throws -> RewardModel? {
        let doc = try await db.collection("rewards").document(accountID).getDocument()
        guard let data = doc.data() else { return nil }
        return RewardModel(
            rewardID:      data["rewardID"]      as? String ?? "",
            accountID:     data["accountID"]     as? String ?? "",
            coffeeCount:   data["coffeeCount"]   as? Int    ?? 0,
            rewardBalance: data["rewardBalance"] as? Int    ?? 0
        )
    }

    // see All Accounts (admin only)
    // Firestore security rules restrict this to admin-role only.
    func getAllAccounts() async throws -> [AccountModel] {
        let snapshot = try await db.collection("accounts").getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return AccountModel(
                accountID:   data["accountID"]   as? String ?? "",
                username:    data["username"]    as? String ?? "",
                email:       data["email"]       as? String ?? "",
                status:      data["status"]      as? Bool   ?? true,
                createdDate: (data["createdDate"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }

    // Admin: Update Username
    // updateData preserves all other fields; setData would overwrite them.
    func updateUsername(accountID: String, newUsername: String) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "username": newUsername
        ])
    }

 
    func updateRewards(accountID: String, coffeeCount: Int, rewardBalance: Int) async throws {
        try await db.collection("rewards").document(accountID).updateData([
            "coffeeCount":   coffeeCount,
            "rewardBalance": rewardBalance
        ])
    }

    
    func toggleAccountStatus(accountID: String, currentStatus: Bool) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "status": !currentStatus
        ])
    }

    // Rewards Lookup (admin only)
    func getRewardsByAccountID(accountID: String) async throws -> RewardModel? {
        let doc = try await db.collection("rewards").document(accountID).getDocument()
        guard let data = doc.data() else { return nil }
        return RewardModel(
            rewardID:      data["rewardID"]      as? String ?? "",
            accountID:     data["accountID"]     as? String ?? "",
            coffeeCount:   data["coffeeCount"]   as? Int    ?? 0,
            rewardBalance: data["rewardBalance"] as? Int    ?? 0
        )
    }
}
