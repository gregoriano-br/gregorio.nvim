#!/bin/bash

# Test script for NABC Horizontal Spacing Adjustment Descriptor
# Run: bash test_nabc_horizontal_spacing.sh

echo "Testing NABC Horizontal Spacing Adjustment Descriptor..."

cd "$(dirname "$0")"

# Test patterns
test_patterns=(
    "//vi"     # Basic large right spacing
    "/pu"      # Basic small right spacing  
    "\`\`ta"   # Basic large left spacing
    "\`gr"     # Basic small left spacing
    "/////pe"  # Multiple right spacing
    "\`\`\`\`\`sc" # Multiple left spacing
    "//vi!pu"  # Complex glyph with spacing
    "\`\`ta!gr!cl" # Multiple complex with spacing
    "//viS2ha" # Spacing with modifier and pitch
    "\`\`puG3hb" # Left spacing with modifiers
)

total_tests=0
passed_tests=0

echo "Testing syntax patterns..."

for pattern in "${test_patterns[@]}"; do
    total_tests=$((total_tests + 1))
    
    # Create temporary test file
    cat > /tmp/test_spacing.gabc << EOF
name: Test;
%%
Test (f|$pattern) word.
EOF
    
    # Test if vim can highlight without errors
    if vim -u NONE -c "set runtimepath+=$(pwd)" -c "syntax on" -c "setfiletype gabc" -c "syntax list nabcHorizontalSpacing" -c "q!" /tmp/test_spacing.gabc 2>/dev/null; then
        echo "✓ Pattern '$pattern' - syntax recognized"
        passed_tests=$((passed_tests + 1))
    else
        echo "✗ Pattern '$pattern' - syntax failed"
    fi
done

# Test highlight group
echo ""
echo "Testing highlight groups..."
if grep -q "highlight link nabcHorizontalSpacing Special" syntax/gabc.vim; then
    echo "✓ Highlight group nabcHorizontalSpacing linked to Special"
    passed_tests=$((passed_tests + 1))
    total_tests=$((total_tests + 1))
else
    echo "✗ Highlight group nabcHorizontalSpacing not found"
    total_tests=$((total_tests + 1))
fi

# Test containment
if grep -q "nabcHorizontalSpacing" syntax/gabc.vim | grep -q "contains=.*nabcHorizontalSpacing"; then
    echo "✓ nabcHorizontalSpacing included in nabcSnippet contains"
    passed_tests=$((passed_tests + 1))
    total_tests=$((total_tests + 1))
else
    echo "✗ nabcHorizontalSpacing not properly contained"
    total_tests=$((total_tests + 1))
fi

# Clean up
rm -f /tmp/test_spacing.gabc

echo ""
echo "NABC Horizontal Spacing Test Results:"
echo "Passed: $passed_tests/$total_tests"

if [ $passed_tests -eq $total_tests ]; then
    echo "🎉 All tests passed! NABC horizontal spacing is working correctly."
    exit 0
else
    echo "❌ Some tests failed. Check implementation."
    exit 1
fi