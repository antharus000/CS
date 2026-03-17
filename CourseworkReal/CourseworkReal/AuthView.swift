import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            loginForm
                .onAppear {
                    _ = Auth.auth().addStateDidChangeListener { _, user in
                        isLoggedIn = user != nil
                    }
                }
        }
    }

    var loginForm: some View {
        VStack(spacing: 20) {
            Text(isLoginMode ? "Sign In" : "Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.top, 60)

            if !isLoginMode {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button(action: handleAuth) {
                Text(isLoginMode ? "Sign In" : "Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Button(action: { isLoginMode.toggle() }) {
                Text(isLoginMode ? "Register" : "Sign in")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
    }

    func handleAuth() {
        errorMessage = ""
        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                // No need to set isLoggedIn here — the listener handles it
            }
        } else {
            Task {
                do {
                    try await FirebaseService.shared.registerUser(
                        email: email,
                        password: password,
                        username: username
                    )
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
