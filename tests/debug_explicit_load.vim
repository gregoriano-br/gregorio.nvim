" Debug script with explicit syntax load
call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, '(g) Simple pitch')

" Clear and explicitly load syntax
syntax clear
unlet! b:current_syntax
set runtimepath+=/home/laercio/Documentos/gregorio.nvim
source /home/laercio/Documentos/gregorio.nvim/syntax/gabc.vim

echo 'After explicit load:'
echo 'Line 3, col 2:'
let synstack = synstack(3, 2)
echo 'Synstack: ' . string(synstack)
for id in synstack
  echo '  Syntax: ' . synIDattr(id, 'name') . ' -> ' . synIDattr(synIDtrans(id), 'name')
endfor

" Check specific highlight definition
redir => hlinfo
silent execute 'highlight gabcPitch'
redir END
echo 'gabcPitch highlight: ' . hlinfo

qall!
