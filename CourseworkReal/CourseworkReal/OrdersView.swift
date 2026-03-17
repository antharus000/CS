//
//  OrdersView.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import SwiftUI
import FirebaseAuth

struct OrdersView: View {
    @State private var orders: [Order] = []

    var body: some View {
        NavigationView {
            List(orders, id: \.orderID) { order in
                VStack(alignment: .leading) {
                    Text("Order #\(order.orderID.prefix(8))")
                        .font(.headline)
                    Text(order.orderDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("My Orders")
        }
        .onAppear { loadOrders() }
    }

    func loadOrders() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            orders = (try? await FirebaseService.shared.getOrders(accountID: uid)) ?? []
        }
    }
}
