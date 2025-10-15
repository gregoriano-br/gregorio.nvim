set rtp+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(def|nabc)')
"              1234567890123456

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check each position in 'def|'
call cursor(2, 6)
echo 'Pos 6 ((): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 7)
echo 'Pos 7 (d): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 8)
echo 'Pos 8 (e): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 9)
echo 'Pos 9 (f): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 10)
echo 'Pos 10 (|): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 11)
echo 'Pos 11 (n): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
