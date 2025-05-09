import SwiftUI
import Combine

class PrayersViewModel: ObservableObject {
    @Published var prayers: [PrayerData] = []
    
    func loadPrayers() {
        getPrayer { [weak self] fetchedPrayers in
            DispatchQueue.main.async {
                self?.prayers = fetchedPrayers
            }
        }
    }
}

struct PrayersView: View {
    @StateObject private var viewModel = PrayersViewModel()
    @State private var categories: [String] = ["All"]
    @State private var selectedCategory: String = "All"
    @State private var filteredPrayers: [PrayerData] = []
    @State private var showMenu: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
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
                
                // Hold pages titles and dropdown menu
                VStack(alignment: .center, spacing: 20) {
                    Text("Common Catholic Prayers")
                        .font(.system(size: titleFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))
                        .padding(.top, 20)

                    Text("Select a category to show prayers or choose All to list all.")
                        .multilineTextAlignment(.center)
                        .frame(width: screenWidth * 0.8)
                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 160/255, green: 57/255, blue: 61/255), lineWidth: 2)
                    )
                    .onChange(of: selectedCategory) { newValue in
                        filterPrayers(for: newValue)
                    }
                    
                    // Default status if no prayer is found
                    if filteredPrayers.isEmpty {
                        Text("No prayers found.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        // Formatted display of prayers and additional details
                        List(filteredPrayers) { prayer in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    // Grey color for outer rectangle
                                    .fill(Color(red: 244/255, green: 239/255, blue: 231/255))
                                    .shadow(radius: 3)

                                VStack(spacing: 10) {
                                    Text(prayer.prayerName)
                                        .font(.headline)
                                        // Red Color for Prayer Name
                                        .foregroundColor(Color(red: 160/255, green: 57/255, blue: 61/255))

                                    Text("Used by: \(prayer.prayerApp) | Category: \(prayer.prayerCategory)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text(prayer.prayerText)
                                        .font(.body)
                                        // Blue Color for Prayer
                                        .foregroundColor(Color(red: 38/255, green: 86/255, blue: 134/255))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundColor(.white)
                                        )
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
                    loadCategories()
                    viewModel.loadPrayers()
                }
            }
            .zIndex(0)

            // Side menu overlay
            if showMenu {
                ZStack {
                    SideMenuView(isAuthenticated: .constant(true))
                        .transition(.move(edge: .leading))
                        .zIndex(1)

                    VStack {
                        Spacer().frame(height: 180)
                        Rectangle().fill(Color.clear)
                            .frame(height: 40)
                            .contentShape(Rectangle())
                            .onTapGesture {}
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(2)
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showMenu = false } }
                )
            }

            // Top bar with hamburger menu and logo
            HStack {
                Button(action: { withAnimation { showMenu.toggle() } }) {
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

    private func loadCategories() {
        fetchPrayerCategories { fetched in
            DispatchQueue.main.async { categories = fetched }
        }
    }

    private func filterPrayers(for category: String) {
        if category == "All" {
            filteredPrayers = viewModel.prayers
        } else {
            filteredPrayers = viewModel.prayers.filter { $0.prayerCategory == category }
        }
    }
}

struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        PrayersView()
    }
}
