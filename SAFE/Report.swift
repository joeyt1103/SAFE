import SwiftUI

struct ReportView: View {
    @State private var showLeftForm = false
    @State private var showRightForm = false
    @State private var showMessageBox = false
    @State private var showStep1 = false
    @State private var navigateToFlowChart = false
    
    // Reference lists for Left and Right topics
    let leftReferences = ["Bodily Injury", "Serious Mental Injury", "Sexual Abuse or Exploitation", "Serious Physical Neglect", "Likelihood of Serious Bodily Injury or Sexual Abuse", "Medical Child Abuse", "When in Doubt"]
    let rightReferences = ["Culpability", "Environmental Factors", "Religious Beliefs", "Ensuring Safety", "Contact the Diocese for Further Assistance on These Topics. 610-871-5200 x2204 "]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                let isLandscape = screenWidth > screenHeight // Detect orientation
                
                // Set different sizes for portrait and landscape modes
                let titleFontSize: CGFloat = isLandscape ? 40 : 28
                let buttonFontSize: CGFloat = isLandscape ? 24 : 16
                let bodyFontSize: CGFloat = isLandscape ? 24 : 16
                
                ScrollView {
                    VStack {
                        
                        // Custom Title
                        Text("Reporting Alleged Abuse of a Minor")
                            .font(.system(size: titleFontSize)) // Adjusted font size for title
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // Buttons in an HStack
                        HStack {
                            // Left VStack
                            VStack {
                                Button(action: {
                                    showLeftForm.toggle()
                                }) {
                                    Text("When to Make a Report")
                                        .font(.system(size: buttonFontSize))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 50)
                                }
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .sheet(isPresented: $showLeftForm) {
                                    ReferenceTopicForm(topic: "When to Make a Report", references: leftReferences, header: "Reasons to Make a Report", isPresented: $showLeftForm)
                                }
                            }
                            .padding()
                            
                            // Right VStack
                            VStack {
                                Button(action: {
                                    showRightForm.toggle()
                                }) {
                                    Text("When not to Make a Report")
                                        .font(.system(size: buttonFontSize))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 50)
                                }
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .sheet(isPresented: $showRightForm) {
                                    ReferenceTopicForm(topic: "When not to Make a Report", references: rightReferences, header: "Reasons Not to Make a Report", isPresented: $showRightForm)
                                }
                            }
                            .padding()
                        }
                        .padding()
                        
                        // Align the message box button in the same HStack format
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showMessageBox = true
                            }) {
                                Text("Use the Interactive Reporting Tool")
                                    .font(.system(size: buttonFontSize))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                            }
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .alert(isPresented: $showMessageBox) {
                                Alert(
                                    title: Text("Is the Child in Danger?"),
                                    message: Text("If the child is in imminent danger, please call 911 immediately and if possible remain with the child. When the child is safe, continue with the tool."),
                                    primaryButton: .default(Text("Yes")) {
                                        navigateToFlowChart = false
                                    },
                                    secondaryButton: .default(Text("No")) {
                                        navigateToFlowChart = true
                                    }
                                )
                            }
                            .navigationDestination(isPresented: $navigateToFlowChart) {
                                FlowChartSQL(user_diocese_id: 1)
                            }
                            
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Phone numbers section with aligned text
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("PA Childline:")
                            Text("NJ State Registry:")
                        }
                        VStack(alignment: .leading) {
                            Text("1-800-932-0313")
                            Text("1-877-652-2873")
                        }
                    }
                    .font(.system(size: bodyFontSize)) // Adjusted font size for body text
                    .padding()
                    
                    // Links
                    Link("PA Child Welfare Reporting Website", destination: URL(string: "https://www.compass.state.pa.us/cwis/public/home")!)
                        .font(.system(size: bodyFontSize))
                        .padding()
                    
                    Link("New Jersey Department of Children and Families", destination: URL(string: "https://www.nj.gov/dcf/reporting/how/")!)
                        .font(.system(size: bodyFontSize))
                        .padding()
                    
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
    
    // Updated ReferenceTopicForm to accept a custom header string and modify navigation title size
    struct ReferenceTopicForm: View {
        let topic: String
        let references: [String]
        let header: String
        @Binding var isPresented: Bool // Bind the presentation state
        
        var body: some View {
            NavigationView {
                Form {
                    // Custom Header
                    Section(header: Text(header)) {
                        // Loop through the reference list and display each item
                        ForEach(references, id: \.self) { reference in
                            Text(reference)
                        }
                    }
                    Section {
                        Text("Additional information and links.")
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("PA Childline:")
                                Text("NJ State Registry:")
                            }
                            VStack(alignment: .leading) {
                                Text("1-800-932-0313")
                                Text("1-877-652-2873")
                            }
                        }
                        
                        Link("PA Child Welfare Reporting Website", destination: URL(string: "https://www.compass.state.pa.us/cwis/public/home")!)
                            .padding(2)
                        
                        Link("New Jersey Department of Children and Families", destination: URL(string: "https://www.nj.gov/dcf/reporting/how/")!)
                            .padding(2)
                        
                        Spacer()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("\(topic) Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .navigationBarItems(trailing: Button("Close") {
                    isPresented = false
                })
            }
        }
    }
    
    struct ReportView_Previews: PreviewProvider {
        static var previews: some View {
            ReportView()
        }
    }

