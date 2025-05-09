//=============================================================================
//
//  report_elder.swift
//  SAFE
//
//  Created by Kevin Gualano on 11/12/24.
//
//  Notes:
//  This file defines the view where a user can report a child abuse incident.
//  It looks like it needs to be updated with elder-specific language
//  (it uses the same strings as Report.swift)
//
//=============================================================================

import SwiftUI

struct ReportElderView: View {
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
                let screenWidth = geometry.size.width // Get the screen dimensions for use
                let screenHeight = geometry.size.height
                let isLandscape = screenWidth > screenHeight // Detect device orientation
                
                // Set different font sizes for portrait and landscape modes
                let titleFontSize: CGFloat = isLandscape ? 40 : 28
                let buttonFontSize: CGFloat = isLandscape ? 24 : 16
                let bodyFontSize: CGFloat = isLandscape ? 24 : 16
                
                ScrollView {
                    VStack {
                        VStack {
                            // Header with title and logo
                            HStack {
                                Text("Reporting Alleged Abuse of an Eldery Person")
                                    .font(.custom("Helvetica", size: 32))
                                    .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish color for heading (x/255 where x is the RGB value --> x < 256 and x > 0)
                                    .fontWeight(.bold)
                                Image("SERA_Text_w__Shield")
                                    .resizable()
                                    .frame(width: 140, height: 140)
                            }
                        }
                        
                        // Buttons in an HStack
                        HStack {
                            // Left VStack - when to make a report button & its form
                            VStack {
                                Button(action: {
                                    showLeftForm.toggle()
                                }) {
                                    Text("When to Make a Report")
                                        .font(.system(size: buttonFontSize))
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 50)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish color for text
                                .sheet(isPresented: $showLeftForm) {
                                    ReferenceTopicForm(topic: "When to Make a Report", references: leftReferences, header: "Reasons to Make a Report", isPresented: $showLeftForm)
                                }
                            }
                            .padding()
                            
                            // Right VStack - when not to report button & its form
                            VStack {
                                Button(action: {
                                    showRightForm.toggle()
                                }) {
                                    Text("When Not to Make a Report")
                                        .font(.system(size: buttonFontSize))
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 50)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish color for text
                                .sheet(isPresented: $showRightForm) {
                                    ReferenceTopicForm(topic: "When Not to Make a Report", references: rightReferences, header: "Reasons Not to Make a Report", isPresented: $showRightForm)
                                }
                            }
                            .padding()
                        }
                        .background(Color(red: 38/255, green: 87/255, blue: 135/255), in:RoundedRectangle(cornerRadius: 12)) // Color the background blue
                        .shadow(radius: 4)
                        .padding()
                        
                        //=======================================
                        // Button to activate reporting tool
                        //=======================================
                        
                        // Align the message box button in the same HStack format
                        HStack {
                            Button(action: {
                                showMessageBox = true
                            }) {
                                // Declare and style the button text
                                Text("Use the Interactive Reporting Tool")
                                    .font(.system(size: buttonFontSize))
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                            }
                            // Style the button background
                            .padding()
                            .background(Color(red: 158/255, green: 41/255, blue: 43/255)) // Color the background red
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .foregroundColor(Color.white) // This makes the button text white (is there a better way, perhaps to define on the text itself?)
                            
                            //==========================================================
                            // Here, the alert that the button triggers is defined
                            //==========================================================
                            
                            .alert(isPresented: $showMessageBox) {
                                Alert(
                                    // Set the alert text
                                    title: Text("Is the Person in Danger?"),
                                    message: Text("If the person is in imminent danger, please call 911 immediately and if possible remain with the him/her. When the he/she is safe, continue with the tool."),
                                    
                                    // If the person is currently in danger, don't report because the authorities should be called to intervene
                                    primaryButton: .default(Text("Yes")) {
                                        navigateToFlowChart = false
                                    },
                                    
                                    // If the person isn't in danger anymore, allow reporting the incident
                                    secondaryButton: .default(Text("No")) {
                                        navigateToFlowChart = true
                                    }
                                )
                            } // End of alert definition
                            
                            // Take the alert's results - if the user chose "no", proceed to the report form
                            // Otherwise, nothing will happen because the user should call authorities in an active emergency
                            // (hopefully, the user answered honestly)
                            .navigationDestination(isPresented: $navigateToFlowChart) {
                                FlowChartSQL(user_diocese_id: 1) // Call the flowchartSQL.swift file
                            }
                            
                        } // End of report button HStack
                        .padding()
                        
                        Spacer()
                        // End of report button styles
                        
                        //==================================================
                        // Phone numbers section with aligned text
                        //==================================================
                        
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("PA Childline:")
                                    Text("NJ State Registry:")
                                } .padding()
                                VStack(alignment: .leading) {
                                    Text("1-800-932-0313")
                                    Text("1-877-652-2873")
                                } .padding()
                            }
                        } // End of phone numbers VStack
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.custom("Helvetica", size: 16))
                        .foregroundColor(Color(red: 49/255, green: 86/255, blue: 130/255)) // Make text blue
                        .fontWeight(.bold)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        )
                        .padding()
                        // End of phone numbers HStack styles
                        
                        //==================================================
                        // Web Links VStack
                        //==================================================
                        
                        VStack(alignment: .leading) {
                            Link(destination: URL(string: "https://www.compass.state.pa.us/cwis/public/home")!, label: { Text("PA Child Welfare Reporting Website").underline() })
                                .padding()
                            
                            Link(destination: URL(string: "https://www.nj.gov/dcf/reporting/how/")!, label: { Text("New Jersey Department of Children and Families").underline() })
                                .padding()
                        }
                        .font(.custom("Helvetica", size: 16))
                        .foregroundColor(Color(red: 49/255, green: 86/255, blue: 130/255)) // Make text blue
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        )
                        .padding()
                        
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Orange background gradient
            
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color("#ffb600")]),
                    startPoint: .top,
                    endPoint: .bottom))
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    //===========================================================================
    // The below form displays when the user selects "When <to | Not to> Report"
    //===========================================================================
    
    // Updated ReferenceTopicForm to accept a custom header string and modify navigation title size
    struct ReferenceElderTopicForm: View {
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

// Allows Xcode UI preview display

struct ReportElderView_Previews: PreviewProvider {
    static var previews: some View {
        ReportElderView()
    }
}
