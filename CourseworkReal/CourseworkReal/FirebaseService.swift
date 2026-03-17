import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    func registerUser(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        try await db.collection("accounts").document(uid).setData([
            "accountID": uid,
            "username": username,
            "email": email,
            "status": true,
            "role": "customer",
            "createdDate": Timestamp()
        ])

        try await db.collection("rewards").document(uid).setData([
            "rewardID": uid,
            "accountID": uid,
            "coffeeCount": 0,
            "rewardBalance": 0
        ])
    }

    func getUserRole(uid: String) async throws -> String {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        return doc.data()?["role"] as? String ?? "customer"
    }

    func getAccount(uid: String) async throws -> AccountModel? {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        return AccountModel(
            accountID: data["accountID"] as? String ?? "",
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            status: data["status"] as? Bool ?? true,
            createdDate: (data["createdDate"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    func getRewards(accountID: String) async throws -> RewardModel? {
        let doc = try await db.collection("rewards").document(accountID).getDocument()
        guard let data = doc.data() else { return nil }
        return RewardModel(
            rewardID: data["rewardID"] as? String ?? "",
            accountID: data["accountID"] as? String ?? "",
            coffeeCount: data["coffeeCount"] as? Int ?? 0,
            rewardBalance: data["rewardBalance"] as? Int ?? 0
        )
    }

    func getAllAccounts() async throws -> [AccountModel] {
        let snapshot = try await db.collection("accounts").getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return AccountModel(
                accountID: data["accountID"] as? String ?? "",
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? "",
                status: data["status"] as? Bool ?? true,
                createdDate: (data["createdDate"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    func updateUsername(accountID: String, newUsername: String) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "username": newUsername
        ])
    }

    func updateRewards(accountID: String, coffeeCount: Int, rewardBalance: Int) async throws {
        try await db.collection("rewards").document(accountID).updateData([
            "coffeeCount": coffeeCount,
            "rewardBalance": rewardBalance
        ])
    }

    func toggleAccountStatus(accountID: String, currentStatus: Bool) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "status": !currentStatus
        ])
    }

    func getRewardsByAccountID(accountID: String) async throws -> RewardModel? {
        let doc = try await db.collection("rewards").document(accountID).getDocument()
        guard let data = doc.data() else { return nil }
        return RewardModel(
            rewardID: data["rewardID"] as? String ?? "",
            accountID: data["accountID"] as? String ?? "",
            coffeeCount: data["coffeeCount"] as? Int ?? 0,
            rewardBalance: data["rewardBalance"] as? Int ?? 0
        )
    }
}
