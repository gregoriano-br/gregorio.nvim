#!/usr/bin/env bash
# test_region_separation.sh - Test that headers and notes regions don't overlap

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Testing region separation (headers vs notes)..."

# Create a test file
cat > /tmp/test_regions.gabc << 'EOF'
name: Test Region Separation;
office-part: Introitus;
mode: 1;
%%
(c4) This(f) is(g) a(h) test(i)
EOF

# Test 1: Check if "name:" is highlighted as gabcHeaderField (not gabcSyllable)
echo "Test 1: Checking if 'name:' is in gabcHeaders region..."
result=$(vim -u NONE --noplugin -c "set runtimepath+=." -c "syntax on" -c "set filetype=gabc" \
    -c "normal! 1G" -c "let stack = synstack(1, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "if index(names, 'gabcHeaders') >= 0 | echo 'PASS' | else | echo 'FAIL' | endif" \
    -c "quit" /tmp/test_regions.gabc 2>&1 | grep -E '(PASS|FAIL)')

if [[ "$result" == *"PASS"* ]]; then
    echo -e "${GREEN}✓${NC} Line 1 is in gabcHeaders region"
else
    echo -e "${RED}✗${NC} Line 1 is NOT in gabcHeaders region"
    exit 1
fi

# Test 2: Check if text after %% is in gabcNotes region
echo "Test 2: Checking if text after %% is in gabcNotes region..."
result=$(vim -u NONE --noplugin -c "set runtimepath+=." -c "syntax on" -c "set filetype=gabc" \
    -c "normal! 5G0" -c "let stack = synstack(5, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "if index(names, 'gabcNotes') >= 0 | echo 'PASS' | else | echo 'FAIL' | endif" \
    -c "quit" /tmp/test_regions.gabc 2>&1 | grep -E '(PASS|FAIL)')

if [[ "$result" == *"PASS"* ]]; then
    echo -e "${GREEN}✓${NC} Line 5 is in gabcNotes region"
else
    echo -e "${RED}✗${NC} Line 5 is NOT in gabcNotes region"
    exit 1
fi

# Test 3: Check that header field is NOT highlighted as gabcSyllable
echo "Test 3: Checking that 'name:' is NOT gabcSyllable..."
result=$(vim -u NONE --noplugin -c "set runtimepath+=." -c "syntax on" -c "set filetype=gabc" \
    -c "normal! 1G0" -c "let stack = synstack(1, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "if index(names, 'gabcSyllable') < 0 | echo 'PASS' | else | echo 'FAIL' | endif" \
    -c "quit" /tmp/test_regions.gabc 2>&1 | grep -E '(PASS|FAIL)')

if [[ "$result" == *"PASS"* ]]; then
    echo -e "${GREEN}✓${NC} Header field is NOT gabcSyllable"
else
    echo -e "${RED}✗${NC} Header field IS incorrectly gabcSyllable"
    exit 1
fi

# Test 4: Check that lyric text IS highlighted as gabcSyllable
echo "Test 4: Checking that 'This' after %% IS gabcSyllable..."
result=$(vim -u NONE --noplugin -c "set runtimepath+=." -c "syntax on" -c "set filetype=gabc" \
    -c "normal! 5G0" -c "let stack = synstack(5, 6)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "if index(names, 'gabcSyllable') >= 0 | echo 'PASS' | else | echo 'FAIL' | endif" \
    -c "quit" /tmp/test_regions.gabc 2>&1 | grep -E '(PASS|FAIL)')

if [[ "$result" == *"PASS"* ]]; then
    echo -e "${GREEN}✓${NC} Lyric text IS gabcSyllable"
else
    echo -e "${RED}✗${NC} Lyric text is NOT gabcSyllable"
    exit 1
fi

echo ""
echo -e "${GREEN}All region separation tests passed!${NC}"
rm /tmp/test_regions.gabc
exit 0
