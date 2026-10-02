import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

class GoogleDriveManager: NSObject, GIDSignInDelegate {
    static let shared = GoogleDriveManager()

    var driveService: GTLRDriveService?
    var signInCompletion: ((Bool, Error?) -> Void)?

    override init() {
        super.init()
        GIDSignIn.sharedInstance.delegate = self
    }

    func configureGoogleSignIn(clientID: String) {
        GIDSignIn.sharedInstance.clientID = clientID
    }

    func signIn(from viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        signInCompletion = completion

        if let currentUser = GIDSignIn.sharedInstance.currentUser, currentUser.authentication.accessToken != nil {
            setupDriveService()
            completion(true, nil)
        } else {
            GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: GIDSignIn.sharedInstance.clientID ?? ""), presenting: viewController) { user, error in
                if let error = error {
                    completion(false, error)
                    return
                }

                guard let user = user else {
                    completion(false, GoogleDriveError.signInFailed)
                    return
                }

                self.setupDriveService()
                completion(true, nil)
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        driveService = nil
    }

    private func setupDriveService() {
        driveService = GTLRDriveService()
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            driveService?.authorizer = currentUser.authentication
        }
    }

    func isUserSignedIn() -> Bool {
        return GIDSignIn.sharedInstance.currentUser != nil &&
               GIDSignIn.sharedInstance.currentUser?.authentication.accessToken != nil
    }

    func uploadPhoto(fileURL: URL, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let driveService = driveService else {
            completion(.failure(GoogleDriveError.notSignedIn))
            return
        }

        let file = GTLRDrive_File()
        file.name = fileName
        file.mimeType = "image/jpeg"

        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: "image/jpeg")
        uploadParameters.shouldUploadWithSingleRequest = true

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        query.fields = "id,name,webViewLink"

        driveService.executeQuery(query) { ticket, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let file = result as? GTLRDrive_File, let fileID = file.identifier else {
                    completion(.failure(GoogleDriveError.uploadFailed))
                    return
                }

                completion(.success(fileID))
            }
        }
    }

    func createBackupFolder(completion: @escaping (Result<String, Error>) -> Void) {
        guard let driveService = driveService else {
            completion(.failure(GoogleDriveError.notSignedIn))
            return
        }

        let folderName = "WhatsApp Photos Backup"

        let file = GTLRDrive_File()
        file.name = folderName
        file.mimeType = "application/vnd.google-apps.folder"

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
        query.fields = "id,name"

        driveService.executeQuery(query) { ticket, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let folder = result as? GTLRDrive_File, let folderID = folder.identifier else {
                    completion(.failure(GoogleDriveError.folderCreationFailed))
                    return
                }

                completion(.success(folderID))
            }
        }
    }

    func getOrCreateBackupFolder(completion: @escaping (Result<String, Error>) -> Void) {
        guard let driveService = driveService else {
            completion(.failure(GoogleDriveError.notSignedIn))
            return
        }

        let folderName = "WhatsApp Photos Backup"
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "name='\(folderName)' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        query.spaces = "drive"
        query.fields = "files(id,name)"
        query.pageSize = 10

        driveService.executeQuery(query) { ticket, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let fileList = result as? GTLRDrive_FileList,
                      let files = fileList.files, files.count > 0 else {
                    self.createBackupFolder(completion: completion)
                    return
                }

                if let folderID = files.first?.identifier {
                    completion(.success(folderID))
                } else {
                    completion(.failure(GoogleDriveError.folderNotFound))
                }
            }
        }
    }
}

enum GoogleDriveError: LocalizedError {
    case notSignedIn
    case signInFailed
    case uploadFailed
    case folderCreationFailed
    case folderNotFound

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "User is not signed in to Google Drive"
        case .signInFailed:
            return "Failed to sign in to Google"
        case .uploadFailed:
            return "Failed to upload photo to Google Drive"
        case .folderCreationFailed:
            return "Failed to create backup folder on Google Drive"
        case .folderNotFound:
            return "Backup folder not found on Google Drive"
        }
    }
}
