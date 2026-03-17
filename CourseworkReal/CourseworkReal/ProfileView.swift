//
//  ProfileView.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var account: Account?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            if let account = account {
                Text(account.username)
                    .font(.title)
                    .bold()
                Text(account.email)
                    .foregroundColor(.gray)
                Text(account.status ? "Active" : "Inactive")
                    .foregroundColor(account.status ? .green : .red)
            }

            Button("Sign Out") {
                try? Auth.auth().signOut()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
        }
        .onAppear { loadProfile() }
    }

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            account = try? await FirebaseService.shared.getAccount(uid: uid)
        }
    }
}
