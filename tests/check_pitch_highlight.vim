set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(abc)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check highlight group
call cursor(2, 6)
let pitch_id = synID(line('.'), col('.'), 1)
let pitch_name = synIDattr(pitch_id, 'name')
let pitch_trans = synIDattr(synIDtrans(pitch_id), 'name')

echo 'Pitch syntax group: ' . pitch_name
echo 'Pitch highlight (translated): ' . pitch_trans

qall!
