#!/usr/bin/env bash
# Test real example.gabc file

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Testing example.gabc with current syntax..."
echo ""

# Test line 1 (should be in gabcHeaders, should have gabcHeaderField)
echo "Line 1: 'name: Confortamini...'"
result=$(nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 1G0" \
    -c "let stack = synstack(1, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "echo 'Syntax stack: ' . string(names)" \
    -c "quit" example.gabc 2>&1 | grep "Syntax stack")
echo "$result"

# Check if gabcSyllable is incorrectly present
if [[ "$result" == *"gabcSyllable"* ]]; then
    echo -e "${RED}✗ PROBLEM: gabcSyllable found in header line!${NC}"
else
    echo -e "${GREEN}✓ OK: No gabcSyllable in header${NC}"
fi
echo ""

# Test line 5 (should be in gabcHeaders, should have gabcHeaderField)
echo "Line 5: 'nabc-lines: 1;'"
result=$(nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 5G0" \
    -c "let stack = synstack(5, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "echo 'Syntax stack: ' . string(names)" \
    -c "quit" example.gabc 2>&1 | grep "Syntax stack")
echo "$result"

if [[ "$result" == *"gabcSyllable"* ]]; then
    echo -e "${RED}✗ PROBLEM: gabcSyllable found in header line!${NC}"
else
    echo -e "${GREEN}✓ OK: No gabcSyllable in header${NC}"
fi
echo ""

# Test line 9 (separator %%)
echo "Line 9: '%%'"
result=$(nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 9G0" \
    -c "let stack = synstack(9, 1)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "echo 'Syntax stack: ' . string(names)" \
    -c "quit" example.gabc 2>&1 | grep "Syntax stack")
echo "$result"
echo ""

# Test line 10 (should be in gabcNotes, should have gabcSyllable for text)
echo "Line 10: '(c4@c2) Con(cd...)' - checking position 10 (letter 'C')"
result=$(nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 10G9l" \
    -c "let stack = synstack(10, 10)" \
    -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
    -c "echo 'Syntax stack: ' . string(names)" \
    -c "quit" example.gabc 2>&1 | grep "Syntax stack")
echo "$result"

if [[ "$result" == *"gabcSyllable"* ]]; then
    echo -e "${GREEN}✓ OK: gabcSyllable found in notes section${NC}"
else
    echo -e "${YELLOW}⚠ NOTE: gabcSyllable not found (may be OK depending on position)${NC}"
fi
echo ""

echo "======================================"
echo "Detailed region check:"
echo "======================================"

# Check which regions are active on different lines
for line in 1 5 9 10 15; do
    echo "Line $line:"
    nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
        -c "normal! ${line}G0" \
        -c "let stack = synstack($line, 1)" \
        -c "let names = map(stack, 'synIDattr(v:val, \"name\")')" \
        -c "let regions = filter(copy(names), 'v:val =~ \"gabc\\(Headers\\|Notes\\)\"')" \
        -c "echo '  Regions: ' . string(regions)" \
        -c "quit" example.gabc 2>&1 | grep "Regions"
done
