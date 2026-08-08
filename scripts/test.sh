#!/usr/bin/env bash
#
# Test script for hugo-admonitions
# Builds the docs site and validates HTML output
#
# Usage: ./scripts/test.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"
PUBLIC_DIR="$DOCS_DIR/public"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  hugo-admonitions Test Suite"
echo "=========================================="
echo ""

# Check Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo -e "${RED}ERROR: Hugo is not installed${NC}"
    echo "Install Hugo extended: https://gohugo.io/installation/"
    exit 1
fi

echo -e "${YELLOW}Hugo version:${NC}"
hugo version
echo ""

# Clean previous build
echo -e "${YELLOW}Cleaning previous build...${NC}"
rm -rf "$PUBLIC_DIR"

# Build the docs site
echo -e "${YELLOW}Building docs site...${NC}"
hugo --source "$DOCS_DIR"
echo ""

# Test 1: Verify HTML files exist
echo -e "${YELLOW}Test 1: Checking test HTML files exist...${NC}"
if [[ -f "$PUBLIC_DIR/test-blockquote-before-admonition/index.html" ]]; then
    echo -e "  ${GREEN}✓${NC} test-blockquote-before-admonition/index.html exists"
else
    echo -e "  ${RED}✗${NC} test-blockquote-before-admonition/index.html NOT FOUND"
    exit 1
fi

if [[ -f "$PUBLIC_DIR/test-edge-cases/index.html" ]]; then
    echo -e "  ${GREEN}✓${NC} test-edge-cases/index.html exists"
else
    echo -e "  ${RED}✗${NC} test-edge-cases/index.html NOT FOUND"
    exit 1
fi
echo ""

# Test 2: Verify admonition classes exist in output
echo -e "${YELLOW}Test 2: Checking admonition classes in HTML output...${NC}"
for class in "admonition note" "admonition warning" "admonition tip"; do
    if grep -R -q "class=\"$class\"" "$PUBLIC_DIR"; then
        echo -e "  ${GREEN}✓${NC} Found class=\"$class\""
    else
        echo -e "  ${RED}✗${NC} Missing class=\"$class\""
        exit 1
    fi
done
echo ""

# Test 3: Verify blockquote-before-admonition test has both elements
echo -e "${YELLOW}Test 3: Checking blockquote + admonition coexistence...${NC}"
BLOCKQUOTE_TEST="$PUBLIC_DIR/test-blockquote-before-admonition/index.html"

if grep -q '<blockquote' "$BLOCKQUOTE_TEST"; then
    echo -e "  ${GREEN}✓${NC} Found <blockquote> elements"
else
    echo -e "  ${RED}✗${NC} Missing <blockquote> elements"
    exit 1
fi

if grep -q 'class="admonition' "$BLOCKQUOTE_TEST"; then
    echo -e "  ${GREEN}✓${NC} Found admonition elements"
else
    echo -e "  ${RED}✗${NC} Missing admonition elements"
    exit 1
fi
echo ""

# Summary
echo "=========================================="
echo -e "  ${GREEN}All tests passed!${NC}"
echo "=========================================="
