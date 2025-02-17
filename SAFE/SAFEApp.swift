//
//  SAFEApp.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/18/24.
//

import SwiftUI

@main
struct SAFE: App {
    @StateObject private var userState = UserState.shared
    @AppStorage("isAuthenticated") private var isAuthenticated = false  // Use @AppStorage to bind directly to UserDefaults
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView(isAuthenticated: $isAuthenticated)
                //RequirementsView().environmentObject(UserState.shared)// Show ContentView if authenticated
            } else {
                Login(isAuthenticated: $isAuthenticated)  // Show Login view if not authenticated
            }
        }
    }
}
    
    // Simple loading view
    struct LoadingView: View {
        var body: some View {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
        }
    }

