" Debug script for pitch highlight with syntax reload
call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, '(g) Simple pitch')

" Force reload syntax
syntax clear
unlet! b:current_syntax
set filetype=gabc

echo 'After reload:'
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

quit
