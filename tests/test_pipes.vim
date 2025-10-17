set rtp+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(a|b|c|d)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check all pipes
call cursor(2, 7)
echo 'Pos 7 (|): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 9)
echo 'Pos 9 (|): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 11)
echo 'Pos 11 (|): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
