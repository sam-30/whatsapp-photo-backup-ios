import Foundation
import Photos

class PhotoBackupService: NSObject, ObservableObject {
    @Published var backupProgress: Double = 0
    @Published var isBackingUp: Bool = false
    @Published var statusMessage: String = ""
    @Published var backupedCount: Int = 0
    @Published var failedCount: Int = 0

    static let shared = PhotoBackupService()

    private let photoManager = WhatsAppPhotoManager.shared
    private let driveManager = GoogleDriveManager.shared
    private var backupFolderID: String?

    override private init() {}

    func startBackup(completion: @escaping (Result<BackupResult, Error>) -> Void) {
        guard !isBackingUp else {
            completion(.failure(BackupError.alreadyBackingUp))
            return
        }

        DispatchQueue.main.async {
            self.isBackingUp = true
            self.backupedCount = 0
            self.failedCount = 0
            self.statusMessage = "Starting backup..."
        }

        photoManager.fetchWhatsAppPhotos { [weak self] result in
            switch result {
            case .success(let assets):
                guard !assets.isEmpty else {
                    DispatchQueue.main.async {
                        self?.isBackingUp = false
                        self?.statusMessage = "No WhatsApp photos found"
                    }
                    completion(.failure(WhatsAppError.noPhotosFound))
                    return
                }

                DispatchQueue.main.async {
                    self?.statusMessage = "Found \(assets.count) photos. Getting Google Drive ready..."
                }

                self?.driveManager.getOrCreateBackupFolder { [weak self] folderResult in
                    switch folderResult {
                    case .success(let folderID):
                        self?.backupFolderID = folderID
                        self?.backupPhotos(assets, completion: completion)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.isBackingUp = false
                            self?.statusMessage = "Failed to create backup folder: \(error.localizedDescription)"
                        }
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isBackingUp = false
                    self?.statusMessage = "Failed to fetch photos: \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
        }
    }

    private func backupPhotos(_ assets: [PHAsset], completion: @escaping (Result<BackupResult, Error>) -> Void) {
        let group = DispatchGroup()
        var backupedAssets: [PHAsset] = []
        var errors: [Error] = []

        for (index, asset) in assets.enumerated() {
            group.enter()

            photoManager.exportPhotoToTemporaryLocation(asset: asset) { [weak self] exportResult in
                defer { group.leave() }

                switch exportResult {
                case .success(let fileURL):
                    let fileName = self?.generateFileName(for: asset) ?? "photo_\(index).jpg"

                    self?.driveManager.uploadPhoto(fileURL: fileURL, fileName: fileName) { uploadResult in
                        switch uploadResult {
                        case .success(_):
                            backupedAssets.append(asset)
                            DispatchQueue.main.async {
                                self?.backupedCount += 1
                                let progress = Double(self?.backupedCount ?? 0) / Double(assets.count)
                                self?.backupProgress = progress
                                self?.statusMessage = "Uploaded \(self?.backupedCount ?? 0)/\(assets.count) photos..."
                            }
                        case .failure(let error):
                            errors.append(error)
                            DispatchQueue.main.async {
                                self?.failedCount += 1
                            }
                        }

                        try? self?.photoManager.deleteLocalFile(at: fileURL)
                    }

                case .failure(let error):
                    errors.append(error)
                    DispatchQueue.main.async {
                        self?.failedCount += 1
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.deleteBackupedPhotos(backupedAssets) { deleteResult in
                DispatchQueue.main.async {
                    self?.isBackingUp = false
                    self?.backupProgress = 1.0

                    switch deleteResult {
                    case .success:
                        let result = BackupResult(
                            successCount: backupedAssets.count,
                            failureCount: errors.count,
                            totalCount: assets.count
                        )
                        self?.statusMessage = "Backup complete! \(backupedAssets.count) photos backed up and deleted."
                        completion(.success(result))
                    case .failure(let error):
                        let result = BackupResult(
                            successCount: backupedAssets.count,
                            failureCount: errors.count + 1,
                            totalCount: assets.count
                        )
                        self?.statusMessage = "Backup complete but failed to delete some photos: \(error.localizedDescription)"
                        completion(.success(result))
                    }
                }
            }
        }
    }

    private func deleteBackupedPhotos(_ assets: [PHAsset], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !assets.isEmpty else {
            completion(.success(()))
            return
        }

        let group = DispatchGroup()
        var deleteErrors: [Error] = []

        for asset in assets {
            group.enter()

            photoManager.deletePhotoAsset(asset) { result in
                defer { group.leave() }
                if case .failure(let error) = result {
                    deleteErrors.append(error)
                }
            }
        }

        group.notify(queue: .main) {
            if deleteErrors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(deleteErrors.first ?? BackupError.deletionFailed))
            }
        }
    }

    private func generateFileName(for asset: PHAsset) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let dateString = formatter.string(from: asset.creationDate ?? Date())
        return "WhatsApp_\(dateString).jpg"
    }
}

struct BackupResult {
    let successCount: Int
    let failureCount: Int
    let totalCount: Int
}

enum BackupError: LocalizedError {
    case alreadyBackingUp
    case deletionFailed

    var errorDescription: String? {
        switch self {
        case .alreadyBackingUp:
            return "Backup is already in progress"
        case .deletionFailed:
            return "Failed to delete photos after backup"
        }
    }
}
