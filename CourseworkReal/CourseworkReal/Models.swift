//
//  Models.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import Foundation

struct Account {
    var accountID: String
    var username: String
    var email: String
    var status: Bool
    var createdDate: Date
}

struct Order {
    var orderID: String
    var orderTime: Date
    var orderDate: Date
    var accountID: String
}

struct Reward {
    var rewardID: String
    var accountID: String
    var coffeeCount: Int
    var rewardBalance: Int
}

struct Promotion {
    var promotionID: String
    var title: String
    var desc: String
    var discount: Double
    var startDate: Date
    var endDate: Date
    var active: Bool
}
