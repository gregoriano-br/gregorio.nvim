set rtp+=/home/laercio/Documentos/gregorio.nvim

" Load tex syntax manually
unlet! b:current_syntax
execute 'syntax include @texSyntax ' . $VIMRUNTIME . '/syntax/tex.vim'

" Create test file
enew
setlocal ft=tex
call setline(1, '\textbf{bold} and $x^2$')

sleep 100m

" Test
call cursor(1, 1)
echo 'Backslash: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')
call cursor(1, 2)
echo 't of textbf: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
