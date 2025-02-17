//
//  SideHome.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/19/24.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isAuthenticated: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {  // Add consistent spacing between buttons
                                                    // "My Profile" NavigationLink
            NavigationLink(destination: ProfileView()) {
                Text("Select an Option")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)  // Ensure the Text takes up full width for proper hitbox
            }
            .buttonStyle(PlainButtonStyle())  // Remove default NavigationLink styling
            
            NavigationLink(destination: ProfileView()) {
                Text("My Profile")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)  // Ensure the Text takes up full width for proper hitbox
            }
            .buttonStyle(PlainButtonStyle())  // Remove default NavigationLink styling
            
            // "My Requirements NavigationLink
            NavigationLink(destination: RequirementsView().environmentObject(UserState.shared)) {
                Text("My Requirements")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            
            // "Updates/News" NavigationLink
            NavigationLink(destination: UpdatesView()) {
                Text("Updates/News")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Library" NavigationLink
            NavigationLink(destination: LibraryViewSQL()) {
                Text("Library")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Reference Requirements" NavigationLink
            NavigationLink(destination: CheckListSQL()) {
                Text("Reference Employee/Volunteer Requirements")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Make a Report" NavigationLink
            NavigationLink(destination: ReportView()) {
                Text("Reporting Alleged Abuse of a Minor")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Make a Report" NavigationLink
            NavigationLink(destination: ReportElderView()) {
                Text("Reporting Alleged Abuse of an Elder")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Common Prayer Navilink
            NavigationLink(destination: PrayersView()) {
                Text("Catholic Prayers")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Directory Navilink
            NavigationLink(destination: LocationView()) {
                Text("Diocesan Directory")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                print("attempting to logout")
                logout(isAuthenticated: $isAuthenticated)
                print("logout complete")// Call the logout function on tap
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                                .padding()
                        }
            Spacer()  // Pushes content to the top
            
            
        }
        .padding(.top, 100)  // Apply top padding to push down from top
        .padding(.leading, 10)  // Left padding for aesthetics
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}


