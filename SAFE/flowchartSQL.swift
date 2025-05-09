//===========================================================================
//
// This file defines the view where a user can report an abuse incident.
// It is called within Report.swift and report_elder.swift
//
//===========================================================================

import SwiftUI

struct FlowChartSQL: View {
    @State private var childResidence = 0
    @State private var abuseLocation = 0
    @State private var states = [Pickedstate(state_id: 0, state_full: "Select a State")]
    
    @State private var stepDetails: StepDetails? = nil // For Steps 1 and 2
    @State private var homeDioceseSteps: [Step] = []   // For Steps 3 to 6
    
    var user_diocese_id: Int
    @Environment(\.presentationMode) var presentationMode
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //==================================
                // Header Text
                //==================================
                
                Text("Select the Appropriate Locations:")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish colored text
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                //==================================================
                // First Picker: The alleged abuse occurred in
                //==================================================
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("The alleged abuse occurred in:")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish colored text
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Picker("Select a State", selection: $abuseLocation) {
                        ForEach(states, id: \.state_id) { state in
                            Text(state.state_full).tag(state.state_id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
                
                //=======================================
                // Second Picker: The child lives in
                //=======================================
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("The child lives in:")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) // Grayish colored text
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Picker("Select a State", selection: $childResidence) {
                        ForEach(states, id: \.state_id) { state in
                            Text(state.state_full).tag(state.state_id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
                
                // Displaying steps
                displaySteps()
                    .padding(.top, 10)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color("#ffb600")]),
                startPoint: .top,
                endPoint: .bottom))
        
        .onAppear {
            loadStates() // Load states when the view appears
        }
        .onChange(of: abuseLocation) { oldValue, newValue in
            checkSelectionsAndLoadSteps()
        }
        .onChange(of: childResidence) { oldValue, newValue in
            checkSelectionsAndLoadSteps()
        }
    }
    
    //==========================================
    // Function to display steps 1 through 6
    //==========================================
    
    @ViewBuilder
    private func displaySteps() -> some View {
        if let details = stepDetails {
            
            //====================================================
            // Combined Step 1 for both Location and Residence
            //====================================================
            
            Section(header: Text("Step 1: Complete the CY-47").foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)).fontWeight(.bold).padding(.horizontal, 10)) {
                VStack(alignment: .leading, spacing: 10) {
                    if let locationStep1 = details.step1 {
                        Text(locationStep1.step_head)  // Dynamic header for Location Requirement
                            .font(.headline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(locationStep1.step_data)
                            .font(.body)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                    }
                    if let residenceStep1 = details.step3 {
                        Text(residenceStep1.step_head)  // Dynamic header for Residence Requirement
                            .font(.headline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(residenceStep1.step_data)
                            .font(.body)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                    }
                }
                .padding()
                .background(Color(red: 38/255, green: 87/255, blue: 135/255), in:RoundedRectangle(cornerRadius: 12)) // Color the background blue
                .shadow(radius: 4)
                .padding(.horizontal, 10)
            }
            
            //====================================================
            // Combined Step 2 for both Location and Residence
            //====================================================
            
            Section(header: Text("Step 2: Make the Phone Call").foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) .fontWeight(.bold).padding(.horizontal, 10)) {
                VStack(alignment: .leading, spacing: 10) {
                    if let locationStep2 = details.step2 {
                        Text(locationStep2.step_head)  // Dynamic header for Location Requirement
                            .font(.headline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(locationStep2.step_data)
                            .font(.body)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                    }
                    if let residenceStep2 = details.step4 {
                        Text(residenceStep2.step_head)  // Dynamic header for Residence Requirement
                            .font(.headline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(residenceStep2.step_data)
                            .font(.body)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                    }
                }
                .padding()
                .background(Color(red: 38/255, green: 87/255, blue: 135/255), in:RoundedRectangle(cornerRadius: 12)) // Color the background blue
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.horizontal, 10)
            }
            
            //====================================================
            // Sections for Steps 3 to 6
            //====================================================
            
            ForEach(homeDioceseSteps, id: \.step_num) { step in
                Section(header: Text("Step \(step.step_num):").foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176)) .fontWeight(.bold).padding(.horizontal, 10)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(step.step_head)
                            .font(.headline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(step.step_data)
                            .font(.subheadline)
                            .foregroundColor(.white) // White text
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(red: 38/255, green: 87/255, blue: 135/255), in:RoundedRectangle(cornerRadius: 12)) // Color the background blue
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.horizontal, 10)
                }
            }
        }
    }

    //=========================================
    // Load available states for selection
    //=========================================
    
    func loadStates() {
        DispatchQueue.global(qos: .background).async {
            let fetchedStates = fetchStates()
            DispatchQueue.main.async {
                self.states = [Pickedstate(state_id: 0, state_full: "Select a State")] + fetchedStates
            }
        }
    }
    
    //===============================================================
    // Check if both selections are made and load steps accordingly
    //===============================================================
    
    func checkSelectionsAndLoadSteps() {
        // Only load steps if both selections are non-zero
        if abuseLocation != 0 && childResidence != 0 {
            loadSteps()
        }
    }
    
    //=============================================================================
    // Load steps 1, 2, and home diocese steps 3 through 6 based on user input
    //=============================================================================
    
    func loadSteps() {
        DispatchQueue.global(qos: .background).async {
            // Fetch steps 1 and 2 based on abuseLocation and childResidence
            let fetchedStepDetails = determineStatesSteps1and2(location: abuseLocation, residence: childResidence)
            
            // Fetch steps 3 to 6 based on the provided user_diocese_id parameter
            let fetchedHomeDioceseSteps = fetchHomeDioceseSteps(user_diocese_id: user_diocese_id)
            
            DispatchQueue.main.async {
                self.stepDetails = fetchedStepDetails
                self.homeDioceseSteps = fetchedHomeDioceseSteps
            }
        }
    }
}

//========================
// Preview for Xcode
//========================

struct FlowChartSQL_Previews: PreviewProvider {
    static var previews: some View {
        FlowChartSQL(user_diocese_id: user_diocese_id)
    }
}
