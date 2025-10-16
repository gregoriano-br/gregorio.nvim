#!/usr/bin/env bash
# Test neume spacing syntax highlighting

set -e

# Create a temporary Vim script
cat > /tmp/test_spacing.vim << 'VIMSCRIPT'
set runtimepath+=.
syntax on
filetype on
edit tests/smoke/spacing_smoke_test.gabc

echo "=== Neume Spacing Operators Test ==="
echo ""

" Line 4: Ky(f/0g/0h)ri(i)e()
echo "1. Half space /0"
echo "   Line 4: " . getline(4)
call cursor(4, 6)
let half1 = synIDattr(synID(4, 6, 1), "name")
call cursor(4, 7)
let half2 = synIDattr(synID(4, 7, 1), "name")
echo "   /0 positions: " . half1 . ", " . half2
if half1 == "gabcSpacingHalf" || half2 == "gabcSpacingHalf"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got: " . half1 . ", " . half2 . ")"
endif

echo ""

" Line 7: e(f/!g/!h)le(i)i(j)son()
echo "2. Small separation (same neume) /!"
echo "   Line 7: " . getline(7)
call cursor(7, 5)
let small1 = synIDattr(synID(7, 5, 1), "name")
call cursor(7, 6)
let small2 = synIDattr(synID(7, 6, 1), "name")
echo "   /! positions: " . small1 . ", " . small2
if small1 == "gabcSpacingSingle" || small2 == "gabcSpacingSingle"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got: " . small1 . ", " . small2 . ")"
endif

echo ""

" Line 10: Chri(f/g/h)ste(i)e(j)le(k)i(l)son()
echo "3. Small separation (different neumes) /"
echo "   Line 10: " . getline(10)
call cursor(10, 7)
let sep = synIDattr(synID(10, 7, 1), "name")
echo "   / position: " . sep
if sep == "gabcSpacingSmall"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got: " . sep . ")"
endif

echo ""

" Line 13: Glo(f//g//h)ri(i)a()
echo "4. Medium separation //"
echo "   Line 13: " . getline(13)
call cursor(13, 6)
let med1 = synIDattr(synID(13, 6, 1), "name")
call cursor(13, 7)
let med2 = synIDattr(synID(13, 7, 1), "name")
echo "   // positions: " . med1 . ", " . med2
if med1 == "gabcSpacingDouble" || med2 == "gabcSpacingDouble"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got: " . med1 . ", " . med2 . ")"
endif

echo ""

" Line 16: Pa(f/[2]g/[3]h)ter()
echo "5. Scaled spacing /[factor] (simplified: / + [...] suffix)"
echo "   Line 16: " . getline(16)
call cursor(16, 5)
let slash = synIDattr(synID(16, 5, 1), "name")
call cursor(16, 6)
let bracket_open = synIDattr(synID(16, 6, 1), "name")
call cursor(16, 7)
let factor = synIDattr(synID(16, 7, 1), "name")
call cursor(16, 8)
let bracket_close = synIDattr(synID(16, 8, 1), "name")
echo "   /: " . slash . " | [: " . bracket_open . " | factor: " . factor . " | ]: " . bracket_close
if slash == "gabcSpacingSmall" && bracket_open == "gabcSpacingBracket" && factor == "gabcSpacingFactor" && bracket_close == "gabcSpacingBracket"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got /:" . slash . " [:" . bracket_open . " factor:" . factor . " ]:" . bracket_close . ")"
endif

echo ""

" Line 25: De(f!g!h)us()
echo "6. Zero-width space !"
echo "   Line 25: " . getline(25)
call cursor(25, 4)
let f_pitch = synIDattr(synID(25, 4, 1), "name")
call cursor(25, 5)
let zero = synIDattr(synID(25, 5, 1), "name")
call cursor(25, 6)
let g_pitch = synIDattr(synID(25, 6, 1), "name")
echo "   f: " . f_pitch . " | !: " . zero . " | g: " . g_pitch
if zero == "gabcSpacingZero"
    echo "   ✓ PASS"
else
    echo "   ✗ FAIL (got: " . zero . ")"
endif

echo ""
echo "=== All Spacing Tests Complete ==="

qall!
VIMSCRIPT

nvim --headless --noplugin -u NONE -S /tmp/test_spacing.vim 2>&1
rm /tmp/test_spacing.vim
