# WhatsApp Photo Backup - Build and Test Guide

## Prerequisites

- macOS (for iOS development)
- Xcode 14.0 or later
- CocoaPods 1.13 or later
- iOS 15.1+ device or simulator
- 10GB+ free disk space

## Building the iOS App

### Step 1: Install Dependencies

```bash
cd ios
pod install
```

This installs:
- GoogleSignIn (~> 7.0) - OAuth authentication
- GoogleAPIClientForREST/Drive (~> 3.0) - Google Drive API

### Step 2: Open the Xcode Workspace

```bash
open SetTimeScheduler.xcworkspace
```

**Important**: Always use the `.xcworkspace` file, not the `.xcodeproj` file.

### Step 3: Configure Google SignIn

1. In Xcode, select the "SetTimeScheduler" target
2. Go to "Info" tab
3. Add a URL Type:
   - Identifier: `com.google.signin`
   - URL Scheme: `REVERSED_CLIENT_ID` (e.g., `com.googleusercontent.apps.xxxxx`)

### Step 4: Update GoogleDriveConfig

Edit `ios/SetTimeScheduler/GoogleDriveConfig.swift`:

```swift
static let clientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
```

### Step 5: Build for Device or Simulator

#### For Simulator
```bash
cd ios
xcodebuild build \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build
```

#### For Device
```bash
cd ios
xcodebuild build \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Debug \
  -sdk iphoneos \
  -derivedDataPath build
```

### Step 6: Run Tests

```bash
cd ios
xcodebuild test \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build
```

## Testing Strategy

### Unit Tests

Run the included test suite:

```bash
cd ios
xcodebuild test \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -enableCodeCoverage YES
```

**Test Coverage Includes:**
- PhotoBackupService initialization and state management
- WhatsAppPhotoManager error handling
- GoogleDriveManager authentication state
- BackupResult data structure validation
- Error enum descriptions

### Integration Testing

Test the full backup workflow:

1. **Sign-In Flow**
   - Launch app
   - Tap "Sign in with Google"
   - Verify authentication succeeds
   - Check Google sign-in state

2. **Photo Discovery**
   - Ensure WhatsApp photos are found
   - Verify photo count is accurate
   - Check permission handling

3. **Google Drive Preparation**
   - Verify backup folder is created
   - Check folder location in Google Drive
   - Ensure proper naming

4. **Upload Process**
   - Monitor progress bar updates
   - Verify upload count increases
   - Check file names in Google Drive
   - Confirm file integrity

5. **Deletion Process**
   - Verify photos are deleted after upload
   - Check photo library is updated
   - Ensure device storage is freed

6. **Error Scenarios**
   - Test with no network connection
   - Test with insufficient Google Drive space
   - Test with photo library access denied
   - Test interruption and recovery

### UI Testing

SwiftUI Preview Testing:

```bash
cd ios
xcodebuild build \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Test UI states:
- [ ] Sign-in screen displays correctly
- [ ] Progress screen shows during backup
- [ ] Progress bar animates smoothly
- [ ] Upload counter updates in real-time
- [ ] Status messages are clear
- [ ] Error alerts display properly
- [ ] Sign-out button works

## Performance Testing

### Memory Usage
```bash
# Monitor with Xcode Instruments
# Select: Product → Profile → Leaks
```

**Expected behavior:**
- Memory usage < 100MB during backup
- No memory leaks detected
- Proper cleanup after completion

### Network Performance
```bash
# Test with Network Link Conditioner
# Set to 3G or worse to simulate real conditions
```

**Expected behavior:**
- Graceful handling of slow connections
- No timeout issues with large files
- Proper retry on network errors

### Battery Impact
- Monitor battery drain during backup
- Verify background modes are configured
- Check for unnecessary wake-locks

## Build Artifacts

After successful build, you'll find:

```
build/
├── Debug-iphonesimulator/
│   └── SetTimeScheduler.app
├── Debug-iphoneos/
│   └── SetTimeScheduler.app
└── test-results/
    └── output.json
```

## Continuous Integration

### GitHub Actions Workflow

Create `.github/workflows/build-ios.yml`:

```yaml
name: Build iOS App

on:
  push:
    branches: [ main, claude/** ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.0
        bundler-cache: true
    
    - name: Install CocoaPods
      run: gem install cocoapods
    
    - name: Install Pods
      run: |
        cd ios
        pod install
    
    - name: Build for Testing
      run: |
        cd ios
        xcodebuild build-for-testing \
          -workspace SetTimeScheduler.xcworkspace \
          -scheme SetTimeScheduler \
          -configuration Debug
    
    - name: Run Tests
      run: |
        cd ios
        xcodebuild test \
          -workspace SetTimeScheduler.xcworkspace \
          -scheme SetTimeScheduler \
          -configuration Debug
```

## Troubleshooting Build Issues

### "Pod install" fails

```bash
# Clear CocoaPods cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ios/Pods
pod install
```

### "Xcode build fails"

```bash
# Reset Xcode build cache
rm -rf build
xcodebuild clean
xcodebuild build
```

### "Google SignIn not working"

1. Verify Client ID is correct in GoogleDriveConfig.swift
2. Check URL scheme in Info.plist matches reversed Client ID
3. Verify bundle identifier in Xcode matches Google Cloud Console
4. Restart Xcode and app

### "Tests fail with timeout"

Increase test timeout:
```bash
xcodebuild test ... -test-timeouts-enabled YES
```

## Release Build

Create a release build:

```bash
cd ios
xcodebuild build \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -configuration Release \
  -archivePath build/SetTimeScheduler.xcarchive \
  archive
```

Export for App Store:

```bash
xcodebuild -exportArchive \
  -archivePath build/SetTimeScheduler.xcarchive \
  -exportPath build/exports \
  -exportOptionsPlist ExportOptions.plist
```

## Code Coverage

Generate code coverage report:

```bash
cd ios
xcodebuild test \
  -workspace SetTimeScheduler.xcworkspace \
  -scheme SetTimeScheduler \
  -enableCodeCoverage YES \
  -derivedDataPath build
```

View coverage:
```bash
open build/Logs/Test/coverage.json
```

## Performance Benchmarks

Expected performance metrics:

| Operation | Target | Actual |
|-----------|--------|--------|
| Photo scan | < 5s | - |
| Single photo upload | < 30s | - |
| 10 photos backup | < 2 min | - |
| 100 photos backup | < 15 min | - |
| Photo deletion | < 10s | - |

## Deployment Checklist

- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No memory leaks
- [ ] No network timeouts
- [ ] Google Drive credentials configured
- [ ] Photo library permissions tested
- [ ] Error handling verified
- [ ] UI tested on multiple devices
- [ ] Performance benchmarks met
- [ ] Documentation updated

## Support

For build issues, check:
1. Xcode version compatibility
2. CocoaPods version
3. iOS deployment target
4. Swift version
5. Available disk space
