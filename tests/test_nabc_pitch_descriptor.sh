#!/bin/bash
# Test script for NABC pitch descriptor syntax highlighting

TEST_DIR=$(dirname "$0")
cd "$TEST_DIR/.." || exit 1

echo "=== Testing NABC Pitch Descriptor Syntax Highlighting ==="
echo ""

# Check if patterns are correctly defined in syntax file
SYNTAX_FILE="syntax/gabc.vim"

echo "Checking syntax/gabc.vim for NABC pitch descriptor patterns..."
echo ""

total_tests=0
passed_tests=0

# Test 1: Check if nabcPitchDescriptorH pattern exists
echo -n "Test 1: nabcPitchDescriptorH pattern defined... "
total_tests=$((total_tests + 1))
if grep -q "syntax match nabcPitchDescriptorH" "$SYNTAX_FILE"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 2: Check if nabcPitchDescriptorPitch pattern exists
echo -n "Test 2: nabcPitchDescriptorPitch pattern defined... "
total_tests=$((total_tests + 1))
if grep -q "syntax match nabcPitchDescriptorPitch" "$SYNTAX_FILE"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 3: Check if nabcSnippet contains pitch descriptors
echo -n "Test 3: nabcSnippet contains pitch descriptor elements... "
total_tests=$((total_tests + 1))
if grep "syntax match nabcSnippet" "$SYNTAX_FILE" | grep -qF "nabcPitchDescriptorH"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 4: Check if highlight link for H is defined
echo -n "Test 4: nabcPitchDescriptorH highlight link... "
total_tests=$((total_tests + 1))
if grep -q "highlight link nabcPitchDescriptorH" "$SYNTAX_FILE"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 5: Check if highlight link for Pitch is defined
echo -n "Test 5: nabcPitchDescriptorPitch highlight link... "
total_tests=$((total_tests + 1))
if grep -q "highlight link nabcPitchDescriptorPitch" "$SYNTAX_FILE"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 6: Check if H uses Function highlight
echo -n "Test 6: nabcPitchDescriptorH linked to Function... "
total_tests=$((total_tests + 1))
if grep "highlight link nabcPitchDescriptorH" "$SYNTAX_FILE" | grep -qF "Function"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 7: Check if Pitch uses Identifier highlight
echo -n "Test 7: nabcPitchDescriptorPitch linked to Identifier... "
total_tests=$((total_tests + 1))
if grep "highlight link nabcPitchDescriptorPitch" "$SYNTAX_FILE" | grep -qF "Identifier"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 8: Check if pitch range is correct [a-np]
echo -n "Test 8: Pitch descriptor accepts [a-np]... "
total_tests=$((total_tests + 1))
if grep "nabcPitchDescriptorPitch" "$SYNTAX_FILE" | grep -qF "[a-np]"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 9: Check if H pattern uses lookbehind or simple match
echo -n "Test 9: 'h' pattern correctly defined... "
total_tests=$((total_tests + 1))
if grep "syntax match nabcPitchDescriptorH /h/" "$SYNTAX_FILE"; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

# Test 10: Check if pitch uses lookbehind for h
echo -n "Test 10: Pitch pattern uses lookbehind for 'h'... "
total_tests=$((total_tests + 1))
if grep "nabcPitchDescriptorPitch" "$SYNTAX_FILE" | grep -qF '\(h\)\@<='; then
    echo "✓ PASS"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL"
fi

echo ""
echo "=== Test Summary ==="
echo "Passed: $passed_tests / $total_tests"
echo ""

if [ "$passed_tests" -eq "$total_tests" ]; then
    echo "All tests passed! ✓"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
