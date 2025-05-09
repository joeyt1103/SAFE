import SwiftUI
import Combine

class LocationViewModel: ObservableObject {
    @Published var locationTypes: [String] = ["All"]
    @Published var locations: [String] = ["All"]
    @Published var filteredLocationData: [LocationData] = []
    @Published var locationData: [LocationData] = []

    func loadLocationTypes() {
        fetchLocationTypes { [weak self] fetchedTypes in
            DispatchQueue.main.async {
                self?.locationTypes = fetchedTypes
            }
        }
    }

    func loadLocations() {
        fetchLocations { [weak self] fetchedLocations in
            DispatchQueue.main.async {
                self?.locations = fetchedLocations
            }
        }
    }

    func loadLocationData() {
        getLocations { [weak self] fetchedLocationData in
            DispatchQueue.main.async {
                self?.locationData = fetchedLocationData
                self?.filteredLocationData = fetchedLocationData
            }
        }
    }

    func filterLocations(selectedLocationType: String, selectedLocation: String) {
        filteredLocationData = locationData.filter { location in
            (selectedLocationType == "All" || location.locationType == selectedLocationType) &&
            (selectedLocation == "All" || location.locationName == selectedLocation)
        }
    }
}

struct LocationView: View {
    @StateObject private var viewModel = LocationViewModel()
    @State private var selectedLocationType: String = "All"
    @State private var selectedLocation: String = "All"
    @State private var showMenu: Bool = false

    var body: some View {
        ZStack {
            // Background gradient. Colors taken diretly from mockups
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 242/255, green: 166/255, blue: 41/255),
                Color(red: 244/255, green: 234/255, blue: 217/255)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            // Main content
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                let isLandscape = screenWidth > screenHeight
                let titleFontSize: CGFloat = isLandscape ? 40 : 28
                
                // VStack for all titles/text objects with styling
                VStack(alignment: .center, spacing: 20) {
                    Text("Diocesan Location Directory")
                        .font(.system(size: titleFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))
                        .padding(.top, 20)

                    Text("Filter locations by type and/or location name.")
                        .frame(width: screenWidth * 0.8)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))
                    
                    // HStack to hold dropdown menus for type and location
                    HStack(spacing: 16) {
                        Picker("Type", selection: $selectedLocationType) {
                            ForEach(viewModel.locationTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 160/255, green: 57/255, blue: 61/255), lineWidth: 2)
                        )
                        .onChange(of: selectedLocationType) { _, new in
                            viewModel.filterLocations(selectedLocationType: new, selectedLocation: selectedLocation)
                        }

                        Picker("Location", selection: $selectedLocation) {
                            ForEach(viewModel.locations, id: \.self) { loc in
                                Text(loc).tag(loc)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 160/255, green: 57/255, blue: 61/255), lineWidth: 2)
                        )
                        .onChange(of: selectedLocation) { _, new in
                            viewModel.filterLocations(selectedLocationType: selectedLocationType, selectedLocation: new)
                        }
                    }

                    if viewModel.filteredLocationData.isEmpty {
                        Text("No locations found.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        List(viewModel.filteredLocationData, id: \.self) { location in
                           // Displays information based on selected location
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(red: 244/255, green: 239/255, blue: 231/255))
                                    .shadow(radius: 3)

                                VStack(alignment: .center, spacing: 10) {
                                    Text(location.locationName)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 160/255, green: 57/255, blue: 61/255))

                                    Text("Manager: \(location.locationPastor)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text("Type: \(location.locationType)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text("Status: \(location.locationActive ? "Active" : "Inactive")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Divider()

                                    Text("Contact Information")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.locationAdd1).font(.footnote)
                                        if !location.locationAdd2.isEmpty {
                                            Text(location.locationAdd2).font(.footnote)
                                        }
                                        Text("\(location.locationCity), \(location.locationState) \(location.locationZip)")
                                            .font(.footnote)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Phone: \(location.locationPhone)").font(.footnote)
                                        if !location.locationEmail.isEmpty {
                                            Text("Email: \(location.locationEmail)").font(.footnote)
                                        }
                                        if !location.locationWeb.isEmpty {
                                            Text("Website: \(location.locationWeb)").font(.footnote)
                                        }
                                    }
                                }
                                .padding()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .padding()
                .onAppear {
                    viewModel.loadLocationTypes()
                    viewModel.loadLocations()
                    viewModel.loadLocationData()
                }
            }
            .zIndex(0)

            // Side Menu (Hamburger menu) overlay
            if showMenu {
                ZStack {
                    SideMenuView(isAuthenticated: .constant(true))
                        .transition(.move(edge: .leading))
                        .zIndex(1)

                    VStack {
                        Spacer().frame(height: 180)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                            .contentShape(Rectangle())
                            .onTapGesture { }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.clear)
                    .zIndex(2)
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showMenu = false }
                        }
                )
                .zIndex(1)
            }

            // Top bar pinned to very top. This includes the hamburger menu
            //and reference to SERA logo
            HStack {
                Button(action: {
                    withAnimation { showMenu.toggle() }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Spacer()
                Image("SERA_Text_w__Shield")
                    .resizable()
                    .frame(width: 140, height: 140)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
            .zIndex(2)
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
