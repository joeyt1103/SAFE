//
//  libraryQuery.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/21/24.
//

import PostgresClientKit

struct LibraryQueries {
    
    // Fetch all documents in the library
    static func fetchAllDocuments(completion: @escaping ([Document]) -> Void) {
            var documents = [Document]()
            
            do {
                let connection = try dbConnect()
                defer { connection.close() }
                
                // SQL query to fetch documents
                let query = "SELECT docName, docLocation FROM library"
                let statement = try connection.prepareStatement(text: query)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                for row in cursor {
                    let columns = try row.get().columns
                    let docName = try columns[0].string()       // No need to force unwrap here
                    let docLocation = try columns[1].string()   // Safely access the value
                    
                    let document = Document(name: docName, url: docLocation)
                    documents.append(document)
                }
                
                // Return the documents through the completion handler
                completion(documents)
                
            } catch {
                print("Error executing fetchAllDocuments query: \(error)")
                completion([])  // Return an empty array in case of error
            }
        }
    
    // Additional queries for the Library form can be added here
    // Example: Fetch a document by name
    static func fetchDocumentByName(_ name: String, completion: @escaping (Document?) -> Void) {
        do {
            let connection = try dbConnect()  // Errors thrown from here are caught
            defer { connection.close() }
            
            let query = "SELECT docName, docLocation FROM library WHERE docName = $1"
            let statement = try connection.prepareStatement(text: query)  // Errors caught here
            defer { statement.close() }
            
            // Execute the statement and pass the parameter value for `$1`
            let cursor = try statement.execute(parameterValues: [name])
                    
            

            if let row = cursor.next() {
                let columns = try row.get().columns
                let docName = try columns[0].string()        // Safely access the result
                let docLocation = try columns[1].string()
                
                let document = Document(name: docName, url: docLocation)
                completion(document)
            } else {
                completion(nil)  // No document found
            }
        } catch {
            print("Error executing fetchDocumentByName query: \(error)")
            completion(nil)
        }
    }
    
}
