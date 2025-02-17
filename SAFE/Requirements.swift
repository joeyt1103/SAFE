import SwiftUI

struct RequirementsView: View {
    @EnvironmentObject var userState: UserState // Assuming UserState is a shared singleton
    @StateObject private var dataManager = RequirementsDataManager()
    @State private var clearances: [UserRequirementStatus] = []
    @State private var trainings: [UserRequirementStatus] = []
    @State private var policies: [UserRequirementStatus] = []
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight
            
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let subTitleFontSize: CGFloat = isLandscape ? 30 : 22
            let bodyFontSize: CGFloat = isLandscape ? 24 : 16
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Title Section
                    Text("Requirements for:")
                        .font(.system(size: titleFontSize))
                        .fontWeight(.bold)
                        .padding(.bottom, 15)
                        .padding(.top, 10)
                    
                    // Subtitle Section
                    Text(userState.user_full_name)
                        .font(.system(size: subTitleFontSize))
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    // User State Information
                    Text("\(userState.dioceseName), \(userState.stateId)")
                        .font(.system(size: bodyFontSize))
                        .padding(.bottom, -10)
                    Text(userState.primeMinsitry)
                    
                    
                    Spacer()
                    
                    // Section Views
                    sectionView(title: "Clearances", certifications: clearances, fontSize: bodyFontSize)
                    sectionView(title: "Trainings", certifications: trainings, fontSize: bodyFontSize)
                    sectionView(title: "Policies", certifications: policies, fontSize: bodyFontSize)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
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
                
            
                //print("Clearances: \(clearances)")
                //print("Trainings: \(trainings)")
                //print("Policies: \(policies)")
            }
        }
    }
    
    // Section View Function
    private func sectionView(title: String, certifications: [UserRequirementStatus], fontSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: fontSize + 6))
                .bold()
                .padding(.bottom, 2)
            
            Divider()
                .background(Color.gray)
                .padding(.bottom, 2)
            
            // Table Headers
            HStack {
                Text("Requirement")
                    .font(.system(size: fontSize + 3))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Status")
                    .font(.system(size: fontSize + 3))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 5)
            
            // Certifications
            VStack(alignment: .leading, spacing: 5) {
                ForEach(certifications) { certification in
                    HStack(alignment: .top) {
                        Text(certification.reqID)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: fontSize + 2))
                        
                        Text(certification.status)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: fontSize + 2))
                            
                            .foregroundColor(colorForStatus(certification.status)) // Add dynamic color
                            .padding(.bottom, 6)
                    }
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.4)))
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        if status.starts(with: "Expired On:") {
            return .red
        } else if status.starts(with: "Expiring Within") {
            return .orange
        } else if status.starts(with: "Generated") {
            return.indigo
        } else {
            return .black // Default text color
        }
    }
}

// MARK: - Preview
struct RequirementsView_Previews: PreviewProvider {
    static var previews: some View {
        RequirementsView()
            .environmentObject(UserState.shared)
    }
}
