import SwiftUI

struct NewSessionView: View {
    @State private var title: String = ""
    @State private var bookName: String = ""
    @State private var audioFile: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Session Info")) {
                TextField("Title", text: $title)
                TextField("Book Name", text: $bookName)
                TextField("Audio File", text: $audioFile)
            }
            
            Section {
                Button(action: saveSession) {
                    Text("Save Session")
                }
            }
        }
        .navigationBarTitle("New Reading Session")
    }
    
    private func saveSession() {
        // Logic to save the session
        print("Session saved: \(title), \(bookName), \(audioFile)")
    }
}

struct NewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSessionView()
    }
}