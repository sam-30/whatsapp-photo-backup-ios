# TestFlight Deployment Guide

Complete step-by-step instructions to deploy the WhatsApp Photo Backup app to TestFlight using your Apple Developer account (rotabush@gmail.com).

## Prerequisites

✅ Apple Developer Account: rotabush@gmail.com  
✅ macOS with Xcode 14+ installed  
✅ Valid Apple Developer subscription  
✅ iPhone or iPad for testing  

## Phase 1: App Store Connect Setup

### Step 1.1: Create App Record in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with **rotabush@gmail.com**
3. Go to **Apps** → Click **+** button → **New App**
4. Fill in:
   - **Platform**: iOS
   - **Name**: WhatsApp Photo Backup
   - **Primary Language**: English
   - **Bundle ID**: `com.rotabush.whatsappphotobackup`
   - **SKU**: `WHATSAPP_BACKUP_001` (any unique identifier)
   - **User Access**: Full Access (select yourself)
5. Click **Create**

### Step 1.2: Configure App Information

1. In App Store Connect, go to your app
2. Click **App Information** → **General**
3. Set:
   - **App Name**: WhatsApp Photo Backup
   - **Subtitle**: Backup to Google Drive
   - **Category**: Productivity
   - **Content Rights**: Select appropriate options

### Step 1.3: Create Privacy Policy

1. Go to **App Privacy** on your app page
2. Fill in the privacy questionnaire:
   - **Data Collection**: Your app collects photos
   - **Usage**: Photo backup and Google Drive upload
   - **Third Parties**: Google (for authentication and Drive API)
3. You can use a placeholder policy for TestFlight
4. Save changes

## Phase 2: Certificate and Provisioning Setup

### Step 2.1: Create iOS App Certificate

1. Go to https://developer.apple.com/account
2. Sign in with **rotabush@gmail.com**
3. Go to **Certificates, Identifiers & Profiles**
4. Click **Certificates**
5. Click **+** to create new certificate
6. Select **iOS App Development**
7. Click **Continue**
8. Follow instructions to create CSR (Certificate Signing Request):
   - Open **Keychain Access** on your Mac
   - Go to **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
   - Email: rotabush@gmail.com
   - Common Name: Your Name
   - Select "Saved to disk"
   - Save as `CertificateSigningRequest.certSigningRequest`
9. Upload the CSR file
10. Download the certificate
11. Double-click to install in Keychain

### Step 2.2: Register Your iOS Device

1. In Developer account, go to **Devices**
2. Click **+** to add device
3. Select **iPhone** or **iPad**
4. Enter:
   - **Device Name**: Your Device Name
   - **UDID**: Get from Xcode → Window → Devices and Simulators
5. Click **Continue** → **Register**

### Step 2.3: Create App ID

1. Go to **Identifiers** in Developer account
2. Click **+** to create new identifier
3. Select **App IDs**
4. Select **App**
5. Fill in:
   - **Description**: WhatsApp Photo Backup
   - **Bundle ID**: Explicit → `com.rotabush.whatsappphotobackup`
6. Capabilities to enable:
   - ✅ Photo Library
   - ✅ Sign in with Apple (optional)
   - ✅ Network Extension (if needed)
7. Click **Continue** → **Register**

### Step 2.4: Create Provisioning Profile

1. Go to **Profiles** in Developer account
2. Click **+** to create new profile
3. Select **iOS App Development**
4. Select App ID: `com.rotabush.whatsappphotobackup`
5. Select Certificate: The one you created
6. Select Device: Your registered device
7. Enter Profile Name: `WhatsApp Photo Backup Dev`
8. Click **Continue** → **Generate** → **Download**
9. Double-click to install in Xcode

## Phase 3: Xcode Configuration

### Step 3.1: Open Project in Xcode

```bash
cd /path/to/whatsapp-photo-backup-ios
open SetTimeScheduler.xcworkspace
```

⚠️ **IMPORTANT**: Always use `.xcworkspace`, not `.xcodeproj`

### Step 3.2: Update Bundle Identifier

1. In Xcode, select **SetTimeScheduler** project
2. Select **SetTimeScheduler** target
3. Go to **General** tab
4. Change **Bundle Identifier** to: `com.rotabush.whatsappphotobackup`

### Step 3.3: Configure Signing

1. Select **SetTimeScheduler** target
2. Go to **Signing & Capabilities** tab
3. Set:
   - **Team**: Your team (rotabush@gmail.com)
   - **Bundle Identifier**: `com.rotabush.whatsappphotobackup`
   - **Automatically manage signing**: ✅ Check this box
4. Xcode will automatically fetch/create provisioning profiles

### Step 3.4: Add Google Sign-In URL Scheme

1. Go to **Info** tab in target settings
2. Expand **URL Types**
3. Click **+** to add new URL type
4. Enter:
   - **Identifier**: com.google.signin
   - **URL Scheme**: Your reversed Client ID
     - If Client ID is: `123456789-abcdef.apps.googleusercontent.com`
     - Reversed is: `com.googleusercontent.apps.123456789-abcdef`

### Step 3.5: Configure Google Drive Client ID

1. Update `ios/SetTimeScheduler/GoogleDriveConfig.swift`:
```swift
struct GoogleDriveConfig {
    static let clientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
    static let serverClientID = "YOUR_GOOGLE_SERVER_CLIENT_ID.apps.googleusercontent.com"
    
    static func configure() {
        GoogleDriveManager.shared.configureGoogleSignIn(clientID: clientID)
    }
}
```

2. Get your Client ID from Google Cloud Console:
   - Go to https://console.cloud.google.com
   - Select your project
   - Go to **Credentials**
   - Find your iOS OAuth client
   - Copy the Client ID

## Phase 4: Build and Archive

### Step 4.1: Install Dependencies

```bash
cd ios
pod install
```

### Step 4.2: Build for Testing

```bash
cd ios
xcodebuild build-for-testing \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Release \
  -sdk iphoneos
```

### Step 4.3: Create Archive

**Method 1: Using Xcode (Recommended)**
1. In Xcode: **Product** → **Archive**
2. Select your device (not simulator)
3. Wait for build to complete
4. When archive is created, Xcode opens the Organizer
5. Select your archive
6. Click **Distribute App**
7. Choose **TestFlight & App Store**
8. Follow the steps to upload

**Method 2: Using Command Line**
```bash
cd ios
xcodebuild \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/SetTimeScheduler.xcarchive \
  archive
```

### Step 4.4: Export Archive

```bash
xcodebuild -exportArchive \
  -archivePath build/SetTimeScheduler.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

**Create ExportOptions.plist**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string><none></string>
    <key>method</key>
    <string>app-store</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.rotabush.whatsappphotobackup</key>
        <string>WhatsApp Photo Backup Dev</string>
    </dict>
</dict>
</plist>
```

## Phase 5: Upload to TestFlight

### Step 5.1: Upload via Xcode Organizer

1. In Xcode: **Window** → **Organizer**
2. Select your archive
3. Click **Distribute App**
4. Choose **TestFlight & App Store**
5. Select **TestFlight**
6. Choose **Distribute to App Store Connect**
7. Review version information
8. Click **Upload**
9. Wait for processing (usually 5-15 minutes)

### Step 5.2: Configure TestFlight

Once upload completes:

1. Go to https://appstoreconnect.apple.com
2. Go to your app
3. Click **TestFlight** tab
4. Under **iOS Builds**, you should see your build
5. Click the build to configure:
   - Add **Test Information**
   - Add **Beta App Description**
   - Add **Beta App Review Information**
   - Configure **Privacy Policy**

### Step 5.3: Add Testers

**Internal Testing**:
1. Go to **Internal Testing**
2. Click **+** under **Testers**
3. Add users from your development team
4. They'll receive invitation via email

**External Testing**:
1. Go to **External Testing**
2. Create a **Testing Group**
3. Add beta testers (up to 10,000)
4. Add users from your contacts or by email
5. Submit for **Beta App Review** (Apple review required)

## Phase 6: Submit for Beta App Review

### Step 6.1: Complete Beta App Information

In App Store Connect:
1. Go to **Build** section
2. Complete all required information:
   - **Test Notes**: Describe what to test
   - **Contact Information**: Email for questions
   - **Privacy Policy**: Add link (or temporary)
   - **Screenshots**: Add at least 1 screenshot

### Step 6.2: Add Review Attachments

1. Go to **Version Information**
2. Upload:
   - Screenshots (1080x1920 for iPhone)
   - App Preview Video (optional but recommended)

### Step 6.3: Submit for Review

1. Click **Submit for Review**
2. Answer questionnaire about:
   - Sign-in requirements
   - Advertising
   - Content
3. Click **Submit**
4. Apple reviews within 24-48 hours

### Step 6.4: Release to Testers

Once approved:
1. Go to **TestFlight** section
2. Select approved build
3. Click **Release This Build** for:
   - Internal Testing
   - External Testing Groups

## Testing on Device

### Install TestFlight on Device

1. On iPhone/iPad: **App Store** → Search "TestFlight" → Install

### Accept Invitation

1. Testers receive invitation email
2. Click link or open invitation in TestFlight app
3. Tap **Accept**
4. App appears in TestFlight library
5. Tap **Install** to download

### Test the App

1. Launch WhatsApp Photo Backup app
2. Test workflow:
   - Sign in with Google
   - Grant photo library access
   - Start backup
   - Monitor progress
   - Verify photos deleted
   - Check Google Drive for backup folder

### Report Issues

Use TestFlight's built-in feedback:
1. Shake device to send feedback
2. Select app
3. Take screenshot if needed
4. Write feedback
5. Send to developers

## Troubleshooting

### "Failed to build archive"
- Check Xcode version (14+ required)
- Verify all pods installed: `pod install`
- Clean build folder: **Cmd + Shift + K**
- Rebuild: **Cmd + B**

### "Code signing error"
- Verify bundle identifier matches App ID
- Check team ID is correct
- Renew provisioning profile
- Restart Xcode

### "Upload failed"
- Verify app version is unique
- Check build number format
- Ensure all required fields completed
- Try uploading via Xcode again

### "Beta App Review rejected"
- Read Apple's feedback carefully
- Most common issues:
  - Missing privacy policy
  - Unclear test instructions
  - Missing contact information
- Resubmit after fixes

## Version Management

For future releases:

1. Update version in Xcode:
   - **General** → **Version**: 1.0.1
   - **General** → **Build**: 2

2. Update in `BuildConfig.swift`:
```swift
let appVersion = "1.0.1"
let buildNumber = "2"
```

3. Create new archive and upload following Phase 5

## Expedited Review

If you need faster review:
1. Go to build in App Store Connect
2. Click **Request Expedited Review**
3. Provide reason
4. Usually 24 hour turnaround (not guaranteed)

## Next Steps

1. ✅ Complete all setup above
2. ✅ Build and archive app
3. ✅ Upload to TestFlight
4. ✅ Configure app information
5. ✅ Add testers
6. ✅ Submit for review
7. ✅ Release to testers
8. ✅ Gather feedback
9. ✅ Make improvements
10. ✅ Submit to App Store when ready

## Support

For issues:
- Apple Developer Documentation: https://developer.apple.com/documentation/
- App Store Connect Help: https://appstoreconnect.apple.com/help
- TestFlight FAQ: https://developer.apple.com/testflight/faq/

---

**Your app will be on TestFlight within 24-48 hours!** 🎉
