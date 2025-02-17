import SwiftUI

struct ProfileView: View {
    @ObservedObject var userState = UserState.shared
   
    
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
                    // Header
                    Text("Profile and Settings")
                        .font(.system(size: titleFontSize))
                        .fontWeight(.bold)
                        .padding(.bottom, 15)
                        .padding(.top, 20)
                    
                    Text(userState.userFullName)
                        .font(.system(size: subTitleFontSize))
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    
                    Text("\(userState.city), \(userState.state)")
                        .font(.system(size: 18))
                        .bold()
                        .padding(.bottom, -10)
                    
                    Text("Vocation: \(userState.vocation)")
                        .font(.system(size: 18))
                        .bold()
                        .padding(.bottom, 15)
                    Text("Requirement Category:")
                        .bold()
                        .foregroundColor(Color.indigo)
                        .padding(.bottom, 0)
                    Text("\(userState.catDesc)")
                        .padding(.bottom, 15)
                    
                    
                    // Conditionally display Diocesan Information section
                    if user_dio_emp != 0 {
                        sectionView(
                            title: "Diocesan Employment Information",
                            items: [
                                ("Diocesan Location:", user_office),
                                ("Position:", user_dioTitle)
                            ],
                            fontSize: bodyFontSize
                        )
                    }
                    
                    // Always displayed sections
                    sectionView(
                        title: "Location Information",
                        items: [
                            ("Location:", userState.locName),
                            ("Primary Ministry:", userState.primeMinsitry)
                        ],
                        fontSize: bodyFontSize
                    )
                    
                    sectionView(
                        title: "Contact Information",
                        items: [
                            ("Address:", "\(userState.add1)\(userState.add2.isEmpty == false ? "\n\(userState.add2)" : "")\n\(userState.city), \(user_state_id) \(user_zip)"),
                            ("Cell:", userState.cell),
                            ("Email:", userState.email)
                        ],
                        fontSize: bodyFontSize
                    )
                    
                    sectionView(
                        title: "Settings",
                        items: [
                            ("Username:", userState.username),
                            ("Password:", "************"),
                            ("Placeholder:", "TBD"),
                            ("Placeholder:","TBD")
                        ],
                        fontSize: bodyFontSize
                    )
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .onAppear {
                print("ProfileView loaded with user: \(userState.firstName)")
                       
            }
        }
    }
    
    // Private sectionView function for displaying each section
    private func sectionView(title: String, items: [(label: String, value: String)], fontSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // Section title
            Text(title)
                .font(.system(size: fontSize + 4))
                .bold()
                .padding(.bottom, 2)
            
            Divider()
                .background(Color.gray)
                .padding(.bottom, 2)
            
            // Labels and data aligned in pairs
            VStack(alignment: .leading, spacing: 5) {
                ForEach(items, id: \.label) { item in
                    HStack(alignment: .top) {
                        Text(item.label)
                            .frame(width: 150, alignment: .leading) // Fixed width for label
                            .font(.system(size: fontSize + 3))
                        Text(item.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: fontSize + 3))
                            .padding(.bottom, 2)
                    }
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
            .padding(.bottom, 10)
        }
    }
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
