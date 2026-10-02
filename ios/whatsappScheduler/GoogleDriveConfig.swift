import Foundation

struct GoogleDriveConfig {
    static let clientID = "891545430499-vpqlbffbhq2ekf3dl4c43av3cp6cfbg2.apps.googleusercontent.com"
    static let serverClientID = "891545430499-vpqlbffbhq2ekf3dl4c43av3cp6cfbg2.apps.googleusercontent.com"

    static func configure() {
        GoogleDriveManager.shared.configureGoogleSignIn(clientID: clientID)
    }
}
