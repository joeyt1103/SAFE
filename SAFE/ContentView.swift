//
//  ContentView.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userState = UserState.shared
    @Binding var isAuthenticated: Bool
    @State private var isMenuOpen = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("dlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 100)
                        .padding(.bottom, -15)
                        .padding(.leading, 10)
                    
                    Text("Safe Environment Resource App")
                        .font(.subheadline)
                        .padding(.leading, -10)
                    HStack {
                        Text("Proof of Concept Build")
                            .font(.title2)
                            .padding(.top, 10)
                        
                        Button(action: {
                            Task {
                                do {
                                    try await UserDefaultsManager.shared.getUserDefaults(dbID: user_userID)
                                } catch {
                                    // Handle error, for example, print it or show an alert
                                    print("Failed to refresh user defaults: \(error)")
                                }
                            }
                        }) {
                            Text("Refresh User Defaults")
                        }
                    }
 
                    Image("main screen")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 350)
                    
                    Spacer()
                    
                    if use_cloud_db {
                        Text("Using CloudDB")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color(red: 0, green: 51, blue: 0))
                    } else {
                        Text("Using LocalDB")
                            .font(.body)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                //.navigationTitle(isMenuOpen ? "" : "SERA: \(userState.firstName)")  // Updated to use userState directly
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    }
                }

                if isMenuOpen {
                    HStack {
                        SideMenuView(isAuthenticated: $isAuthenticated)
                            .frame(width: 250)
                            .background(Color.white)
                        Spacer()
                    }
                    .zIndex(1)

                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .zIndex(0)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                }
            }
            .animation(.easeInOut, value: isMenuOpen)
            .onAppear {
                UserState.shared.loadFromDefaults()
                print("ContentView refreshed with latest UserState: \(userState.firstName) \(userState.lastName)")
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isAuthenticated: .constant(true))  // Use .constant for preview
    }
}
