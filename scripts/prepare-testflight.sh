#!/bin/bash

# WhatsApp Photo Backup - TestFlight Preparation Script
# Run this on macOS to prepare app for TestFlight submission

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}WhatsApp Photo Backup - TestFlight Preparation${NC}"
echo ""

# Check for macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script must be run on macOS${NC}"
    exit 1
fi

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ macOS detected${NC}"
echo -e "${GREEN}✓ Xcode found${NC}"
echo ""

# Step 1: Install Pods
echo -e "${YELLOW}Step 1: Installing CocoaPods dependencies...${NC}"
cd ios
if ! command -v pod &> /dev/null; then
    echo -e "${RED}Error: CocoaPods not installed${NC}"
    echo "Run: sudo gem install cocoapods"
    exit 1
fi

pod install --repo-update
echo -e "${GREEN}✓ Pods installed${NC}"
cd ..

# Step 2: Verify Configuration
echo ""
echo -e "${YELLOW}Step 2: Verifying configuration...${NC}"

if grep -q "YOUR_GOOGLE_CLIENT_ID" ios/whatsappScheduler/GoogleDriveConfig.swift; then
    echo -e "${RED}✗ Google Client ID not configured${NC}"
    echo "  Please update: ios/whatsappScheduler/GoogleDriveConfig.swift"
    echo "  Replace YOUR_GOOGLE_CLIENT_ID with your actual Client ID"
    exit 1
fi
echo -e "${GREEN}✓ Google Client ID configured${NC}"

# Step 3: Verify Bundle ID
echo -e "${YELLOW}Step 3: Checking bundle identifier...${NC}"
BUNDLE_ID="com.rotabush.whatsappphotobackup"
echo "Expected Bundle ID: $BUNDLE_ID"
echo "Please verify in Xcode:"
echo "  1. Select whatsappScheduler project"
echo "  2. Select whatsappScheduler target"
echo "  3. Go to General tab"
echo "  4. Bundle Identifier should be: $BUNDLE_ID"
echo ""

# Step 4: Run Code Verification
echo -e "${YELLOW}Step 4: Running code verification...${NC}"
scripts/verify-swift-code.sh
echo -e "${GREEN}✓ Code verification passed${NC}"

# Step 5: Clean Build
echo ""
echo -e "${YELLOW}Step 5: Cleaning build artifacts...${NC}"
cd ios
rm -rf build
xcodebuild clean -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -configuration Release
echo -e "${GREEN}✓ Build cleaned${NC}"
cd ..

# Step 6: Build for Testing
echo ""
echo -e "${YELLOW}Step 6: Building for TestFlight...${NC}"
cd ios
echo "Please select your iOS device (not simulator) in Xcode or via:"
echo "  xcode-select --reset"
echo ""

xcodebuild build-for-testing \
    -workspace whatsappScheduler.xcworkspace \
    -scheme whatsappScheduler \
    -configuration Release \
    -sdk iphoneos

echo -e "${GREEN}✓ Build successful${NC}"
cd ..

# Step 7: Ready for Archive
echo ""
echo -e "${GREEN}========== READY FOR ARCHIVE ==========${NC}"
echo ""
echo "Next steps:"
echo "1. Open Xcode:"
echo "   open ios/whatsappScheduler.xcworkspace"
echo ""
echo "2. Select whatsappScheduler target"
echo "3. Select your iOS device from top menu"
echo "4. Go to Product → Archive"
echo "5. Wait for build to complete"
echo "6. When Organizer opens, click 'Distribute App'"
echo "7. Choose 'TestFlight & App Store'"
echo "8. Follow the upload wizard"
echo ""
echo "Or use command line:"
echo "  cd ios"
echo "  xcodebuild archive ..."
echo ""
echo -e "${YELLOW}Important Reminders:${NC}"
echo "✓ Ensure bundle ID is: $BUNDLE_ID"
echo "✓ Verify signing team is: rotabush@gmail.com"
echo "✓ Update version number before each build"
echo "✓ Check Google Client ID is configured"
echo ""
echo -e "${GREEN}🎉 Preparation complete!${NC}"
