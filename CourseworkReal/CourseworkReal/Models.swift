import Foundation

// One account model to user
struct AccountModel {
    var accountID: String    // Firebase Auth UID - primary key
    var username: String     // Display name chosen at registration
    var email: String        // Stored in both Firebase Auth and Firestore
    var status: Bool         // true = active, false = deactivated by admin
    var createdDate: Date    // Set at registration; used for future analytics
}


struct RewardModel {
    var rewardID: String      // Same as accountID; acts as primary key
    var accountID: String     // Foreign key back to AccountModel
    var coffeeCount: Int      // Coffees purchased in the current cycle (0-9 inclusive)
    var rewardBalance: Int    // Number of free coffees currently available (>= 0)
}
