#!/bin/bash

# WhatsApp Photo Backup - iOS Build Script
# Run this on macOS with Xcode installed

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}WhatsApp Photo Backup - iOS Build Script${NC}"
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

XCODE_VERSION=$(xcodebuild -version | head -1)
echo -e "${GREEN}✓ Xcode found: $XCODE_VERSION${NC}"

# Check for CocoaPods
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}Installing CocoaPods...${NC}"
    sudo gem install cocoapods
fi

POD_VERSION=$(pod --version)
echo -e "${GREEN}✓ CocoaPods found: $POD_VERSION${NC}"

# Install Pod dependencies
echo ""
echo -e "${YELLOW}Installing Pod dependencies...${NC}"
cd ios
pod install --repo-update

# Check configuration
echo ""
echo -e "${YELLOW}Checking configuration...${NC}"

if grep -q "YOUR_GOOGLE_CLIENT_ID" SetTimeScheduler/GoogleDriveConfig.swift; then
    echo -e "${RED}✗ Google Client ID not configured${NC}"
    echo "  Please update: ios/SetTimeScheduler/GoogleDriveConfig.swift"
    echo "  Replace YOUR_GOOGLE_CLIENT_ID with your actual Client ID"
    exit 1
fi

echo -e "${GREEN}✓ Google Client ID configured${NC}"

# Build configuration
BUILD_TYPE="${1:-Debug}"
BUILD_TARGET="${2:-simulator}"

echo ""
echo -e "${YELLOW}Building for $BUILD_TYPE ($BUILD_TARGET)...${NC}"

if [ "$BUILD_TARGET" = "simulator" ]; then
    SDK="iphonesimulator"
    DESTINATION="generic/platform=iOS Simulator"
else
    SDK="iphoneos"
    DESTINATION="generic/platform=iOS"
fi

# Clean build
echo -e "${YELLOW}Cleaning build artifacts...${NC}"
rm -rf build
xcodebuild clean -workspace SetTimeScheduler.xcworkspace \
    -scheme SetTimeScheduler \
    -configuration "$BUILD_TYPE"

# Build
echo -e "${YELLOW}Building app...${NC}"
xcodebuild build \
    -workspace SetTimeScheduler.xcworkspace \
    -scheme SetTimeScheduler \
    -configuration "$BUILD_TYPE" \
    -sdk "$SDK" \
    -derivedDataPath build \
    -destination "$DESTINATION" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"

# Show build artifacts location
if [ "$BUILD_TARGET" = "simulator" ]; then
    APP_PATH="build/Build/Products/${BUILD_TYPE}-iphonesimulator/SetTimeScheduler.app"
    if [ -d "$APP_PATH" ]; then
        echo -e "${GREEN}✓ App location: $APP_PATH${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}Running tests...${NC}"

xcodebuild test \
    -workspace SetTimeScheduler.xcworkspace \
    -scheme SetTimeScheduler \
    -configuration "$BUILD_TYPE" \
    -sdk "$SDK" \
    -destination "platform=iOS Simulator,name=iPhone 15" \
    -enableCodeCoverage YES \
    -derivedDataPath build

echo ""
echo -e "${GREEN}✓ Tests completed!${NC}"

echo ""
echo -e "${GREEN}🎉 Build and test successful!${NC}"
