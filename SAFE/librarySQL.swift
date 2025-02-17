import SwiftUI
import Foundation
import PostgresClientKit
import Combine

struct LibraryViewSQL: View {
    @State private var selectedDocument: Document? = nil
    @State private var documents: [Document] = []
    @State private var documentSources: [String] = []
    @State private var selectedSource: String = "Show All Sources"
    @State private var documentTypes: [String] = []
    @State private var selectedType: String = "Show All Document Types"

    var body: some View {
            VStack {
                Text("Documents Library")
                    .font(.largeTitle)

                Text("You can see all your Documents or filter by document source and/or type.")
                    .font(.subheadline)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)

                // ComboBox for Document Source
                Text("Select a Document Source:")
                    .font(.headline)
                    .padding(.bottom, -15)
                Picker("Select a Source", selection: $selectedSource) {
                    ForEach(documentSources, id: \.self) { source in
                        Text(source)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.bottom, 20)
                .onReceive(Just(selectedSource)) { newSource in
                    fetchDocumentTypes(for: newSource) // Always fetch types even if all sources selected
                    fetchFilteredDocuments() // Fetch filtered documents when source changes
                }

                // ComboBox for Document Type
                Text("Select a Document Type:")
                    .font(.headline)
                    .padding(.bottom, -15)
                Picker("Select a Type", selection: $selectedType) {
                    ForEach(documentTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.bottom, 20)
                .onReceive(Just(selectedType)) { _ in
                    fetchFilteredDocuments() // Fetch filtered documents when type changes
                }

                // List for Document selection
                Text("Select a Document or Policy:")
                    .font(.headline)
                    .padding(.top, 35)
                    .padding(.bottom, -10)

                List(documents, id: \.name) { document in
                    HStack {
                        Image(systemName: "doc.text")
                            .padding(.trailing, 10)

                        Text(document.name)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = URL(string: document.url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear {
                fetchDocumentSources() // Populate sources and types on load
                fetchFilteredDocuments() // Show all documents by default on load
            }
        }


    // Fetch documents based on the selected source and type
    func fetchFilteredDocuments() {
        do {
            let connection = try dbConnect()
            defer { connection.close() }

            let query = """
            SELECT "library"."docName", "library"."docLocation"
            FROM "library"
            WHERE "library"."target"::text[] = '{"All"}'::text[]
               OR $1::text = ANY("library"."target"::text[])
            ORDER BY "docName"
            """
            var parameters = [String]()
            
            // Ensure `userCategory` is valid
            //print("User Category: \(user_category)") // Debug userCategory
            parameters.append(user_category)

            //print("Constructed Query: \(query)") // Debug constructed query
            //print("Parameters Passed: \(parameters)") // Debug parameters

            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }

            let cursor = try statement.execute(parameterValues: parameters)
            var fetchedDocuments = [Document]()

            for row in cursor {
                let columns = try row.get().columns
                let docName = try columns[0].string()
                let docLocation = try columns[1].string()

                let document = Document(name: docName, url: docLocation)
                fetchedDocuments.append(document)
            }

            DispatchQueue.main.async {
                self.documents = fetchedDocuments
            }

        } catch {
            print("Error fetching documents: \(error)")
        }
    }
    
    func fetchDocumentSources() {
        do {
            let connection = try dbConnect()
            defer { connection.close() }
            
            let query = """
            SELECT DISTINCT "entity" FROM "safe_source_doc_category" WHERE "active"=TRUE ORDER BY "entity"
            """
            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            var fetchedSources = [String]()

            for row in cursor {
                let columns = try row.get().columns
                let entity = try columns[0].string()
                fetchedSources.append(entity)
            }
            
            DispatchQueue.main.async {
                self.documentSources = ["Show All Sources"] + fetchedSources
                // Automatically fetch all document types when the view appears
                self.fetchDocumentTypes(for: "Show All Sources")
            }

        } catch {
            print("Error fetching document sources: \(error)")
        }
    }

    
    func fetchDocumentTypes(for source: String) {
            do {
                let connection = try dbConnect()
                defer { connection.close() }

                let query: String
                if source == "Show All Sources" {
                    query = """
                    SELECT DISTINCT "sub_category" FROM "safe_source_doc_category" ORDER BY "sub_category"
                    """
                } else {
                    query = """
                    SELECT DISTINCT "sub_category" FROM "safe_source_doc_category" WHERE "entity" = $1 ORDER BY "sub_category"
                    """
                }

                let statement = try connection.prepareStatement(text: query)
                defer { statement.close() }

                let cursor: Cursor
                if source == "Show All Sources" {
                    cursor = try statement.execute()
                } else {
                    cursor = try statement.execute(parameterValues: [source])
                }

                var fetchedTypes = [String]()

                for row in cursor {
                    let columns = try row.get().columns
                    let subCategory = try columns[0].string()
                    fetchedTypes.append(subCategory) // Only append sub_category
                }

                DispatchQueue.main.async {
                    // Only update if the source has changed
                    self.documentTypes = ["Show All Document Types"] + fetchedTypes
                }

            } catch {
                print("Error fetching document types: \(error)")
            }
        }
}

struct Document: Identifiable {
    var id = UUID()
    var name: String
    var url: String
}

struct LibraryViewSQL_Previews: PreviewProvider {
    static var previews: some View {
        LibraryViewSQL()
    }
}
