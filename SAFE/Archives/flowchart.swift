import SwiftUI

struct Step1: View {
    // State variables to track the selections
    @State private var abuseLocation = 0
    @State private var childResidence = 0
    @Environment(\.presentationMode) var presentationMode

    // Computed property to get the corresponding data for state selections
    var selectedData: String? {
        if abuseLocation == 1 && childResidence == 1 {
            return PP
        } else if abuseLocation == 1 && childResidence == 2 {
            return PJ
        } else if abuseLocation == 2 && childResidence == 1 {
            return JP
        } else if abuseLocation == 2 && childResidence == 2 {
            return JJ
        }
        return nil // No valid selection yet
    }

    // Computed property for determining whether to use step2nj or step2 for Step 2
    var step2Content: String? {
        if abuseLocation == 2 && childResidence == 2 {
            return step2nj  // Use step2nj if both selections are NJ
        } else if abuseLocation != 0 && childResidence != 0 {
            return step2     // Use step2 for all other valid combinations
        }
        return nil // Do nothing if no valid selection (0, 0)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Reduce padding here to move everything closer to the top
                Section(header: Text("Select the Appropriate Locations:")
                    .padding(.horizontal, 10)
                    .padding(.top, 10)) { // Adjust top padding to minimize space
                    // First Picker: The alleged abuse occurred in
                    VStack(alignment: .leading) {
                        Text("The alleged abuse occurred in:")
                            .padding(.horizontal, 10)
                        Picker("The alleged abuse occurred in:", selection: $abuseLocation) {
                            Text("Select a State").tag(0)
                            Text("Pennsylvania").tag(1)
                            Text("New Jersey").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 10) // Horizontal padding for pickers
                    }

                    // Second Picker: The child lives in
                    VStack(alignment: .leading) {
                        Text("The child lives in:")
                            .padding(.horizontal)
                        Picker("The child lives in:", selection: $childResidence) {
                            Text("Select a State").tag(0)
                            Text("Pennsylvania").tag(1)
                            Text("New Jersey").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 10)
                    }
                }

                // Conditionally show the text boxes for "You Must Call" based on state selections
                if abuseLocation != 0 && childResidence != 0 {
                    Section(header: Text("You Must Call:")
                        .padding(.horizontal, 10)) {
                        if let selectedData = selectedData {
                            Text(selectedData)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal, 10)
                        }
                    }

                    // Conditionally show Step 2 content based on state selections
                    Section(header: Text("Should You Complete the CY-47 ?")
                        .padding(.horizontal, 10)) {
                        if let step2Content = step2Content {
                            Text(step2Content)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal, 10)
                        }
                    }

                    // Box 3: Notify the Person in Charge
                    Section(header: Text("Next You Must Notify the Person in Charge:")
                        .padding(.horizontal, 10)) {
                        Text(charge_notify)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                    }

                    // Box 4: Next You Must Contact
                    Section(header: Text("Next You Must Contact:")
                            .padding(.horizontal, 10)) {
                        Text(next_contact)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                    }

                    // Box 5: Follow Up
                    Section(header: Text("Follow Up:")
                        .padding(.horizontal, 10)) {
                        Text(follow_up)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.top, 5) // Adjust padding at the top for better spacing
        }
        .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       Button(action: {
                           presentationMode.wrappedValue.dismiss()
                       }) {
                           Image(systemName: "chevron.left") // Adds the "<" symbol without any text
                       }
                   }
               }
               .navigationBarTitle("Reporting Tool")
           }
       }

       struct Step1_Previews: PreviewProvider {
           static var previews: some View {
               Step1()
           }
       }
