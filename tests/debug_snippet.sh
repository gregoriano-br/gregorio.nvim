#!/bin/bash

# Debug snippet syntax matching

cat > /tmp/test_snippet.gabc << 'EOF'
name: Test;
%%
(e|test|fgh)
EOF

echo "Testing snippet patterns directly..."
echo "Pattern: (e|test|fgh)"
echo

# Test position 12 ('e')
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'filetype plugin on' \
  +' syntax enable' \
  +'e /tmp/test_snippet.gabc' \
  +'call cursor(3, 2)' \
  +'redir! > /tmp/test_pos2.txt' \
  +'echo "Position 2 (e):"' \
  +'echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " -> ")' \
  +'redir END' \
  +'qa!'

cat /tmp/test_pos2.txt

# Test position 4 ('|')
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'filetype plugin on' \
  +'syntax enable' \
  +'e /tmp/test_snippet.gabc' \
  +'call cursor(3, 4)' \
  +'redir! > /tmp/test_pos4.txt' \
  +'echo "Position 4 (|):"' \
  +'echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " -> ")' \
  +'redir END' \
  +'qa!'

cat /tmp/test_pos4.txt

# Test position 5 ('t' in test)
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'filetype plugin on' \
  +'syntax enable' \
  +'e /tmp/test_snippet.gabc' \
  +'call cursor(3, 5)' \
  +'redir! > /tmp/test_pos5.txt' \
  +'echo "Position 5 (t in test):"' \
  +'echo join(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), " -> ")' \
  +'redir END' \
  +'qa!'

cat /tmp/test_pos5.txt

echo
echo "Checking if gabcSnippet pattern exists..."
nvim --headless -u NONE \
  +'set rtp+=/home/laercio/Documentos/gregorio.nvim' \
  +'filetype plugin on' \
  +'syntax enable' \
  +'e /tmp/test_snippet.gabc' \
  +'redir! > /tmp/test_syntax.txt' \
  +'syn list gabcSnippet' \
  +'redir END' \
  +'qa!'

cat /tmp/test_syntax.txt
