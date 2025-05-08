import Foundation
import PostgresClientKit

// Variable descriptions
// ADE, Adult Diocesan Employee Non-Education
// ADSE, Adult Diocesan School Employee
// AVCM, Adult Volunteer Contact with Minors
// MDE, Minor Diocesan Employee
// MV, Minor Volunteer 14-17
// MVU, Minor Volunteer under 14


// Data models for categorizing requirements in the SAFE Source system

struct ParticipationCategory {
    let cat_id: String
    let cat_description: String
    let cat_includes: String
    let cat_age_range: String
}

struct PolicyData {
    let policy_id: String
    let policy_description: String
    let policy_completion: String
}

struct ClearanceData {
    let clearance_id: String
    let clearance_description: String
    let clearance_completion: String
}

struct doaTrainings {
    let doa_training_id: String
    let doa_training_description: String
    let doa_training_completion: String
}

struct paStateTrainings {
    let paTraining_id: String
    let paTraining_description: String
    let paTraining_completion: String
}

// Global arrays for storing fetched data used throughout the app
var fetchedParticipationCategories: [ParticipationCategory] = []
var fetchedPolicyData: [PolicyData] = []
var fetchedClearanceData: [ClearanceData] = []
var fetchedDoaTrainings: [doaTrainings] = []
var fetchedPaStateTrainings: [paStateTrainings] = []

// Loads active participation categories from the database
func fetchParticipationCategories() {
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let query = """
        SELECT "cat_id", "cat_description", "cat_includes", "cat_age_range"
        FROM "safe_source_participation_category" 
        WHERE "cat_active" = TRUE
        ORDER BY "cat_id";
        """
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        var fetchedSources = [ParticipationCategory]()

        for row in cursor {
            let columns = try row.get().columns
            let catid = try columns[0].string()
            let category = try columns[1].string()
            let includes = try columns[2].string()
            let ageRange = try columns[3].string()
            
            fetchedSources.append(
                ParticipationCategory(cat_id: catid, cat_description: category, cat_includes: includes, cat_age_range: ageRange)
            )
        }
        
        DispatchQueue.main.async {
            fetchedParticipationCategories = fetchedSources
        }

    } catch {
        print("Error fetching participation categories: \(error)")
    }
}

// Loads active policy requirements for a specific user category and diocese
func fetchPolicyData(inputData: String) {
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let pquery = """
        SELECT 
            "safe_source_policies"."policy_id",
            "safe_source_policies"."policy_description",
            "safe_source_person_requirements"."req_completion"
        FROM "safe_source_policies"
        INNER JOIN "safe_source_person_requirements"
            ON "safe_source_policies"."policy_id" = "safe_source_person_requirements"."req_id"
        WHERE "safe_source_person_requirements"."req_active" = TRUE
            AND "safe_source_policies"."policy_of" = $2
            AND "safe_source_person_requirements"."req_type" = 'Policy'
            AND "safe_source_person_requirements"."person_cat" = $1
        ORDER BY "policy_description";
        """
        
        let statement = try connection.prepareStatement(text: pquery)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [inputData, user_diocese_name])
        var pfetchedSources = [PolicyData]()
        
        for row in cursor {
            let columns = try row.get().columns
            let policyid = try columns[0].string()
            let pdescription = try columns[1].string()
            let completion = try columns[2].string()
            
            pfetchedSources.append(
                PolicyData(policy_id: policyid, policy_description: pdescription, policy_completion: completion)
            )
        }
        
        DispatchQueue.main.async {
            fetchedPolicyData = pfetchedSources
        }
        
    } catch {
        print("Error fetching policy data: \(error)")
    }
}

// Loads clearance requirements for a user category
func fetchClearanceData(inputData: String) {
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let pquery = """
        SELECT 
            "safe_source_clearances"."clearance_id",
            "safe_source_clearances"."clearance_description",
            "safe_source_person_requirements"."req_completion"
        FROM "safe_source_clearances" 
        INNER JOIN "safe_source_person_requirements"
            ON "safe_source_clearances"."clearance_id" = "safe_source_person_requirements"."req_id"
        WHERE "safe_source_person_requirements"."req_active" = TRUE
            AND "safe_source_person_requirements"."req_type" = 'Clearance'
            AND "safe_source_person_requirements"."person_cat" = $1
        ORDER BY "clearance_description";
        """
        
        let statement = try connection.prepareStatement(text: pquery)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [inputData])
        var cfetchedSources = [ClearanceData]()
        
        for row in cursor {
            let columns = try row.get().columns
            let clearanceId = try columns[0].string()
            let clearanceDesc = try columns[1].string()
            let completion = try columns[2].string()
            
            cfetchedSources.append(
                ClearanceData(clearance_id: clearanceId, clearance_description: clearanceDesc, clearance_completion: completion)
            )
        }
        
        DispatchQueue.main.async {
            fetchedClearanceData = cfetchedSources
            print("Fetched clearances: \(cfetchedSources)")
        }
        
    } catch {
        print("Error fetching clearance data: \(error)")
    }
}

// Loads internal DOA trainings based on user’s diocese and category
func fetchDoaTrainingData(inputData: String) {
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let pquery = """
        SELECT 
            "safe_source_trainings"."training_id",
            "safe_source_trainings"."training_description",
            "safe_source_person_requirements"."req_completion"
        FROM "safe_source_trainings"
        INNER JOIN "safe_source_person_requirements"
            ON "safe_source_trainings"."training_id" = "safe_source_person_requirements"."req_id"
        WHERE "safe_source_person_requirements"."req_active" = TRUE
            AND "safe_source_person_requirements"."req_source" = $1
            AND "safe_source_person_requirements"."req_type" = 'Training'
            AND "safe_source_person_requirements"."person_cat" = $2
        ORDER BY "training_description";
        """
        
        let statement = try connection.prepareStatement(text: pquery)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [user_diocese_name, inputData])
        var tfetchedSources = [doaTrainings]()
        
        for row in cursor {
            let columns = try row.get().columns
            let trainingid = try columns[0].string()
            let trainingdescription = try columns[1].string()
            let completion = try columns[2].string()
            
            tfetchedSources.append(
                doaTrainings(doa_training_id: trainingid, doa_training_description: trainingdescription, doa_training_completion: completion)
            )
        }
        
        DispatchQueue.main.async {
            fetchedDoaTrainings = tfetchedSources
        }
        
    } catch {
        print("Error fetching DOA Training data: \(error)")
    }
}

// Loads PA state-specific trainings for a given user category
func fetchPATrainingData(inputData: String) {
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let pquery = """
        SELECT 
            "safe_source_trainings"."training_id",
            "safe_source_trainings"."training_description",
            "safe_source_person_requirements"."req_completion"
        FROM "safe_source_trainings"
        INNER JOIN "safe_source_person_requirements"
            ON "safe_source_trainings"."training_id" = "safe_source_person_requirements"."req_id"
        WHERE "safe_source_person_requirements"."req_active" = TRUE
            AND "safe_source_person_requirements"."req_source" = $1
            AND "safe_source_person_requirements"."req_type" = 'Training'
            AND "safe_source_person_requirements"."person_cat" = $2
        ORDER BY "training_description";
        """
        
        let statement = try connection.prepareStatement(text: pquery)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [user_state_id, inputData])
        var tfetchedSources = [paStateTrainings]()
        
        for row in cursor {
            let columns = try row.get().columns
            let trainingid = try columns[0].string()
            let trainingdescription = try columns[1].string()
            let completion = try columns[2].string()
            
            tfetchedSources.append(
                paStateTrainings(paTraining_id: trainingid, paTraining_description: trainingdescription, paTraining_completion: completion)
            )
        }
        
        DispatchQueue.main.async {
            fetchedPaStateTrainings = tfetchedSources
        }
        
    } catch {
        print("Error fetching PA State Training data: \(error)")
    }
}
