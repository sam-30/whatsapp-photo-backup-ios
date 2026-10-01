import Foundation

struct GoogleDriveConfig {
    static let clientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
    static let serverClientID = "YOUR_GOOGLE_SERVER_CLIENT_ID.apps.googleusercontent.com"

    static func configure() {
        GoogleDriveManager.shared.configureGoogleSignIn(clientID: clientID)
    }
}
