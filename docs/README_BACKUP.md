# WhatsApp Photo Backup Feature

## Overview

This feature provides automatic backup of WhatsApp photos to Google Drive with local deletion after successful upload.

## Architecture

### Components

1. **WhatsAppPhotoManager**
   - Manages photo library access and permissions
   - Scans for WhatsApp photos in the device's photo library
   - Exports photos to temporary location for upload
   - Handles photo deletion after backup

2. **GoogleDriveManager**
   - Manages Google Sign-in authentication
   - Interfaces with Google Drive API
   - Uploads photos to Google Drive
   - Creates and manages backup folder

3. **PhotoBackupService**
   - Orchestrates the backup workflow
   - Tracks progress and status
   - Coordinates between photo manager and drive manager
   - Publishes progress updates for UI

4. **BackupView**
   - SwiftUI interface for the backup feature
   - Displays sign-in screen
   - Shows backup progress
   - Handles user interactions

## Workflow

```
User taps "Start Backup"
    ↓
Check Google Drive authentication
    ↓
Fetch WhatsApp photos from library
    ↓
Create/get backup folder in Google Drive
    ↓
For each photo:
    ├─ Export to temporary location
    ├─ Upload to Google Drive
    ├─ Delete local file
    └─ Update progress
    ↓
Delete all backed-up photos from library
    ↓
Display final results
```

## Integration

### Adding to Existing Project

1. Copy the Swift files to your Xcode project:
   - WhatsAppPhotoManager.swift
   - GoogleDriveManager.swift
   - PhotoBackupService.swift
   - BackupView.swift
   - GoogleDriveConfig.swift

2. Update Podfile with:
   ```ruby
   pod 'GoogleAPIClientForREST/Drive', '~> 3.0'
   pod 'GoogleSignIn', '~> 7.0'
   ```

3. Run `pod install`

4. Configure Google Cloud Project and add Client ID to GoogleDriveConfig.swift

5. Add Info.plist entries for photo library access

6. Add URL scheme for Google Sign-in in Xcode

### Using in Your App

Present the BackupView:
```swift
NavigationLink(destination: BackupView()) {
    Text("Backup Photos")
}
```

Or show as a sheet:
```swift
@State private var showBackup = false

Sheet(isPresented: $showBackup) {
    BackupView()
}
```

## Error Handling

The app handles various error scenarios:

- Photo library access denied
- Google authentication failures
- Network/upload errors
- Storage quota exceeded
- Invalid file formats

Each error provides a user-friendly message.

## Performance

- Batch uploads for efficiency
- Concurrent photo processing
- Progress tracking with real-time updates
- Temporary file cleanup to save space

## Security

- OAuth 2.0 authentication (no password storage)
- Secure HTTPS uploads
- Photo library permission system
- No metadata stored locally
- Users can revoke access anytime

## Testing

Run the included tests:
```bash
xcodebuild test -workspace whatsappScheduler.xcworkspace -scheme whatsappScheduler
```

## Configuration

### Client ID Setup

1. Get your Google Client ID from Google Cloud Console
2. Update GoogleDriveConfig.swift:
   ```swift
   static let clientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
   ```
3. Add URL scheme in Xcode Info.plist

### Customization

- Backup folder name in GoogleDriveManager.swift
- Photo album name in WhatsAppPhotoManager.swift
- File naming format in PhotoBackupService.swift
- UI colors and text in BackupView.swift

## Limitations

- Requires iOS 15.1 or later
- Photos must be in "WhatsApp Images" album
- Requires internet connection
- Limited by Google Drive storage quota
- Requires explicit user permissions

## Future Enhancements

- Scheduled automatic backups
- Backup history and recovery
- Selective photo filtering
- Compression options
- Cloud storage provider options (iCloud, Dropbox)
- Offline mode with sync on connection

## Debugging

Enable verbose logging by adding:
```swift
os_log("Message", log: OSLog.default, type: .debug)
```

Check Xcode console for detailed error messages and progress events.

## References

- [Google Drive API Documentation](https://developers.google.com/drive/api/guides/about-sdk)
- [Google SignIn SDK](https://developers.google.com/identity/sign-in/ios)
- [Photos Framework Documentation](https://developer.apple.com/documentation/photos)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)

## License

Part of SetTime application.
