import SwiftUI

class UpdatesViewModel: ObservableObject {
    @Published var updates: [UpdateData] = []
    
    func loadUpdates() {
        //print("Loading updates...")
        getUpdate { [weak self] fetchedUpdates in
            DispatchQueue.main.async {
                self?.updates = fetchedUpdates
                //print("Updates loaded: \(fetchedUpdates.count)")
            }
        }
    }
}

struct UpdatesView: View {
    @StateObject private var viewModel = UpdatesViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight
            
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let bodyFontSize: CGFloat = isLandscape ? 24 : 16
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Updates and News")
                        .font(.system(size: titleFontSize))
                        .fontWeight(.bold)
                        .padding(.bottom, 15)
                        .padding(.top, 20)
                    
                    ForEach(viewModel.updates) { update in
                        sectionView(
                            title: update.updHeader,
                            items: [update.updBody],
                            date: update.updBegin,
                            fontSize: bodyFontSize + 2
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                viewModel.loadUpdates()
            }
        }
    }
    
    func sectionView(title: String, items: [String], date: Date, fontSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: fontSize + 4))
                    .bold()

            Text("Posted On: \(date.formatted(.dateTime.month().day().year()))")
                        .font(.system(size: fontSize - 4))
                        //.foregroundColor(.black)
                        .padding(.bottom, 2)
            .padding(.bottom, 2)
            
            Divider()
                .background(Color.gray)
                .padding(.bottom, 2)
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: fontSize))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 2)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
            .padding(.bottom, 30)
        }
    }
}

struct UpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesView()
    }
}
