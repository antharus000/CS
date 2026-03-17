import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    let db = Firestore.firestore()
    
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
    }
    
    func loginUser(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
}

