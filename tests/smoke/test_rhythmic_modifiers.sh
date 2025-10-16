#!/usr/bin/env bash

# Test script for GABC Rhythmic and Articulation Modifiers syntax highlighting
# Tests punctum mora (.), episema (_), ictus ('), and signs above staff (r1-r8)

cd "$(dirname "$0")/../.."

echo "=== Rhythmic and Articulation Modifiers Syntax Test ==="
echo ""

# Function to test syntax highlighting at a specific position
test_syntax() {
    local file=$1
    local line=$2
    local col=$3
    local expected=$4
    local description=$5
    
    result=$(nvim --headless -u NONE \
        -c "set runtimepath+=." \
        -c "syntax enable" \
        -c "edit $file" \
        -c "call cursor($line, $col)" \
        -c "let synstack = synstack(line('.'), col('.'))" \
        -c "let names = []" \
        -c "for id in synstack | call add(names, synIDattr(id, 'name')) | endfor" \
        -c "echom join(names, ' > ')" \
        -c "qall!" 2>&1 | tail -1)
    
    if echo "$result" | grep -q "$expected"; then
        echo "✓ $description"
        return 0
    else
        echo "✗ $description"
        echo "  Expected: $expected"
        echo "  Got: $result"
        return 1
    fi
}

# Test file
TEST_FILE="tests/smoke/rhythmic_modifiers_test.gabc"

passed=0
failed=0

echo "=== Punctum Mora Tests ==="
echo "Test 1: Punctum mora (.) - Line 7: (g.h.i.)"
if test_syntax "$TEST_FILE" 7 3 "gabcModifierSimple" "Punctum mora after pitch g"; then
    ((passed++))
else
    ((failed++))
fi

echo ""
echo "=== Episema Tests ==="
echo "Test 2: Episema without suffix (_) - Line 10: (g_h_i_)"
if test_syntax "$TEST_FILE" 10 3 "gabcModifierEpisema" "Episema after pitch g"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 3: Episema with suffix _0 - Line 13: (g_0h_1i_2)"
if test_syntax "$TEST_FILE" 13 3 "gabcModifierEpisema" "Episema _ in g_0"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 4: Episema suffix number 0 - Line 13"
if test_syntax "$TEST_FILE" 13 4 "gabcModifierEpisemaNumber" "Episema suffix 0 in g_0"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 5: Episema suffix number 5 - Line 14: (g_3h_4i_5)"
if test_syntax "$TEST_FILE" 14 8 "gabcModifierEpisemaNumber" "Episema suffix 5 in i_5"; then
    ((passed++))
else
    ((failed++))
fi

echo ""
echo "=== Ictus Tests ==="
echo "Test 6: Ictus without suffix (') - Line 17: (g'h'i')"
if test_syntax "$TEST_FILE" 17 3 "gabcModifierIctus" "Ictus after pitch g"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 7: Ictus with suffix '0 - Line 20: (g'0h'1i'0)"
if test_syntax "$TEST_FILE" 20 3 "gabcModifierIctus" "Ictus ' in g'0"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 8: Ictus suffix number 0 - Line 20"
if test_syntax "$TEST_FILE" 20 4 "gabcModifierIctusNumber" "Ictus suffix 0 in g'0"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 9: Ictus suffix number 1 - Line 20"
if test_syntax "$TEST_FILE" 20 7 "gabcModifierIctusNumber" "Ictus suffix 1 in h'1"; then
    ((passed++))
else
    ((failed++))
fi

echo ""
echo "=== Signs Above Staff Tests ==="
echo "Test 10: r1 accent - Line 23: (gr1hr2ir3)"
if test_syntax "$TEST_FILE" 23 3 "gabcModifierSpecial" "r1 modifier"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 11: r5 semicircle - Line 24: (gr4hr5)"
if test_syntax "$TEST_FILE" 24 6 "gabcModifierSpecial" "r5 modifier"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 12: r6 musica ficta flat - Line 27: (gr6hr7ir8)"
if test_syntax "$TEST_FILE" 27 3 "gabcModifierSpecial" "r6 modifier"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 13: r8 musica ficta sharp - Line 27"
if test_syntax "$TEST_FILE" 27 9 "gabcModifierSpecial" "r8 modifier"; then
    ((passed++))
else
    ((failed++))
fi

echo ""
echo "=== Integration Tests ==="
echo "Test 14: Combined modifiers (gv.h~_iw'0) - Line 30"
if test_syntax "$TEST_FILE" 30 4 "gabcModifierSimple" "Punctum mora in gv."; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 15: Episema with accidental - Line 33: (gx.hy_iz'1)"
if test_syntax "$TEST_FILE" 33 7 "gabcModifierEpisema" "Episema in hy_"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 16: All episema suffixes - Line 36: (g_0h_1i_2j_3k_4l_5)"
if test_syntax "$TEST_FILE" 36 13 "gabcModifierEpisemaNumber" "Episema suffix 2 in i_2"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 17: Old r0 vs new r1 - Line 48: (gr0gr1)"
if test_syntax "$TEST_FILE" 48 3 "gabcModifierSpecial" "r0 (punctum cavum with lines)"; then
    ((passed++))
else
    ((failed++))
fi

echo "Test 18: r1 after r0 - Line 48"
if test_syntax "$TEST_FILE" 48 6 "gabcModifierSpecial" "r1 (accent above)"; then
    ((passed++))
else
    ((failed++))
fi

echo ""
echo "=== Test Summary ==="
echo "Passed: $passed"
echo "Failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
    echo "✓ All Rhythmic Modifiers Tests Passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
