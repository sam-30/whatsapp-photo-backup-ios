import XCTest
@testable import whatsappScheduler

class PhotoBackupServiceTests: XCTestCase {
    var backupService: PhotoBackupService!

    override func setUp() {
        super.setUp()
        backupService = PhotoBackupService.shared
    }

    override func tearDown() {
        super.tearDown()
        backupService = nil
    }

    func testBackupProgressTracking() {
        XCTAssertEqual(backupService.backupProgress, 0)
        XCTAssertEqual(backupService.backupedCount, 0)
        XCTAssertFalse(backupService.isBackingUp)
    }

    func testWhatsAppPhotoManagerInitialization() {
        let manager = WhatsAppPhotoManager.shared
        XCTAssertNotNil(manager)
    }

    func testGoogleDriveManagerInitialization() {
        let manager = GoogleDriveManager.shared
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isUserSignedIn())
    }

    func testBackupResultStructure() {
        let result = BackupResult(successCount: 5, failureCount: 1, totalCount: 6)
        XCTAssertEqual(result.successCount, 5)
        XCTAssertEqual(result.failureCount, 1)
        XCTAssertEqual(result.totalCount, 6)
    }

    func testWhatsAppErrorDescriptions() {
        XCTAssertNotNil(WhatsAppError.photoAccessDenied.errorDescription)
        XCTAssertNotNil(WhatsAppError.exportFailed.errorDescription)
        XCTAssertNotNil(WhatsAppError.deletionFailed.errorDescription)
        XCTAssertNotNil(WhatsAppError.noPhotosFound.errorDescription)
    }

    func testGoogleDriveErrorDescriptions() {
        XCTAssertNotNil(GoogleDriveError.notSignedIn.errorDescription)
        XCTAssertNotNil(GoogleDriveError.signInFailed.errorDescription)
        XCTAssertNotNil(GoogleDriveError.uploadFailed.errorDescription)
        XCTAssertNotNil(GoogleDriveError.folderCreationFailed.errorDescription)
    }

    func testBackupErrorDescriptions() {
        XCTAssertNotNil(BackupError.alreadyBackingUp.errorDescription)
        XCTAssertNotNil(BackupError.deletionFailed.errorDescription)
    }
}

class WhatsAppPhotoManagerTests: XCTestCase {
    var photoManager: WhatsAppPhotoManager!

    override func setUp() {
        super.setUp()
        photoManager = WhatsAppPhotoManager.shared
    }

    override func tearDown() {
        super.tearDown()
        photoManager = nil
    }

    func testPhotoManagerInitialization() {
        XCTAssertNotNil(photoManager)
    }
}

class GoogleDriveManagerTests: XCTestCase {
    var driveManager: GoogleDriveManager!

    override func setUp() {
        super.setUp()
        driveManager = GoogleDriveManager.shared
    }

    override func tearDown() {
        super.tearDown()
        driveManager = nil
    }

    func testDriveManagerInitialization() {
        XCTAssertNotNil(driveManager)
    }

    func testDriveServiceNilBeforeSignIn() {
        XCTAssertNil(driveManager.driveService)
    }

    func testSignOutClearsDriveService() {
        driveManager.driveService = GTLRDriveService()
        XCTAssertNotNil(driveManager.driveService)

        driveManager.signOut()
        XCTAssertNil(driveManager.driveService)
    }
}
