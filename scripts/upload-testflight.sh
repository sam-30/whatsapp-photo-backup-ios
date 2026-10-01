#!/bin/bash

# WhatsApp Photo Backup - Automated TestFlight Upload
# Uses Apple's Transporter tool for command-line upload
# Requires: IPA file from deploy-testflight.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
EXPORT_DIR="$BUILD_DIR/ipa"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  WhatsApp Photo Backup - Automated TestFlight Upload       ║"
echo "║  Using Apple Transporter                                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Find IPA file
IPA_FILE=$(find "$EXPORT_DIR" -name "*.ipa" -type f | head -1)

if [ -z "$IPA_FILE" ] || [ ! -f "$IPA_FILE" ]; then
    echo -e "${RED}✗ IPA file not found${NC}"
    echo "  Run ./scripts/deploy-testflight.sh first to create IPA"
    exit 1
fi

echo -e "${YELLOW}▶ IPA File Found${NC}"
echo "  $IPA_FILE"
echo "  Size: $(du -h "$IPA_FILE" | cut -f1)"
echo ""

# Check for Transporter
if ! command -v xcrun &> /dev/null; then
    echo -e "${RED}✗ Xcode Command Line Tools not found${NC}"
    exit 1
fi

echo -e "${YELLOW}▶ Preparing for upload...${NC}"

# Create temporary package for upload
TEMP_DIR="/tmp/whatsapp-backup-upload"
mkdir -p "$TEMP_DIR"
cp "$IPA_FILE" "$TEMP_DIR/"

echo -e "${GREEN}✓ Ready for upload${NC}"
echo ""

# Provide upload instructions
echo -e "${YELLOW}▶ Upload Options${NC}"
echo ""
echo "Option 1: Automatic Upload (Recommended)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run this command:"
echo ""
echo "xcrun altool --upload-app -f \"$IPA_FILE\" \\"
echo "  -t ios \\"
echo "  -u rotabush@gmail.com \\"
echo "  -p \"<your-app-specific-password>\""
echo ""
echo ""
echo "Option 2: Using Transporter App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Open Transporter from Applications/Utilities"
echo "2. Click '+'"
echo "3. Select: $IPA_FILE"
echo "4. Click 'Deliver'"
echo "5. Sign in with: rotabush@gmail.com"
echo ""
echo ""
echo "Option 3: Using Xcode Organizer (Manual)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run: ./scripts/deploy-testflight.sh"
echo "This will open Xcode Organizer for manual upload"
echo ""

echo -e "${YELLOW}▶ Getting App-Specific Password${NC}"
echo ""
echo "If using automatic upload, you need an App-Specific Password:"
echo "1. Go to https://appleid.apple.com"
echo "2. Sign in with: rotabush@gmail.com"
echo "3. Go to Security → App Passwords"
echo "4. Generate new password for 'Apple Transporter'"
echo "5. Use the password with the upload command above"
echo ""

# Offer to run upload
read -p "Press Enter to open Transporter app, or Ctrl+C to exit: " -t 10 || true
echo ""

if command -v open &> /dev/null; then
    open -a Transporter
    echo -e "${GREEN}✓ Transporter opening...${NC}"
    echo ""
    echo "When Transporter opens:"
    echo "  1. Click '+' button"
    echo "  2. Select the IPA file"
    echo "  3. Click 'Deliver'"
    echo "  4. Sign in with: rotabush@gmail.com"
    echo "  5. Wait for upload to complete"
fi

echo ""
echo -e "${YELLOW}IPA Location: $IPA_FILE${NC}"
echo ""
echo "After upload:"
echo "  • Go to https://appstoreconnect.apple.com"
echo "  • Go to TestFlight tab"
echo "  • Find your build"
echo "  • Add test information"
echo "  • Add testers"
echo "  • Release build to testers"
echo ""
