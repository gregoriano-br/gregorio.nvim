set rtp+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'test{cent}[trad](fg)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Test centering brace  
call cursor(2, 5)
echo 'Pos 5 ({): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 6)
echo 'Pos 6 (c): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 9)
echo 'Pos 9 (}): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test translation bracket
call cursor(2, 10)
echo 'Pos 10 ([): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 11)
echo 'Pos 11 (t): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 14)
echo 'Pos 14 (]): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
