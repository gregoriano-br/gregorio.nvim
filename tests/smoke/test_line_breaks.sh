#!/bin/bash

# Test script for GABC line breaks syntax highlighting
# Tests z/Z (justified/ragged) with suffixes +/-/0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="$SCRIPT_DIR/line_breaks_test.gabc"
SYNTAX_FILE="$SCRIPT_DIR/../../syntax/gabc.vim"

echo "========================================="
echo "GABC Line Breaks Syntax Test"
echo "========================================="
echo ""

# Check if test file exists
if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Test file not found: $TEST_FILE"
    exit 1
fi

# Check if syntax file exists
if [ ! -f "$SYNTAX_FILE" ]; then
    echo "❌ Syntax file not found: $SYNTAX_FILE"
    exit 1
fi

echo "✓ Test file: $TEST_FILE"
echo "✓ Syntax file: $SYNTAX_FILE"
echo ""

# Test 1: Verify line break base symbols defined
echo "Test 1: Checking line break base definitions..."
if grep -q "gabcLineBreak" "$SYNTAX_FILE"; then
    echo "  ✓ gabcLineBreak syntax element defined"
else
    echo "  ❌ gabcLineBreak NOT defined"
    exit 1
fi

if grep -q "gabcLineBreakSuffix" "$SYNTAX_FILE"; then
    echo "  ✓ gabcLineBreakSuffix syntax element defined"
else
    echo "  ❌ gabcLineBreakSuffix NOT defined"
    exit 1
fi
echo "✓ Test 1 PASSED: Line break elements defined"
echo ""

# Test 2: Verify highlight links
echo "Test 2: Checking highlight link definitions..."
if grep -q "highlight link gabcLineBreak Statement" "$SYNTAX_FILE"; then
    echo "  ✓ gabcLineBreak linked to Statement"
else
    echo "  ❌ gabcLineBreak highlight link incorrect or missing"
    exit 1
fi

if grep -q "highlight link gabcLineBreakSuffix Identifier" "$SYNTAX_FILE"; then
    echo "  ✓ gabcLineBreakSuffix linked to Identifier"
else
    echo "  ❌ gabcLineBreakSuffix highlight link incorrect or missing"
    exit 1
fi
echo "✓ Test 2 PASSED: Highlight links configured"
echo ""

# Test 3: Verify base pattern matches z and Z
echo "Test 3: Checking base pattern definition..."
if grep -q 'gabcLineBreak.*\[zZ\]' "$SYNTAX_FILE"; then
    echo "  ✓ Line break pattern matches z and Z"
else
    echo "  ❌ Line break base pattern incorrect or missing"
    exit 1
fi
echo "✓ Test 3 PASSED: Base pattern matches z/Z correctly"
echo ""

# Test 4: Verify suffix patterns with lookbehind
echo "Test 4: Checking suffix pattern definitions..."
if grep "gabcLineBreakSuffix" "$SYNTAX_FILE" | grep -q '\@<='; then
    echo "  ✓ Line break suffixes use lookbehind"
else
    echo "  ❌ Suffix pattern missing lookbehind"
    exit 1
fi

# Check for +/- suffix
if grep -q 'gabcLineBreakSuffix.*\[+-\]' "$SYNTAX_FILE"; then
    echo "  ✓ Plus/minus suffix pattern defined"
else
    echo "  ❌ Plus/minus suffix pattern missing"
    exit 1
fi

# Check for 0 suffix (z only)
if grep 'gabcLineBreakSuffix' "$SYNTAX_FILE" | grep -q 'z.*0'; then
    echo "  ✓ Zero suffix pattern defined (z only)"
else
    echo "  ❌ Zero suffix pattern missing or incorrect"
    exit 1
fi
echo "✓ Test 4 PASSED: Suffix patterns use lookbehind correctly"
echo ""

# Test 5: Verify containment
echo "Test 5: Checking containment in gabcSnippet..."
if grep "gabcLineBreak" "$SYNTAX_FILE" | grep -q "contained containedin=gabcSnippet"; then
    echo "  ✓ gabcLineBreak contained in gabcSnippet"
else
    echo "  ❌ gabcLineBreak NOT properly contained"
    exit 1
fi

if grep "gabcLineBreakSuffix" "$SYNTAX_FILE" | grep -q "contained containedin=gabcSnippet"; then
    echo "  ✓ gabcLineBreakSuffix contained in gabcSnippet"
else
    echo "  ❌ gabcLineBreakSuffix NOT properly contained"
    exit 1
fi
echo "✓ Test 5 PASSED: Proper containment"
echo ""

# Test 6: Run Vim to check for syntax errors
echo "Test 6: Validating syntax file with Vim..."
if vim -u NONE -N -c "set runtimepath+=$SCRIPT_DIR/../.." -c "syntax on" -c "filetype plugin on" -c "edit $TEST_FILE" -c "qa!" 2>&1 | grep -i error; then
    echo "❌ Test 6 FAILED: Vim reported syntax errors"
    exit 1
else
    echo "✓ Test 6 PASSED: No Vim syntax errors"
fi
echo ""

# Test 7: Verify test file content
echo "Test 7: Checking test file content..."
Z_COUNT=$(grep -o ' z' "$TEST_FILE" | wc -l)
Z_CAP_COUNT=$(grep -o ' Z' "$TEST_FILE" | wc -l)
TOTAL_BREAKS=$((Z_COUNT + Z_CAP_COUNT))

if [ "$TOTAL_BREAKS" -gt 20 ]; then
    echo "  ✓ Test file contains $TOTAL_BREAKS line break examples"
    echo "    - lowercase z: $Z_COUNT"
    echo "    - uppercase Z: $Z_CAP_COUNT"
else
    echo "  ❌ Test file has insufficient line break examples: $TOTAL_BREAKS"
    exit 1
fi
echo "✓ Test 7 PASSED: Test file has comprehensive examples"
echo ""

echo "========================================="
echo "✓ ALL TESTS PASSED"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Line break syntax elements defined (z/Z)"
echo "  - Highlight linked (Statement for z/Z, Identifier for suffixes)"
echo "  - Suffixes with lookbehind (+/- for both, 0 for z only)"
echo "  - Proper containment in gabcSnippet"
echo "  - No Vim syntax errors"
echo "  - $TOTAL_BREAKS test examples (z: $Z_COUNT, Z: $Z_CAP_COUNT)"
echo ""
