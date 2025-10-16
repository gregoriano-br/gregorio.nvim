#!/bin/bash

# Test script for GABC Pitch Attributes syntax highlighting
# Tests generic [attribute:value] syntax (e.g., [shape:stroke], [color:red])
# with proper highlighting for brackets, attribute name, colon, and value

TESTFILE="tests/smoke/shape_hints_smoke_test.gabc"
VIMSCRIPT=$(cat << 'VIMEOF'
" Load the GABC syntax
set rtp+=.
syntax on
filetype plugin on

" Open the test file
edit tests/smoke/shape_hints_smoke_test.gabc

" Helper function to get syntax group at position
function! GetSyntaxAt(line, col)
    let synid = synID(a:line, a:col, 1)
    let synname = synIDattr(synid, "name")
    let transname = synIDattr(synIDtrans(synid), "name")
    return synname
endfunction

" Test results
let s:tests_passed = 0
let s:tests_failed = 0
let s:test_details = []

" Test helper
function! TestSyntax(testname, line, col, expected)
    let actual = GetSyntaxAt(a:line, a:col)
    if actual == a:expected
        let s:tests_passed += 1
        call add(s:test_details, "✓ " . a:testname)
        return 1
    else
        let s:tests_failed += 1
        let msg = "✗ " . a:testname . " - Expected: " . a:expected . ", Got: " . actual
        call add(s:test_details, msg)
        return 0
    endif
endfunction

" === Pitch Attributes Syntax Tests ===

" Test 1: Basic shape attribute (gf[shape:stroke])
" Line 8: (gf[shape:stroke])
call TestSyntax("Test 1.1: Opening bracket [", 8, 4, "gabcPitchAttrBracket")
call TestSyntax("Test 1.2: Name 'shape'", 8, 5, "gabcPitchAttrName")
call TestSyntax("Test 1.3: Colon ':'", 8, 10, "gabcPitchAttrColon")
call TestSyntax("Test 1.4: Value 'stroke'", 8, 11, "gabcPitchAttrValue")
call TestSyntax("Test 1.5: Closing bracket ]", 8, 17, "gabcPitchAttrBracket")

" Test 2: Shape attribute with virga (h[shape:virga])
" Line 11: (h[shape:virga])
call TestSyntax("Test 2.1: Opening bracket [", 11, 3, "gabcPitchAttrBracket")
call TestSyntax("Test 2.2: Name 'shape'", 11, 4, "gabcPitchAttrName")
call TestSyntax("Test 2.3: Colon ':'", 11, 9, "gabcPitchAttrColon")
call TestSyntax("Test 2.4: Value 'virga'", 11, 10, "gabcPitchAttrValue")
call TestSyntax("Test 2.5: Closing bracket ]", 11, 15, "gabcPitchAttrBracket")

" Test 3: Multiple pitches with shape attributes (g[shape:punctum]f[shape:virga])
" Line 14: (g[shape:punctum]f[shape:virga])
call TestSyntax("Test 3.1: First opening bracket [", 14, 3, "gabcPitchAttrBracket")
call TestSyntax("Test 3.2: First name 'shape'", 14, 4, "gabcPitchAttrName")
call TestSyntax("Test 3.3: First colon ':'", 14, 9, "gabcPitchAttrColon")
call TestSyntax("Test 3.4: First value 'punctum'", 14, 10, "gabcPitchAttrValue")
call TestSyntax("Test 3.5: Second opening bracket [", 14, 19, "gabcPitchAttrBracket")
call TestSyntax("Test 3.6: Second name 'shape'", 14, 20, "gabcPitchAttrName")
call TestSyntax("Test 3.7: Second colon ':'", 14, 25, "gabcPitchAttrColon")
call TestSyntax("Test 3.8: Second value 'virga'", 14, 26, "gabcPitchAttrValue")

" Test 4: Shape attribute after uppercase pitch (G[shape:stroke])
" Line 17: (G[shape:stroke])
call TestSyntax("Test 4.1: Opening bracket [", 17, 3, "gabcPitchAttrBracket")
call TestSyntax("Test 4.2: Name 'shape'", 17, 4, "gabcPitchAttrName")
call TestSyntax("Test 4.3: Colon ':'", 17, 9, "gabcPitchAttrColon")
call TestSyntax("Test 4.4: Value 'stroke'", 17, 10, "gabcPitchAttrValue")

" Test 5: Shape attribute after pitch modifier (gv[shape:virga])
" Line 20: (gv[shape:virga])
call TestSyntax("Test 5.1: Opening bracket [", 20, 4, "gabcPitchAttrBracket")
call TestSyntax("Test 5.2: Name 'shape'", 20, 5, "gabcPitchAttrName")
call TestSyntax("Test 5.3: Colon ':'", 20, 10, "gabcPitchAttrColon")
call TestSyntax("Test 5.4: Value 'virga'", 20, 11, "gabcPitchAttrValue")

" Test 6: Shape attribute after accidental (gx[shape:flat])
" Line 23: (gx[shape:flat])
call TestSyntax("Test 6.1: Opening bracket [", 23, 4, "gabcPitchAttrBracket")
call TestSyntax("Test 6.2: Name 'shape'", 23, 5, "gabcPitchAttrName")
call TestSyntax("Test 6.3: Colon ':'", 23, 10, "gabcPitchAttrColon")
call TestSyntax("Test 6.4: Value 'flat'", 23, 11, "gabcPitchAttrValue")

" === Summary ===
echo "=== GABC Pitch Attributes Syntax Test Results ==="
echo ""
for detail in s:test_details
    echo detail
endfor
echo ""
echo "Tests Passed: " . s:tests_passed
echo "Tests Failed: " . s:tests_failed
echo ""

if s:tests_failed == 0
    echo "=== All Pitch Attributes Tests PASSED ✓ ==="
    cquit 0
else
    echo "=== Some Pitch Attributes Tests FAILED ✗ ==="
    cquit 1
endif
VIMEOF
)

# Run the test
echo "$VIMSCRIPT" | nvim -N -u NONE -i NONE -e -s
exit $?
