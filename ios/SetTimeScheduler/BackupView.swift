import SwiftUI

struct BackupView: View {
    @ObservedObject var backupService = PhotoBackupService.shared
    @StateObject var googleDriveManager = GoogleDriveManager.shared
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSignedIn = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isSignedIn {
                    backupContentView
                } else {
                    signInView
                }
            }
            .navigationBarTitle("WhatsApp Photo Backup", displayMode: .inline)
            .navigationBarBackButtonHidden(backupService.isBackingUp)
            .onAppear {
                isSignedIn = googleDriveManager.isUserSignedIn()
            }
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    @ViewBuilder
    var signInView: some View {
        VStack(spacing: 30) {
            Image(systemName: "cloud.and.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            VStack(spacing: 10) {
                Text("Backup Your Photos")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Sign in with Google to backup your WhatsApp photos to Google Drive")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: signIn) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    @ViewBuilder
    var backupContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if backupService.isBackingUp {
                    backupProgressView
                } else {
                    readyToBackupView
                }
            }
            .padding()
        }

        VStack(spacing: 10) {
            if backupService.isBackingUp {
                Button(action: {}) {
                    Text("Backup in Progress...")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(true)
            } else {
                Button(action: startBackup) {
                    Text("Start Backup")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: signOut) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    var backupProgressView: some View {
        VStack(spacing: 15) {
            VStack(spacing: 10) {
                Text("Backing Up Photos")
                    .font(.headline)

                ProgressView(value: backupService.backupProgress)
                    .tint(.blue)

                HStack {
                    Text("Progress: \(Int(backupService.backupProgress * 100))%")
                        .font(.caption)
                    Spacer()
                    Text("\(backupService.backupedCount) backed up")
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            Text(backupService.statusMessage)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            if backupService.failedCount > 0 {
                VStack(spacing: 5) {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                        Text("Failures: \(backupService.failedCount)")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(UIColor.systemOrange).opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    @ViewBuilder
    var readyToBackupView: some View {
        VStack(spacing: 15) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)

                Text("Ready to Backup")
                    .font(.headline)

                Text("Your photos will be securely backed up to Google Drive and deleted from your device.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("What happens next:")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 8) {
                    backupStep("1", "Find all WhatsApp photos")
                    backupStep("2", "Upload to Google Drive")
                    backupStep("3", "Delete local copies")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBlue).opacity(0.05))
            .cornerRadius(10)
        }
    }

    func backupStep(_ number: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(number)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text(text)
        }
    }

    func signIn() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first else {
            errorMessage = "Could not find window"
            showingError = true
            return
        }

        guard let rootViewController = window.rootViewController else {
            errorMessage = "Could not find root view controller"
            showingError = true
            return
        }

        googleDriveManager.signIn(from: rootViewController) { success, error in
            DispatchQueue.main.async {
                if success {
                    isSignedIn = true
                } else {
                    errorMessage = error?.localizedDescription ?? "Sign in failed"
                    showingError = true
                }
            }
        }
    }

    func startBackup() {
        backupService.startBackup { result in
            switch result {
            case .success(let backupResult):
                errorMessage = "Backup complete!\nBacked up: \(backupResult.successCount)\nFailed: \(backupResult.failureCount)"
                showingError = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }

    func signOut() {
        googleDriveManager.signOut()
        isSignedIn = false
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView()
    }
}
