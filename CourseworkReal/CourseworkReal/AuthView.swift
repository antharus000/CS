import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
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

            if isLoading {
                ProgressView()
            } else {
                Button(action: handleAuth) {
                    Text(isLoginMode ? "Sign In" : "Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Button(action: { isLoginMode.toggle() }) {
                Text(isLoginMode ? "Don't have an account? Register" : "Already have an account? Sign in")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
    }

    func handleAuth() {
        errorMessage = ""
        isLoading = true

        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let uid = result?.user.uid else { return }
                Task {
                    let role = try? await FirebaseService.shared.getUserRole(uid: uid)
                    appState.userRole = role ?? "customer"
                }
            }
        } else {
            Task {
                do {
                    try await FirebaseService.shared.registerUser(
                        email: email,
                        password: password,
                        username: username
                    )
                    let uid = Auth.auth().currentUser?.uid ?? ""
                    let role = try? await FirebaseService.shared.getUserRole(uid: uid)
                    appState.userRole = role ?? "customer"
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }
    }
}
