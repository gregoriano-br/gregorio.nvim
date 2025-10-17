#!/bin/bash
# Test script for NABC glyph modifiers syntax highlighting
# Tests the highlighting of S, G, M, -, >, ~ modifiers with optional numeric suffixes

TEST_DIR=$(dirname "$0")
cd "$TEST_DIR/.." || exit 1

echo "=== Testing NABC Glyph Modifiers Syntax Highlighting ==="
echo ""

# Test file with NABC glyph modifiers
TEST_FILE=$(mktemp --suffix=.gabc)
cat > "$TEST_FILE" << 'EOF'
name: NABC Glyph Modifiers Test;
%%
Test(e|viS|f|puG|g|taM)
Modifiers(e|vi-|f|pu>|g|ta~)
WithNumbers(e|viS1|f|puG2|g|taM3|a|vi-4|b|pu>5|c|ta~6)
Compound(e|grS2|f|cl-3|g|peG4|a|poM5|b|to>6|c|ci~7)
StGall(e|stS|f|stG1|g|st-2)
Laon(e|ocM|f|ocG3|g|un~4)
MaxSuffix(e|viS9|f|puG9|g|taM9|a|vi-9|b|pu>9|c|ta~9)
Mixed(e|viS2G3|f|pu-1M4|g|ta~5>6)
EOF

echo "Test file created: $TEST_FILE"
echo ""
echo "Test file content:"
cat "$TEST_FILE"
echo ""
echo "---"
echo ""

# Function to check syntax highlighting
check_syntax() {
    local pattern=$1
    local description=$2
    local should_match=$3  # "yes" or "no"
    
    # Use Vim to check if pattern matches with the correct syntax group
    result=$(vim -e -s "$TEST_FILE" 2>&1 << VIMEOF
source syntax/gabc.vim
syntax on
let matches = []
call cursor(1, 1)
while search('$pattern', 'W') > 0
    let synID = synID(line('.'), col('.'), 1)
    let synName = synIDattr(synID, 'name')
    call add(matches, synName)
endwhile
if len(matches) > 0
    echo join(matches, ', ')
else
    echo 'NONE'
endif
quit
VIMEOF
)
    
    if [ "$should_match" = "yes" ]; then
        if echo "$result" | grep -qE "nabc|Modifier|Number"; then
            echo "✓ PASS: $description"
            echo "  Found: $result"
        else
            echo "✗ FAIL: $description"
            echo "  Expected NABC syntax group, got: $result"
            return 1
        fi
    else
        if echo "$result" | grep -qE "nabc|Modifier|Number"; then
            echo "✗ FAIL: $description (should NOT match)"
            echo "  Unexpected: $result"
            return 1
        else
            echo "✓ PASS: $description (correctly not matched)"
        fi
    fi
    
    return 0
}

# Track test results
total_tests=0
passed_tests=0

# Test 1: Simple S modifier
echo "Test 1: Simple S modifier (viS)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(3, 1)
call search('viS', 'W')
call search('S', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: 'S' in viS highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: 'S' in viS not highlighted correctly"
fi
echo ""

# Test 2: Simple G modifier
echo "Test 2: Simple G modifier (puG)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(3, 1)
call search('puG', 'W')
call search('G', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: 'G' in puG highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: 'G' in puG not highlighted correctly"
fi
echo ""

# Test 3: Simple M modifier
echo "Test 3: Simple M modifier (taM)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(3, 1)
call search('taM', 'W')
call search('M', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: 'M' in taM highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: 'M' in taM not highlighted correctly"
fi
echo ""

# Test 4: Episema modifier (-)
echo "Test 4: Episema modifier (vi-)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(4, 1)
call search('vi-', 'W')
call search('-', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: '-' in vi- highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: '-' in vi- not highlighted correctly"
fi
echo ""

# Test 5: Augmentive liquescence (>)
echo "Test 5: Augmentive liquescence (pu>)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(4, 1)
call search('pu>', 'W')
call search('>', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: '>' in pu> highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: '>' in pu> not highlighted correctly"
fi
echo ""

# Test 6: Diminutive liquescence (~)
echo "Test 6: Diminutive liquescence (ta~)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(4, 1)
call search('ta~', 'W')
call search('~', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: '~' in ta~ highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: '~' in ta~ not highlighted correctly"
fi
echo ""

# Test 7: Modifier with numeric suffix (viS1)
echo "Test 7: Modifier with numeric suffix (viS1)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifierNumber"
source syntax/gabc.vim
syntax on
call cursor(5, 1)
call search('viS1', 'W')
call search('S1', 'c')
call search('1', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: '1' in viS1 highlighted as nabcGlyphModifierNumber"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: '1' in viS1 not highlighted correctly"
fi
echo ""

# Test 8: Maximum suffix value (viS9)
echo "Test 8: Maximum suffix value (viS9)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifierNumber"
source syntax/gabc.vim
syntax on
call cursor(7, 1)
call search('viS9', 'W')
call search('S9', 'c')
call search('9', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: '9' in viS9 highlighted as nabcGlyphModifierNumber"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: '9' in viS9 not highlighted correctly"
fi
echo ""

# Test 9: St. Gall neume with modifier (stG1)
echo "Test 9: St. Gall neume with modifier (stG1)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(6, 1)
call search('stG1', 'W')
call search('G', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: 'G' in stG1 (St. Gall) highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: 'G' in stG1 not highlighted correctly"
fi
echo ""

# Test 10: Laon neume with modifier (ocM)
echo "Test 10: Laon neume with modifier (ocM)"
total_tests=$((total_tests + 1))
if vim -e -s "$TEST_FILE" 2>&1 << 'VIMEOF' | grep -q "nabcGlyphModifier"
source syntax/gabc.vim
syntax on
call cursor(6, 1)
call search('ocM', 'W')
call search('M', 'c')
let synID = synID(line('.'), col('.'), 1)
echo synIDattr(synID, 'name')
quit
VIMEOF
then
    echo "✓ PASS: 'M' in ocM (Laon) highlighted as nabcGlyphModifier"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ FAIL: 'M' in ocM not highlighted correctly"
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo "Passed: $passed_tests / $total_tests"
echo ""

# Cleanup
rm "$TEST_FILE"

# Exit with appropriate code
if [ "$passed_tests" -eq "$total_tests" ]; then
    echo "All tests passed! ✓"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
