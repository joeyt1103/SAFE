//
//  flowchart_data.swift
//  SAFE
//
//  Created by Kevin Gualano on 10/16/24.
//

struct Pickedstate {
    let state_id: Int
    let state_full: String
}

struct Step {
    var step_head: String
    var step_data: String
    var step_num: Int
}

struct StepDetails {
    var step1: Step?
    var step2: Step?
    var step3: Step?
    var step4: Step?
    var step5: Step?
    var step6: Step?
}

// Function to fetch states from PostgreSQL
func fetchStates() -> [Pickedstate] {
    var fetchedStates = [Pickedstate]()
    
    do {
        let connection = try dbConnect() // dbConnect is the function to connect to the server
        defer { connection.close() }
        
        let query = """
        SELECT "entity_id", "entity_name"
        FROM "data_source_entity"
        WHERE "use_flowchart" = TRUE
        AND "ent_type" = 'State' 
        AND "ent_active" = TRUE
        ORDER BY "entity_name"; 
        """
        
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        
        for row in cursor {
            let columns = try row.get().columns
            let stateId = try columns[0].int()
            let stateFull = try columns[1].string()
            
            let state = Pickedstate(state_id: stateId, state_full: stateFull)
            fetchedStates.append(state)
        }
    } catch {
        print("Error connecting to the database or fetching data: \(error)")
    }
    
    return fetchedStates
}
//Fetching the details for Steps 1 and 2
func determineStatesSteps1and2(location: Int, residence: Int) -> StepDetails {
    var steps = StepDetails()
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let query = """
            SELECT "step_head", "step_data", "step_num"
            FROM "safe_source_reporting_steps"
            WHERE "step_num" IN (1, 2)
            AND "step_req_by" = $1
            AND "step_active" = TRUE
            ORDER BY "step_num";
        """
        
        if location == residence {
            // Case 1: Single state (e.g., PA/PA or NJ/NJ)
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [location])
            
            for row in cursor {
                let columns = try row.get().columns
                let stepHead = try columns[0].string()
                let stepData = try columns[1].string()
                let stepNum = try columns[2].int()
                
                // Assign results to steps
                if stepNum == 1 {
                    steps.step1 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                } else if stepNum == 2 {
                    steps.step2 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                }
            }
            
        } else {
            // Case 2: Mixed states (e.g., PA/NJ or NJ/PA)
            
            // Fetch steps for location
            let statementLocation = try connection.prepareStatement(text: query)
            defer { statementLocation.close() }
            let cursorLocation = try statementLocation.execute(parameterValues: [location])
            
            // Separate variables for location and residence results
            var locationStep1: Step? = nil
            var locationStep2: Step? = nil
            
            for row in cursorLocation {
                let columns = try row.get().columns
                let stepHead = try columns[0].string()
                let stepData = try columns[1].string()
                let stepNum = try columns[2].int()
                
                // Assign location results
                if stepNum == 1 {
                    locationStep1 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                } else if stepNum == 2 {
                    locationStep2 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                }
            }
            
            // Fetch steps for residence
            let statementResidence = try connection.prepareStatement(text: query)
            defer { statementResidence.close() }
            let cursorResidence = try statementResidence.execute(parameterValues: [residence])
            
            var residenceStep1: Step? = nil
            var residenceStep2: Step? = nil
            
            for row in cursorResidence {
                let columns = try row.get().columns
                let stepHead = try columns[0].string()
                let stepData = try columns[1].string()
                let stepNum = try columns[2].int()
                
                // Assign residence results
                if stepNum == 1 {
                    residenceStep1 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                } else if stepNum == 2 {
                    residenceStep2 = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
                }
            }
            
            // Combine location and residence steps in StepDetails
            steps.step1 = locationStep1 ?? residenceStep1
            steps.step2 = locationStep2 ?? residenceStep2
            
            // Append residence steps separately if they are also needed
            if residenceStep1 != nil || residenceStep2 != nil {
                steps.step3 = residenceStep1
                steps.step4 = residenceStep2
            }
        }
        
    } catch {
        print("Error: \(error)")
    }
    
    return steps
}

func fetchHomeDioceseSteps(user_diocese_id: Int) -> [Step] {
    var steps: [Step] = []
    
    do {
        let connection = try dbConnect() // Connect to your database
        defer { connection.close() }
        
        let query = """
            SELECT "step_head", "step_data", "step_num"
            FROM "safe_source_reporting_steps"
            WHERE "step_num" BETWEEN 3 AND 6
            AND "step_req_by" = $1
            AND "step_active" = TRUE
            ORDER BY "step_num";
        """
        
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        
        let cursor = try statement.execute(parameterValues: [user_diocese_id])
        
        for row in cursor {
            let columns = try row.get().columns
            let stepHead = try columns[0].string()
            let stepData = try columns[1].string()
            let stepNum = try columns[2].int()
            
            let step = Step(step_head: stepHead, step_data: stepData, step_num: stepNum)
            steps.append(step)
        }
        
    } catch {
        print("Error: \(error)")
    }
    
    return steps
}
