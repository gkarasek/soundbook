import SwiftUI
import UIKit

/// Paste your Apps Script /exec URL here after deploying Scripts/google-sheet-webhook.gs
private let interestFormEndpoint = URL(string: "https://script.google.com/macros/s/AKfycbzHcsfuRSj_ikhbO8XrXJXtMweJ3HrZtO7R1ILvzwk21XgPZBn4Gjnc6n6oHK1_bTa_/exec")!

struct CategoryInterestSheet: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var email = ""
    @State private var idea = ""
    @State private var phase: Phase = .form
    @State private var emailInvalid = false

    private enum Phase {
        case form
        case sending
        case success
        case error
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                switch phase {
                case .form, .sending:
                    formContent
                case .success:
                    resultContent(title: "You’re in.", buttonTitle: "Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .error:
                    resultContent(title: "Couldn’t send.", buttonTitle: "Try again") {
                        phase = .form
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(24)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Get updates")
                .font(.title2.weight(.semibold))

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(phase == .sending)
                .opacity(phase == .sending ? 0.6 : 1)

            if emailInvalid {
                Text("Check email")
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            TextField("Category idea (optional)", text: $idea)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(phase == .sending)
                .opacity(phase == .sending ? 0.6 : 1)

            Button(action: submit) {
                HStack {
                    if phase == .sending {
                        ProgressView()
                    }
                    Text(phase == .sending ? "Sending" : "Submit")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(canSubmit ? Color.accentColor : Color.gray.opacity(0.5))
                .cornerRadius(10)
            }
            .disabled(!canSubmit)
        }
    }

    private var canSubmit: Bool {
        phase != .sending && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func resultContent(
        title: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))
            Button(action: action) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func submit() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIdea = idea.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(trimmedEmail) else {
            emailInvalid = true
            return
        }

        emailInvalid = false
        phase = .sending
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        postInterest(email: trimmedEmail, idea: trimmedIdea) { ok in
            DispatchQueue.main.async {
                phase = ok ? .success : .error
            }
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func postInterest(email: String, idea: String, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: interestFormEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email,
            "idea": idea,
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                completion(false)
                return
            }

            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ok = json["ok"] as? Bool {
                completion(ok)
                return
            }

            // Apps Script often returns plain text after redirects; treat 2xx as success.
            completion(true)
        }.resume()
    }
}

#Preview {
    CategoryInterestSheet()
}
