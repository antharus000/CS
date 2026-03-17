import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    let db = Firestore.firestore()

    // MARK: - Account

    func registerUser(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        try await db.collection("accounts").document(uid).setData([
            "accountID": uid,
            "username": username,
            "email": email,
            "status": true,
            "createdDate": Timestamp()
        ])

        // Create a blank rewards document for this user
        try await db.collection("rewards").document(uid).setData([
            "rewardID": uid,
            "accountID": uid,
            "coffeeCount": 0,
            "rewardBalance": 0
        ])
    }

    func getAccount(uid: String) async throws -> Account? {
        let doc = try await db.collection("accounts").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        return Account(
            accountID: data["accountID"] as? String ?? "",
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            status: data["status"] as? Bool ?? true,
            createdDate: (data["createdDate"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    // MARK: - Rewards

    func getRewards(accountID: String) async throws -> Reward? {
        let doc = try await db.collection("rewards").document(accountID).getDocument()
        guard let data = doc.data() else { return nil }
        return Reward(
            rewardID: data["rewardID"] as? String ?? "",
            accountID: data["accountID"] as? String ?? "",
            coffeeCount: data["coffeeCount"] as? Int ?? 0,
            rewardBalance: data["rewardBalance"] as? Int ?? 0
        )
    }

    func addCoffee(accountID: String) async throws {
        let ref = db.collection("rewards").document(accountID)
        let doc = try await ref.getDocument()
        let currentCount = doc.data()?["coffeeCount"] as? Int ?? 0
        let currentBalance = doc.data()?["rewardBalance"] as? Int ?? 0

        let newCount = currentCount + 1
        // Every 5 coffees earns 1 reward point
        let newBalance = currentBalance + (newCount % 5 == 0 ? 1 : 0)

        try await ref.updateData([
            "coffeeCount": newCount,
            "rewardBalance": newBalance
        ])
    }

    func redeemReward(accountID: String) async throws {
        let ref = db.collection("rewards").document(accountID)
        let doc = try await ref.getDocument()
        let currentBalance = doc.data()?["rewardBalance"] as? Int ?? 0

        guard currentBalance > 0 else { throw NSError(domain: "No rewards to redeem", code: 0) }

        try await ref.updateData([
            "rewardBalance": currentBalance - 1
        ])
    }

    // MARK: - Orders

    func placeOrder(accountID: String) async throws {
        let orderRef = db.collection("orders").document()
        try await orderRef.setData([
            "orderID": orderRef.documentID,
            "orderTime": Timestamp(),
            "orderDate": Timestamp(),
            "accountID": accountID
        ])
    }

    func getOrders(accountID: String) async throws -> [Order] {
        let snapshot = try await db.collection("orders")
            .whereField("accountID", isEqualTo: accountID)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Order(
                orderID: data["orderID"] as? String ?? "",
                orderTime: (data["orderTime"] as? Timestamp)?.dateValue() ?? Date(),
                orderDate: (data["orderDate"] as? Timestamp)?.dateValue() ?? Date(),
                accountID: data["accountID"] as? String ?? ""
            )
        }
    }

    // MARK: - Promotions

    func getActivePromotions() async throws -> [Promotion] {
        let snapshot = try await db.collection("promotions")
            .whereField("active", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Promotion(
                promotionID: doc.documentID,
                title: data["title"] as? String ?? "",
                desc: data["desc"] as? String ?? "",
                discount: data["discount"] as? Double ?? 0.0,
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                active: data["active"] as? Bool ?? false
            )
        }
    }
}
