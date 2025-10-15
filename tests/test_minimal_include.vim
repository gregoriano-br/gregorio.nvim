" Minimal test mimicking man.vim approach
unlet! b:current_syntax
syntax include @texSyntax $VIMRUNTIME/syntax/tex.vim

" Simple region using the cluster
syntax region testVerbatim matchgroup=Delimiter start=+<v>+ end=+</v>+ contains=@texSyntax

" Test
enew
call setline(1, '<v>\textbf{bold}</v>')
syntax on
sleep 200m

call cursor(1, 5)
echo 'Backslash: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')
call cursor(1, 6)
echo 'textbf: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

let stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack: ' . string(stack)

let b:current_syntax = 'test'
quitall!
