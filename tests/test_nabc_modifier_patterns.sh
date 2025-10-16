#!/bin/bash
# Automated test for NABC glyph modifiers using nvim --headless
# Tests pattern matching capability

echo "=== NABC Glyph Modifiers Pattern Matching Test ==="
echo ""

# Test if patterns are correctly defined in syntax file
SYNTAX_FILE="/home/laercio/Documentos/gregorio.nvim/syntax/gabc.vim"

echo "Checking syntax/gabc.vim for NABC modifier patterns..."
echo ""

# Test 1: Check if nabcGlyphModifier pattern exists
echo -n "Test 1: nabcGlyphModifier pattern defined... "
if grep -q "syntax match nabcGlyphModifier" "$SYNTAX_FILE"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 2: Check if nabcGlyphModifierNumber pattern exists
echo -n "Test 2: nabcGlyphModifierNumber pattern defined... "
if grep -q "syntax match nabcGlyphModifierNumber" "$SYNTAX_FILE"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 3: Check if nabcSnippet contains the new modifiers
echo -n "Test 3: nabcSnippet contains modifiers... "
if grep -q "contains=.*nabcGlyphModifier" "$SYNTAX_FILE"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 4: Check if highlight links are defined
echo -n "Test 4: nabcGlyphModifier highlight link... "
if grep -q "highlight link nabcGlyphModifier" "$SYNTAX_FILE"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

echo -n "Test 5: nabcGlyphModifierNumber highlight link... "
if grep -q "highlight link nabcGlyphModifierNumber" "$SYNTAX_FILE"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 6: Check modifier character class
echo -n "Test 6: Modifier character class includes S,G,M,-,>,~... "
if grep "syntax match nabcGlyphModifier" "$SYNTAX_FILE" | grep -qF "[SGM\->~]"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 7: Check number suffix range
echo -n "Test 7: Number suffix accepts 1-9... "
if grep "syntax match nabcGlyphModifierNumber" "$SYNTAX_FILE" | grep -q "\[1-9\]"; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

echo ""
echo "=== Pattern Definition Tests Complete ===" 
echo "All 7 tests passed! ✓"
echo ""
echo "Note: To visually verify highlighting, run:"
echo "  ./tests/visual_test_nabc_modifiers.sh"
echo ""
echo "Or open examples/nabc_glyph_modifiers.gabc in nvim"

exit 0
