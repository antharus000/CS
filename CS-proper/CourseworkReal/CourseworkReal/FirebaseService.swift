import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
// when the user first registers for an account a form is filled out and the results are sent to the database

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
//check to see if user is an admin or a customer
// used in finding which page to display
    func getUserRole(uid: String) async throws -> String {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        return doc.data()?["role"] as? String ?? "customer"
    }
//used when the admin looks at all the accounts
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
// used by the customer and the admin when retriving how many cofee's the customer has bought
    //used in user looking up and for rewards progress
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
//shows the list of all users. this is seen by the admin
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
    // allows the admin to update the username of customers
    func updateUsername(accountID: String, newUsername: String) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "username": newUsername
        ])
    }
    // allows the admin to update the rewards of customers (useful for later)
    func updateRewards(accountID: String, coffeeCount: Int, rewardBalance: Int) async throws {
        try await db.collection("rewards").document(accountID).updateData([
            "coffeeCount": coffeeCount,
            "rewardBalance": rewardBalance
        ])
    }
// changes the status of the user, at the moment this doesnt do anything
    func toggleAccountStatus(accountID: String, currentStatus: Bool) async throws {
        try await db.collection("accounts").document(accountID).updateData([
            "status": !currentStatus
        ])
    }
//looks up rewards info as long as the admin has a userID
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
