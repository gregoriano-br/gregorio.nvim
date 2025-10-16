#!/usr/bin/env bash
# Test: Specialized pitch attributes syntax validation
# Verifies that semantic attribute types are properly highlighted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_FILE="$PROJECT_ROOT/tests/specialized_attributes_test.gabc"

echo "Testing specialized pitch attributes syntax..."

# Test 1: Verify all specialized attribute patterns are defined
echo "✓ Checking specialized attribute pattern definitions..."

REQUIRED_PATTERNS=(
    "gabcAttrChoralSign"
    "gabcAttrChoralNabc"
    "gabcAttrBrace"
    "gabcAttrStemLength"
    "gabcAttrLedgerLines"
    "gabcAttrSlur"
    "gabcAttrEpisemaTune"
    "gabcAttrAboveLinesText"
    "gabcAttrVerbatimNote"
    "gabcAttrVerbatimGlyph"
    "gabcAttrVerbatimElement"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if grep -q "syntax.*$pattern" "$PROJECT_ROOT/syntax/gabc.vim"; then
        echo "  ✓ $pattern pattern defined"
    else
        echo "  ✗ ERROR: $pattern pattern not found"
        exit 1
    fi
done

# Test 2: Verify all highlight links are correct
echo "✓ Checking specialized attribute highlight links..."

HIGHLIGHT_CHECKS=(
    "gabcAttrChoralSign:Type"
    "gabcAttrChoralNabc:Type"
    "gabcAttrBrace:Function"
    "gabcAttrStemLength:Number"
    "gabcAttrLedgerLines:Function"
    "gabcAttrSlur:Function"
    "gabcAttrEpisemaTune:Number"
    "gabcAttrAboveLinesText:String"
    "gabcAttrVerbatimDelim:Special"
)

for check in "${HIGHLIGHT_CHECKS[@]}"; do
    pattern="${check%%:*}"
    expected="${check##*:}"
    if grep -q "highlight link $pattern $expected" "$PROJECT_ROOT/syntax/gabc.vim"; then
        echo "  ✓ $pattern → $expected"
    else
        echo "  ✗ ERROR: $pattern highlight link incorrect or missing"
        exit 1
    fi
done

# Test 3: Verify specialized attributes are in gabcSnippet contains list
echo "✓ Verifying specialized attributes in gabcSnippet contains list..."

CONTAINS_LINE=$(grep -A 1 'syntax match gabcSnippet' "$PROJECT_ROOT/syntax/gabc.vim" | tr '\n' ' ')

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if echo "$CONTAINS_LINE" | grep -q "$pattern"; then
        echo "  ✓ $pattern in contains list"
    else
        echo "  ✗ ERROR: $pattern missing from gabcSnippet contains list"
        exit 1
    fi
done

# Test 4: Verify test file has examples of all attribute types
echo "✓ Checking test file coverage..."

TEST_ATTRIBUTES=(
    "\[cs:"
    "\[cn:"
    "\[ob:"
    "\[ub:"
    "\[ocb:"
    "\[ocba:"
    "\[ll:"
    "\[oll:"
    "\[ull:"
    "\[oslur:"
    "\[uslur:"
    "\[oh:"
    "\[uh:"
    "\[alt:"
    "\[nv:"
    "\[gv:"
    "\[ev:"
)

for attr in "${TEST_ATTRIBUTES[@]}"; do
    count=$(grep -c "$attr" "$TEST_FILE" || true)
    if [ "$count" -gt 0 ]; then
        echo "  ✓ $attr found ($count examples)"
    else
        echo "  ✗ ERROR: No examples of $attr in test file"
        exit 1
    fi
done

# Test 5: Verify verbatim TeX attributes use @texSyntax
echo "✓ Verifying verbatim TeX syntax integration..."

for tex_attr in "gabcAttrVerbatimNote" "gabcAttrVerbatimGlyph" "gabcAttrVerbatimElement"; do
    if grep "syntax region $tex_attr" "$PROJECT_ROOT/syntax/gabc.vim" | grep -q "@texSyntax"; then
        echo "  ✓ $tex_attr includes @texSyntax"
    else
        echo "  ✗ ERROR: $tex_attr missing @texSyntax"
        exit 1
    fi
done

# Test 6: Verify specialized attributes defined BEFORE generic
echo "✓ Verifying pattern precedence (specialized before generic)..."

SPECIALIZED_LINE=$(grep -n "^syntax match gabcAttrChoralSign" "$PROJECT_ROOT/syntax/gabc.vim" | head -1 | cut -d: -f1)
GENERIC_LINE=$(grep -n "^syntax match gabcPitchAttrBracket" "$PROJECT_ROOT/syntax/gabc.vim" | head -1 | cut -d: -f1)

if [ "$SPECIALIZED_LINE" -lt "$GENERIC_LINE" ]; then
    echo "  ✓ Specialized attributes (line $SPECIALIZED_LINE) before generic (line $GENERIC_LINE)"
else
    echo "  ✗ ERROR: Generic attributes defined before specialized (precedence issue)"
    exit 1
fi

# Test 7: Count total attribute examples in test file
echo "✓ Counting test coverage..."

TOTAL_SPECIALIZED=$(grep -o '\[[a-z]\+:' "$TEST_FILE" | wc -l)
CHORAL_SIGNS=$(grep -c '\[cs:' "$TEST_FILE" || true)
BRACES=$(grep -c '\[.*b:' "$TEST_FILE" || true)
VERBATIM_TEX=$(grep -c '\[[neg]v:' "$TEST_FILE" || true)

echo "  ✓ Total specialized attributes: $TOTAL_SPECIALIZED"
echo "  ✓ Choral signs (cs/cn): $CHORAL_SIGNS"
echo "  ✓ Braces (ob/ub/ocb/ocba): $BRACES"
echo "  ✓ Verbatim TeX (nv/gv/ev): $VERBATIM_TEX"

# Test 8: Verify no Vim syntax errors
echo "✓ Checking for Vim syntax errors..."

if command -v vim >/dev/null 2>&1; then
    if vim -u NONE -c "set runtimepath+=$PROJECT_ROOT" -c "syntax on" -c "set filetype=gabc" \
        -c "source $PROJECT_ROOT/syntax/gabc.vim" -c "quit" "$TEST_FILE" 2>&1 | grep -i error; then
        echo "  ✗ ERROR: Vim reported syntax errors"
        exit 1
    else
        echo "  ✓ No Vim syntax errors detected"
    fi
else
    echo "  ⚠ Vim not found, skipping syntax error check"
fi

echo ""
echo "✅ ALL TESTS PASSED"
echo ""
echo "Summary:"
echo "- 11 specialized attribute patterns defined"
echo "- 9 highlight links configured correctly"
echo "- All attributes in gabcSnippet contains list"
echo "- 17 different attribute types tested"
echo "- $TOTAL_SPECIALIZED total attribute examples in test file"
echo "- Verbatim TeX attributes include LaTeX syntax highlighting"
echo "- Specialized patterns have precedence over generic patterns"
