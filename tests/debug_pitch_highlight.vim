" Debug script for pitch highlight
call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, '(g) Simple pitch')

set filetype=gabc

echo 'Line 3, col 2:'
let synstack = synstack(3, 2)
echo 'Synstack: ' . string(synstack)
for id in synstack
  echo '  Syntax: ' . synIDattr(id, 'name') . ' -> ' . synIDattr(synIDtrans(id), 'name')
endfor

echo 'Highlight groups defined:'
redir => hlgroups
silent highlight
redir END
for line in split(hlgroups, "\n")
  if line =~? 'gabcPitch'
    echo line
  endif
endfor

quit
