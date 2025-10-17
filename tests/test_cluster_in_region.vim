" Test if @texSyntax works inside a region
set rtp+=/home/laercio/Documentos/gregorio.nvim

" Load tex syntax
unlet! b:current_syntax
execute 'syntax include @texSyntax ' . $VIMRUNTIME . '/syntax/tex.vim'

" Create a simple test region
syntax region testRegion start=/{/ end=/}/ contains=@texSyntax

" Test
enew
call setline(1, 'Before {\textbf{bold}} after')
syntax on
sleep 100m

call cursor(1, 10)
echo 'Backslash pos 10: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(1, 11)
echo 'textbf pos 11: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
