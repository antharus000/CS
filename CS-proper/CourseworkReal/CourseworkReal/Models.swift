import Foundation

// the general model for the database, each structure is a collection.
//each user has 1 account model and one reward model.
struct AccountModel {
    var accountID: String
    var username: String
    var email: String
    var status: Bool
    var createdDate: Date
}

struct RewardModel {
    var rewardID: String
    var accountID: String
    var coffeeCount: Int
    var rewardBalance: Int
}



