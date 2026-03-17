import Foundation

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
