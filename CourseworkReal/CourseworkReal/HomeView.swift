//
//  HomeView.swift
//  CourseworkReal
//
//  Created by James Stratford on 17/03/2026.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle)
            Button("Sign Out") {
                try? Auth.auth().signOut()
            }
            .foregroundColor(.red)
        }
    }
}
