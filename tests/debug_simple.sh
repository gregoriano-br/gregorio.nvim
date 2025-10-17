#!/usr/bin/env bash
# Simple debug script to check syntax regions

echo "Creating test file..."
cat > /tmp/test.gabc << 'EOF'
name: Test;
%%
(c4) Test(f)
EOF

echo "Checking line 1 (header)..."
nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
     -c "normal! 1G0" \
     -c "let names = map(synstack(1,1), 'synIDattr(v:val, \"name\")')" \
     -c "echo 'Line 1 groups: ' . string(names)" \
     -c "q" /tmp/test.gabc 2>&1 | grep "Line 1"

echo ""
echo "Checking line 3 (notes)..."
nvim -u NONE --noplugin -c "set rtp+=." -c "syntax on" -c "set ft=gabc" \
     -c "normal! 3G0" \
     -c "let names = map(synstack(3,1), 'synIDattr(v:val, \"name\")')" \
     -c "echo 'Line 3 groups: ' . string(names)" \
     -c "q" /tmp/test.gabc 2>&1 | grep "Line 3"
