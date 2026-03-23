import SwiftUI

struct NewSessionView: View {
    @ObservedObject var viewModel: BookSessionViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var title = ""
    @State private var bookTitle = ""
    @State private var audioFilePath = ""

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !bookTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Info")) {
                    TextField("Session title", text: $title)
                    TextField("Book title", text: $bookTitle)
                    TextField("Optional local audio file path", text: $audioFilePath)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveSession() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func saveSession() {
        let trimmedPath = audioFilePath.trimmingCharacters(in: .whitespacesAndNewlines)
        let audioURL = trimmedPath.isEmpty ? nil : URL(fileURLWithPath: trimmedPath)
        viewModel.createSession(title: title, bookTitle: bookTitle, audioURL: audioURL)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    NewSessionView(viewModel: BookSessionViewModel())
}
