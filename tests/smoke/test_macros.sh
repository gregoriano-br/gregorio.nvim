#!/usr/bin/env bash
# Test script for GABC macro syntax highlighting
# Tests that all macro patterns (nm0-9, gm0-9, em0-9) are properly defined and highlighted

set -e

SYNTAX_FILE="syntax/gabc.vim"
TEST_FILE="tests/macros_test.gabc"

echo "=========================================="
echo "GABC Macro Syntax Validation Tests"
echo "=========================================="
echo ""

# Test 1: Verify all macro pattern definitions exist
echo "Test 1: Verify macro pattern definitions..."
if grep -q "syntax match gabcMacroNote" "$SYNTAX_FILE" && \
   grep -q "syntax match gabcMacroGlyph" "$SYNTAX_FILE" && \
   grep -q "syntax match gabcMacroElement" "$SYNTAX_FILE"; then
    echo "✓ All macro patterns defined (Note, Glyph, Element)"
else
    echo "✗ FAIL: Missing macro pattern definitions"
    exit 1
fi

# Test 2: Verify macro component patterns exist
echo ""
echo "Test 2: Verify macro component patterns..."
if grep -q "syntax match gabcMacroIdentifier" "$SYNTAX_FILE" && \
   grep -q "syntax match gabcMacroNumber" "$SYNTAX_FILE"; then
    echo "✓ Macro component patterns defined (Identifier, Number)"
else
    echo "✗ FAIL: Missing macro component patterns"
    exit 1
fi

# Test 3: Verify highlight links are correct
echo ""
echo "Test 3: Verify highlight links..."
IDENTIFIER_LINK=$(grep "highlight link gabcMacroIdentifier" "$SYNTAX_FILE" | awk '{print $4}')
NUMBER_LINK=$(grep "highlight link gabcMacroNumber" "$SYNTAX_FILE" | awk '{print $4}')

if [ "$IDENTIFIER_LINK" = "Function" ]; then
    echo "✓ gabcMacroIdentifier links to Function"
else
    echo "✗ FAIL: gabcMacroIdentifier should link to Function, got: $IDENTIFIER_LINK"
    exit 1
fi

if [ "$NUMBER_LINK" = "Number" ]; then
    echo "✓ gabcMacroNumber links to Number"
else
    echo "✗ FAIL: gabcMacroNumber should link to Number, got: $NUMBER_LINK"
    exit 1
fi

# Test 4: Verify macros are in gabcSnippet contains list
echo ""
echo "Test 4: Verify macros in gabcSnippet contains list..."
CONTAINS_LINE=$(grep "syntax match gabcSnippet" "$SYNTAX_FILE" | grep "contains=")

if echo "$CONTAINS_LINE" | grep -q "gabcMacroNote" && \
   echo "$CONTAINS_LINE" | grep -q "gabcMacroGlyph" && \
   echo "$CONTAINS_LINE" | grep -q "gabcMacroElement"; then
    echo "✓ All macro elements in gabcSnippet contains list"
else
    echo "✗ FAIL: Missing macro elements in gabcSnippet contains list"
    exit 1
fi

# Test 5: Verify test file has all macro types
echo ""
echo "Test 5: Verify test file coverage..."

NM_COUNT=$(grep -o "\[nm[0-9]\]" "$TEST_FILE" | wc -l)
GM_COUNT=$(grep -o "\[gm[0-9]\]" "$TEST_FILE" | wc -l)
EM_COUNT=$(grep -o "\[em[0-9]\]" "$TEST_FILE" | wc -l)

echo "   Note-level macros (nm): $NM_COUNT examples"
echo "   Glyph-level macros (gm): $GM_COUNT examples"
echo "   Element-level macros (em): $EM_COUNT examples"

if [ "$NM_COUNT" -ge 10 ] && [ "$GM_COUNT" -ge 10 ] && [ "$EM_COUNT" -ge 10 ]; then
    echo "✓ Test file has sufficient coverage (10+ of each type)"
else
    echo "✗ FAIL: Insufficient test coverage"
    exit 1
fi

# Test 6: Verify all digits 0-9 are tested for each macro type
echo ""
echo "Test 6: Verify all digits tested..."

for digit in {0..9}; do
    if ! grep -q "\[nm${digit}\]" "$TEST_FILE"; then
        echo "✗ FAIL: Missing test for [nm${digit}]"
        exit 1
    fi
    if ! grep -q "\[gm${digit}\]" "$TEST_FILE"; then
        echo "✗ FAIL: Missing test for [gm${digit}]"
        exit 1
    fi
    if ! grep -q "\[em${digit}\]" "$TEST_FILE"; then
        echo "✗ FAIL: Missing test for [em${digit}]"
        exit 1
    fi
done
echo "✓ All digits 0-9 tested for each macro type"

# Test 7: Verify pattern order (macros should be after verbatim TeX, before generic attributes)
echo ""
echo "Test 7: Verify pattern definition order..."

VERBATIM_LINE=$(grep -n "syntax region gabcAttrVerbatimElement" "$SYNTAX_FILE" | cut -d: -f1 | head -1)
MACRO_LINE=$(grep -n "syntax match gabcMacroNote" "$SYNTAX_FILE" | cut -d: -f1 | head -1)
GENERIC_LINE=$(grep -n "^syntax match gabcPitchAttrBracket" "$SYNTAX_FILE" | cut -d: -f1 | head -1)

echo "   VerbatimElement line: $VERBATIM_LINE"
echo "   MacroNote line: $MACRO_LINE"
echo "   GenericAttr line: $GENERIC_LINE"

if [ "$MACRO_LINE" -gt "$VERBATIM_LINE" ] && [ "$MACRO_LINE" -lt "$GENERIC_LINE" ]; then
    echo "✓ Macro patterns correctly positioned (after verbatim, before generic)"
else
    echo "✗ FAIL: Incorrect pattern order (macros should be after verbatim TeX, before generic attributes)"
    exit 1
fi

# Test 8: Verify no Vim syntax errors
echo ""
echo "Test 8: Verify no syntax errors..."
if nvim --headless --noplugin -u NONE -c "source $SYNTAX_FILE" -c "quit" 2>&1 | grep -q "Error"; then
    echo "✗ FAIL: Vim syntax errors detected"
    nvim --headless --noplugin -u NONE -c "source $SYNTAX_FILE" -c "quit" 2>&1
    exit 1
else
    echo "✓ No Vim syntax errors"
fi

echo ""
echo "=========================================="
echo "All macro syntax tests passed! ✓"
echo "=========================================="
