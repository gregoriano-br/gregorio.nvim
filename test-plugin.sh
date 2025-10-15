#!/usr/bin/env bash

# Test script for gregorio.nvim plugin
# This script performs basic checks to ensure the plugin is working correctly

echo "Testing gregorio.nvim plugin..."
echo "================================"

# Check if we're in the right directory
if [ ! -f "plugin/gregorio.vim" ]; then
    echo "Error: This script must be run from the plugin root directory"
    echo "Expected to find plugin/gregorio.vim"
    exit 1
fi

echo "✓ Plugin directory structure found"

# Check required files exist
required_files=(
    "plugin/gregorio.vim"
    "ftdetect/gabc.vim"
    "ftplugin/gabc.vim"
    "syntax/gabc.vim"
    "lua/gabc/init.lua"
    "lua/gabc/markup.lua"
    "lua/gabc/transpose.lua"
    "lua/gabc/utils.lua"
    "lua/gabc/nabc.lua"
    "snippets/gabc.snippets"
    "doc/gregorio.txt"
    "README.md"
    "LICENSE"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found $file"
    else
        echo "✗ Missing $file"
    fi
done

# Check if example file has correct syntax
if [ -f "example.gabc" ]; then
    echo "✓ Example GABC file found"
    
    # Basic syntax checks
    if grep -q "^name:" example.gabc; then
        echo "✓ Example has proper header"
    else
        echo "✗ Example missing proper header"
    fi
    
    if grep -q "^%%" example.gabc; then
        echo "✓ Example has header separator"
    else
        echo "✗ Example missing header separator"
    fi
    
    if grep -q "nabc-lines:" example.gabc; then
        echo "✓ Example includes NABC extension"
    else
        echo "! Example doesn't include NABC extension (optional)"
    fi
else
    echo "! No example file found (optional)"
fi

# Check documentation
if [ -f "doc/gregorio.txt" ]; then
    if grep -q "*gregorio.txt*" doc/gregorio.txt; then
        echo "✓ Vim help documentation is properly formatted"
    else
        echo "✗ Vim help documentation formatting issue"
    fi
fi

# Check if Lua modules are syntactically correct (basic check)
for lua_file in lua/gabc/*.lua; do
    if [ -f "$lua_file" ]; then
        if lua -l luac -e "luac.compile('$lua_file')" 2>/dev/null; then
            echo "✓ $lua_file syntax OK"
        else
            echo "✗ $lua_file has syntax errors"
        fi
    fi
done

echo ""
echo "Test completed!"
echo ""
echo "To install this plugin:"
echo "1. Copy the entire directory to your Neovim configuration"
echo "2. Add require('gabc').setup() to your init.lua"
echo "3. Restart Neovim"
echo "4. Open example.gabc to test functionality"
echo ""
echo "For detailed usage instructions, see README.md or :help gabc"

# Optional: Headless smoke test with watchdog (no user config)
if command -v nvim >/dev/null 2>&1; then
    echo ""
    echo "Running headless smoke test (watchdog 8s)…"
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE \
        +"set rtp+=." +"filetype plugin on" +"syntax on" +"edit example.gabc" +"setf gabc" \
        +"redir => output" +"silent! syntax list gabcHeader gabcNotesRegion" +"redir END" +"echo output" +"qall" \
        2>/dev/null | sed -n '1,8p'
    rc=${PIPESTATUS[0]}
    if [ $rc -eq 0 ]; then
        echo "✓ Headless smoke test completed"
    else
        echo "! Headless smoke test failed (rc=$rc)"
    fi

    echo ""
    echo "Running markup smoke test (bold/italic) with watchdog…"
    rm -f tests/smoke_gabc_markup.out
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_gabc_markup.vim 2>/dev/null || true
    if [ -f tests/smoke_gabc_markup.out ]; then
        cat tests/smoke_gabc_markup.out | sed -n '1,10p'
    fi
    if grep -q "BOLD-GROUP=gabcBoldText" tests/smoke_gabc_markup.out && grep -q "ITALIC-GROUP=gabcItalicText" tests/smoke_gabc_markup.out; then
        echo "✓ Markup smoke test passed"
    else
        echo "! Markup smoke test may have failed"
    fi

    echo ""
    echo "Running new tags smoke test with watchdog…"
    rm -f tests/smoke_gabc_newtags.out
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_gabc_newtags.vim 2>/dev/null || true
    if [ -f tests/smoke_gabc_newtags.out ]; then
        cat tests/smoke_gabc_newtags.out | sed -n '1,10p'
    fi
    # Check for expected groups and ensure no leakage of gabcProtrusionTag
    if grep -q "ELISION_TEXT=gabcElisionText" tests/smoke_gabc_newtags.out && \
       grep -q "ALT_TEXT=gabcAboveLinesText" tests/smoke_gabc_newtags.out && \
       grep -q "PR0_COLON=gabcProtrusionColon" tests/smoke_gabc_newtags.out && \
       grep -q "PR1_AFTER_STACK=\['gabcSyllable'\]" tests/smoke_gabc_newtags.out && \
       ! grep -q "gabcProtrusionTag.*PR1_AFTER" tests/smoke_gabc_newtags.out; then
        echo "✓ New tags smoke test passed (no protrusion tag leakage)"
    else
        echo "! New tags smoke test may have failed"
    fi

    echo ""
    echo "Running LaTeX embedding smoke test with watchdog…"
    rm -f tests/smoke_gabc_latex.out
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_gabc_latex.vim 2>/dev/null || true
    if [ -f tests/smoke_gabc_latex.out ]; then
        cat tests/smoke_gabc_latex.out | sed -n '1,10p'
    fi
    # Check if LaTeX syntax is recognized inside <v> tags
    if grep -q "TEST_LATEX=PASS" tests/smoke_gabc_latex.out && \
       grep -q "IN_VERBATIM=PASS" tests/smoke_gabc_latex.out && \
       grep -q "NO_LEAK=PASS" tests/smoke_gabc_latex.out; then
        echo "✓ LaTeX embedding smoke test passed"
    else
        echo "! LaTeX embedding smoke test may have failed"
    fi

    echo ""
    echo "Running NABC snippet alternation smoke test with watchdog…"
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_nabc_snippet.vim 2>/dev/null | grep -E "(PASS|FAIL)" || true
    # Check if both GABC and NABC snippets are recognized correctly
    if timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_nabc_snippet.vim 2>&1 | grep -q "HAS_GABC_SIMPLE=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_nabc_snippet.vim 2>&1 | grep -q "HAS_NABC_SIMPLE=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_nabc_snippet.vim 2>&1 | grep -q "HAS_NABC_QUAD_3=PASS"; then
        echo "✓ NABC snippet alternation smoke test passed"
    else
        echo "! NABC snippet alternation smoke test may have failed"
    fi

    echo ""
    echo "Running GABC pitch syntax smoke test with watchdog…"
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>/dev/null | grep -E "(PASS|FAIL|HIGHLIGHT)" || true
    # Check if pitch letters are recognized correctly
    if timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>&1 | grep -q "HAS_PITCH_A=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>&1 | grep -q "HAS_PITCH_P=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>&1 | grep -q "HAS_PITCH_A_UPPER=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>&1 | grep -q "HAS_PITCH_P_UPPER=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch.vim 2>&1 | grep -q "IN_SNIPPET=PASS"; then
        echo "✓ GABC pitch syntax smoke test passed"
    else
        echo "! GABC pitch syntax smoke test may have failed"
    fi

    echo ""
    echo "Running GABC pitch suffix syntax smoke test with watchdog…"
    ./scripts/nvim-watchdog.sh 8 -- --headless -n -u NONE -i NONE -S tests/smoke_gabc_pitch_suffix.vim 2>/dev/null | grep -E "(PASS|FAIL|HIGHLIGHT)" || true
    # Check if pitch inclinatum suffixes (0, 1, 2) are recognized correctly
    if timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch_suffix.vim 2>&1 | grep -q "HAS_SUFFIX_0=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch_suffix.vim 2>&1 | grep -q "HAS_SUFFIX_1=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch_suffix.vim 2>&1 | grep -q "HAS_SUFFIX_2=PASS" && \
       timeout 5s nvim --headless -u NONE -i NONE -S tests/smoke_gabc_pitch_suffix.vim 2>&1 | grep -q "LOWERCASE_NO_SUFFIX=PASS"; then
        echo "✓ GABC pitch suffix syntax smoke test passed"
    else
        echo "! GABC pitch suffix syntax smoke test may have failed"
    fi
else
    echo "! Neovim not found; skipping headless smoke test"
fi