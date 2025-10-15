set rtp+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'test{cent}[trad](fg)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Test with synIDtrans to see actual highlighting
call cursor(2, 5)
let id5 = synID(line('.'), col('.'), 1)
echo 'Pos 5 ({): name=' . synIDattr(id5, 'name') . ' trans=' . synIDattr(synIDtrans(id5), 'name')

call cursor(2, 6)
let id6 = synID(line('.'), col('.'), 1)
echo 'Pos 6 (c): name=' . synIDattr(id6, 'name') . ' trans=' . synIDattr(synIDtrans(id6), 'name')

call cursor(2, 9)
let id9 = synID(line('.'), col('.'), 1)
echo 'Pos 9 (}): name=' . synIDattr(id9, 'name') . ' trans=' . synIDattr(synIDtrans(id9), 'name')

call cursor(2, 10)
let id10 = synID(line('.'), col('.'), 1)
echo 'Pos 10 ([): name=' . synIDattr(id10, 'name') . ' trans=' . synIDattr(synIDtrans(id10), 'name')

quitall!
