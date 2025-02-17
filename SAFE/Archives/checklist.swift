import SwiftUI


struct CheckList: View {
    // State variables to track the selections
    @State private var category = 0

    @Environment(\.presentationMode) var presentationMode

    // Computed properties to return the correct values based on category
    var selectedDesc: String {
        switch category {
        case 1: return ADE_DESC
        case 2: return AVCM_DESC
        case 3: return MDE_DESC
        case 4: return MV_DESC
        case 5: return MVU_DESC
        default: return ""
        }
    }

    var selectedPolicy: String {
        switch category {
        case 1: return ADE_POLICY
        case 2: return AVCM_POLICY
        case 3: return MV_POLICY
        case 4: return MV_DESC
        case 5: return MVU_POLICY
        default: return ""
        }
    }

    var selectedClearance: String {
        switch category {
        case 1: return ADE_CLEARANCE
        case 2: return AVCM_CLEARANCE
        case 3: return MDE_CLEARANCE
        case 4: return MV_CLEARANCE
        case 5: return MVU_CLEARANCE
        default: return ""
        }
    }

    var selectedState: String {
        switch category {
        case 1: return ADE_STATE
        case 2: return AVCM_STATE
        case 3: return MDE_STATE
        case 4: return MV_STATE
        case 5: return MVU_STATE
        default: return ""
        }
    }

    var selectedDOA: String {
        switch category {
        case 1: return ADE_DOA
        case 2: return AVCM_DOA
        case 3: return MDE_DOA
        case 4: return MV_DOA
        case 5: return MVU_DOA
        default: return ""
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight // Detect orientation

            // Set different sizes for portrait and landscape modes
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let headerFontSize: CGFloat = isLandscape ? 24 : 18
            let _: CGFloat = isLandscape ? 20 : 16

            ScrollView {
                VStack(alignment: .leading) {
                    // Custom header for left-aligned title
                    Text("Requirements")
                        .font(.system(size: titleFontSize, weight: .bold))  // Adjusted font size for title
                        .padding(.top, 20)
                        .padding(.leading, 10)

                    Text("This page will assist you in determining which clearances, trainings and certifications are required for all the various ways the faithful particiate in the life of the Church.")
                        .font(.system(size: headerFontSize))  // Adjusted font size for header
                        .padding(.top, 10)
                        .padding(.horizontal, 10)

                    Picker("Category", selection: $category) {
                        Text("Select a Category of Participation").tag(0)
                        Text("Adult Clergy, Religious, Parish, School or Diocesan Employee").tag(1)
                        Text("Adult Volunteer Who has Contact with Minors").tag(2)
                        Text("Minor Employee of a Parish, School or Office").tag(3)
                        Text("Minor Volunteers between Ages 14 - 17").tag(4)
                        Text("Minor Volunteer under the Age of 14").tag(5)
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 150)
                    .padding(.horizontal, 10)

                    Spacer()

                    if category != 0 {
                        VStack(spacing: 10) {
                            // Box 1 with header
                            VStack(alignment: .leading) {
                                Text("Those Included in the Category:")
                                    .font(.system(size: headerFontSize)) // Adjusted font size for headers
                                    .padding(.horizontal, 10)
                                Text(selectedDesc)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.leading)
                            }

                            // Box 2 with header
                            VStack(alignment: .leading) {
                                Text("Required Diocesan Policies:")
                                    .font(.system(size: headerFontSize)) // Adjusted font size for headers
                                    .padding(.horizontal, 10)
                                Text(selectedPolicy)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.leading)
                            }

                            // Box 3 with header
                            VStack(alignment: .leading) {
                                Text("Required Clearances:")
                                    .font(.system(size: headerFontSize)) // Adjusted font size for headers
                                    .padding(.horizontal, 10)
                                Text(selectedClearance)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.leading)
                            }

                            // Box 4 with header
                            VStack(alignment: .leading) {
                                Text("Required State Training and Certifications:")
                                    .font(.system(size: headerFontSize)) // Adjusted font size for headers
                                    .padding(.horizontal, 10)
                                Text(selectedState)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.leading)
                            }

                            // Box 5 with header
                            VStack(alignment: .leading) {
                                Text("Required Diocesan Trainings:")
                                    .font(.system(size: headerFontSize)) // Adjusted font size for headers
                                    .padding(.horizontal, 10)
                                Text(selectedDOA)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.top, 20)
                    }

                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CheckList_Previews: PreviewProvider {
    static var previews: some View {
        CheckList()
    }
}
