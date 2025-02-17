//
//  directorySQL.swift
//  SAFE
//
//  Created by Kevin Gualano on 12/5/24.
//
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
                self?.filteredLocationData = fetchedLocationData // Default to all
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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight
            
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            
            VStack(alignment: .center, spacing: 20) {
                // Title
                Text("Diocesan Location Directory")
                    .font(.system(size: titleFontSize))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Description
                Text("Filter locations by type and/or location name.")
                    .frame(width: screenWidth * 0.8, alignment: .center)
                    .multilineTextAlignment(.leading)
                
                // Location Type Picker
                VStack(alignment: .leading) {
                    Text("Select Location Type:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Picker("Location Type", selection: $selectedLocationType) {
                        ForEach(viewModel.locationTypes, id: \.self) { locationType in
                            Text(locationType).tag(locationType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedLocationType) {oldValue, newValue in
                        viewModel.filterLocations(selectedLocationType: newValue, selectedLocation: selectedLocation)
                    }
                }
                .frame(width: screenWidth * 0.8)
                
                // Location Picker
                VStack(alignment: .leading) {
                    Text("Select Location:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Picker("Location", selection: $selectedLocation) {
                        ForEach(viewModel.locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedLocation) { oldValue, newValue in
                        viewModel.filterLocations(selectedLocationType: selectedLocationType, selectedLocation: newValue)
                    }
                }
                .frame(width: screenWidth * 0.8)
                
                if viewModel.filteredLocationData.isEmpty {
                    Text("No locations found.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    List($viewModel.filteredLocationData, id: \.self) { $location in
                        VStack(alignment: .leading, spacing: 10) {
                            // Location Name
                            Text(location.locationName)
                                .font(.title3)
                                .bold()
                                .padding(.bottom, -5)
                            
                            // Manager, Type, Status
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top) {
                                    Text("Manager:").frame(width: 60, alignment: .leading)
                                    Text(location.locationPastor).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                HStack(alignment: .top) {
                                    Text("Type:").frame(width: 60, alignment: .leading)
                                    Text(location.locationType).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                HStack(alignment: .top) {
                                    Text("Status:").frame(width: 60, alignment: .leading)
                                    Text(location.locationActive ? "Active" : "Inactive").frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .font(.footnote)
                            Divider()
                                .background(Color.black)
                                .frame(height: 7)
                            
                            Text("Contact Information")
                                .font(.subheadline)
                                .bold()
                                .padding(.bottom, -5)
                            
                            // Address
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.locationAdd1)
                                if !location.locationAdd2.isEmpty {
                                    Text(location.locationAdd2)
                                }
                                Text("\(location.locationCity), \(location.locationState) \(location.locationZip)")
                            }
                            .font(.footnote)
                            .padding(.bottom, 5)
                            
                            // Contact Information
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top) {
                                    Text("Phone:").frame(width: 60, alignment: .leading)
                                    Text(location.locationPhone).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if !location.locationEmail.isEmpty {
                                    HStack(alignment: .top) {
                                        Text("Email:").frame(width: 60, alignment: .leading)
                                        Text(location.locationEmail).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                if !location.locationWeb.isEmpty {
                                    HStack(alignment: .top) {
                                        Text("Website:").frame(width: 60, alignment: .leading)
                                        Text(location.locationWeb).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .font(.footnote)
                            Divider()
                                .background(Color.black)
                                .frame(height: 7)
                        }
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                        .padding(.vertical, 5)
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
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
