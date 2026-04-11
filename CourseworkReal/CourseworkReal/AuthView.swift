import SwiftUI
import FirebaseAuth

// BenugoTextField
// Reusable branded input component. Extracted to avoid repeating the same
// padding, background, border, and colour modifiers on every field.
// isSecure toggles between TextField (visible) and SecureField (masked).

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

// AuthView
// Handles both login and registration in a single view.
// isLoginMode toggles between the two paths.
// All input is validated client-side before any Firebase call is made.

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

                    // MARK: Header
                    VStack(spacing: 8) {
                        Text("BENUGO")
                            .font(.system(size: 34, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(Color.benEspresso)

                        Text(isLoginMode ? "Sign in to your account" : "Create your account")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.benSlate)
                    }
                    .padding(.top, 72)
                    .padding(.bottom, 40)

                    // Input Fields
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

                        // Password hint shown only during registration so the user knows the requirements before submitting
                        if !isLoginMode {
                            Text("Min 8 characters, must include a number and a special character.")
                                .font(.caption)
                                .foregroundColor(Color.benSlate)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }

                    // Error Display
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                    }

                    // login or register button
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

                    // Mode Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLoginMode.toggle()
                            errorMessage = "" // clears errors when switching modes
                        }
                    }) {
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

    // Client-Side Validation (Registration)
    // Runs before any Firebase call so invalid data never reaches the network.
    // Returns nil if all checks pass, or an error string to display.
    func validateRegistration() -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        // Test 1.8: blank email
        if trimmedEmail.isEmpty {
            return "Email cannot be blank."
        }

        // Basic email format: must contain @ with something either side
        if !trimmedEmail.contains("@") || trimmedEmail.hasPrefix("@") {
            return "Please enter a valid email address."
        }

        // Blank username
        if trimmedUsername.isEmpty {
            return "Username cannot be blank."
        }

        // Test 1.2: minimum 8 characters (boundary: 8 is accepted, 7 is not)
        if password.count < 8 {
            return "Password must be at least 8 characters long."
        }

        // Password must contain at least one digit
        if password.first(where: { $0.isNumber }) == nil {
            return "Password must contain at least one number."
        }

        // Test 1.3: password must contain at least one special character
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")
        if password.unicodeScalars.first(where: { specialChars.contains($0) }) == nil {
            return "Password must contain at least one special character."
        }

        return nil // all checks passed
    }

    // handleAuth
    // Validates inputs then calls Firebase. if succesful, appState.userRole
    // is set which causes Initial.swift to go to the correct screen.
    func handleAuth() {
        errorMessage = ""

        if isLoginMode {
            // Login: blank-field checks before hitting the network
            guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Email cannot be blank."
                return
            }
            guard !password.isEmpty else {
                errorMessage = "Password cannot be blank."
                return
            }

            isLoading = true
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoading = false
                if let error = error {
                    // Firebase covers wrong password (test 1.6) and
                    // unregistered email (test 1.7) at this point
                    errorMessage = error.localizedDescription
                    return
                }
                guard let uid = result?.user.uid else { return }
                Task {
                    let role = try? await FirebaseService.shared.getUserRole(uid: uid)
                    // Default to customer if role is missing
                    appState.userRole = role ?? "customer"
                }
            }
        } else {
            // run client-side validation first (for registation)
            if let validationError = validateRegistration() {
                errorMessage = validationError
                return
            }

            isLoading = true
            Task {
                do {
                    try await FirebaseService.shared.registerUser(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password,
                        username: username.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    let uid = Auth.auth().currentUser?.uid ?? ""
                    let role = try? await FirebaseService.shared.getUserRole(uid: uid)
                    appState.userRole = role ?? "customer"
                } catch {
                    // Firebase covers duplicate email (test 1.4) here
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }
    }
}
