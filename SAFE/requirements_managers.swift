import SwiftUI
import Foundation

class RequirementsDataManager: ObservableObject {
    @Published var requirements: [Requirement] = []
    @Published var statuses: [UserRequirementStatus] = []


    init() {}

    // Fetch both requirements and statuses
    func fetchData(userID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let userCategory = UserState.shared.requirementGroup

        DispatchQueue.global(qos: .userInitiated).async {
            let fetchedRequirements = fetchUserRequirements(userCategory: userCategory, userID: userID)
            let fetchedStatuses = fetchUserRequirementsStatus(userID: userID, userCategory: userCategory)
            
            DispatchQueue.main.async {
                self.requirements = fetchedRequirements
                self.statuses = fetchedStatuses
                completion(.success(()))
            }
        }
    }
    
    
// Categorize requirements into clearances, trainings, and policies
    func categorizedRequirements(requirements: [Requirement], histories: [UserRequirementStatus]) -> (clearances: [UserRequirementStatus], trainings: [UserRequirementStatus], policies: [UserRequirementStatus]) {
        var clearances: [UserRequirementStatus] = []
        var trainings: [UserRequirementStatus] = []
        var policies: [UserRequirementStatus] = []
        
        for history in histories {
            // Match the requirement with the same reqID
            if let matchedRequirement = requirements.first(where: { $0.reqID == history.reqID }) {
                //print("Processing reqType: \(matchedRequirement.reqType.lowercased())")
                switch matchedRequirement.reqType.lowercased() {
                case "clearance":
                    clearances.append(history)
                case "training":
                    trainings.append(history)
                case "policy":
                    policies.append(history)
                default:
                    print("Unknown reqType for reqID: \(matchedRequirement.reqID)")
                }
            } else {
                print("No matching requirement found for reqID: \(history.reqID)")
            }
        }
        
        // Debugging: Print categorized results
        //print("Clearances: \(clearances)")
        //print("Trainings: \(trainings)")
        //print("Policies: \(policies)")
        
        return (clearances, trainings, policies)
    }
}
