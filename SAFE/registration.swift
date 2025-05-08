import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    // Form inputs
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var cell = ""
    @State private var middleName = ""
    @State private var pin = ""

    // UI state
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    // Title and category selections
    @StateObject private var titlesViewModel = TitlesViewModel()
    @State private var selectedTitle: String? = nil
    @State private var selectedCategoryID: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                personalInfoSection
                accountDetailsSection
                registrationButtonSection
            }
            .navigationTitle("Register")
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successful") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                titlesViewModel.fetchTitles()
                fetchCategories()
            }
        }
    }

    // MARK: - Personal Info Section

    private var personalInfoSection: some View {
        Section(header: Text("Personal Information")) {
            Picker("Select Title", selection: Binding(
                get: { selectedTitle ?? "Select Title" },
                set: { selectedTitle = $0 == "Select Title" ? nil : $0 }
            )) {
                Text("Select Title").tag("Select Title")
                ForEach(titlesViewModel.titles) { title in
                    Text(title.name).tag(title.name)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("First Name", text: $firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)

                TextField("Middle Name", text: $middleName)
                    .textContentType(.middleName)
                    .textInputAutocapitalization(.words)

                TextField("Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)
            }
        }
    }

    // MARK: - Account Details Section

    private var accountDetailsSection: some View {
        Section(header: Text("Account Details")) {
            Picker("Category of Participation", selection: Binding(
                get: { selectedCategoryID ?? "Select a Category" },
                set: { selectedCategoryID = $0 == "Select a Category" ? nil : $0 }
            )) {
                Text("Select a Category").tag("Select a Category")
                ForEach(fetchedPartCategories) { category in
                    Text(category.cat_description).tag(category.cat_id)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                TextField("Username", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)

                TextField("Pin", text: $pin)
                    .keyboardType(.numberPad)
            }
        }
    }

    // MARK: - Register Button Section

    private var registrationButtonSection: some View {
        Section {
            Button(action: registerUser) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Register")
                }
            }
            .disabled(isFormInvalid)
        }
    }

    // MARK: - Form Validation

    private var isFormInvalid: Bool {
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        pin.isEmpty ||
        password != confirmPassword ||
        selectedTitle == nil ||
        selectedCategoryID == "Select a Category" ||
        !isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // MARK: - Registration Logic

    private func registerUser() {
        guard let title = selectedTitle,
              let categoryID = selectedCategoryID else {
            alertMessage = "Please select both a title and a category"
            showAlert = true
            return
        }

        isLoading = true

        Task {
            if let uid = insertNewUser(
                username: username,
                password: password,
                firstName: firstName,
                lastName: lastName,
                email: email
            ) {
                insertUserExtended(
                    userID: uid,
                    Title: title,
                    middleName: middleName,
                    pin: pin,
                    userRequirement: categoryID
                )
                isLoading = false
                alertMessage = "Registration successful!"
                showAlert = true
            } else {
                alertMessage = "Failed to create user. Please try again."
                showAlert = true
                isLoading = false
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
