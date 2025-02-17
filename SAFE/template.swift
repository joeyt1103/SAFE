import SwiftUI

struct CustomTemplateView: View {
    let pageTitle: String // Pass the title of the page as a parameter

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isLandscape = screenWidth > screenHeight // Detect orientation

            // Set different sizes for portrait and landscape modes
            let titleFontSize: CGFloat = isLandscape ? 40 : 28
            let headerFontSize: CGFloat = isLandscape ? 24 : 18
            let bodyFontSize: CGFloat = isLandscape ? 20 : 16

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {

                    // Custom Title
                    Text(pageTitle)
                        .font(.system(size: titleFontSize)) // Adjusted font size for title
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.leading, 10)

                    // Example Section Header and Body Text
                    Text("Section Header Example")
                        .font(.system(size: headerFontSize)) // Adjusted font size for headers
                        .padding(.horizontal, 10)

                    Text("This is an example body text. You can replace this with the actual content.")
                        .font(.system(size: bodyFontSize)) // Adjusted font size for body text
                        .padding(.horizontal, 10)

                    // Spacer to push content upwards
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CustomTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTemplateView(pageTitle: "Template Page")
    }
}
