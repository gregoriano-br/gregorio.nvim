#!/bin/bash

# Test NABC neume highlighting
# Validates that NABC neume codes are correctly identified and highlighted

echo "=== NABC Neume Highlighting Test ==="
echo

# Create test file with NABC neumes
cat > /tmp/test_nabc.gabc << 'EOF'
name: NABC Test;
%%
Test(e|vi|f|pu|g|ta|h)
More(a|gr-cl|b|pe.po|c|to~ci)
Special(d|sc/pf|e|sf!tr|f|st)
Groups(g|ds~ts|h|tg-bv|i|tv)
More(j|pq'pr|k|pi_vs|l|or)
Final(m|sa.ql|n|qi!pt|p|ni)
Laon(a|oc|b|un)
EOF

echo "Test pattern 1: (e|vi|f|pu|g|ta|h)"
echo "Expected: 'vi', 'pu', 'ta' should be nabcNeume"
echo

# Test position 4 ('vi' - should be nabcNeume)
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_nabc.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(3, 8)' \
  +'redir! > /tmp/test_vi.txt' \
  +'silent echo "Position 8 (vi): " . join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/test_vi.txt | tr -d '\n')
echo "$result"
if echo "$result" | grep -q "nabcNeume"; then
  echo "✓ PASS: 'vi' contains nabcNeume"
else
  echo "✗ FAIL: 'vi' does NOT contain nabcNeume"
fi
echo

# Test position 14 ('pu' - should be nabcNeume)
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_nabc.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(3, 14)' \
  +'redir! > /tmp/test_pu.txt' \
  +'silent echo "Position 14 (pu): " . join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/test_pu.txt | tr -d '\n')
echo "$result"
if echo "$result" | grep -q "nabcNeume"; then
  echo "✓ PASS: 'pu' contains nabcNeume"
else
  echo "✗ FAIL: 'pu' does NOT contain nabcNeume"
fi
echo

echo "Test pattern 2: More(a|gr-cl|b|pe.po|c|to~ci)"
echo "Expected: 'gr', 'cl', 'pe', 'po', 'to', 'ci' should be nabcNeume"
echo

# Test compound neumes with modifiers
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_nabc.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(4, 8)' \
  +'redir! > /tmp/test_gr.txt' \
  +'silent echo "Line 4 pos 8 (gr): " . join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/test_gr.txt | tr -d '\n')
echo "$result"
if echo "$result" | grep -q "nabcNeume"; then
  echo "✓ PASS: 'gr' contains nabcNeume"
else
  echo "✗ FAIL: 'gr' does NOT contain nabcNeume"
fi
echo

echo "Test Laon-specific neumes: (a|oc|b|un)"
echo "Expected: 'oc' and 'un' should be nabcNeume"
echo

# Test Laon neume 'oc'
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'e /tmp/test_nabc.gabc' \
  +'setfiletype gabc' \
  +'syntax enable' \
  +'call cursor(8, 9)' \
  +'redir! > /tmp/test_oc.txt' \
  +'silent echo "Line 8 pos 9 (oc): " . join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " | ")' \
  +'redir END' \
  +'qa!'

result=$(cat /tmp/test_oc.txt | tr -d '\n')
echo "$result"
if echo "$result" | grep -q "nabcNeume"; then
  echo "✓ PASS: 'oc' (Laon) contains nabcNeume"
else
  echo "✗ FAIL: 'oc' (Laon) does NOT contain nabcNeume"
fi
echo

echo "Summary: NABC neume codes should be highlighted as keywords"
echo "All 2-letter codes (vi, pu, ta, gr, cl, pe, po, to, ci, sc, pf, sf, tr, st, ds, ts, tg, bv, tv, pq, pr, pi, vs, or, sa, ql, qi, pt, ni, oc, un)"

# Cleanup
rm /tmp/test_nabc.gabc /tmp/test_*.txt 2>/dev/null

echo
echo "Test completed."
