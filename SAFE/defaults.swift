//
//  defaults.swift
//  SAFE
//
//  Created by Kevin Gualano on 10/19/24.
//
// This file contains all default data that will be used throughout the app
//

import Foundation
import PostgresClientKit
import SwiftUI
import Combine

// MARK: - Utilities and data management
// Local or cloud server switch
let use_cloud_db = true // When distributing the app, set this to true

// MARK: - Admin default data
var req_warning_period = 3 // Number of months to begin reminding user their clearance/training before it expires

// MARK: - Save user name and password
var SavedUserID = 0

// 1. Define UserDefaultsKeys enum
enum UserDefaultsKeys: String, CaseIterable {
    case userId = "user_id"
    case password = "user_password"
    case username = "username"
    case dioceseName = "user_diocese_name"
    case dioceseId = "user_diocese_id"
    case state = "user_state"
    case stateId = "user_state_id"
    case superLevel = "user_super_level"
    case staff = "user_staff"
    case title = "user_title"
    case locationId = "user_location_id"
    case pin = "user_pin"
    case requirementGroup = "user_requirement_group"
    case vocation = "user_vocation"
    case addressId = "user_address_id"
    case firstName = "user_first_name"
    case lastName = "user_last_name"
    case primeMinistry = "user_prime_ministry"
    case email = "user_email"
    case middleName = "user_middle_name"
    case add1 = "user_add1"
    case add2 = "user_add2"
    case city = "user_city"
    case zip = "user_zip"
    case gender = "user_gender"
    case cell = "user_cell"
    case dioEmp = "user_dio_emp"
    case locRole = "user_loc_role"
    case locName = "user_loc_name"
    case locType = "user_loc_type"
    case catDesc = "user_cat_desc"
    case userFullName = "user_full_name"
}

// 2. Define the User model
struct User: Codable {
    let id: Int
    let password: String
    let username: String
    let firstName: String
    let lastName: String
    let isSuperuser: Bool
    let isStaff: Bool
    let diocese: String
    let state: String
    let title: String
    let dioceseId: Int
    let locationId: Int
    let pin: String
    let userRequirementGroup: String
    let vocation: String
    let userAddressId: Int
    let primeMinistry: String
    let email: String
    let middleName: String?
    let add1: String
    let add2: String?
    let city: String
    let zip: String
    let cell: String
    let gender: String
    let dioEmp: Int
    let locRole: String
    let locName: String
    let locType: String
    let catDesc: String
    var userFullName: String {
        "\(firstName) \(middleName?.isEmpty == false ? middleName! + " " : "")\(lastName)"
            .trimmingCharacters(in: .whitespaces)
    }
}

// 3. Define UserDefaultsManager
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults: UserDefaults
    
    private init() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.kevingualano.SAFE") else {
            fatalError("Could not create UserDefaults")
        }
        self.defaults = sharedDefaults
    }
    
    func getUserDefaults(dbID: Int) async throws {
        do {
            let connection = try dbConnect() // Assuming dbConnect() is defined elsewhere
            defer { connection.close() }
            
            let query = """
            SELECT "auth_user"."id", "auth_user"."password", "auth_user"."username", "auth_user"."first_name", "auth_user"."last_name",
                   "auth_user"."is_superuser", "auth_user"."is_staff", "auth_user_extended"."diocese", "auth_user_extended"."state",
                   "auth_user_extended"."title", "auth_user_extended"."diocese_id", "auth_user_extended"."loc_id",
                   "auth_user_extended"."pin", "auth_user_extended"."user_requirement_group", "auth_user_extended"."vocation",
                   "auth_user_extended"."user_address_id", "auth_user_extended"."prime_ministry", "auth_user"."email",
                   "auth_user_extended"."middle_name", "auth_user_extended"."add1", "auth_user_extended"."add2", "auth_user_extended"."city",
                   "auth_user_extended"."zip", "auth_user_extended"."cell", "auth_user_extended"."gender", "auth_user_extended"."dio_employee",
                   "auth_user_extended"."loc_role", "data_source_location"."loc_name", "data_source_location"."loc_type"
            FROM "auth_user"
            INNER JOIN "auth_user_extended" ON "auth_user"."id" = "auth_user_extended"."user_id"
            LEFT JOIN "data_source_location" ON "auth_user_extended"."loc_id" = "data_source_location"."loc_id"
            WHERE "auth_user"."id" = $1
            """
            
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [dbID])
            for row in cursor {
                if let columns = try? row.get().columns {
                    let user = User(
                        id: try columns[0].int(),
                        password: try columns[1].string(),
                        username: try columns[2].string(),
                        firstName: try columns[3].string(),
                        lastName: try columns[4].string(),
                        isSuperuser: try columns[5].bool(),
                        isStaff: try columns[6].bool(),
                        diocese: try columns[7].string(),
                        state: try columns[8].string(),
                        title: try columns[9].string(),
                        dioceseId: try columns[10].int(),
                        locationId: try columns[11].int(),
                        pin: try columns[12].string(),
                        userRequirementGroup: try columns[13].string(),
                        vocation: try columns[14].string(),
                        userAddressId: try columns[15].int(),
                        primeMinistry: try columns[16].string(),
                        email: try columns[17].string(),
                        middleName: try? columns[18].string(),
                        add1: try columns[19].string(),
                        add2: try? columns[20].string(),
                        city: try columns[21].string(),
                        zip: try columns[22].string(),
                        cell: try columns[23].string(),
                        gender: try columns[24].string(),
                        dioEmp: try columns[25].int(),
                        locRole: try columns[26].string(),
                        locName: try columns[27].string(),
                        locType: try columns[28].string(),
                        catDesc: "Place hold need to do query"
                        
                    )
                    print("User Stuff \(user)")
                    saveUserToDefaults(user)
                }
            }
        } catch {
            print("Error occurred: \(error)")
            throw error
        }
    }
    
    private func saveUserToDefaults(_ user: User) {
        defaults.set(user.id, forKey: UserDefaultsKeys.userId.rawValue)
        defaults.set(user.password, forKey: UserDefaultsKeys.password.rawValue)
        defaults.set(user.username, forKey: UserDefaultsKeys.username.rawValue)
        defaults.set(user.diocese, forKey: UserDefaultsKeys.dioceseName.rawValue)
        defaults.set(user.dioceseId, forKey: UserDefaultsKeys.dioceseId.rawValue)
        defaults.set(user.state, forKey: UserDefaultsKeys.state.rawValue)
        defaults.set(user.state, forKey: UserDefaultsKeys.stateId.rawValue)
        defaults.set(user.isSuperuser, forKey: UserDefaultsKeys.superLevel.rawValue)
        defaults.set(user.isStaff, forKey: UserDefaultsKeys.staff.rawValue)
        defaults.set(user.title, forKey: UserDefaultsKeys.title.rawValue)
        defaults.set(user.locationId, forKey: UserDefaultsKeys.locationId.rawValue)
        defaults.set(user.pin, forKey: UserDefaultsKeys.pin.rawValue)
        defaults.set(user.userRequirementGroup, forKey: UserDefaultsKeys.requirementGroup.rawValue)
        defaults.set(user.vocation, forKey: UserDefaultsKeys.vocation.rawValue)
        defaults.set(user.userAddressId, forKey: UserDefaultsKeys.addressId.rawValue)
        defaults.set(user.firstName, forKey: UserDefaultsKeys.firstName.rawValue)
        defaults.set(user.lastName, forKey: UserDefaultsKeys.lastName.rawValue)
        defaults.set(user.primeMinistry, forKey: UserDefaultsKeys.primeMinistry.rawValue)
        defaults.set(user.email, forKey: UserDefaultsKeys.email.rawValue)
        defaults.set(user.middleName, forKey: UserDefaultsKeys.middleName.rawValue)
        defaults.set(user.add1, forKey: UserDefaultsKeys.add1.rawValue)
        defaults.set(user.add2, forKey: UserDefaultsKeys.add2.rawValue)
        defaults.set(user.city, forKey: UserDefaultsKeys.city.rawValue)
        defaults.set(user.zip, forKey: UserDefaultsKeys.zip.rawValue)
        defaults.set(user.cell, forKey: UserDefaultsKeys.cell.rawValue)
        defaults.set(user.gender, forKey: UserDefaultsKeys.gender.rawValue)
        defaults.set(user.locName, forKey: UserDefaultsKeys.locName.rawValue)
        defaults.set(user.locRole, forKey: UserDefaultsKeys.locRole.rawValue)
        defaults.set(user.locType, forKey: UserDefaultsKeys.locType.rawValue)
        defaults.set(user.catDesc, forKey: UserDefaultsKeys.catDesc.rawValue)
        defaults.set(user.userFullName, forKey: UserDefaultsKeys.userFullName.rawValue)
        
        defaults.synchronize()
    }
}

    // 4. Define UserState
    class UserState: ObservableObject {
        static let shared = UserState()
        private let defaults: UserDefaults

        private init() {
            guard let sharedDefaults = UserDefaults(suiteName: "group.kevingualano.SAFE") else {
                fatalError("Could not create UserDefaults")
            }
            self.defaults = sharedDefaults
            loadFromDefaults()
        }
        
        @Published var userId: Int = 0
        @Published var username: String = ""
        @Published var dioceseName: String = ""
        @Published var dioceseId: Int = 0
        @Published var state: String = ""
        @Published var stateId: String = ""
        @Published var isSuperuser: Bool = false
        @Published var isStaff: Bool = false
        @Published var title: String = ""
        @Published var locationId: Int = 0
        @Published var pin: String = ""
        @Published var requirementGroup: String = ""
        @Published var vocation: String = ""
        @Published var addressId: Int = 0
        @Published var firstName: String = ""
        @Published var lastName: String = ""
        @Published var email: String = ""
        @Published var primeMinsitry: String = ""
        @Published var middleName: String = ""
        @Published var isAuthenticated: Bool = false
        @Published var add1: String = ""
        @Published var add2: String = ""
        @Published var city: String = ""
        @Published var zip: String = ""
        @Published var cell: String = ""
        @Published var gender: String = ""
        @Published var dioEmp: Int = 0
        @Published var locName: String = ""
        @Published var catDesc: String = ""
        @Published var locType: String = ""
        @Published var locRole: String = ""
        @Published var fullName: String = ""
        @Published var userFullName: String = ""
        
        
        var user_full_name: String {
            "\(title) \(firstName) \(middleName) \(lastName)".trimmingCharacters(in: .whitespaces)
        }
        
        var user_city_state_zip: String {
            "\(city), \(state) \(zip) ".trimmingCharacters(in: .whitespaces)
        }
 
        
        func loadFromDefaults() {
            
            userId = defaults.integer(forKey: UserDefaultsKeys.userId.rawValue)
            //print("Loaded User ID: \(userId), Username: \(username)")
            username = defaults.string(forKey: UserDefaultsKeys.username.rawValue) ?? ""
            dioceseName = defaults.string(forKey: UserDefaultsKeys.dioceseName.rawValue) ?? ""
            dioceseId = defaults.integer(forKey: UserDefaultsKeys.dioceseId.rawValue)
            state = defaults.string(forKey: UserDefaultsKeys.state.rawValue) ?? ""
            stateId = defaults.string(forKey: UserDefaultsKeys.stateId.rawValue) ?? ""
            isSuperuser = defaults.bool(forKey: UserDefaultsKeys.superLevel.rawValue)
            isStaff = defaults.bool(forKey: UserDefaultsKeys.staff.rawValue)
            title = defaults.string(forKey: UserDefaultsKeys.title.rawValue) ?? ""
            locationId = defaults.integer(forKey: UserDefaultsKeys.locationId.rawValue)
            pin = defaults.string(forKey: UserDefaultsKeys.pin.rawValue) ?? ""
            requirementGroup = defaults.string(forKey: UserDefaultsKeys.requirementGroup.rawValue) ?? ""
            vocation = defaults.string(forKey: UserDefaultsKeys.vocation.rawValue) ?? ""
            addressId = defaults.integer(forKey: UserDefaultsKeys.addressId.rawValue)
            firstName = defaults.string(forKey: UserDefaultsKeys.firstName.rawValue) ?? ""
            lastName = defaults.string(forKey: UserDefaultsKeys.lastName.rawValue) ?? ""
            email = defaults.string(forKey: UserDefaultsKeys.email.rawValue) ?? ""
            primeMinsitry = defaults.string(forKey: UserDefaultsKeys.primeMinistry.rawValue) ?? ""
            middleName = defaults.string(forKey: UserDefaultsKeys.middleName.rawValue) ?? ""
            add1 = defaults.string(forKey: UserDefaultsKeys.add1.rawValue) ?? ""
            add2 = defaults.string(forKey: UserDefaultsKeys.add2.rawValue) ?? ""
            city = defaults.string(forKey: UserDefaultsKeys.city.rawValue) ?? ""
            zip = defaults.string(forKey: UserDefaultsKeys.zip.rawValue) ?? ""
            cell = defaults.string(forKey: UserDefaultsKeys.cell.rawValue) ?? ""
            gender = defaults.string(forKey: UserDefaultsKeys.gender.rawValue) ?? ""
            dioEmp = defaults.integer(forKey: UserDefaultsKeys.dioEmp.rawValue)
            locName = defaults.string(forKey: UserDefaultsKeys.locName.rawValue) ?? ""
            catDesc = defaults.string(forKey: UserDefaultsKeys.catDesc.rawValue) ?? ""
            locType = defaults.string(forKey: UserDefaultsKeys.locType.rawValue) ?? ""
            locRole = defaults.string(forKey: UserDefaultsKeys.locRole.rawValue) ?? ""
            userFullName = defaults.string(forKey: UserDefaultsKeys.userFullName.rawValue) ?? ""
            
            
        }
        
        func updateUserState(from user: User) {
            DispatchQueue.main.async {
                self.userId = user.id
                self.username = user.username
                self.dioceseName = user.diocese
                self.dioceseId = user.dioceseId
                self.state = "\(user.state) State"
                self.stateId = user.state
                self.isSuperuser = user.isSuperuser
                self.isStaff = user.isStaff
                self.title = user.title
                self.locationId = user.locationId
                self.pin = user.pin
                self.requirementGroup = user.userRequirementGroup
                self.vocation = user.vocation
                self.addressId = user.userAddressId
                self.firstName = user.firstName
                self.lastName = user.lastName
                self.primeMinsitry = user.primeMinistry
                self.email = user.email
                self.middleName = user.middleName ?? ""
                self.add1 = user.add1
                self.add2 = user.add2 ?? ""
                self.city = user.city
                self.zip = user.zip
                self.cell = user.cell
                self.gender = user.gender
                self.dioEmp = user.dioEmp
                self.locName = user.locName
                self.catDesc = user.catDesc
                self.locType = user.locType
                self.locRole = user.locRole
                self.userFullName = user.userFullName
                
            }
        }
        
        func clearUserState() {
            DispatchQueue.main.async {
                self.userId = 0
                self.username = ""
                self.dioceseName = ""
                self.dioceseId = 0
                self.state = ""
                self.stateId = ""
                self.isSuperuser = false
                self.isStaff = false
                self.title = ""
                self.locationId = 0
                self.pin = ""
                self.requirementGroup = ""
                self.vocation = ""
                self.addressId = 0
                self.firstName = ""
                self.lastName = ""
                self.primeMinsitry = ""
                self.email = ""
                self.middleName = ""
                self.add1 = ""
                self.add2 = ""
                self.city = ""
                self.zip = ""
                self.cell = ""
                self.gender = ""
                self.dioEmp = 0
                self.locName = ""
                self.catDesc = ""
                self.locType = ""
                self.locRole = ""
                self.userFullName = ""
                
                // Clear UserDefaults
                UserDefaultsKeys.allCases.forEach { key in
                    UserDefaults.standard.removeObject(forKey: key.rawValue)
                }
                UserDefaults.standard.synchronize()
                
            }
        }
    }

// Get values from UserState
var user_userID = UserState.shared.userId
var user_username = UserState.shared.username
var user_diocese_name = UserState.shared.dioceseName
var user_diocese_id = UserState.shared.dioceseId
var user_state = UserState.shared.state
var user_state_id = "\(UserState.shared.stateId) State"
var user_level = UserState.shared.requirementGroup
var user_title = UserState.shared.title
var user_first_name = UserState.shared.firstName
var user_last_name = UserState.shared.lastName
var user_user_full_name = UserState.shared.user_full_name
var user_category = UserState.shared.requirementGroup
var user_prime_ministry = UserState.shared.primeMinsitry
var user_email = UserState.shared.email
var user_super_user = UserState.shared.isSuperuser
var user_staff = UserState.shared.isStaff
var user_pin = UserState.shared.pin
var user_locationID = UserState.shared.locationId
var user_vocation = UserState.shared.vocation
var user_middle_name = UserState.shared.middleName
var user_add1 = UserState.shared.add1
var user_add2 = UserState.shared.add2
var user_city = UserState.shared.city
var user_zip = UserState.shared.zip
var user_cell = UserState.shared.cell
var user_gender = UserState.shared.gender
var user_city_state_zip = UserState.shared.user_city_state_zip
var user_dio_emp = UserState.shared.dioEmp
var user_locName = UserState.shared.locName
var user_cat_desc = UserState.shared.catDesc
var user_loc_type = UserState.shared.locType
var user_loc_role = UserState.shared.locRole
var user_office = "Placeholder Location"
var user_dioTitle = "King of France"

//Notes
/*
 dioEmp is linked to the safe_source_entity_contacts by the contact_id
 if the user is not a diocesan employee (Office, School, Parish - not clergy or religous unless in an office)
 the dio_employee is set 0 as the indicator not an employee
 
 
 */
