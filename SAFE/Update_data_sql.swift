import SwiftUI
import Foundation
import PostgresClientKit

struct UpdateData: Identifiable {
    let id = UUID()
    var updHeader: String
    var updBody: String
    var updDept: String
    var updBegin: Date = Date() // Default value so we don't need to pass it
}

func getUpdate(completion: @escaping ([UpdateData]) -> Void) {
    var fetchedUpdates: [UpdateData] = []
    
    do {
        let connection = try dbConnect()
        defer { connection.close() }
        
        let queryUpdates = """
        SELECT "upd_header", "upd_body", "dept", "upd_begin"::text
        FROM "safe_source_updates"
        WHERE "upd_show" = true
        ORDER BY "upd_begin" DESC
        """
        
        let statement = try connection.prepareStatement(text: queryUpdates)
        defer { statement.close() }
        
        let cursor = try statement.execute()
        defer { cursor.close() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        for row in cursor {
            let columns = try row.get().columns
            let updHeader = try columns[0].string()
            let updBody = try columns[1].string()
            let updDept = try columns[2].string()
            let updBeginString = try columns[3].string()
            
            if let updBegin = dateFormatter.date(from: updBeginString) {
                //print("Successfully parsed date: \(updBeginString) to \(updBegin)")
                fetchedUpdates.append(UpdateData(
                    updHeader: updHeader,
                    updBody: updBody,
                    updDept: updDept,
                    updBegin: updBegin
                ))
            } else {
                print("Failed to parse date: \(updBeginString)")
            }
        }
        
        completion(fetchedUpdates)
    } catch {
        print("Database error: \(error)")
        completion([])
    }
}
