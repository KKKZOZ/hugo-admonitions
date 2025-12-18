# Hugo Admonitions Test Suite

This directory contains a comprehensive test suite for the hugo-admonitions module, including tests for the blockquote-before-admonition fix (Issue #43).

## Overview

The test suite validates that:
- Admonitions render correctly in various scenarios
- Blockquotes preceding admonitions don't cause rendering errors
- Edge cases (invalid types, empty values) are handled gracefully
- All admonition types work as expected

## Prerequisites

- **Hugo v0.140.0 or later** - Required for extended blockquote syntax
- **Node.js** (optional, for Node.js test script)
- **Bash** (optional, for shell test script)

## Running Tests

### Using Node.js (Recommended)

```bash
npm test
```

Or directly:

```bash
node tests/test.js
```

### Using Bash

```bash
npm run test:bash
```

Or directly:

```bash
bash tests/test.sh
```

## Test Cases

### Blockquote Before Admonition (`blockquote-before-admonition.md`)

Tests the fix for [Issue #43](https://github.com/KKKZOZ/hugo-admonitions/issues/43):

- ✅ Blockquote immediately before admonition
- ✅ Blockquote with text between
- ✅ Multiple blockquotes before admonition
- ✅ Blockquote with blank line before admonition
- ✅ Normal admonition (baseline)

### Edge Cases (`edge-cases.md`)

Tests various edge cases and error handling:

- ✅ Invalid AlertType fallback to regular blockquote
- ✅ Empty AlertType handling
- ✅ All valid admonition types
- ✅ Foldable admonitions (with `-` and `+` signs)
- ✅ Admonitions with custom titles

## Test Structure

```
tests/
├── README.md                    # This file
├── hugo.toml                    # Hugo configuration for tests
├── test.sh                      # Bash test script
├── test.js                      # Node.js test script
├── test-cases/                  # Test markdown files
│   ├── blockquote-before-admonition.md
│   └── edge-cases.md
├── layouts/                     # Minimal layouts for testing
│   └── _default/
│       └── single.html
└── public/                      # Generated output (gitignored)
```

## What the Tests Validate

1. **Build Success**: Hugo builds without errors
2. **HTML Generation**: HTML files are generated correctly
3. **Admonition Rendering**: Admonitions are rendered with proper CSS classes
4. **Fallback Handling**: Invalid admonition types fall back to regular blockquotes
5. **No Errors**: No error messages appear in the generated HTML

## Adding New Tests

To add new test cases:

1. Create a new markdown file in `tests/test-cases/`
2. Add test scenarios with various edge cases
3. Run the test suite to ensure they pass
4. Update this README if needed

## Continuous Integration

These tests can be integrated into CI/CD pipelines. The test scripts exit with:
- `0` on success
- `1` on failure

Example GitHub Actions workflow:

```yaml
- name: Run tests
  run: npm test
```

## Troubleshooting

### Hugo not found

Make sure Hugo is installed and in your PATH:

```bash
hugo version
```

### Build failures

Check that:
- Hugo version is 0.140.0 or later
- All required files are present
- No syntax errors in test markdown files

### Test failures

If tests fail:
1. Check the error messages in the test output
2. Verify the generated HTML in `tests/public/`
3. Ensure the render hook template is correct
4. Check that all required partials exist

