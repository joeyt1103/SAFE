//
//  pCategory 2.swift
//  SAFE
//
//  Created by Maximilian Sarko on 5/8/25.
//


import SwiftUI

// Data structures used within the checklist view for displaying fetched content
struct pCategory: Hashable {
    let cat_id: String
    let cat_description: String
    let cat_includes: String
    let cat_age_range: String
}

struct PolicyDataReturn: Hashable {
    let policy_id: String
    let policy_description: String
    let policy_completion: String
}

struct ClearanceDataReturn: Hashable {
    let clearance_id: String
    let clearance_description: String
    let clearance_completion: String
}

struct DoaTrainingDataReturn: Hashable {
    let doa_training_id: String
    let doa_training_description: String
    let doa_training_completion: String
}

struct PaTrainingDataReturn: Hashable {
    let paTraining_id: String
    let paTraining_description: String
    let paTraining_completion: String
}

// View that displays requirement information based on selected participation category
struct CheckListSQL: View {
    @State private var categories: [pCategory] = []
    @State private var selectedCategory: pCategory? = nil
    @State private var policies: [PolicyDataReturn] = []
    @State private var clearances: [ClearanceDataReturn] = []
    @State private var doaTrainings: [DoaTrainingDataReturn] = []
    @State private var paTrainings: [PaTrainingDataReturn] = []

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight

            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let headerFontSize: CGFloat = isLandscape ? 24 : 18

            ScrollView {
                VStack(alignment: .leading) {
                    Text("Requirements")
                        .font(.system(size: titleFontSize, weight: .bold))
                        .padding(.top, 20)
                        .padding(.leading, 10)

                    Text("This page will assist you in determining which clearances, trainings, and certifications are required for all the various ways the faithful participate in the life of the Church.")
                        .font(.system(size: headerFontSize))
                        .padding(.top, 10)
                        .padding(.horizontal, 10)

                    // Category selector (wheel style)
                    Picker("Select a Category of Participation", selection: $selectedCategory) {
                        Text("Select a Category").tag(nil as pCategory?)
                        ForEach(categories, id: \.cat_id) { category in
                            Text(category.cat_description).tag(category as pCategory?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 150)
                    .padding(.horizontal, 10)
                    .onChange(of: selectedCategory) {
                        if selectedCategory != nil {
                            // Small delay before loading to allow UI state change
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                loadPolicies()
                                loadClearances()
                                loadDoaTraining()
                                loadPaTraining()
                            }
                        }
                    }

                    Spacer()

                    // Only show data sections if a category is selected
                    if let selected = selectedCategory {
                        VStack(spacing: 10) {
                            // Category context: "includes" and "age range"
                            VStack(alignment: .leading) {
                                Text("Those Included in the Category:")
                                    .font(.system(size: headerFontSize))
                                    .padding(.horizontal, 10)
                                Text(selected.cat_includes)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                            }

                            VStack(alignment: .leading) {
                                Text("Applies to those who are:")
                                    .font(.system(size: headerFontSize))
                                    .padding(.horizontal, 10)
                                Text(selected.cat_age_range)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 10)
                            }

                            // Policy requirements
                            sectionView(
                                title: "Required Diocesan Policies:",
                                items: policies.map { ($0.policy_description, $0.policy_completion) },
                                fontSize: headerFontSize
                            )

                            // Clearance requirements
                            sectionView(
                                title: "Required Clearances:",
                                items: clearances.map { ($0.clearance_description, $0.clearance_completion) },
                                fontSize: headerFontSize
                            )

                            // PA State training requirements
                            sectionView(
                                title: "PA State Certifications and Trainings Required:",
                                items: paTrainings.map { ($0.paTraining_description, $0.paTraining_completion) },
                                fontSize: headerFontSize
                            )

                            // Diocesan training requirements
                            sectionView(
                                title: "Required Diocesan Trainings/Certifications:",
                                items: doaTrainings.map { ($0.doa_training_description, $0.doa_training_completion) },
                                fontSize: headerFontSize
                            )
                        }
                        .padding(.top, 20)
                    }

                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                // Load everything on screen entry
                loadCategories()
                loadPolicies()
                loadClearances()
                loadDoaTraining()
                loadPaTraining() 
            }
        }
    }

    // Load participation categories from shared data source
    func loadCategories() {
        fetchParticipationCategories()
        DispatchQueue.main.async {
            categories = fetchedParticipationCategories.map {
                pCategory(cat_id: $0.cat_id, cat_description: $0.cat_description, cat_includes: $0.cat_includes, cat_age_range: $0.cat_age_range)
            }
        }
    }

    // Load policy data for selected category
    func loadPolicies() {
        if let selectedCategory = selectedCategory {
            fetchPolicyData(inputData: selectedCategory.cat_id)
            DispatchQueue.main.async {
                policies = fetchedPolicyData.map {
                    PolicyDataReturn(policy_id: $0.policy_id, policy_description: $0.policy_description, policy_completion: $0.policy_completion)
                }
            }
        } 
    }

    // Load clearance data
    func loadClearances() {
        if let selectedCategory = selectedCategory {
            fetchClearanceData(inputData: selectedCategory.cat_id)
            DispatchQueue.main.async {
                clearances = fetchedClearanceData.map {
                    ClearanceDataReturn(clearance_id: $0.clearance_id, clearance_description: $0.clearance_description, clearance_completion: $0.clearance_completion)
                }
            }
        }
    }

    // Load diocesan training data
    func loadDoaTraining() {
        if let selectedCategory = selectedCategory {
            fetchDoaTrainingData(inputData: selectedCategory.cat_id)
        }
        DispatchQueue.main.async {
            doaTrainings = fetchedDoaTrainings.map {
                DoaTrainingDataReturn(doa_training_id: $0.doa_training_id, doa_training_description: $0.doa_training_description, doa_training_completion: $0.doa_training_completion)
            }
        }
    }

    // Load PA state training data
    func loadPaTraining() {
        if let selectedCategory = selectedCategory {
            fetchPATrainingData(inputData: selectedCategory.cat_id)
        }
        DispatchQueue.main.async {
            paTrainings = fetchedPaStateTrainings.map {
                PaTrainingDataReturn(paTraining_id: $0.paTraining_id, paTraining_description: $0.paTraining_description, paTraining_completion: $0.paTraining_completion)
            }
        }
    }

    // Helper for rendering section UI
    func sectionView(title: String, items: [(String, String)], fontSize: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: fontSize))
                .padding(.horizontal, 10)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    VStack(alignment: .leading) {
                        Text(item.0)
                            .bold()
                            .padding(5)
                        Text(item.1)
                            .padding([.horizontal, .bottom])
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 13)

                    if index != items.count - 1 {
                        Divider().padding(.horizontal, 10)
                    }
                }
            }
            .padding(.top, 15)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal, 10)
        }
    }
}

struct CheckListSQL_Previews: PreviewProvider {
    static var previews: some View {
        CheckListSQL()
    }
}
