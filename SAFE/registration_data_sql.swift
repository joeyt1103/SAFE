//
//  registration_data_sql.swift
//  SAFE
//
//  Created by Kevin Gualano on 11/11/24.
//

import SwiftUI
import PostgresClientKit

// MARK: - Titles

struct Titles: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

class TitlesViewModel: ObservableObject {
    @Published var titles: [Titles] = []

    // Fetch all available titles from the ref_titles table
    func fetchTitles() {
        do {
            let connection = try dbConnect()
            defer { connection.close() }

            let query = """
            SELECT "title"
            FROM "ref_titles"
            ORDER BY "title";
            """
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }

            let cursor = try statement.execute()
            var fetchedTitles = [Titles]()

            for row in cursor {
                let columns = try row.get().columns
                let title = try columns[0].string()
                fetchedTitles.append(Titles(name: title))
            }

            DispatchQueue.main.async {
                self.titles = fetchedTitles
            }

        } catch {
            print("Error fetching titles: \(error)")
        }
    }
}

// MARK: - Participation Categories

struct PartCategory: Identifiable, Hashable {
    let id = UUID()
    let cat_id: String
    let cat_description: String
}

// Shared global array used by forms like RegisterView
var fetchedPartCategories: [PartCategory] = []

// Fetch all active participation categories from DB
func fetchCategories() {
    do {
        let connection = try dbConnect()
        defer { connection.close() }

        let query = """
        SELECT "cat_id", "cat_description"
        FROM "safe_source_participation_category" 
        WHERE "cat_active" = TRUE
        ORDER BY "cat_id";
        """
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }

        let cursor = try statement.execute()
        var fetchedSources = [PartCategory]()

        for row in cursor {
            let columns = try row.get().columns
            let catid = try columns[0].string()
            let category = try columns[1].string()
            fetchedSources.append(PartCategory(cat_id: catid, cat_description: category))
        }

        DispatchQueue.main.async {
            fetchedPartCategories = fetchedSources
        }

    } catch {
        print("Error fetching participation categories: \(error)")
    }
}

// MARK: - User Registration Functions

// Inserts new user into auth_user table and returns the generated user ID
func insertNewUser(username: String, password: String, firstName: String, lastName: String, email: String) -> Int? {
    var userId: Int?

    do {
        let connection = try dbConnect()
        defer { connection.close() }

        let query = """
        INSERT INTO "auth_user" ("username", "password", "first_name", "last_name", "email")
        VALUES ($1, $2, $3, $4, $5)
        RETURNING "id";
        """
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }

        let cursor = try statement.execute(parameterValues: [username, password, firstName, lastName, email])

        if let row = cursor.next() {
            userId = try row.get().columns[0].int()
        }

    } catch {
        print("Error inserting into auth_user: \(error)")
    }

    return userId
}

// Inserts related extended user info into auth_user_extended table
func insertUserExtended(userID: Int, Title: String, middleName: String, pin: String, userRequirement: String) {
    do {
        let connection = try dbConnect()
        defer { connection.close() }

        let query = """
        INSERT INTO "auth_user_extended" ("user_id", "id", "title", "middle_name", "pin", "user_requirement_group")
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING "user_id";
        """
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }

        try statement.execute(parameterValues: [userID, userID, Title, middleName, pin, userRequirement])

        print("Successfully added extended data for user: \(userID)")

    } catch {
        print("Error inserting into auth_user_extended: \(error)")
    }
}
