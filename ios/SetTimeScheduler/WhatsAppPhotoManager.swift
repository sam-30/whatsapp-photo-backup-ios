import Foundation
import Photos

class WhatsAppPhotoManager {
    static let shared = WhatsAppPhotoManager()

    private init() {}

    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    func fetchWhatsAppPhotos(completion: @escaping (Result<[PHAsset], Error>) -> Void) {
        requestPhotoLibraryAccess { hasAccess in
            guard hasAccess else {
                completion(.failure(WhatsAppError.photoAccessDenied))
                return
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "creationDate != nil")
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let whatsappAlbumName = "WhatsApp Images"
            let albums = PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .any,
                options: nil
            )

            var whatsappPhotos: [PHAsset] = []

            albums.enumerateObjects { collection, _, _ in
                if collection.localizedTitle == whatsappAlbumName {
                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    assets.enumerateObjects { asset, _, _ in
                        if asset.mediaType == .image {
                            whatsappPhotos.append(asset)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                completion(.success(whatsappPhotos))
            }
        }
    }

    func exportPhotoToTemporaryLocation(asset: PHAsset, completion: @escaping (Result<URL, Error>) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true

        asset.requestContentEditingInput(with: options) { input, _ in
            guard let input = input, let imageURL = input.fullSizeImageURL else {
                completion(.failure(WhatsAppError.exportFailed))
                return
            }

            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".jpg"
            let tempFileURL = tempDirectory.appendingPathComponent(fileName)

            do {
                try FileManager.default.copyItem(at: imageURL, to: tempFileURL)
                completion(.success(tempFileURL))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deletePhotoAsset(_ asset: PHAsset, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(WhatsAppError.deletionFailed))
                }
            }
        }
    }

    func deleteLocalFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}

enum WhatsAppError: LocalizedError {
    case photoAccessDenied
    case exportFailed
    case deletionFailed
    case noPhotosFound

    var errorDescription: String? {
        switch self {
        case .photoAccessDenied:
            return "Photo library access was denied"
        case .exportFailed:
            return "Failed to export photo"
        case .deletionFailed:
            return "Failed to delete photo"
        case .noPhotosFound:
            return "No WhatsApp photos found"
        }
    }
}
