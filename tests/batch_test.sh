#!/usr/bin/env bash
# Simple test using nvim in batch mode

cd /home/laercio/Documentos/gregorio.nvim

echo "=== Testing header line (line 1) ==="
nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 1G0" \
    -c "redir! > /tmp/vim_test_line1.txt" \
    -c "silent echo 'Stack:' map(synstack(1,1), 'synIDattr(v:val, \"name\")')" \
    -c "redir END" \
    -c "quit" example.gabc

cat /tmp/vim_test_line1.txt
echo ""

if grep -q "gabcSyllable" /tmp/vim_test_line1.txt; then
    echo "❌ FAIL: gabcSyllable found in header!"
else
    echo "✅ PASS: No gabcSyllable in header"
fi

echo ""
echo "=== Testing notes line (line 10) ==="
nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
    -c "normal! 10G10l" \
    -c "redir! > /tmp/vim_test_line10.txt" \
    -c "silent echo 'Stack:' map(synstack(10,10), 'synIDattr(v:val, \"name\")')" \
    -c "redir END" \
    -c "quit" example.gabc

cat /tmp/vim_test_line10.txt
echo ""

if grep -q "gabcSyllable" /tmp/vim_test_line10.txt; then
    echo "✅ PASS: gabcSyllable found in notes section"
else
    echo "⚠️  NOTE: gabcSyllable not found (position dependent)"
fi

echo ""
echo "=== Region boundaries test ==="
for line in 1 8 9 10; do
    nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
        -c "normal! ${line}G0" \
        -c "redir! > /tmp/vim_region_${line}.txt" \
        -c "silent echo filter(map(synstack($line,1), 'synIDattr(v:val, \"name\")'), 'v:val =~ \"gabc.*\"')" \
        -c "redir END" \
        -c "quit" example.gabc
    echo "Line $line: $(cat /tmp/vim_region_${line}.txt)"
done

rm /tmp/vim_*.txt 2>/dev/null || true
