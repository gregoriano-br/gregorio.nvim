set rtp+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(def|nabc)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check synstack for each position
call cursor(2, 7)
let stack7 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack Pos 7 (d): ' . string(stack7)

call cursor(2, 8)
let stack8 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack Pos 8 (e): ' . string(stack8)

call cursor(2, 9)
let stack9 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack Pos 9 (f): ' . string(stack9)

call cursor(2, 10)
let stack10 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack Pos 10 (|): ' . string(stack10)

quitall!
