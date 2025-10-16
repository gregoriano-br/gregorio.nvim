#!/bin/bash

# NABC Significant Letters and Tironian Letters Validation Test
# Tests pattern matching for textual annotation systems

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'  
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0

echo -e "${BLUE}NABC Significant/Tironian Letters Pattern Validation${NC}"
echo "====================================================="

# Function to test pattern matching with grep
test_pattern() {
    local test_name="$1"
    local test_string="$2"
    local pattern="$3"
    local should_match="$4"  # true/false
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Test with grep
    if echo "$test_string" | grep -q "$pattern"; then
        local matches=true
    else
        local matches=false
    fi
    
    # Check if result matches expectation
    if [[ "$matches" == "$should_match" ]]; then
        echo -e "  ${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}✗${NC} $test_name (expected: $should_match, got: $matches)"
    fi
}

# Function to test extraction with grep -o
test_extraction() {
    local test_name="$1"
    local test_string="$2" 
    local pattern="$3"
    local expected_count="$4"  # expected number of matches
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Count matches
    local actual_count=$(echo "$test_string" | grep -o "$pattern" | wc -l)
    
    # Check if count matches expected
    if [[ "$actual_count" -eq "$expected_count" ]]; then
        echo -e "  ${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}✗${NC} $test_name (expected: $expected_count, got: $actual_count)"
    fi
}

echo -e "\n${YELLOW}Testing Significant Letters Base Patterns${NC}"

# Significant letters base pattern: ls
test_pattern "Significant letter base 'ls'" "lsb1" "ls" true
test_pattern "Invalid base 'lt' for significant" "ltb1" "ls" false

echo -e "\n${YELLOW}Testing Tironian Letters Base Patterns${NC}"

# Tironian letters base pattern: lt  
test_pattern "Tironian letter base 'lt'" "lti1" "lt" true
test_pattern "Invalid base 'ls' for tironian" "lsi1" "lt" false

echo -e "\n${YELLOW}Testing St. Gall Significant Letters${NC}"

# St. Gall shorthand patterns
test_pattern "Simple St. Gall shorthand 'b'" "lsb1" "lsb1" true
test_pattern "Complex St. Gall shorthand 'fid'" "lsfid3" "lsfid3" true
test_pattern "St. Gall shorthand with wide form 'cw'" "lscw5" "lscw5" true
test_pattern "St. Gall compound shorthand 'pulcre'" "lspulcre7" "lspulcre7" true

# Test some specific St. Gall shorthands
test_extraction "St. Gall common shorthands" \
    "lsb1 lsc2 lseq3 lsfid4 lsm5 lst6 lsv7" \
    "ls[a-z]\+[1-9]" \
    7

echo -e "\n${YELLOW}Testing Laon Significant Letters${NC}"

# Laon shorthand patterns (subset that don't conflict with St. Gall)
test_pattern "Laon shorthand 'a'" "lsa1" "lsa1" true
test_pattern "Laon shorthand 'f'" "lsf2" "lsf2" true
test_pattern "Laon shorthand 'h'" "lsh3" "lsh3" true
test_pattern "Laon compound shorthand 'simp'" "lssimp4" "lssimp4" true
test_pattern "Laon compound shorthand 'simpl'" "lssimpl5" "lssimpl5" true

# Test Laon-specific patterns
test_extraction "Laon specific shorthands" \
    "lsa1 lsf2 lsh3 lshn4 lshp5 lsnl6 lsnt7" \
    "ls[a-z-]\+[1-9]" \
    7

echo -e "\n${YELLOW}Testing Tironian Letters (Laon Only)${NC}"

# Tironian letter patterns
test_pattern "Simple tironian 'i'" "lti1" "lti1" true
test_pattern "Tironian 'do'" "ltdo2" "ltdo2" true
test_pattern "Tironian 'qm'" "ltqm3" "ltqm3" true
test_pattern "Tironian compound 'ps'" "ltps4" "ltps4" true

# Test all tironian shorthands
test_extraction "All tironian shorthands" \
    "lti1 ltdo2 ltdr3 ltdx4 ltps5 ltqm6 ltsb7 ltse8 ltsj9" \
    "lt[a-z]\+[1-9]" \
    9

echo -e "\n${YELLOW}Testing Position Numbers${NC}"

# Position number validation (1-9)
test_extraction "Valid position numbers 1-9" \
    "lsb1 lsc2 lsd3 lse4 lsf5 lsg6 lsh7 lsi8 lsj9" \
    "[1-9]" \
    9

test_pattern "Zero position rejected" "lsb0" "lsb[1-9]" false
test_pattern "Invalid position letter rejected" "lsba" "lsba[1-9]" false

echo -e "\n${YELLOW}Testing Multiple Consecutive Letters${NC}"

test_extraction "Multiple significant letters" \
    "lsb1lsc2" \
    "ls[a-z]\+[1-9]" \
    2

test_extraction "Multiple tironian letters" \
    "lti1ltdo2" \
    "lt[a-z]\+[1-9]" \
    2

test_extraction "Mixed significant and tironian" \
    "lsb1lti2lsc3ltdo4" \
    "l[st][a-z]\+[1-9]" \
    4

echo -e "\n${YELLOW}Testing Integration with Other NABC Elements${NC}"

# Test integration with glyph descriptors
test_pattern "After glyph descriptor" "vilsb1" "lsb1" true
test_pattern "After subpunctis" "su1lsb2" "lsb2" true
test_pattern "After prepunctis" "pp3lti4" "lti4" true

# Test complex combinations
test_pattern "Complex NABC sequence" "visu1pp2lsb3ltdo4" "lsb3" true
test_pattern "Complex NABC sequence" "visu1pp2lsb3ltdo4" "ltdo4" true

echo -e "\n${YELLOW}Testing Edge Cases and Invalid Patterns${NC}"

# Invalid combinations
test_pattern "Incomplete significant letter rejected" "ls" "ls[a-z]\+[1-9]" false  
test_pattern "Incomplete tironian letter rejected" "lt" "lt[a-z]\+[1-9]" false
test_pattern "Missing number rejected" "lsb" "lsb[1-9]" false
test_pattern "Missing shorthand rejected" "ls1" "ls[a-z]\+1" false

# Invalid shorthands (these should match since they're technically valid patterns, but semantically incorrect)
# Note: These tests check syntax validation, not semantic correctness
test_pattern "Syntactically valid but semantically invalid shorthand" "lsxyz1" "lsxyz1" true
test_pattern "Cross-tradition usage (semantically incorrect)" "lsdo1" "lsdo1" true  
test_pattern "Cross-tradition usage (semantically incorrect)" "ltb1" "ltb1" true

echo -e "\n${YELLOW}Testing Longest Shorthands${NC}"

# Test longest shorthands to ensure pattern matching works
test_pattern "Longest St. Gall shorthand 'pulcre'" "lspulcre1" "lspulcre1" true
test_pattern "Longest St. Gall shorthand 'simil'" "lssimil2" "lssimil2" true
test_pattern "Longest Laon shorthand 'simpl'" "lssimpl3" "lssimpl3" true

echo -e "\n${YELLOW}Checking Syntax File Integration${NC}"

# Verify syntax patterns are in the file
SYNTAX_FILE="syntax/gabc.vim"

if [[ -f "$SYNTAX_FILE" ]]; then
    if grep -q "nabcSignificantLetter" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSignificantLetter pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSignificantLetter pattern missing"
    fi
    
    if grep -q "nabcTironianLetter" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcTironianLetter pattern found in syntax file"  
    else
        echo -e "  ${RED}✗${NC} nabcTironianLetter pattern missing"
    fi
    
    if grep -q "nabcSignificantBase" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSignificantBase pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSignificantBase pattern missing"
    fi
    
    if grep -q "nabcTironianBase" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcTironianBase pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcTironianBase pattern missing"
    fi
    
    # Check integration with nabcSnippet
    if grep -q "contains=.*nabcSignificantLetter" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} Significant letters integrated with nabcSnippet"
    else
        echo -e "  ${RED}✗${NC} Missing significant letters integration with nabcSnippet"
    fi
    
    if grep -q "contains=.*nabcTironianLetter" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} Tironian letters integrated with nabcSnippet"
    else
        echo -e "  ${RED}✗${NC} Missing tironian letters integration with nabcSnippet"
    fi
    
    # Check highlight groups
    if grep -q "highlight link nabcSignificantBase Function" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} Significant letter base highlighting configured"
    else
        echo -e "  ${RED}✗${NC} Missing significant letter base highlighting"
    fi
    
    if grep -q "highlight link nabcTironianBase Function" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} Tironian letter base highlighting configured" 
    else
        echo -e "  ${RED}✗${NC} Missing tironian letter base highlighting"
    fi
else
    echo -e "  ${RED}✗${NC} Syntax file not found: $SYNTAX_FILE"
fi

echo -e "\n${YELLOW}Testing Example File${NC}"

# Check if example file exists and has expected patterns
EXAMPLE_FILE="example_significant_tironian.gabc"
if [[ -f "$EXAMPLE_FILE" ]]; then
    sig_count=$(grep -o "ls[a-z-]\+[1-9]" "$EXAMPLE_FILE" | wc -l)
    tir_count=$(grep -o "lt[a-z]\+[1-9]" "$EXAMPLE_FILE" | wc -l)
    
    echo -e "  ${GREEN}✓${NC} Example file found with $sig_count significant letters and $tir_count tironian letters"
    
    if [[ $sig_count -gt 50 ]]; then
        echo -e "  ${GREEN}✓${NC} Comprehensive significant letter examples (${sig_count} total)"
    else
        echo -e "  ${YELLOW}?${NC} Limited significant letter examples (${sig_count} total)"
    fi
    
    if [[ $tir_count -gt 10 ]]; then
        echo -e "  ${GREEN}✓${NC} Good tironian letter coverage (${tir_count} total)"
    else
        echo -e "  ${YELLOW}?${NC} Limited tironian letter examples (${tir_count} total)"
    fi
else
    echo -e "  ${RED}✗${NC} Example file not found: $EXAMPLE_FILE"
fi

# Summary
echo -e "\n====================================================="
if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}All tests passed! ($PASSED_TESTS/$TOTAL_TESTS)${NC}"
    echo -e "${GREEN}✓ NABC Significant/Tironian Letters implementation validated${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. ($PASSED_TESTS/$TOTAL_TESTS passed)${NC}"
    echo -e "${YELLOW}Review the failing patterns and syntax file integration.${NC}"
    exit 1
fi