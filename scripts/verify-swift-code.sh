#!/bin/bash

# Verify Swift code structure and syntax

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFT_FILES=(
    "ios/whatsappScheduler/WhatsAppPhotoManager.swift"
    "ios/whatsappScheduler/GoogleDriveManager.swift"
    "ios/whatsappScheduler/PhotoBackupService.swift"
    "ios/whatsappScheduler/BackupView.swift"
    "ios/whatsappScheduler/GoogleDriveConfig.swift"
    "ios/whatsappScheduler/BackupServiceTests.swift"
)

echo "=== Swift Code Verification ===="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

check_file() {
    local file="$1"
    local path="$PROJECT_DIR/$file"

    if [ ! -f "$path" ]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi

    # Check for basic Swift syntax
    if ! grep -q "^import" "$path"; then
        echo -e "${RED}✗ $file: Missing import statement${NC}"
        ((ERRORS++))
        return 1
    fi

    # Check for class or struct
    if ! grep -q "^\(class\|struct\) " "$path"; then
        echo -e "${YELLOW}⚠ $file: No class or struct definition found${NC}"
    fi

    # Check brace balance
    OPEN_BRACES=$(grep -o "{" "$path" | wc -l)
    CLOSE_BRACES=$(grep -o "}" "$path" | wc -l)

    if [ "$OPEN_BRACES" -ne "$CLOSE_BRACES" ]; then
        echo -e "${RED}✗ $file: Brace mismatch (open: $OPEN_BRACES, close: $CLOSE_BRACES)${NC}"
        ((ERRORS++))
        return 1
    fi

    # Check for syntax issues
    if grep -q "TODO\|FIXME\|XXX" "$path"; then
        TODOS=$(grep -c "TODO\|FIXME\|XXX" "$path")
        echo -e "${YELLOW}⚠ $file: Contains $TODOS TODO/FIXME comments${NC}"
    fi

    # Count lines
    LINE_COUNT=$(wc -l < "$path")

    # Report
    echo -e "${GREEN}✓ $file${NC} ($LINE_COUNT lines)"

    return 0
}

# Verify each file
for file in "${SWIFT_FILES[@]}"; do
    check_file "$file" || ((ERRORS++))
done

echo ""
echo "=== Code Metrics ===="
echo ""

# Total lines of code
TOTAL_LINES=$(wc -l "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null | tail -1 | awk '{print $1}')
echo "Total Swift Lines: $TOTAL_LINES"

# Count classes
CLASS_COUNT=$(grep -h "^class " "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null | wc -l)
echo "Classes: $CLASS_COUNT"

# Count structs
STRUCT_COUNT=$(grep -h "^struct " "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null | wc -l)
echo "Structs: $STRUCT_COUNT"

# Count enums
ENUM_COUNT=$(grep -h "^enum " "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null | wc -l)
echo "Enums: $ENUM_COUNT"

# Count functions
FUNC_COUNT=$(grep -h "func " "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null | wc -l)
echo "Functions: $FUNC_COUNT"

echo ""
echo "=== Dependencies Check ===="
echo ""

# Check for required imports
echo "Checking imports..."

REQUIRED_IMPORTS=(
    "Foundation"
    "Photos"
    "GoogleSignIn"
    "GoogleAPIClientForREST"
    "SwiftUI"
)

for import in "${REQUIRED_IMPORTS[@]}"; do
    if grep -q "import $import" "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null; then
        echo -e "${GREEN}✓ $import${NC}"
    else
        echo -e "${YELLOW}⚠ $import not found${NC}"
    fi
done

echo ""
echo "=== Error Handling ==="
echo ""

# Check for error types
ERROR_TYPES=(
    "WhatsAppError"
    "GoogleDriveError"
    "BackupError"
)

for error in "${ERROR_TYPES[@]}"; do
    if grep -q "enum $error" "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null; then
        echo -e "${GREEN}✓ $error defined${NC}"
    else
        echo -e "${RED}✗ $error not found${NC}"
        ((ERRORS++))
    fi
done

echo ""
echo "=== Service Classes ==="
echo ""

# Check for service classes
SERVICES=(
    "WhatsAppPhotoManager"
    "GoogleDriveManager"
    "PhotoBackupService"
)

for service in "${SERVICES[@]}"; do
    if grep -q "class $service" "$PROJECT_DIR"/ios/whatsappScheduler/*.swift 2>/dev/null; then
        echo -e "${GREEN}✓ $service defined${NC}"
    else
        echo -e "${RED}✗ $service not found${NC}"
        ((ERRORS++))
    fi
done

echo ""
echo "=== UI Components ==="
echo ""

# Check for SwiftUI views
if grep -q "struct BackupView: View" "$PROJECT_DIR"/ios/whatsappScheduler/BackupView.swift; then
    echo -e "${GREEN}✓ BackupView SwiftUI component${NC}"
else
    echo -e "${RED}✗ BackupView not found${NC}"
    ((ERRORS++))
fi

echo ""
echo "=== Summary ==="
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    exit 1
fi
