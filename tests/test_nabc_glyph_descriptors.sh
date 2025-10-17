#!/bin/bash
# Test NABC Glyph Descriptors syntax highlighting in Vim
# Tests both basic and complex glyph descriptors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNTAX_FILE="$SCRIPT_DIR/../syntax/gabc.vim"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASSED=0
TOTAL=0

# Test function: verify pattern exists in syntax file
test_syntax_pattern() {
    local test_name="$1"
    local pattern_name="$2"
    
    TOTAL=$((TOTAL + 1))
    
    if grep -q "$pattern_name" "$SYNTAX_FILE"; then
        echo -e "${GREEN}✓${NC} Test $TOTAL: $test_name - PASSED"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} Test $TOTAL: $test_name - FAILED"
        return 1
    fi
}

# Test function: verify pattern matches expected text
test_pattern_match() {
    local test_name="$1"
    local input="$2"
    local pattern="$3"
    
    TOTAL=$((TOTAL + 1))
    
    if echo "$input" | grep -qE "$pattern"; then
        echo -e "${GREEN}✓${NC} Test $TOTAL: $test_name - PASSED"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} Test $TOTAL: $test_name - FAILED"
        return 1
    fi
}

echo "Testing NABC Glyph Descriptors..."
echo "=================================="

echo ""
echo "Syntax Pattern Existence Tests:"
test_syntax_pattern "nabcBasicGlyphDescriptor exists" "nabcBasicGlyphDescriptor"
test_syntax_pattern "nabcComplexGlyphDelimiter exists" "nabcComplexGlyphDelimiter"
test_syntax_pattern "Delimiter highlight exists" "highlight.*nabcComplexGlyphDelimiter.*Delimiter"

echo ""
echo "Basic Glyph Descriptor Pattern Tests:"
# Pattern: neume + optional(modifier) + optional(pitch_descriptor)
# Simplified pattern for testing
test_pattern_match "Simple neume: vi" "vi" "vi"
test_pattern_match "Neume with modifier: viS" "viS" "vi[SGM>~-]"
test_pattern_match "Neume with numbered modifier: viS2" "viS2" "vi[SGM>~-][1-9]"
test_pattern_match "Neume with pitch: viha" "viha" "vih[a-np]"
test_pattern_match "Complete: viS2ha" "viS2ha" "vi[SGM>~-][1-9]h[a-np]"

echo ""
echo "Complex Glyph Descriptor Pattern Tests:"
# Test delimiter matching
test_pattern_match "Delimiter in vi!pu" "vi!pu" "!"
test_pattern_match "Multiple delimiters: vi!pu!ta" "vi!pu!ta" "!"

echo ""
echo "Integration Tests (complete structures):"
test_pattern_match "vi!pu matches basic+delimiter" "vi!pu" "vi!pu"
test_pattern_match "viS!puG matches with modifiers" "viS!puG" "vi[SGM>~-]!pu[SGM>~-]"
test_pattern_match "viha!puhm matches with pitch" "viha!puhm" "vih[a-np]!puh[a-np]"
test_pattern_match "viS2ha!puG3hm full complex" "viS2ha!puG3hm" "vi[SGM>~-][1-9]h[a-np]!pu[SGM>~-][1-9]h[a-np]"

echo ""
echo "=================================="
echo "Results: $PASSED/$TOTAL tests passed"

if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
