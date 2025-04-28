// RequirementsView.swift

import SwiftUI

// View that displays user's requirement statuses: clearances, trainings, and policies
struct RequirementsView: View {
    @EnvironmentObject var userState: UserState
    @StateObject private var dataManager = RequirementsDataManager()

    @State private var clearances: [UserRequirementStatus] = []
    @State private var trainings: [UserRequirementStatus] = []
    @State private var policies: [UserRequirementStatus] = []
    @State private var showMenu = false

    var body: some View {
        NavigationView {
            ZStack {
                // Main scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Top bar with menu button and logo
                        HStack {
        
                            Image("SERA_Text_w__Shield")
                                .resizable()
                                .frame(width: 140, height: 140)
                        }

                        // User information
                        Text("Requirements for:")
                            .font(.custom("Helvetica", size: 32))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                            .fontWeight(.bold)

                        Text(userState.user_full_name)
                            .font(.custom("Helvetica", size: 24))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))

                        Text("\(userState.dioceseName), \(userState.stateId)")
                            .font(.custom("Helvetica", size: 18))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))

                        Text(userState.primeMinsitry)
                            .font(.custom("Helvetica", size: 18))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))

                        // Sections for each type of requirement
                        sectionView(title: "Clearances", certifications: clearances)
                        sectionView(title: "Trainings", certifications: trainings)
                        sectionView(title: "Policies", certifications: policies)
                    }
                    .padding()
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.945, green: 0.651, blue: 0.168),
                            Color(red: 0.949, green: 0.949, blue: 0.949)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .onAppear {
                    // Fetch user-specific requirement data
                    let userId = userState.userId
                    dataManager.fetchData(userID: userId) { result in
                        switch result {
                        case .success:
                            let categorized = dataManager.categorizedRequirements(
                                requirements: dataManager.requirements,
                                histories: dataManager.statuses
                            )
                            clearances = categorized.clearances
                            trainings = categorized.trainings
                            policies = categorized.policies
                        case .failure(let error):
                            print("Error fetching requirements: \(error)")
                        }
                    }
                }

                // Side menu overlay
                if showMenu {
                    ZStack {
                        SideMenuView(isAuthenticated: .constant(true))
                            .transition(.move(edge: .leading))
                            .zIndex(1)

                        VStack {
                            Spacer().frame(height: 180)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 40)
                                .contentShape(Rectangle())
                                .onTapGesture { }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.clear)
                        .zIndex(2)
                    }
                    .background(
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation { showMenu = false }
                            }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Helper view to render each requirements section
    private func sectionView(title: String, certifications: [UserRequirementStatus]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Helvetica", size: 22))
                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                .bold()

            Divider()

            VStack(spacing: 12) {
                ForEach(certifications) { cert in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(cert.reqID)
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                            Spacer()
                            Text(cert.status)
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(colorForStatus(cert.status))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    // Determines the color to use based on the requirement status
    private func colorForStatus(_ status: String) -> Color {
        if status.starts(with: "Expired On:") {
            return .red
        } else if status.starts(with: "Expiring Within") {
            return .orange
        } else if status.starts(with: "Generated") {
            return .indigo
        } else {
            return .black
        }
    }
}
