" Debug test for NABC snippet syntax
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create simple test content
enew
call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, 'A(b|c)')

" Set filetype and force syntax reload
let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax
sleep 300m

" Helper function to get syntax groups at a position
function! GetSyntaxAt(line, col)
    let synstack = synstack(a:line, a:col)
    return map(synstack, 'synIDattr(v:val, "name")')
endfunction

" Debug: check each position in line 3: A(b|c)
" Position 1: A
" Position 2: (
" Position 3: b
" Position 4: |
" Position 5: c
" Position 6: )

echom 'Line 2 content: ' . getline(2)
echom 'Line 3 content: ' . getline(3)
echom ''
echom 'Line 2 Pos 1 (%%): ' . join(GetSyntaxAt(2, 1), ', ')
echom 'Line 3 Pos 1 (A): ' . join(GetSyntaxAt(3, 1), ', ')
echom 'Line 3 Pos 2 ((: ' . join(GetSyntaxAt(3, 2), ', ')
echom 'Line 3 Pos 3 (b): ' . join(GetSyntaxAt(3, 3), ', ')
echom 'Line 3 Pos 4 (|): ' . join(GetSyntaxAt(3, 4), ', ')
echom 'Line 3 Pos 5 (c): ' . join(GetSyntaxAt(3, 5), ', ')
echom 'Line 3 Pos 6 ()): ' . join(GetSyntaxAt(3, 6), ', ')

qall!
