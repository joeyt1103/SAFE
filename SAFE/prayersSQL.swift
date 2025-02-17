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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight
            
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let _: CGFloat = isLandscape ? 24 : 16
            
            VStack(alignment: .center, spacing: 20) {
                Text("Common Catholic Prayers")
                    .font(.system(size: titleFontSize))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Select a category to see only those prayers in that category, or select All to see all prayers")
                    .frame(width: screenWidth * 0.8, alignment: .center)
                    .multilineTextAlignment(.leading)
                
                // Picker for selecting category
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onReceive(Just(selectedCategory)) { newValue in
                    filterPrayers(for: newValue)
                }
                
                // List of prayers
                if filteredPrayers.isEmpty {
                    Text("No prayers found.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    List(filteredPrayers) { prayer in
                        VStack(alignment: .leading) {
                            Text(prayer.prayerName)
                                .font(.headline)
                            Text("Used By: \(prayer.prayerApp)")
                                .font(.footnote)
                            Text("Source:   \(prayer.prayerSource)")
                                .font(.footnote)
                                .padding(.bottom, 5)
                            Divider()
                                .background(Color.black)
                                .frame(height: 7)
                            Text(prayer.prayerText)
                                .font(.subheadline)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                            Divider()
                                .background(Color.black)
                                .frame(height: 7)
                        }
                        .padding(.vertical, 5)
                        
                    }
                    .listStyle(PlainListStyle()) // Simple style for the list
                }
            }
            .padding()
            .onAppear {
                loadCategories()
                viewModel.loadPrayers()
            }
            .onReceive(Just(selectedCategory)) { newValue in
                filterPrayers(for: newValue)
            }
        }
    }
    private func loadCategories() {
        fetchPrayerCategories { fetchedCategories in
            DispatchQueue.main.async {
                categories = fetchedCategories
            }
        }
    }
    
    private func filterPrayers(for category: String) {
        if selectedCategory == "All" {
            filteredPrayers = viewModel.prayers
        } else {
            filteredPrayers = viewModel.prayers.filter { $0.prayerCategory == selectedCategory }
        }
    }
}
struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        PrayersView()
    }
}
