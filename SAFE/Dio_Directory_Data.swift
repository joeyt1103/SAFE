import SwiftUI
import Foundation
import PostgresClientKit

// MARK: - Location Data Structure
struct LocationData: Identifiable, Equatable, Hashable {
    let id = UUID()
    let locationId: Int
    var locationName: String
    var locationPastor: String
    var locationAdd1: String
    var locationAdd2: String
    var locationCity: String
    var locationState: String
    var locationZip: String
    let locationCounty: String
    var locationPhone: String
    var locationFax: String
    var locationEmail: String
    var locationWeb: String
    var locationActive: Bool
    let locationDOAid: Int
    var locationType: String
}

// MARK: - Fetch Location Names
func fetchLocations(completion: @escaping ([String]) -> Void) {
    var locations: [String] = ["All"] // Default to "All"
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryLocations = """
        SELECT DISTINCT "loc_name"
        FROM "data_source_location"
        ORDER BY "loc_name"
        """
        
        let statement = try connection.prepareStatement(text: queryLocations)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        for row in cursor {
            let columns = try row.get().columns
            let locationName = try columns[0].string()
            locations.append(locationName)
        }
        completion(locations)
    } catch {
        print("Database error in fetchLocations: \(error)")
        completion(["All"]) // Return default value in case of error
    }
}

// MARK: - Fetch Counties
func fetchCounties(completion: @escaping ([String]) -> Void) {
    var counties: [String] = ["All"] // Default to "All"
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryCounties = """
        SELECT DISTINCT "loc_county"
        FROM "data_source_location"
        GROUP BY "loc_county"
        ORDER BY "loc_county"
        """
        
        let statement = try connection.prepareStatement(text: queryCounties)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        for row in cursor {
            let columns = try row.get().columns
            if let locationCounty = try? columns[0].string() {
                counties.append(locationCounty)
            }
        }
        
        completion(counties)
    } catch {
        print("Database error in fetchCounties: \(error)")
        completion(["All"]) // Return default value in case of error
    }
}

// MARK: - Fetch Location Data
func getLocations(completion: @escaping ([LocationData]) -> Void) {
    var fetchedLocations: [LocationData] = []
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryLocations = """
        SELECT DISTINCT "loc_id", "loc_name", "loc_pastor",
                        "loc_add1", "loc_add2", "loc_city", 
                        "loc_state", "loc_zip", "loc_county", 
                        "loc_phone", "loc_fax", "loc_email", 
                        "loc_web", "loc_active", "diocese_id","loc_type"
        FROM "data_source_location"
        ORDER BY "loc_name"
        """
        
        let statement = try connection.prepareStatement(text: queryLocations)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        for row in cursor {
            let columns = try row.get().columns
            let locationId = try columns[0].int()
            let locationName = try columns[1].string()
            let locationPastor = try columns[2].string()
            let locationAdd1 = try columns[3].string()
            let locationAdd2 = (try? columns[4].string()) ?? ""
            let locationCity = try columns[5].string()
            let locationState = try columns[6].string()
            let locationZip = try columns[7].string()
            let locationCounty = try columns[8].string()
            let locationPhone = try columns[9].string()
            let locationFax = try columns[10].string()
            let locationEmail = try columns[11].string()
            let locationWeb = try columns[12].string()
            let locationActive = try columns[13].bool()
            let locationDOAid = try columns[14].int()
            let locationType = try columns[15].string()
            
            fetchedLocations.append(
                LocationData(
                    locationId: locationId,
                    locationName: locationName,
                    locationPastor: locationPastor,
                    locationAdd1: locationAdd1,
                    locationAdd2: locationAdd2,
                    locationCity: locationCity,
                    locationState: locationState,
                    locationZip: locationZip,
                    locationCounty: locationCounty,
                    locationPhone: locationPhone,
                    locationFax: locationFax,
                    locationEmail: locationEmail,
                    locationWeb: locationWeb,
                    locationActive: locationActive,
                    locationDOAid: locationDOAid,
                    locationType: locationType

                )
            )
        }
        
        completion(fetchedLocations)
    } catch {
        print("Database error in getLocations: \(error)")
        completion([])
    }
}


// MARK: - Fetch Location Types
func fetchLocationTypes(completion: @escaping ([String]) -> Void) {
    var types: [String] = ["All"] // Default to "All"
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryLocations = """
        SELECT DISTINCT "loc_type"
        FROM "data_source_location"
        GROUP BY "loc_type"
        ORDER BY "loc_type"
        """
        
        let statement = try connection.prepareStatement(text: queryLocations)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        for row in cursor {
            let columns = try row.get().columns
            if let locationType = try? columns[0].string() {
                types.append(locationType)
            }
        }
        
        completion(types)
    } catch {
        print("Database error in fetch location types: \(error)")
        completion(["All"]) // Return default value in case of error
    }
}
