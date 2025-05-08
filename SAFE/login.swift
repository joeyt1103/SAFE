import SwiftUI

@MainActor
struct Login: View {
    @Binding var isAuthenticated: Bool               // Bound to parent to track authentication state
    @State private var name: String = ""             // Username field
    @State private var password: String = ""         // Password field
    @State private var showPassword: Bool = false    // Toggle password visibility
    @State private var showAlert = false             // Controls alert popup
    @State private var alertMessage: String = ""     // Alert message content
    @State private var showRegisterView: Bool = false // Triggers registration screen

    // Disable buttons if any field is empty
    var isRegisterNewUserButtonDisabled: Bool {
        [name, password].contains(where: \.isEmpty)
    }

    var isSignInButtonDisabled: Bool {
        [name, password].contains(where: \.isEmpty)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Image("loginLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 70)
                    .padding()

                Text("To Access Please Login")
                    .font(.title.bold())
                    .foregroundStyle(Color.red)
                    .padding(.top, 20)

                // Username Input
                TextField("User Name",
                          text: $name,
                          prompt: Text("User Name").foregroundColor(.gray))
                    .padding(12)
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(Color.gray.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 3))
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)

                // Password Input (with toggle)
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password",
                                      text: $password,
                                      prompt: Text("Password").foregroundColor(.gray))
                        } else {
                            SecureField("Password",
                                        text: $password,
                                        prompt: Text("Password").foregroundColor(.gray))
                        }
                    }
                    .padding(12)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.gray.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 3))

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 29)

                // Sign In Button
                Button(action: {
                    authenticateUser(username: name, password: password)
                }) {
                    Text("Sign In")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: 300)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .padding()
                .disabled(isSignInButtonDisabled)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                // Registration Button
                Button(action: {
                    showRegisterView = true
                }) {
                    Text("Register for Access")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: 300)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .padding(.top, -15)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .fullScreenCover(isPresented: $showRegisterView) {
                    RegisterView()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color("#ffb600")]),
                    startPoint: .top,
                    endPoint: .bottom)
            )
        }
    }

    // Authenticates user by matching username and password in the database
    func authenticateUser(username: String, password: String) {
        do {
            let connection = try dbConnect()
            defer { connection.close() }

            let query = """
            SELECT "id", "password", "username", "first_name", "last_name"
            FROM "auth_user"
            WHERE "username" = $1
            AND "password" = $2
            """
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }

            let cursor = try statement.execute(parameterValues: [username, password])

            if let row = cursor.next(), let columns = try? row.get().columns {
                let id = try? columns[0].int()
                let passwordSQL = try? columns[1].string()
                let usernameSQL = try? columns[2].string()

                // Validate match and set auth token + defaults
                if passwordSQL == password && usernameSQL == username, let userID = id {
                    let token = UUID().uuidString
                    UserDefaults.standard.set(token, forKey: "user_token")
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")

                    Task {
                        do {
                            try await UserDefaultsManager.shared.getUserDefaults(dbID: userID)
                            UserState.shared.loadFromDefaults()
                            UserDefaults.standard.set(true, forKey: "isAuthenticated")
                            UserDefaults.standard.synchronize()
                            isAuthenticated = true
                        } catch {
                            alertMessage = "Error loading user defaults: \(error)"
                            showAlert = true
                        }
                    }
                } else {
                    alertMessage = "Incorrect username or password."
                    showAlert = true
                }
            } else {
                alertMessage = "Incorrect username or password."
                showAlert = true
            }
        } catch {
            alertMessage = "Error during authentication: \(error)"
            showAlert = true
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(isAuthenticated: .constant(false))
    }
}
