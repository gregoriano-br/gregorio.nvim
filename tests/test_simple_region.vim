" Test without syntax include
" Simple region 
syntax region testVerbatim matchgroup=Delimiter start=+<v>+ end=+</v>+

" Test
enew
call setline(1, '<v>\textbf{bold}</v>')
syntax on
sleep 100m

call cursor(1, 5)
let stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack at 5: ' . string(stack)

call cursor(1, 1)
let stack1 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack at 1: ' . string(stack1)

quitall!
