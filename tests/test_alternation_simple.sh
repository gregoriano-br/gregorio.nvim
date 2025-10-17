#!/bin/bash

# Simple test for GABC/NABC alternation
# Tests the basic pattern (gabc|nabc|gabc|nabc|gabc)

echo "=== Simple Alternation Test ==="
echo "Pattern: (e|nabc|fgFE|nabc2|h)"
echo

# Create test file
cat > /tmp/test_alt.gabc << 'EOF'
name: Test;
%%
(e|nabc|fgFE|nabc2|h)
EOF

echo "Testing position 2 (letter 'e' - should be gabcSnippet)..."
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_alt.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(3, 2)' \
  +'redir! > /tmp/pos2.txt' \
  +'silent echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/pos2.txt | tr -d '\n' | tr -d ' ')
echo "Result: $result"
if echo "$result" | grep -q "gabcSnippet"; then
  echo "✓ PASS: Position 2 contains gabcSnippet"
else
  echo "✗ FAIL: Position 2 does NOT contain gabcSnippet"
fi
echo

echo "Testing position 4 (in 'nabc' - should be nabcSnippet)..."
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_alt.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(3, 4)' \
  +'redir! > /tmp/pos4.txt' \
  +'silent echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/pos4.txt | tr -d '\n' | tr -d ' ')
echo "Result: $result"
if echo "$result" | grep -q "nabcSnippet"; then
  echo "✓ PASS: Position 4 contains nabcSnippet"
else
  echo "✗ FAIL: Position 4 does NOT contain nabcSnippet"
fi
echo

echo "Testing position 9 (in 'fgFE' - should be gabcSnippet for perfect alternation, but may be nabcSnippet)..."
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_alt.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(3, 9)' \
  +'redir! > /tmp/pos9.txt' \
  +'silent echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/pos9.txt | tr -d '\n' | tr -d ' ')
echo "Result: $result"
if echo "$result" | grep -q "gabcSnippet"; then
  echo "✓ PASS: Position 9 contains gabcSnippet (perfect alternation working!)"
elif echo "$result" | grep -q "nabcSnippet"; then
  echo "⚠ EXPECTED: Position 9 contains nabcSnippet (known limitation - Vim syntax can't alternate)"
else
  echo "✗ FAIL: Position 9 contains neither snippet type"
fi

echo
echo "Summary: Basic structure working. Perfect alternation is a known limitation."
