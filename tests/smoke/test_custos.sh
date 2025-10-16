#!/bin/bash

# Test script for GABC custos (end-of-line guide) syntax highlighting
# Tests pitch+ pattern for indicating next note on following line

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="$SCRIPT_DIR/custos_test.gabc"
SYNTAX_FILE="$SCRIPT_DIR/../../syntax/gabc.vim"

echo "========================================="
echo "GABC Custos Syntax Test"
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

# Test 1: Verify custos pattern is defined
echo "Test 1: Checking custos definition..."
if grep -q "gabcCustos" "$SYNTAX_FILE"; then
    echo "  ✓ gabcCustos syntax element defined"
else
    echo "  ❌ gabcCustos NOT defined"
    exit 1
fi
echo "✓ Test 1 PASSED: Custos pattern defined"
echo ""

# Test 2: Verify highlight link
echo "Test 2: Checking highlight link definition..."
if grep -q "highlight link gabcCustos Operator" "$SYNTAX_FILE"; then
    echo "  ✓ gabcCustos linked to Operator"
else
    echo "  ❌ gabcCustos highlight link incorrect or missing"
    exit 1
fi
echo "✓ Test 2 PASSED: Highlight link configured"
echo ""

# Test 3: Verify pattern matches pitch+ (lowercase only)
echo "Test 3: Checking pattern definition..."
if grep -q 'gabcCustos.*\[a-np\]+' "$SYNTAX_FILE"; then
    echo "  ✓ Custos pattern matches lowercase pitch+ (e.g., f+, g+)"
else
    echo "  ❌ Custos pattern incorrect or missing"
    exit 1
fi
echo "✓ Test 3 PASSED: Pattern matches lowercase pitch+ correctly"
echo ""

# Test 4: Verify containment
echo "Test 4: Checking containment in gabcSnippet..."
if grep "gabcCustos" "$SYNTAX_FILE" | grep -q "contained containedin=gabcSnippet"; then
    echo "  ✓ gabcCustos contained in gabcSnippet"
else
    echo "  ❌ gabcCustos NOT properly contained"
    exit 1
fi
echo "✓ Test 4 PASSED: Proper containment"
echo ""

# Test 5: Run Vim to check for syntax errors
echo "Test 5: Validating syntax file with Vim..."
if vim -u NONE -N -c "set runtimepath+=$SCRIPT_DIR/../.." -c "syntax on" -c "filetype plugin on" -c "edit $TEST_FILE" -c "qa!" 2>&1 | grep -i error; then
    echo "❌ Test 5 FAILED: Vim reported syntax errors"
    exit 1
else
    echo "✓ Test 5 PASSED: No Vim syntax errors"
fi
echo ""

# Test 6: Verify custos examples in test file (lowercase only)
echo "Test 6: Checking test file content..."
CUSTOS_COUNT=$(grep -o '[a-np]+' "$TEST_FILE" | wc -l)
if [ "$CUSTOS_COUNT" -gt 15 ]; then
    echo "  ✓ Test file contains $CUSTOS_COUNT custos examples (lowercase)"
else
    echo "  ❌ Test file has insufficient custos examples: $CUSTOS_COUNT"
    exit 1
fi
echo "✓ Test 6 PASSED: Test file has comprehensive examples"
echo ""

echo "========================================="
echo "✓ ALL TESTS PASSED"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Custos syntax element defined (lowercase pitches only)"
echo "  - Highlight linked to Operator"
echo "  - Pattern matches pitch+ correctly ([a-np]+)"
echo "  - Proper containment in gabcSnippet"
echo "  - No Vim syntax errors"
echo "  - $CUSTOS_COUNT test examples"
echo ""
