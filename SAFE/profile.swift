// ProfileView.swift

import SwiftUI

// Simple struct to pair labels with values
struct LabelValue: Hashable {
    let label: String
    let value: String
}

// Main view showing user profile and settings
struct ProfileView: View {
    @ObservedObject var userState = UserState.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with title and logo
                HStack {
                    Text("Profile and Settings")
                        .font(.custom("Helvetica", size: 32))
                        .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                        .fontWeight(.bold)
                    NavigationLink(destination: IDCard()) {
                        Text("IDCard")
                            .foregroundColor(.black)
                            .font(.custom("Helvetica", size: 10))
                            .padding(.leading, 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Image("SERA_Text_w__Shield")
                        .resizable()
                        .frame(width: 140, height: 140)
                }

                // Basic user information
                profileField(title: userState.userFullName, fontSize: 24)
                profileField(title: "\(userState.city), \(userState.state)", fontSize: 18)
                profileField(title: "Vocation: \(userState.vocation)", fontSize: 18)
                profileField(title: "Requirement Category: \(userState.catDesc)", fontSize: 16, color: .indigo)

                // Conditionally show diocesan employment info
                if user_dio_emp != 0 {
                    sectionView(title: "Diocesan Employment Information", items: [
                        LabelValue(label: "Diocesan Location:", value: user_office),
                        LabelValue(label: "Position:", value: user_dioTitle)
                    ])
                }

                // Location information
                sectionView(title: "Location Information", items: [
                    LabelValue(label: "Location:", value: userState.locName),
                    LabelValue(label: "Primary Ministry:", value: userState.primeMinsitry)
                ])

                // Contact information
                sectionView(title: "Contact Information", items: [
                    LabelValue(label: "Address:", value: "\(userState.add1)\(userState.add2.isEmpty ? "" : "\n\(userState.add2)")\n\(userState.city), \(user_state_id) \(user_zip)"),
                    LabelValue(label: "Cell:", value: userState.cell),
                    LabelValue(label: "Email:", value: userState.email)
                ])

                // Placeholder settings (likely to be updated later)
                sectionView(title: "Settings", items: [
                    LabelValue(label: "Username:", value: userState.username),
                    LabelValue(label: "Password:", value: "************"),
                    LabelValue(label: "Placeholder:", value: "TBD"),
                    LabelValue(label: "Placeholder:", value: "TBD")
                ])
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
    }

    // Displays a simple single text field
    private func profileField(title: String, fontSize: CGFloat, color: Color = Color(red: 0.3176, green: 0.3176, blue: 0.3176)) -> some View {
        Text(title)
            .font(.custom("Helvetica", size: fontSize))
            .foregroundColor(color)
    }

    // Displays a titled section of multiple label-value pairs
    private func sectionView(title: String, items: [LabelValue]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Helvetica", size: 22))
                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                .bold()

            Divider()

            ForEach(items, id: \.self) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.label)
                            .font(.custom("Helvetica", size: 16))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                        Spacer()
                        Text(item.value)
                            .font(.custom("Helvetica", size: 16))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
#Preview {
    ProfileView()
}
