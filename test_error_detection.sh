#!/bin/bash

# Test Error Detection in GABC Syntax Highlighting
# Tests that invalid characters in gabcSnippet and nabcSnippet contexts
# are properly highlighted as errors

echo "Testing GABC/NABC Error Detection..."
echo "=========================================="

TEST_FILE="test_error_detection.gabc"

if [ ! -f "$TEST_FILE" ]; then
    echo "Error: Test file $TEST_FILE not found!"
    exit 1
fi

echo "Test file content:"
echo "------------------"
cat "$TEST_FILE"
echo ""
echo "------------------"

# Test using vim in ex mode to verify syntax highlighting
echo "Testing syntax error detection..."

# Create a vim script that checks for error highlighting
cat > test_errors.vim << 'EOF'
" Load the test file
edit test_error_detection.gabc

" Enable syntax highlighting
syntax on
filetype on

" Save syntax state for analysis
redir > syntax_output.txt
syntax list
redir END

" Create a simple validation report
redir > error_report.txt
echo "GABC/NABC Error Detection Test Report"
echo "====================================="
echo ""
echo "Checking for Error highlight groups:"
syntax list gabcError
syntax list nabcError
echo ""
echo "File processed successfully."
redir END

quit
EOF

# Run vim with the test script
vim -e -s -c "source test_errors.vim" 2>/dev/null

if [ -f "error_report.txt" ]; then
    echo "Vim syntax test completed:"
    cat error_report.txt
    rm -f error_report.txt syntax_output.txt test_errors.vim
else
    echo "Warning: Could not generate error report"
fi

echo ""
echo "Manual validation required:"
echo "1. Open $TEST_FILE in vim/neovim"
echo "2. Verify that invalid characters are highlighted in red"
echo "3. Valid GABC/NABC should remain properly highlighted"
echo ""
echo "Expected error highlights:"
echo "- Line 4: '@invalid&chars%' in GABC context"
echo "- Line 6: 'invalid\$chars#here' in NABC context" 
echo "- Line 7: 'another%' in NABC context"
echo "- Line 9: Invalid chars in mixed GABC"
echo "- Line 10: '123xyz' in NABC context"

echo ""
echo "Test setup complete. Manual verification required."