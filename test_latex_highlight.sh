#!/bin/bash

echo "Testing LaTeX syntax highlighting in GABC headers and content..."

# Set up test environment
cd /home/laercio/Documentos/gregorio.nvim

# Test the syntax highlighting
nvim --headless -n -u NONE -i NONE \
  -c "set runtimepath+=$(pwd)" \
  -c "syntax enable" \
  -c "set filetype=gabc" \
  -c "source syntax/gabc.vim" \
  -c "edit test_complete_latex.gabc" \
  -c "echo 'Testing LaTeX highlighting...'" \
  -c "quit!"

echo "LaTeX highlighting test completed!"