//
//  Prayers_data_sql.swift
//  SAFE
//
//  Created by Kevin Gualano on 12/5/24.
//

import SwiftUI
import Foundation
import PostgresClientKit

struct PrayerData: Identifiable, Equatable {
    let id = UUID()
    var prayerName: String
    var prayerText: String
    var prayerApp: String
    var prayerSource: String
    var prayerCategory: String
}


func fetchPrayerCategories(completion: @escaping ([String]) -> Void) {
    var categories: [String] = ["All"] // Default to "All"
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryCategories = """
        SELECT DISTINCT "prayer_category"
        FROM "safe_source_prayers"
        WHERE "prayer_show" = true
        ORDER BY "prayer_category"
        """
        
        let statement = try connection.prepareStatement(text: queryCategories)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        for row in cursor {
            let columns = try row.get().columns
            if let category = try? columns[0].string() {
                categories.append(category)
            }
        }
        
        completion(categories)
    } catch {
        print("Database error: \(error)")
        completion(["All"]) // Return default value in case of error
    }
}
func getPrayer(completion: @escaping ([PrayerData]) -> Void) {
    var fetchedPrayers: [PrayerData] = []
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryPrayers = """
        SELECT "prayer_name", "prayer_text", "prayer_appropriate", "prayer_source", "prayer_category"
        FROM "safe_source_prayers"
        WHERE "prayer_show" = true
        ORDER BY "prayer_name"
        """
        
        let statement = try connection.prepareStatement(text: queryPrayers)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
    
        
        for row in cursor {
            let columns = try row.get().columns
            let prayerName = try columns[0].string()
            let prayerText = try columns[1].string()
            let prayerApp = try columns[2].string()
            let prayerSource = try columns[3].string()
            let prayerCategory = try columns[4].string()
            
            
            
                fetchedPrayers.append(PrayerData(
                    prayerName: prayerName,
                    prayerText: prayerText,
                    prayerApp: prayerApp,
                    prayerSource: prayerSource,
                    prayerCategory: prayerCategory
                ))
            
        }
        
        completion(fetchedPrayers)
    } catch {
        print("Database error: \(error)")
        completion([])
    }
}
