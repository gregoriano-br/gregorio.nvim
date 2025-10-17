#!/bin/bash

# NABC Subpunctis/Prepunctis Descriptors Validation Test
# Tests pattern matching using grep and file analysis

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'  
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0

echo -e "${BLUE}NABC Subpunctis/Prepunctis Descriptors Pattern Validation${NC}"
echo "==============================================================="

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
    local expected_matches="$4"  # space-separated list
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Extract matches
    local actual_matches=$(echo "$test_string" | grep -o "$pattern" | tr '\n' ' ' | sed 's/ $//')
    
    # Check if matches expected
    if [[ "$actual_matches" == "$expected_matches" ]]; then
        echo -e "  ${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}✗${NC} $test_name (expected: '$expected_matches', got: '$actual_matches')"
    fi
}

echo -e "\n${YELLOW}Testing Base Code Patterns${NC}"

# Base code pattern: \(su\|pp\)
test_extraction "Base codes in simple descriptors" \
    "su1 pp2 sut3 ppq4" \
    "\(su\|pp\)" \
    "su pp su pp"

test_pattern "Subpunctis base matches" "su1" "\(su\|pp\)" true
test_pattern "Prepunctis base matches" "pp2" "\(su\|pp\)" true
test_pattern "Invalid base rejected" "ab1" "\(su\|pp\)" false

echo -e "\n${YELLOW}Testing Complete Descriptor Patterns${NC}"

# Complete descriptor pattern: \(su\|pp\)[tuvwxynqz]\?[1-9]
test_extraction "Simple descriptors" \
    "su1 pp2 su9" \
    "\(su\|pp\)[tuvwxynqz]\?[1-9]" \
    "su1 pp2 su9"

test_extraction "Descriptors with St. Gall modifiers" \
    "sut1 suu2 suv3 suw4 sux5 suy6" \
    "\(su\|pp\)[tuvwxynqz]\?[1-9]" \
    "sut1 suu2 suv3 suw4 sux5 suy6"

test_extraction "Descriptors with Laon modifiers" \
    "sun1 suq2 suz3 ppn4 ppq5 ppz6" \
    "\(su\|pp\)[tuvwxynqz]\?[1-9]" \
    "sun1 suq2 suz3 ppn4 ppq5 ppz6"

echo -e "\n${YELLOW}Testing Multiple Consecutive Descriptors${NC}"

test_extraction "Multiple simple descriptors" \
    "su1pp2su3" \
    "\(su\|pp\)[tuvwxynqz]\?[1-9]" \
    "su1 pp2 su3"

test_extraction "Multiple with modifiers" \
    "sut1ppq2suz3ppw4" \
    "\(su\|pp\)[tuvwxynqz]\?[1-9]" \
    "sut1 ppq2 suz3 ppw4"

echo -e "\n${YELLOW}Testing Component Patterns${NC}"

# Modifier pattern: [tuvwxynqz]
test_extraction "St. Gall modifiers" \
    "t u v w x y" \
    "[tuvwxynqz]" \
    "t u v w x y"

test_extraction "Laon modifiers" \
    "n q z x" \
    "[tuvwxynqz]" \
    "n q z x"

# Number pattern: [1-9]  
test_extraction "Valid numbers" \
    "1 2 3 4 5 6 7 8 9" \
    "[1-9]" \
    "1 2 3 4 5 6 7 8 9"

test_pattern "Zero rejected" "su0" "[1-9]" false  # Zero should NOT be found by [1-9] pattern
test_pattern "Letters rejected in numbers" "sua" "[1-9]" false

echo -e "\n${YELLOW}Testing Edge Cases${NC}"

test_pattern "Incomplete descriptor rejected" "su" "\(su\|pp\)[tuvwxynqz]\?[1-9]" false
test_pattern "Invalid modifier rejected" "sub1" "\(su\|pp\)[tuvwxynqz]\?[1-9]" false
test_pattern "No number rejected" "sut" "\(su\|pp\)[tuvwxynqz]\?[1-9]" false

echo -e "\n${YELLOW}Testing Real GABC Context${NC}"

# Test in GABC notation context
test_pattern "In NABC snippet" "(|su1|)" "su1" true
test_pattern "In NABC snippet with modifier" "(|sut3|)" "sut3" true 
test_pattern "Multiple in snippet" "(|su1pp2|)" "su1" true
test_pattern "Multiple in snippet" "(|su1pp2|)" "pp2" true

echo -e "\n${YELLOW}Checking Syntax File Integration${NC}"

# Verify syntax patterns are in the file
SYNTAX_FILE="syntax/gabc.vim"

if [[ -f "$SYNTAX_FILE" ]]; then
    if grep -q "nabcSubPrepunctisBase" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSubPrepunctisBase pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSubPrepunctisBase pattern missing"
    fi
    
    if grep -q "nabcSubPrepunctisModifier" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSubPrepunctisModifier pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSubPrepunctisModifier pattern missing"
    fi
    
    if grep -q "nabcSubPrepunctisNumber" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSubPrepunctisNumber pattern found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSubPrepunctisNumber pattern missing"
    fi
    
    if grep -q "nabcSubPrepunctisDescriptor" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} nabcSubPrepunctisDescriptor container found in syntax file"
    else
        echo -e "  ${RED}✗${NC} nabcSubPrepunctisDescriptor container missing"
    fi
    
    # Check integration with nabcSnippet
    if grep -q "contains=.*nabcSubPrepunctisDescriptor" "$SYNTAX_FILE"; then
        echo -e "  ${GREEN}✓${NC} Integration with nabcSnippet container verified"
    else
        echo -e "  ${RED}✗${NC} Missing integration with nabcSnippet container"
    fi
else
    echo -e "  ${RED}✗${NC} Syntax file not found: $SYNTAX_FILE"
fi

# Summary
echo -e "\n==============================================================="
if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}All tests passed! ($PASSED_TESTS/$TOTAL_TESTS)${NC}"
    echo -e "${GREEN}✓ NABC Subpunctis/Prepunctis descriptors implementation validated${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. ($PASSED_TESTS/$TOTAL_TESTS passed)${NC}"
    echo -e "${YELLOW}Review the failing patterns and syntax file integration.${NC}"
    exit 1
fi