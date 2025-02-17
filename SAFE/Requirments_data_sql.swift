import SwiftUI
import Foundation
//import PostgresClientKit

// This module contains the calculations needed for the requirements view
// This will only get the most recent (or last) requirement data

struct UserRequirementStatus: Identifiable {
    let id = UUID()
    let userID: Int
    let reqID: String
    let validOn: Date
    let expiresDate: Date
    let status: String
}

struct Requirement {
    let reqID: String
    let personCat: String
    let reqType: String
    let term: Int?
}

struct PolicyHistory {
    let userID: Int
    let policy_id: String
    let date_fulfilled: Date
        
}

struct ClearanceHistory {
    let userID: Int
    let clearance_id: String
    let validOn: Date
    let term: Int
    let expiresDate: Date?
    
}

struct TrainingHistory {
    let userID: Int
    let training_id: String
    let validOn: Date
    let term: Int
    let expiresDate: Date?
    
}

protocol HistoryRecord {
    var reqID: String { get }
    var validOn: Date { get }
    var expiresDate: Date? { get }
    
}


extension ClearanceHistory: HistoryRecord {
    var reqID: String {
        return clearance_id
    }
}
extension TrainingHistory: HistoryRecord {
    var reqID: String {
        return training_id
    }
}

// Helper function to calculate status
func calculateStatus(validOn: Date, expiresDate: Date?, term: Int, warningPeriod: Int = req_warning_period) -> String {
    let currentDate = Date()
    let warningThreshold = Calendar.current.date(byAdding: .month, value: warningPeriod, to: currentDate)!
    let longTermThreshold = Calendar.current.date(byAdding: .month, value: (term * 12) - warningPeriod, to: currentDate)!

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    // Handle the specific default date for "Generated"
    if formatter.string(from: validOn) == "0001-01-01" {
        return "Generated"
    }

    // Once and done
    if term == 0 {
        return "Completed On: \(formatter.string(from: validOn))"
    }

    // Policies don't have expiration dates
    if expiresDate == nil {
        return "Completed On: \(formatter.string(from: validOn))"
    }

    guard let expires = expiresDate else {
        return "Unknown Status"
    }

    // Expired
    if expires < currentDate {
        return "Expired On: \(formatter.string(from: expires))"
    }

    // Expiring within the warning period
    if expires <= warningThreshold {
        return "Expiring Within \(warningPeriod) months: \(formatter.string(from: expires))"
    }

    // Up to date
    if expires > longTermThreshold {
        return "Currently Up to Date"
    }

    return "Unknown Status"
}

// Fetch user requirements based on user category
func fetchUserRequirements(userCategory: String, userID: Int) -> [Requirement] {
    var requirements = [Requirement]()
    let sql = """
    WITH template_requirements AS (
        SELECT req_id, person_cat, req_type, NULL::BIGINT AS term
        FROM safe_source_person_requirements
        WHERE person_cat = $1 AND req_active = TRUE
    ),
    history_clearances AS (
        SELECT DISTINCT clearance_id AS req_id, '' AS person_cat, 'Clearance' AS req_type, term,
               ROW_NUMBER() OVER (PARTITION BY clearance_id ORDER BY valid_on DESC) AS rn
        FROM user_clearance_history
        WHERE user_id = $2
    ),
    history_trainings AS (
        SELECT DISTINCT training_id AS req_id, '' AS person_cat, 'Training' AS req_type, term,
               ROW_NUMBER() OVER (PARTITION BY training_id ORDER BY valid_on DESC) AS rn
        FROM user_training_history
        WHERE user_id = $2
    ),
    history_policies AS (
        SELECT DISTINCT policy_id AS req_id, '' AS person_cat, 'Policy' AS req_type, 0::BIGINT AS term,
               ROW_NUMBER() OVER (PARTITION BY policy_id ORDER BY valid_on DESC) AS rn
        FROM user_policy_history
        WHERE user_id = $2
    ),
    history_requirements AS (
        SELECT req_id, person_cat, req_type, term
        FROM history_clearances
        WHERE rn = 1

        UNION

        SELECT req_id, person_cat, req_type, term
        FROM history_trainings
        WHERE rn = 1

        UNION

        SELECT req_id, person_cat, req_type, term
        FROM history_policies
        WHERE rn = 1
    )
    SELECT *
    FROM template_requirements

    UNION

    SELECT *
    FROM history_requirements
    WHERE req_id NOT IN (SELECT req_id FROM template_requirements);
    """
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [userCategory, userID])
        for row in cursor {
            let columns = try row.get().columns
            let termValue = try columns[3].optionalInt() // Handle nullable term
            let req = Requirement(
                reqID: try columns[0].string(),
                personCat: try columns[1].string(),
                reqType: try columns[2].string(),
                term: termValue
            )
            requirements.append(req)
        }
    } catch {
        print("Error fetching requirements: \(error)")
    }
    return requirements
}

// Fetch user policy history
func fetchUserPolicyHistory(userID: Int) -> [PolicyHistory] {
    var policyHistory = [PolicyHistory]()
    let sql = """
    SELECT user_id, policy_id, 
           COALESCE(date_fulfilled, '0001-01-01') AS valid_on
    FROM (
        SELECT user_id, policy_id, date_fulfilled,
               ROW_NUMBER() OVER (PARTITION BY policy_id ORDER BY date_fulfilled DESC) AS rn
        FROM user_policy_history
        WHERE user_id = $1
    ) subquery
    WHERE rn = 1;
    """
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [userID])
        
        for row in cursor {
            do {
                let columns = try row.get().columns
                
                // Handle optional string and date conversion
                let validOnString = try columns[2].optionalString()
                let validOnDate: Date
                
                if let validOnString = validOnString {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let date = formatter.date(from: validOnString) {
                        validOnDate = date
                    } else {
                        //print("Invalid date format for validOn: \(validOnString), using distantPast as fallback.")
                        validOnDate = Date.distantPast
                    }
                } else {
                    validOnDate = Date.distantPast // Handle NULL values with a fallback date
                }
                
                let history = PolicyHistory(
                    userID: try columns[0].int(),
                    policy_id: try columns[1].string(),
                    date_fulfilled: validOnDate
                )
                policyHistory.append(history)
                
            } catch {
                print("Error processing row: \(error)")
            }
        }
        
    } catch {
        print("Error fetching policy history: \(error)")
    }
    
    // Debugging: print the result
    //print("Policy History Fetched: \(policyHistory)")
    return policyHistory
}
// Fetch user clearance history
func fetchUserClearanceHistory(userID: Int) -> [ClearanceHistory] {
    var clearanceHistory = [ClearanceHistory]()
    let sql = """
    SELECT user_id, clearance_id, 
           COALESCE(date_fulfilled, '0001-01-01') AS valid_on, 
           term, 
           expires_on AS expires_date
    FROM (
        SELECT user_id, clearance_id, date_fulfilled, term, expires_on,
               ROW_NUMBER() OVER (PARTITION BY clearance_id ORDER BY date_fulfilled DESC) AS rn
        FROM user_clearance_history
        WHERE user_id = $1
    ) subquery
    WHERE rn = 1;
    """
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [userID])
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust if using timestamps
        
        for row in cursor {
            let columns = try row.get().columns
            
            // Convert validOn to Date
            let validOnString = try columns[2].string()
            guard let validOnDate = formatter.date(from: validOnString) else {
                print("Error: Invalid date format for validOn: \(validOnString)")
                continue
            }
            
            // Convert expiresDate to Date (optional)
            let expiresDateString = try columns[4].optionalString()
            let expiresDate = expiresDateString.flatMap { formatter.date(from: $0) }
            
            let history = ClearanceHistory(
                userID: try columns[0].int(),
                clearance_id: try columns[1].string(),
                validOn: validOnDate,
                term: try columns[3].int(),
                expiresDate: expiresDate
            )
            clearanceHistory.append(history)
            //print("clearance history: \(clearanceHistory)")
        }
    } catch {
        print("Error fetching clearance history: \(error)")
    }
    //print("clearance hist sql: \(clearanceHistory)")
    return clearanceHistory
}

// Fetch user training history
func fetchUserTrainingHistory(userID: Int) -> [TrainingHistory] {
    var trainingHistory = [TrainingHistory]()
    let sql = """
    SELECT user_id, training_id, 
           COALESCE(date_fulfilled, '0001-01-01') AS valid_on, 
           term, 
           expires_on AS expires_date
    FROM (
        SELECT user_id, training_id, date_fulfilled, term, expires_on,
               ROW_NUMBER() OVER (PARTITION BY training_id ORDER BY date_fulfilled DESC) AS rn
        FROM user_training_history
        WHERE user_id = $1
    ) subquery
    WHERE rn = 1;
    """
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [userID])
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for row in cursor {
            let columns = try row.get().columns
            
            // Convert validOn to Date
            let validOnString = try columns[2].string()
            guard let validOnDate = formatter.date(from: validOnString) else {
                print("Error: Invalid date format for validOn: \(validOnString)")
                continue
            }
            
            // Convert expiresDate to Date (optional)
            let expiresDateString = try columns[4].optionalString()
            let expiresDate = expiresDateString.flatMap { formatter.date(from: $0) }
            
            let history = TrainingHistory(
                userID: try columns[0].int(),
                training_id: try columns[1].string(),
                validOn: validOnDate,
                term: try columns[3].int(),
                expiresDate: expiresDate
            )
            trainingHistory.append(history)
            //print("training history: \(trainingHistory)")
        }
    } catch {
        print("Error fetching training history: \(error)")
    }
    //print("training hist sql: \(trainingHistory)")
    return trainingHistory
}
// Combine everything into user requirement statuses
func fetchUserRequirementsStatus(userID: Int, userCategory: String) -> [UserRequirementStatus] {
    let requirements = fetchUserRequirements(userCategory: userCategory, userID: userID)
    let policyHistory = fetchUserPolicyHistory(userID: userID)
    let clearanceHistory = fetchUserClearanceHistory(userID: userID)
    let trainingHistory = fetchUserTrainingHistory(userID: userID)

    let allHistories: [HistoryRecord] = policyHistory.map {
        ClearanceHistory(userID: $0.userID, clearance_id: $0.policy_id, validOn: $0.date_fulfilled, term: 0, expiresDate: nil)
    } + clearanceHistory + trainingHistory

    var statuses = [UserRequirementStatus]()

    for req in requirements {
        let matchingHistories = allHistories.filter { $0.reqID == req.reqID }

        if let latestHistory = matchingHistories.max(by: { $0.validOn < $1.validOn }) {
            let term = (latestHistory as? ClearanceHistory)?.term ?? (latestHistory as? TrainingHistory)?.term ?? 0
            let expiresDate = (term == 0) ? nil : latestHistory.expiresDate

            statuses.append(UserRequirementStatus(
                userID: userID,
                reqID: latestHistory.reqID,
                validOn: latestHistory.validOn,
                expiresDate: expiresDate ?? Date.distantFuture,
                status: calculateStatus(
                    validOn: latestHistory.validOn,
                    expiresDate: expiresDate,
                    term: term
                )
            ))
        } else {
            statuses.append(UserRequirementStatus(
                userID: userID,
                reqID: req.reqID,
                validOn: Date.distantPast,
                expiresDate: Date.distantPast,
                status: "Not Completed"
            ))
        }
    }

    return statuses
}
