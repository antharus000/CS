import SwiftUI
import FirebaseAuth

struct BenugoTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt:
                    Text(placeholder).foregroundColor(Color.benSlate)
                )
            } else {
                TextField("", text: $text, prompt:
                    Text(placeholder).foregroundColor(Color.benSlate)
                )
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
            }
        }
        .padding(14)
        .background(Color.benLinen)
        .foregroundColor(Color.benEspresso)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.benStone, lineWidth: 1)
        )
        .cornerRadius(10)
        .padding(.horizontal, 24)
    }
}

struct AuthView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.benCream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // Header
                    VStack(spacing: 8) {
                        Text("BENUGO")
                            .font(.system(size: 34, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(Color.benEspresso)


                        Text(isLoginMode ? "Sign in to your account" : "Create your account")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(Color.benSlate)
                    }
                    .padding(.top, 72)
                    .padding(.bottom, 40)

                    // Fields
                    VStack(spacing: 12) {
                        if !isLoginMode {
                            BenugoTextField(
                                placeholder: "Username",
                                text: $username
                            )
                        }

                        BenugoTextField(
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        BenugoTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )
                    }

                    // Error
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                    }

                    // Primary button / loading
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(Color.benForest)
                                .frame(height: 52)
                        } else {
                            Button(action: handleAuth) {
                                Text(isLoginMode ? "Sign In" : "Register")
                                    .font(.system(size: 15, weight: .medium))
                                    .tracking(1)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.benForest)
                                    .foregroundColor(Color.benCream)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 24)

                    // Divider idea
//                    HStack {
//                        Rectangle().fill(Color.benStone).frame(height: 1)
//                        Text("or")
//                            .font(.caption)
//                            .foregroundColor(Color.benSlate)
//                            .padding(.horizontal, 12)
//                        Rectangle().fill(Color.benStone).frame(height: 1)
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.top, 28)

                    // Toggle mode
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLoginMode.toggle()
                        }
                    }) {
                        Text(isLoginMode ? "Don't have an account? " : "Already have an account? ")
                            .foregroundColor(Color.benSlate)
                         Text(isLoginMode ? "Register" : "Sign in")
                            .foregroundColor(Color.benForest)
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 14))
                    .padding(.top, 20)

                    Spacer(minLength: 40)
                }
            }
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
