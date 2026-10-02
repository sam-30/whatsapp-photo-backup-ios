# WhatsApp Photo Backup to Google Drive - iOS App Setup Guide

This guide provides comprehensive instructions for setting up and using the WhatsApp Photo Backup app that automatically backs up WhatsApp photos to Google Drive and deletes local copies.

## Overview

The app performs the following steps:
1. Scans the device photo library for WhatsApp photos
2. Uploads them securely to a backup folder in Google Drive
3. Deletes the local copies after successful upload
4. Provides real-time progress updates and error handling

## Prerequisites

- iOS 15.1 or later
- Xcode 14.0 or later
- CocoaPods installed
- Google Account with Google Drive access
- Google Cloud Project with Drive API enabled

## Installation Steps

### 1. Set Up Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Enable the Google Drive API:
   - Search for "Drive API" in the search bar
   - Click "Enable"
4. Create OAuth 2.0 credentials:
   - Go to "Credentials" in the left sidebar
   - Click "Create Credentials" → "OAuth client ID"
   - Select "iOS"
   - Add your bundle identifier (e.g., `com.settimeapp.whatsappbackup`)
   - For development, you need to add your device's IDFA
   - Click "Create"
   - Copy the Client ID

### 2. Configure Xcode Project

1. Open the iOS project in Xcode:
   ```bash
   cd ios
   open whatsappScheduler.xcworkspace
   ```

2. Add GoogleSignIn URL scheme:
   - Select the project in Xcode
   - Select "whatsappScheduler" target
   - Go to "Info" tab
   - Add a new URL Type:
     - Identifier: com.google.signin
     - URL Scheme: `REVERSED_CLIENT_ID`
     - (Replace REVERSED_CLIENT_ID with your client ID reversed, e.g., `com.googleusercontent.apps.xxxx`)

3. Update GoogleDriveConfig.swift:
   - Open `ios/whatsappScheduler/GoogleDriveConfig.swift`
   - Replace `YOUR_GOOGLE_CLIENT_ID` with your actual Client ID from Google Cloud Console
   - Replace `YOUR_GOOGLE_SERVER_CLIENT_ID` with your Server Client ID

### 3. Install Dependencies

```bash
cd ios
pod install
```

This will install:
- GoogleSignIn (~> 7.0)
- GoogleAPIClientForREST/Drive (~> 3.0)

### 4. Update Info.plist

The app requires the following permissions. These should be automatically included, but verify:

Add to your `Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to your photos to back them up to Google Drive.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos to back them up to Google Drive.</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access to function properly.</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

## File Structure

The app consists of the following Swift files:

### Core Components

- **WhatsAppPhotoManager.swift**
  - Handles access to photo library
  - Scans for WhatsApp photos
  - Exports photos to temporary location
  - Deletes photos after backup

- **GoogleDriveManager.swift**
  - Manages Google Sign-in
  - Handles Google Drive API interactions
  - Uploads photos to Google Drive
  - Creates/manages backup folder

- **PhotoBackupService.swift**
  - Orchestrates the backup process
  - Manages progress tracking
  - Coordinates photo export and Google Drive upload
  - Handles photo deletion

- **BackupView.swift**
  - SwiftUI interface
  - Sign-in screen
  - Backup progress display
  - Status updates

- **GoogleDriveConfig.swift**
  - Configuration constants
  - Google Sign-in setup

## Usage

### First Time Setup

1. Launch the app
2. Tap "Sign in with Google"
3. Authenticate with your Google account
4. Grant the required permissions

### Starting a Backup

1. From the main screen, tap "Start Backup"
2. The app will:
   - Find all WhatsApp photos on your device
   - Create a backup folder in Google Drive (if it doesn't exist)
   - Upload each photo with a timestamp
   - Delete local copies
   - Show progress in real-time

### Monitoring Progress

- Real-time progress bar shows upload percentage
- Counter displays number of successfully backed up photos
- Failed uploads are tracked separately
- Status messages provide detailed information

## Security & Privacy Considerations

### Photo Library Access
- The app uses iOS Photo Library framework with proper permission requests
- Photos are only accessed with explicit user permission
- Users can manage access in Settings → Privacy → Photos

### Google Drive Integration
- OAuth 2.0 authentication (not password-based)
- Access tokens are managed securely by Google SignIn SDK
- Users can revoke access at any time
- Photos are uploaded over HTTPS

### Data Handling
- Temporary files are deleted after upload
- No metadata is stored on device
- Backup folder is created in user's own Google Drive
- All operations can be audited in Google Drive

## Advanced Configuration

### Customizing Backup Folder Name

Edit `GoogleDriveManager.swift`, change the `folderName` in `getOrCreateBackupFolder()`:
```swift
let folderName = "My Custom Backup Folder"
```

### Filtering Photos

Edit `WhatsAppPhotoManager.swift` in `fetchWhatsAppPhotos()` to customize which photos are included:
```swift
let whatsappAlbumName = "Your Custom Album Name"
```

### Adjusting File Naming

Edit `PhotoBackupService.swift` in `generateFileName()` to customize how files are named:
```swift
let dateString = formatter.string(from: asset.creationDate ?? Date())
return "CustomPrefix_\(dateString).jpg"
```

## Troubleshooting

### "Photo library access was denied"
- Go to Settings → Privacy → Photos
- Make sure the app is allowed to access photos
- Tap "Full Photos Library" access

### "Failed to sign in to Google"
- Verify your Google Client ID is correct in GoogleDriveConfig.swift
- Check that the URL scheme is properly configured in Info.plist
- Ensure your bundle identifier matches the one registered in Google Cloud Console

### "Failed to upload photo to Google Drive"
- Check internet connection
- Verify Google Drive API is enabled in Cloud Console
- Check that your Google account has sufficient storage space

### Photos not found
- Ensure photos exist in the "WhatsApp Images" album
- Check if WhatsApp permission to access photos is granted
- Verify iOS version is 15.1 or later

### Backup interrupted or incomplete
- Check network connectivity
- Ensure app is allowed to run in background
- Try backing up a smaller batch of photos first

## API Reference

### WhatsAppPhotoManager

```swift
// Request photo library access
func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void)

// Fetch all WhatsApp photos
func fetchWhatsAppPhotos(completion: @escaping (Result<[PHAsset], Error>) -> Void)

// Export photo to temporary location
func exportPhotoToTemporaryLocation(asset: PHAsset, completion: @escaping (Result<URL, Error>) -> Void)

// Delete photo from library
func deletePhotoAsset(_ asset: PHAsset, completion: @escaping (Result<Void, Error>) -> Void)

// Delete temporary file
func deleteLocalFile(at url: URL) throws
```

### GoogleDriveManager

```swift
// Configure Google Sign-in
func configureGoogleSignIn(clientID: String)

// Sign in user
func signIn(from viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void)

// Sign out
func signOut()

// Check if user is signed in
func isUserSignedIn() -> Bool

// Upload photo to Google Drive
func uploadPhoto(fileURL: URL, fileName: String, completion: @escaping (Result<String, Error>) -> Void)

// Create backup folder
func createBackupFolder(completion: @escaping (Result<String, Error>) -> Void)

// Get or create backup folder
func getOrCreateBackupFolder(completion: @escaping (Result<String, Error>) -> Void)
```

### PhotoBackupService

```swift
// Start backup process
func startBackup(completion: @escaping (Result<BackupResult, Error>) -> Void)

// Published properties for UI updates
@Published var backupProgress: Double
@Published var isBackingUp: Bool
@Published var statusMessage: String
@Published var backupedCount: Int
@Published var failedCount: Int
```

## Performance Considerations

- Large photo collections (1000+) may take significant time
- Upload speed depends on internet connection
- Consider backing up during WiFi for faster speeds
- Background app refresh should be enabled for best results

## Building for TestFlight

1. Archive the project:
   ```bash
   xcodebuild -workspace ios/whatsappScheduler.xcworkspace \
     -scheme whatsappScheduler \
     -configuration Release \
     -archivePath build/whatsappScheduler.xcarchive \
     archive
   ```

2. Export the archive:
   ```bash
   xcodebuild -exportArchive \
     -archivePath build/whatsappScheduler.xcarchive \
     -exportPath build/exports \
     -exportOptionsPlist ExportOptions.plist
   ```

3. Upload to App Store Connect

## Support & Issues

For issues or feature requests related to WhatsApp photo backup:
1. Check the Troubleshooting section above
2. Review device logs in Xcode Console
3. Verify all configuration steps were completed correctly

## License

This component is part of the SetTime application.
