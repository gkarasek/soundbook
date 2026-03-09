import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookSessionViewModel()
    @State private var showNewSessionSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.sessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("No Reading Sessions Yet")
                            .font(.headline)
                        
                        Text("Create a new session to synchronize sounds with your reading")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showNewSessionSheet = true }) {
                            Text("Create Session")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text(session.bookTitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(session.soundMappings.count\) sound mappings")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteSession)
                    }
                }
            }
            .navigationTitle("soundbook")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewSessionSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showNewSessionSheet) {
                NewSessionView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}