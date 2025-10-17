#!/usr/bin/env bash
# test_nocustos.sh - Automated validation for [nocustos] attribute implementation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    local details="${3:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        if [ -n "$details" ]; then
            echo -e "  ${YELLOW}Details:${NC} $details"
        fi
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Verify gabcAttrNoCustos pattern exists
echo "Test 1: Checking gabcAttrNoCustos pattern definition..."
if grep -q "syntax match gabcAttrNoCustos" syntax/gabc.vim; then
    print_result "gabcAttrNoCustos pattern defined" "PASS"
else
    print_result "gabcAttrNoCustos pattern defined" "FAIL" "Pattern not found in syntax/gabc.vim"
fi

# Test 2: Verify pattern uses correct flags
echo "Test 2: Checking pattern flags (contained, containedin)..."
if grep "syntax match gabcAttrNoCustos.*contained containedin=gabcSnippet" syntax/gabc.vim > /dev/null; then
    print_result "Pattern has correct containment" "PASS"
else
    print_result "Pattern has correct containment" "FAIL" "Missing 'contained containedin=gabcSnippet'"
fi

# Test 3: Verify highlight link exists
echo "Test 3: Checking highlight link..."
if grep -q "highlight link gabcAttrNoCustos" syntax/gabc.vim; then
    print_result "Highlight link defined" "PASS"
else
    print_result "Highlight link defined" "FAIL" "No highlight link for gabcAttrNoCustos"
fi

# Test 4: Verify highlight group assignment
echo "Test 4: Checking highlight group (should be Keyword)..."
if grep -q "highlight link gabcAttrNoCustos Keyword" syntax/gabc.vim; then
    print_result "Highlight group is Keyword" "PASS"
else
    highlight_group=$(grep "highlight link gabcAttrNoCustos" syntax/gabc.vim | awk '{print $4}')
    print_result "Highlight group is Keyword" "FAIL" "Found: $highlight_group"
fi

# Test 5: Verify gabcAttrNoCustos is in gabcSnippet contains list
echo "Test 5: Checking gabcSnippet contains list..."
if grep "syntax match gabcSnippet.*contains=.*gabcAttrNoCustos" syntax/gabc.vim > /dev/null; then
    print_result "gabcAttrNoCustos in contains list" "PASS"
else
    print_result "gabcAttrNoCustos in contains list" "FAIL" "Not found in gabcSnippet contains="
fi

# Test 6: Verify test file has adequate coverage
echo "Test 6: Checking test file coverage..."
test_file="tests/nocustos_test.gabc"
if [ -f "$test_file" ]; then
    nocustos_count=$(grep -o "\[nocustos\]" "$test_file" | wc -l)
    if [ "$nocustos_count" -ge 10 ]; then
        print_result "Test file has $nocustos_count [nocustos] examples" "PASS"
    else
        print_result "Test file coverage" "FAIL" "Only $nocustos_count examples (need >= 10)"
    fi
else
    print_result "Test file exists" "FAIL" "File $test_file not found"
fi

# Test 7: Verify pattern precedence (should be before macros, after verbatim TeX)
echo "Test 7: Checking pattern precedence..."
nocustos_line=$(grep -n "syntax match gabcAttrNoCustos" syntax/gabc.vim | cut -d: -f1)
macro_line=$(grep -n "syntax match gabcMacroNote" syntax/gabc.vim | cut -d: -f1)
verbatim_line=$(grep -n "syntax region gabcAttrVerbatimElement" syntax/gabc.vim | cut -d: -f1)

if [ "$nocustos_line" -gt "$verbatim_line" ] && [ "$nocustos_line" -lt "$macro_line" ]; then
    print_result "Pattern precedence correct (verbatim < nocustos < macros)" "PASS"
else
    print_result "Pattern precedence" "FAIL" "Lines: verbatim=$verbatim_line, nocustos=$nocustos_line, macro=$macro_line"
fi

# Test 8: Verify no syntax errors when loading
echo "Test 8: Checking for syntax errors..."
if vim -u NONE -c "set runtimepath+=." -c "syntax on" -c "set filetype=gabc" -c "quit" tests/nocustos_test.gabc 2>&1 | grep -i error > /dev/null; then
    print_result "No syntax errors" "FAIL" "Vim reported errors"
else
    print_result "No syntax errors" "PASS"
fi

# Print summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "Total tests run: ${TESTS_RUN}"
echo -e "${GREEN}Tests passed: ${TESTS_PASSED}${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
    echo -e "${RED}Tests failed: ${TESTS_FAILED}${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
