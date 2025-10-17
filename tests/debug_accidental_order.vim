" Debug script to verify accidental order: pitch BEFORE accidental symbol
" Example: (ixiv) = i + x (flat on i) + i + v (virga)

function! GetSyntaxAt(line, col) abort
  let synstack = synstack(a:line, a:col)
  if empty(synstack)
    return 'NONE'
  endif
  return synIDattr(synstack[-1], 'name')
endfunction

call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, '(ixiv) Flat on i, then i with virga')

" Clear and explicitly load syntax
syntax clear
unlet! b:current_syntax
set runtimepath+=/home/laercio/Documentos/gregorio.nvim
source /home/laercio/Documentos/gregorio.nvim/syntax/gabc.vim

echo 'Testing (ixiv):'
echo 'Positions in line 3: (ixiv)'
echo '                     123456'
echo ''

" Position 2: i (first part of ix - should be gabcAccidental)
let syn2 = GetSyntaxAt(3, 2)
echo 'Pos 2 (i in ix): ' . syn2

" Position 3: x (second part of ix - should be gabcAccidental)  
let syn3 = GetSyntaxAt(3, 3)
echo 'Pos 3 (x in ix): ' . syn3

" Position 4: i (standalone pitch - should be gabcPitch)
let syn4 = GetSyntaxAt(3, 4)
echo 'Pos 4 (i alone): ' . syn4

" Position 5: v (virga modifier - should be gabcModifierSimple)
let syn5 = GetSyntaxAt(3, 5)
echo 'Pos 5 (v virga): ' . syn5

echo ''
echo 'Expected:'
echo 'Pos 2-3 (ix): gabcAccidental (pitch i + flat x)'
echo 'Pos 4 (i): gabcPitch'
echo 'Pos 5 (v): gabcModifierSimple'

qall!
