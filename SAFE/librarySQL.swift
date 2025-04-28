// LibrarySQL.swift

import SwiftUI
import Foundation
import PostgresClientKit
import Combine

// View that displays a searchable and filterable document library
struct LibraryViewSQL: View {
    @State private var selectedDocument: Document? = nil
    @State private var documents: [Document] = []
    @State private var documentSources: [String] = []
    @State private var selectedSource: String = "Show All Sources"
    @State private var documentTypes: [String] = []
    @State private var selectedType: String = "Show All Document Types"

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.945, green: 0.651, blue: 0.168),
                    Color(red: 0.949, green: 0.949, blue: 0.949)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    HStack {
                        Text("Documents Library")
                            .font(.custom("Helvetica", size: 30))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                            .fontWeight(.bold)

                        Spacer()

                        Image("SERA_Text_w__Shield")
                            .resizable()
                            .frame(width: 140, height: 140)
                    }

                    // Subheader description
                    Text("View all documents or filter by source and type.")
                        .font(.custom("Helvetica", size: 16))
                        .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))

                    // Filter controls
                    VStack(spacing: 20) {
                        // Source picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Document Source")
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                                .fontWeight(.semibold)

                            Picker("Select a Source", selection: $selectedSource) {
                                ForEach(documentSources, id: \.self) { source in
                                    Text(source)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            .onReceive(Just(selectedSource)) { _ in
                                fetchDocumentTypes(for: selectedSource)
                                fetchFilteredDocuments()
                            }
                        }

                        // Type picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Document Type")
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                                .fontWeight(.semibold)

                            Picker("Select a Type", selection: $selectedType) {
                                ForEach(documentTypes, id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            .onReceive(Just(selectedType)) { _ in
                                fetchFilteredDocuments()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .shadow(radius: 4)

                    Divider().padding(.vertical)

                    // List of available documents
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Documents")
                            .font(.custom("Helvetica", size: 20))
                            .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                            .fontWeight(.semibold)

                        ForEach(documents, id: \.name) { document in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 8)

                                Text(document.name)
                                    .font(.custom("Helvetica", size: 16))
                                    .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .onTapGesture {
                                if let url = URL(string: document.url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .onAppear {
                fetchDocumentSources()
                fetchFilteredDocuments()
            }
        }
    }

    // Fetches and filters documents based on current source and type selections
    func fetchFilteredDocuments() { /* implementation elsewhere */ }

    // Fetches list of document sources from the database
    func fetchDocumentSources() { /* implementation elsewhere */ }

    // Fetches document types based on selected source
    func fetchDocumentTypes(for source: String) { /* implementation elsewhere */ }
}

// Model representing a document
struct Document: Identifiable {
    var id = UUID()
    var name: String
    var url: String
}
