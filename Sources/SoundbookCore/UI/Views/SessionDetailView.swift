import SwiftUI

struct SessionDetailView: View {
    @State private var session: BookSession

    init(session: BookSession) {
        _session = State(initialValue: session)
    }

    var body: some View {
        Form {
            Section(header: Text("Session Details")) {
                TextField("Title", text: $session.title)
                TextField("Book Title", text: $session.bookTitle)
                if let audioURL = session.audioURL {
                    Text(audioURL.path)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Sound Mappings")) {
                if session.soundMappings.isEmpty {
                    Text("No sound mappings yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(session.soundMappings) { mapping in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sound ID: \(mapping.soundID.uuidString)")
                                .font(.subheadline)
                            Text("Timestamp: \(mapping.timestamp, specifier: "%.1f")s")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Session Details")
    }
}

#Preview {
    SessionDetailView(
        session: BookSession(
            id: UUID(),
            title: "Night Read",
            bookTitle: "The Hound of the Baskervilles",
            audioURL: nil,
            soundMappings: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
