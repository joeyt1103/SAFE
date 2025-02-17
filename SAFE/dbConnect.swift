//
//  postgres.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/21/24.
//

import PostgresClientKit


// Global function to connect to the PostgreSQL database
func dbConnect() throws -> PostgresClientKit.Connection {
    // Configuration for the connection
    var configuration = PostgresClientKit.ConnectionConfiguration()
    
    if use_cloud_db == true {
        configuration.host = "3.16.36.7"                      // for AWS Server
        configuration.credential = .scramSHA256(password: "C@th0l1c")     // Authentication type for AWS
    } else {
        configuration.host = "192.168.4.33"   //For local Server
        configuration.credential = .trust     // Authentication type for Local
    }
    
    configuration.port = 5432             // Default PostgreSQL port
    configuration.ssl = false             // Set to true if using SSL
    configuration.database = "safe"       // Your database name
    configuration.user = "ds_student_design"       // PostgreSQL username
    
    
    // Return the connection
    return try PostgresClientKit.Connection(configuration: configuration)
    
}

// Test the database connection
func testDBConnection() {
    do {
        // Attempt to connect to the database
        let connection = try dbConnect()
        
        // If connection is successful
        print("Connection to database successful!")
        
        // Close the connection after testing
        connection.close()
    } catch {
        // If there was an error, print it out
        print("Error connecting to database: \(error)")
    }
}


