#!/usr/bin/env node

/**
 * Test script for hugo-admonitions
 * This script builds a test Hugo site and validates that admonitions render correctly
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const SCRIPT_DIR = __dirname;
const PROJECT_ROOT = path.resolve(SCRIPT_DIR, '..');
const TEST_DIR = SCRIPT_DIR;
const BUILD_DIR = path.join(TEST_DIR, 'public');
const CONTENT_DIR = path.join(TEST_DIR, 'test-cases');

// Colors for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkHugoInstalled() {
  try {
    execSync('hugo version', { stdio: 'ignore' });
    return true;
  } catch (error) {
    return false;
  }
}

function getHugoVersion() {
  try {
    const output = execSync('hugo version', { encoding: 'utf-8' });
    const match = output.match(/v(\d+\.\d+\.\d+)/);
    return match ? match[1] : 'unknown';
  } catch (error) {
    return 'unknown';
  }
}

function countFiles(dir, extension) {
  if (!fs.existsSync(dir)) {
    return 0;
  }
  
  let count = 0;
  const files = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const file of files) {
    const filePath = path.join(dir, file.name);
    if (file.isDirectory()) {
      count += countFiles(filePath, extension);
    } else if (file.name.endsWith(extension)) {
      count++;
    }
  }
  
  return count;
}

function searchInFiles(dir, pattern, excludePattern = null) {
  if (!fs.existsSync(dir)) {
    return [];
  }
  
  const results = [];
  const files = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const file of files) {
    const filePath = path.join(dir, file.name);
    if (file.isDirectory()) {
      results.push(...searchInFiles(filePath, pattern, excludePattern));
    } else if (file.name.endsWith('.html')) {
      try {
        const content = fs.readFileSync(filePath, 'utf-8');
        if (excludePattern && excludePattern.test(content)) {
          continue;
        }
        if (pattern.test(content)) {
          results.push(filePath);
        }
      } catch (error) {
        // Skip files that can't be read
      }
    }
  }
  
  return results;
}

function countMatches(dir, pattern) {
  const files = searchInFiles(dir, pattern);
  let totalMatches = 0;
  
  for (const file of files) {
    try {
      const content = fs.readFileSync(file, 'utf-8');
      const matches = content.match(pattern);
      if (matches) {
        totalMatches += matches.length;
      }
    } catch (error) {
      // Skip files that can't be read
    }
  }
  
  return totalMatches;
}

function main() {
  log('==========================================', 'yellow');
  log('Hugo Admonitions Test Suite', 'yellow');
  log('==========================================', 'yellow');
  log('');

  // Check if Hugo is installed
  if (!checkHugoInstalled()) {
    log('✗ Error: Hugo is not installed or not in PATH', 'red');
    log('Please install Hugo v0.140.0 or later: https://gohugo.io/installation/', 'red');
    process.exit(1);
  }

  const hugoVersion = getHugoVersion();
  log(`Testing with Hugo v${hugoVersion}`, 'yellow');
  log('');

  // Clean previous build
  if (fs.existsSync(BUILD_DIR)) {
    log('Cleaning previous build...', 'yellow');
    fs.rmSync(BUILD_DIR, { recursive: true, force: true });
  }

  // Build the site
  log('Building test site...', 'yellow');
  try {
    execSync('hugo --quiet', {
      cwd: TEST_DIR,
      stdio: 'inherit',
    });
    log('✓ Build successful', 'green');
  } catch (error) {
    log('✗ Error: Hugo build failed', 'red');
    process.exit(1);
  }

  log('');
  log('Validating output...', 'yellow');

  let errors = 0;
  let warnings = 0;

  // Check that HTML files were generated
  const htmlFiles = countFiles(BUILD_DIR, '.html');
  if (htmlFiles === 0) {
    log('✗ Error: No HTML files were generated', 'red');
    errors++;
  } else {
    log(`✓ Generated ${htmlFiles} HTML file(s)`, 'green');
  }

  // Check for admonition classes in output
  const admonitionCount = countMatches(BUILD_DIR, /class="admonition/g);
  if (admonitionCount === 0) {
    log('⚠ Warning: No admonition classes found in output', 'yellow');
    warnings++;
  } else {
    log(`✓ Found ${admonitionCount} admonition(s) in output`, 'green');
  }

  // Check for blockquote fallback (should exist for invalid types)
  const blockquoteCount = countMatches(BUILD_DIR, /<blockquote>/g);
  if (blockquoteCount > 0) {
    log(`✓ Found ${blockquoteCount} regular blockquote(s) (expected for fallbacks)`, 'green');
  }

  // Check for specific test cases
  log('');
  log('Checking specific test cases...', 'yellow');

  // Test Case: Blockquote before admonition should not cause errors
  const testCaseFiles = searchInFiles(BUILD_DIR, /blockquote-before-admonition/i);
  if (testCaseFiles.length > 0) {
    log('✓ Blockquote before admonition test case rendered', 'green');
  } else {
    log('✗ Error: Blockquote before admonition test case not found', 'red');
    errors++;
  }

  // Check that no error messages are in the HTML (excluding DOCTYPE)
  const errorFiles = searchInFiles(
    BUILD_DIR,
    /\b(error|Error|ERROR)\b/i,
    /DOCTYPE/i
  );
  if (errorFiles.length > 0) {
    log('⚠ Warning: Potential error messages found in HTML', 'yellow');
    warnings++;
  }

  // Summary
  log('');
  log('==========================================', 'yellow');
  if (errors === 0) {
    log('✓ All tests passed!', 'green');
    if (warnings > 0) {
      log(`⚠ ${warnings} warning(s)`, 'yellow');
    }
    process.exit(0);
  } else {
    log(`✗ Tests failed with ${errors} error(s)`, 'red');
    if (warnings > 0) {
      log(`⚠ ${warnings} warning(s)`, 'yellow');
    }
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { main };

