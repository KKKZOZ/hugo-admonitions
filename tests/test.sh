#!/bin/bash

# Test script for hugo-admonitions
# This script builds a test Hugo site and validates that admonitions render correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$SCRIPT_DIR"
BUILD_DIR="$TEST_DIR/public"
CONTENT_DIR="$TEST_DIR/test-cases"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo -e "${RED}Error: Hugo is not installed or not in PATH${NC}"
    echo "Please install Hugo v0.140.0 or later: https://gohugo.io/installation/"
    exit 1
fi

# Check Hugo version
HUGO_VERSION=$(hugo version | grep -oP 'v\d+\.\d+\.\d+' | head -1)
MIN_VERSION="0.140.0"

echo -e "${YELLOW}Testing with Hugo $HUGO_VERSION${NC}"

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Create content directory structure
mkdir -p "$CONTENT_DIR"

# Build the site
echo -e "${YELLOW}Building test site...${NC}"
cd "$TEST_DIR"
hugo --quiet

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Hugo build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build successful${NC}"

# Validate output
echo -e "${YELLOW}Validating output...${NC}"

ERRORS=0
WARNINGS=0

# Check that HTML files were generated
HTML_FILES=$(find "$BUILD_DIR" -name "*.html" -type f | wc -l | tr -d ' ')

if [ "$HTML_FILES" -eq "0" ]; then
    echo -e "${RED}✗ Error: No HTML files were generated${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Generated $HTML_FILES HTML file(s)${NC}"
fi

# Check for admonition classes in output
ADMONITION_COUNT=$(grep -r "class=\"admonition" "$BUILD_DIR" 2>/dev/null | wc -l | tr -d ' ')

if [ "$ADMONITION_COUNT" -eq "0" ]; then
    echo -e "${YELLOW}⚠ Warning: No admonition classes found in output${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ Found $ADMONITION_COUNT admonition(s) in output${NC}"
fi

# Check for blockquote fallback (should exist for invalid types)
BLOCKQUOTE_COUNT=$(grep -r "<blockquote>" "$BUILD_DIR" 2>/dev/null | wc -l | tr -d ' ')

if [ "$BLOCKQUOTE_COUNT" -gt "0" ]; then
    echo -e "${GREEN}✓ Found $BLOCKQUOTE_COUNT regular blockquote(s) (expected for fallbacks)${NC}"
fi

# Check for specific test cases
echo -e "${YELLOW}Checking specific test cases...${NC}"

# Test Case: Blockquote before admonition should not cause errors
if grep -r "blockquote-before-admonition" "$BUILD_DIR" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Blockquote before admonition test case rendered${NC}"
else
    echo -e "${RED}✗ Error: Blockquote before admonition test case not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check that no error messages are in the HTML
if grep -ri "error\|Error\|ERROR" "$BUILD_DIR"/*.html 2>/dev/null | grep -v "DOCTYPE\|DOCTYPE html" > /dev/null; then
    echo -e "${YELLOW}⚠ Warning: Potential error messages found in HTML${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "=========================================="
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ Tests failed with $ERRORS error(s)${NC}"
    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
    fi
    exit 1
fi

