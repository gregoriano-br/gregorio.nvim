#!/bin/bash

# Test script for GABC separation bars syntax highlighting
# Tests divisio marks (bars) and their numeric suffixes and modifiers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="$SCRIPT_DIR/separation_bars_test.gabc"
SYNTAX_FILE="$SCRIPT_DIR/../../syntax/gabc.vim"

echo "========================================="
echo "GABC Separation Bars Syntax Test"
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

# Test 1: Verify all bar types are defined
echo "Test 1: Checking bar type definitions..."
REQUIRED_BARS=(
    "gabcBarDouble"
    "gabcBarDotted"
    "gabcBarMaior"
    "gabcBarMinor"
    "gabcBarMinima"
    "gabcBarMinimaOcto"
    "gabcBarVirgula"
    "gabcBarMinorSuffix"
    "gabcBarZeroSuffix"
)

ALL_BARS_FOUND=true
for bar in "${REQUIRED_BARS[@]}"; do
    if grep -q "$bar" "$SYNTAX_FILE"; then
        echo "  ✓ $bar defined"
    else
        echo "  ❌ $bar NOT defined"
        ALL_BARS_FOUND=false
    fi
done

if [ "$ALL_BARS_FOUND" = true ]; then
    echo "✓ Test 1 PASSED: All bar types defined"
else
    echo "❌ Test 1 FAILED: Some bar types missing"
    exit 1
fi
echo ""

# Test 2: Verify highlight links
echo "Test 2: Checking highlight link definitions..."
REQUIRED_HIGHLIGHTS=(
    "gabcBarDouble.*Special"
    "gabcBarDotted.*Special"
    "gabcBarMaior.*Special"
    "gabcBarMinor.*Special"
    "gabcBarMinima.*Special"
    "gabcBarMinimaOcto.*Special"
    "gabcBarVirgula.*Special"
    "gabcBarMinorSuffix.*Number"
    "gabcBarZeroSuffix.*Number"
)

ALL_HIGHLIGHTS_FOUND=true
for highlight in "${REQUIRED_HIGHLIGHTS[@]}"; do
    if grep -qE "highlight link $highlight" "$SYNTAX_FILE"; then
        echo "  ✓ $highlight linked"
    else
        echo "  ❌ $highlight NOT linked"
        ALL_HIGHLIGHTS_FOUND=false
    fi
done

if [ "$ALL_HIGHLIGHTS_FOUND" = true ]; then
    echo "✓ Test 2 PASSED: All highlight links defined"
else
    echo "❌ Test 2 FAILED: Some highlight links missing"
    exit 1
fi
echo ""

# Test 3: Verify pattern correctness (basic patterns)
echo "Test 3: Checking pattern definitions..."

# Check for compound bars first (higher precedence)
if grep -q 'syntax match gabcBarDouble /::/' "$SYNTAX_FILE"; then
    echo "  ✓ Double bar (::) pattern correct"
else
    echo "  ❌ Double bar (::) pattern incorrect or missing"
    exit 1
fi

if grep -q 'syntax match gabcBarDotted /:?/' "$SYNTAX_FILE"; then
    echo "  ✓ Dotted bar (:?) pattern correct"
else
    echo "  ❌ Dotted bar (:?) pattern incorrect or missing"
    exit 1
fi

# Check simple bars
if grep -q 'syntax match gabcBarMaior /:/' "$SYNTAX_FILE"; then
    echo "  ✓ Maior bar (:) pattern correct"
else
    echo "  ❌ Maior bar (:) pattern incorrect or missing"
    exit 1
fi

if grep -q 'syntax match gabcBarMinor /;/' "$SYNTAX_FILE"; then
    echo "  ✓ Minor bar (;) pattern correct"
else
    echo "  ❌ Minor bar (;) pattern incorrect or missing"
    exit 1
fi

if grep -q 'syntax match gabcBarMinima /,/' "$SYNTAX_FILE"; then
    echo "  ✓ Minima bar (,) pattern correct"
else
    echo "  ❌ Minima bar (,) pattern incorrect or missing"
    exit 1
fi

if grep -q 'syntax match gabcBarMinimaOcto' "$SYNTAX_FILE" && grep -q '/\\^/' "$SYNTAX_FILE"; then
    echo "  ✓ Minimis bar (^) pattern correct"
else
    echo "  ❌ Minimis bar (^) pattern incorrect or missing"
    exit 1
fi

if grep -q 'syntax match gabcBarVirgula /`/' "$SYNTAX_FILE"; then
    echo '  ✓ Virgula bar (`) pattern correct'
else
    echo '  ❌ Virgula bar (`) pattern incorrect or missing'
    exit 1
fi

echo "✓ Test 3 PASSED: All bar patterns defined correctly"
echo ""

# Test 4: Verify suffix patterns with lookbehind
echo "Test 4: Checking suffix pattern definitions..."

if grep -q 'gabcBarMinorSuffix' "$SYNTAX_FILE" && grep -q '\@<=' "$SYNTAX_FILE"; then
    echo "  ✓ Minor bar suffix (1-8) uses lookbehind"
else
    echo "  ❌ Minor bar suffix pattern incorrect or missing"
    exit 1
fi

if grep -q 'gabcBarZeroSuffix' "$SYNTAX_FILE" && grep -q '\@<=' "$SYNTAX_FILE"; then
    echo '  ✓ Zero suffix (,^`) uses lookbehind'
else
    echo '  ❌ Zero suffix pattern incorrect or missing'
    exit 1
fi

echo "✓ Test 4 PASSED: Suffix patterns use lookbehind correctly"
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

# Test 6: Verify contained context
echo "Test 6: Checking containment in gabcSnippet..."
BAR_PATTERNS=(
    "gabcBarDouble"
    "gabcBarDotted"
    "gabcBarMaior"
    "gabcBarMinor"
    "gabcBarMinima"
    "gabcBarMinimaOcto"
    "gabcBarVirgula"
    "gabcBarMinorSuffix"
    "gabcBarZeroSuffix"
)

ALL_CONTAINED=true
for pattern in "${BAR_PATTERNS[@]}"; do
    if grep "$pattern" "$SYNTAX_FILE" | grep -q "contained containedin=gabcSnippet"; then
        echo "  ✓ $pattern contained in gabcSnippet"
    else
        echo "  ❌ $pattern NOT properly contained"
        ALL_CONTAINED=false
    fi
done

if [ "$ALL_CONTAINED" = true ]; then
    echo "✓ Test 6 PASSED: All bars properly contained"
else
    echo "❌ Test 6 FAILED: Some bars not properly contained"
    exit 1
fi
echo ""

echo "========================================="
echo "✓ ALL TESTS PASSED"
echo "========================================="
echo ""
echo "Summary:"
echo "  - 9 bar syntax elements defined"
echo "  - All highlight links configured"
echo "  - Lookbehind patterns for suffixes"
echo "  - Proper containment in gabcSnippet"
echo "  - No Vim syntax errors"
echo ""
