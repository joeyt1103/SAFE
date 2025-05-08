import SwiftUI

// Main landing screen with welcome visuals and optional sidebar navigation
struct ContentView: View {
    @ObservedObject var userState = UserState.shared
    @Binding var isAuthenticated: Bool
    @State private var isMenuOpen = false  // Controls sidebar menu toggle

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Top logo
                    Image("dlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 75)
                        .padding(.top, -50)
                        .padding(.leading, 80)

                    Text("Safe Environment Resource App")
                        .font(.subheadline)
                        .padding(.leading, 150)
                        .padding(.top, -20)

                    // Main image/banner
                    Image("La Pentecôte")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 350)
                        .padding(.top, -30)

                    Text("Welcome to SERA")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, -150)
                        .padding(.top, -40)
                        .foregroundColor(Color(red: 0.58, green: 0.18, blue: 0.20).opacity(0.9))

                    // Intro/description box
                    Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo")
                        .font(.system(size: 20))
                        .foregroundColor(.brown)
                        .multilineTextAlignment(.leading)
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 0.98, green: 0.95, blue: 0.85))
                        )

                    Spacer()

                    // DB Mode Indicator
                    if use_cloud_db {
                        Text("Using CloudDB")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color(red: 0, green: 0, blue: 50))
                    } else {
                        Text("Using LocalDB")
                            .font(.body)
                            .bold()
                            .foregroundColor(.red)
                    }

                    Spacer()

                    // Build type and refresh action
                    HStack {
                        Text("Proof of Concept Build")
                            .font(.body)
                            .padding(.top, 10)

                        Button(action: {
                            Task {
                                do {
                                    try await UserDefaultsManager.shared.getUserDefaults(dbID: user_userID)
                                } catch {
                                    print("Failed to refresh user defaults: \(error)")
                                }
                            }
                        }) {
                            Text("Refresh User Defaults")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Menu button
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.top, 30)
                                .padding(.leading, 10)
                        }
                    }
                }

                // Sidebar menu with overlay when open
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color("#ffb600")]),
                    startPoint: .top,
                    endPoint: .bottom)
            )
            .animation(.easeInOut, value: isMenuOpen)
            .onAppear {
                // Reload shared state from persistent store
                UserState.shared.loadFromDefaults()
                print("ContentView refreshed with latest UserState: \(userState.firstName) \(userState.lastName)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isAuthenticated: .constant(true))  // Preview with static binding
    }
}
