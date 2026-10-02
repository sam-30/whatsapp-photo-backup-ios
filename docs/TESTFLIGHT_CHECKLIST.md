# TestFlight Deployment Checklist

Use this checklist to ensure you complete all steps for deploying to TestFlight.

## Phase 1: App Store Connect Setup
- [ ] Sign in to App Store Connect with rotabush@gmail.com
- [ ] Create new app record
- [ ] Set app name: "WhatsApp Photo Backup"
- [ ] Set bundle ID: `com.rotabush.whatsappphotobackup`
- [ ] Fill in app information (category, subtitle)
- [ ] Add privacy policy
- [ ] Save all changes

## Phase 2: Certificates & Provisioning
- [ ] Create iOS App Development certificate
- [ ] Generate Certificate Signing Request from Keychain
- [ ] Upload CSR and download certificate
- [ ] Install certificate in Keychain
- [ ] Register your iPhone/iPad device (UDID)
- [ ] Create App ID for bundle ID
- [ ] Enable Photo Library capability
- [ ] Create iOS App Development provisioning profile
- [ ] Download and install provisioning profile

## Phase 3: Xcode Configuration
- [ ] Open `whatsappScheduler.xcworkspace` (NOT .xcodeproj)
- [ ] Update bundle identifier to `com.rotabush.whatsappphotobackup`
- [ ] Set team to your Apple ID (rotabush@gmail.com)
- [ ] Enable automatic signing
- [ ] Add Google SignIn URL scheme:
  - [ ] Identifier: `com.google.signin`
  - [ ] URL Scheme: Your reversed Client ID
- [ ] Update GoogleDriveConfig.swift with Google Client ID
- [ ] Verify Podfile has Google dependencies:
  - [ ] GoogleSignIn (~> 7.0)
  - [ ] GoogleAPIClientForREST/Drive (~> 3.0)

## Phase 4: Build Preparation
- [ ] Run: `cd ios && pod install`
- [ ] Verify no build errors: `xcodebuild build-for-testing`
- [ ] Run code verification: `scripts/verify-swift-code.sh`
- [ ] Select actual iPhone (not simulator) as build target
- [ ] Set Release build configuration

## Phase 5: Archive & Export
- [ ] Clean build folder (Cmd + Shift + K)
- [ ] Create archive:
  - [ ] Product → Archive (Xcode)
  - [ ] Wait for build to complete
- [ ] Xcode Organizer opens with archive
- [ ] Click "Distribute App"
- [ ] Choose "TestFlight & App Store"
- [ ] Choose distribution method
- [ ] Review code signing
- [ ] Proceed to upload

## Phase 6: TestFlight Configuration
- [ ] Go to App Store Connect
- [ ] Find your uploaded build
- [ ] Add test information:
  - [ ] **Test Notes**: What to test and how
  - [ ] **Contact Information**: Your email
- [ ] Add privacy policy link
- [ ] Take screenshots (at least 1)
- [ ] Fill app description for beta

## Phase 7: Testers
- [ ] Decide on testing approach:
  - [ ] Internal testing (your team)
  - [ ] External testing (public)
- [ ] Add internal testers:
  - [ ] Go to Internal Testing
  - [ ] Add your test email addresses
- [ ] For external testing:
  - [ ] Create testing group
  - [ ] Add testers' emails
  - [ ] Submit for beta app review

## Phase 8: Beta App Review
- [ ] Complete all required information
- [ ] Answer Apple's review questions
- [ ] Upload any required documentation
- [ ] Submit for review
- [ ] Wait for approval (24-48 hours)
- [ ] Once approved, release build to testers

## Phase 9: Testing
- [ ] Install TestFlight on your iPhone
- [ ] Accept invitation
- [ ] Download app via TestFlight
- [ ] Test core features:
  - [ ] Google Sign-in works
  - [ ] Photo library access granted
  - [ ] Can start backup process
  - [ ] Progress bar shows
  - [ ] Photos upload correctly
  - [ ] Photos delete after upload
  - [ ] Google Drive has backup folder
- [ ] Test error scenarios:
  - [ ] Deny photo permissions
  - [ ] Disable network
  - [ ] Insufficient Google Drive space

## Phase 10: Gathering Feedback
- [ ] Ask testers to test functionality
- [ ] Request crash reports via TestFlight
- [ ] Monitor feedback submissions
- [ ] Fix any reported issues
- [ ] Create new build if needed
- [ ] Re-upload to TestFlight

## Important Notes

### Bundle ID
- **MUST** be: `com.rotabush.whatsappphotobackup`
- Used everywhere (Xcode, App Store Connect, Apple Developer)

### Provisioning Profile
- Downloaded from Developer portal
- Must include your registered device
- Set to App ID you created

### Google Client ID
- Required for Google Sign-in to work
- Get from Google Cloud Console
- Add to GoogleDriveConfig.swift

### Version Numbers
- **Version** (Marketing): 1.0.0
- **Build** (Internal): Increments each upload (1, 2, 3...)

### Certificate Validity
- App Development certs valid for 1 year
- Renew before expiration
- Distribution certs valid for 3 years

## Quick Reference: Commands

```bash
# Navigate to project
cd /path/to/whatsapp-photo-backup-ios

# Install pods
cd ios && pod install

# Verify code
scripts/verify-swift-code.sh

# Build for testing
xcodebuild build-for-testing \
  -workspace whatsappScheduler.xcworkspace \
  -scheme whatsappScheduler \
  -configuration Release

# Open in Xcode
open whatsappScheduler.xcworkspace
```

## Troubleshooting Quick Fix

| Issue | Solution |
|-------|----------|
| Code signing fails | Restart Xcode, check team ID, renew provisioning profile |
| Archive fails | `pod install`, clean build, check version number |
| Upload fails | Unique version, check build number, valid signing |
| TestFlight rejected | Check app info, privacy policy, test notes |
| Device not showing | Restart Xcode, reconnect device, check UDID |

## Timeline Expectation

- Setup: 30 minutes
- Building: 10 minutes
- Uploading: 5 minutes
- Apple processing: 5-15 minutes
- Beta review: 24-48 hours
- **Total: ~2 hours (mostly waiting)**

## Contact Info for Reference

- **Apple ID**: rotabush@gmail.com
- **Bundle ID**: com.rotabush.whatsappphotobackup
- **App Name**: WhatsApp Photo Backup
- **Team**: Your development team

---

✅ **Mark off each item as you complete it!**

Once all items are checked, your app will be on TestFlight! 🎉
