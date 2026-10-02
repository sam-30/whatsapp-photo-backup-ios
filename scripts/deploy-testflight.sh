#!/bin/bash

# WhatsApp Photo Backup - Full TestFlight Deployment Script
# This script automates the entire build-to-TestFlight workflow
# Run on macOS with Xcode installed

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BUNDLE_ID="com.rotabush.whatsappphotobackup"
PROVISIONING_PROFILE="WhatsApp Photo Backup Dev"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/whatsappScheduler.xcarchive"
EXPORT_DIR="$BUILD_DIR/ipa"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  WhatsApp Photo Backup - TestFlight Deployment             ║"
echo "║  Automated Build & Upload Script                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print progress
print_step() {
    echo ""
    echo -e "${YELLOW}▶ $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 0: Verify environment
print_step "Verifying environment..."

if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi
print_success "macOS detected"

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed"
    exit 1
fi
print_success "Xcode found: $(xcodebuild -version | head -1)"

if ! command -v pod &> /dev/null; then
    print_error "CocoaPods not installed. Run: sudo gem install cocoapods"
    exit 1
fi
print_success "CocoaPods found: v$(pod --version)"

# Step 1: Install dependencies
print_step "Installing CocoaPods dependencies..."
cd "$PROJECT_DIR/ios"
pod install --repo-update 2>&1 | grep -E "^(Analyzing|Installing|Generating)" || true
print_success "Dependencies installed"
cd "$PROJECT_DIR"

# Step 2: Verify configuration
print_step "Verifying app configuration..."

if grep -q "YOUR_GOOGLE_CLIENT_ID" "$PROJECT_DIR/ios/whatsappScheduler/GoogleDriveConfig.swift"; then
    print_error "Google Client ID not configured in GoogleDriveConfig.swift"
    echo "  Please update with your actual Client ID from Google Cloud Console"
    exit 1
fi
print_success "Google Client ID configured"

# Step 3: Run code verification
print_step "Running code verification..."
if ! "$PROJECT_DIR/scripts/verify-swift-code.sh" > /dev/null 2>&1; then
    print_error "Code verification failed"
    exit 1
fi
print_success "Code verification passed"

# Step 4: Get version information
print_step "Getting version information..."

cd "$PROJECT_DIR/ios"

# Try to extract from Xcode project
MARKETING_VERSION=$(xcodebuild -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -showBuildSettings | grep MARKETING_VERSION | head -1 | sed 's/.*= //')

CURRENT_PROJECT_VERSION=$(xcodebuild -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -showBuildSettings | grep CURRENT_PROJECT_VERSION | head -1 | sed 's/.*= //')

cd "$PROJECT_DIR"

if [ -z "$MARKETING_VERSION" ]; then
    MARKETING_VERSION="1.0.0"
fi

if [ -z "$CURRENT_PROJECT_VERSION" ]; then
    CURRENT_PROJECT_VERSION="1"
fi

echo "  Version: $MARKETING_VERSION (Build $CURRENT_PROJECT_VERSION)"
print_success "Version information retrieved"

# Step 5: Clean build
print_step "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
cd "$PROJECT_DIR/ios"
xcodebuild clean -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -configuration Release > /dev/null 2>&1
cd "$PROJECT_DIR"
print_success "Build cleaned"

# Step 6: Build archive
print_step "Building archive (this may take 2-5 minutes)..."
cd "$PROJECT_DIR/ios"

xcodebuild archive \
    -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$BUILD_DIR/derived" \
    2>&1 | grep -E "(Building|Compiling|Linking|Archive)" || true

if [ ! -d "$ARCHIVE_PATH" ]; then
    print_error "Archive creation failed"
    exit 1
fi

cd "$PROJECT_DIR"
print_success "Archive created: $ARCHIVE_PATH"

# Step 7: Export IPA
print_step "Exporting IPA file..."

mkdir -p "$EXPORT_DIR"

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$PROJECT_DIR/ios/ExportOptions.plist" \
    2>&1 | grep -E "(Exporting|Export)" || true

# Find the exported IPA
IPA_FILE=$(find "$EXPORT_DIR" -name "*.ipa" -type f | head -1)

if [ -z "$IPA_FILE" ] || [ ! -f "$IPA_FILE" ]; then
    print_error "IPA export failed"
    exit 1
fi

print_success "IPA exported: $(basename $IPA_FILE)"
print_success "Size: $(du -h "$IPA_FILE" | cut -f1)"

# Step 8: Upload to TestFlight
print_step "Uploading to TestFlight..."
echo ""
echo -e "${YELLOW}This will open Xcode Organizer for final upload.${NC}"
echo "Steps:"
echo "  1. Xcode Organizer window will appear"
echo "  2. Select your archive"
echo "  3. Click 'Distribute App'"
echo "  4. Choose 'TestFlight & App Store'"
echo "  5. Choose 'Distribute to App Store Connect'"
echo "  6. Review and click 'Upload'"
echo ""
read -p "Press Enter to continue with upload in Xcode Organizer..."

# Open Organizer to upload
open "xcode://open?path=$ARCHIVE_PATH"

echo ""
print_success "Organizer opened for upload"
echo ""
echo -e "${YELLOW}📋 Manual Steps Required:${NC}"
echo "  1. In Organizer, click 'Distribute App' for the archive"
echo "  2. Choose 'TestFlight & App Store'"
echo "  3. Choose 'Distribute to App Store Connect'"
echo "  4. Sign in as: rotabush@gmail.com"
echo "  5. Select 'Distribute to App Store Connect'"
echo "  6. Review code signing"
echo "  7. Click 'Upload'"
echo ""
echo -e "${YELLOW}⏱️  Processing:${NC}"
echo "  • Upload: ~5 minutes"
echo "  • Apple processing: ~5-15 minutes"
echo "  • TestFlight available: ~15-20 minutes"
echo ""

# Step 9: Provide next steps
print_step "Deployment information"
echo ""
echo -e "${BLUE}App Information:${NC}"
echo "  • Name: WhatsApp Photo Backup"
echo "  • Bundle ID: $BUNDLE_ID"
echo "  • Version: $MARKETING_VERSION"
echo "  • Build: $CURRENT_PROJECT_VERSION"
echo ""
echo -e "${BLUE}Artifact Location:${NC}"
echo "  • Archive: $ARCHIVE_PATH"
echo "  • IPA: $IPA_FILE"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Complete upload in Xcode Organizer"
echo "  2. Go to https://appstoreconnect.apple.com"
echo "  3. Go to TestFlight tab"
echo "  4. Find your build"
echo "  5. Add test information"
echo "  6. Add testers"
echo "  7. Submit for Beta App Review (if external)"
echo "  8. Release to testers"
echo ""

print_success "Build preparation complete!"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Your app is ready for TestFlight!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
