//
//  keychain.swift
//  SAFE
//
//  Created by Kevin Gualano on 11/9/24.
//

import SwiftUI
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query)
        SecItemAdd(query, nil)
    }

    func load(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }

    func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        SecItemDelete(query)
    }
}


func saveUserToken(token: String) {
    if let tokenData = token.data(using: .utf8) {
        KeychainHelper.shared.save(tokenData, service: "com.kevingualano.SAFE", account: "userToken")
    }
}


func loadUserToken() -> String? {
    if let tokenData = KeychainHelper.shared.load(service: "com.kevingualano.SAFE", account: "userToken"),
       let token = String(data: tokenData, encoding: .utf8) {
        return token
    }
    return nil
}

func saveUserSession(userID: Int, token: String) {
    //save to keychain
    saveUserToken(token: token)
    
    //save userID to userdefaults
    UserDefaults.standard.set(userID, forKey: "userID")
    UserDefaults.standard.synchronize()
    
}

func logout(isAuthenticated: Binding<Bool>) {
    // Clear token from Keychain
    KeychainHelper.shared.delete(service: "com.kevingualano.SAFE", account: "userToken")
    
    // Clear all saved data in UserDefaults, including authentication status
    UserDefaultsKeys.allCases.forEach { key in
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    UserDefaults.standard.set(false, forKey: "isAuthenticated")  // Explicitly set isAuthenticated to false
    UserDefaults.standard.synchronize()
    
    // Clear UserState to reset in-memory data
    UserState.shared.clearUserState()
       print("UserState after clearing:")
       print("First name: \(UserState.shared.firstName)")
       print("UserID: \(UserState.shared.userId)")
    
    // Update isAuthenticated to false to ensure login screen is shown
    isAuthenticated.wrappedValue = false
    
    print("Logout completed, all user data and authentication state cleared.")
}
