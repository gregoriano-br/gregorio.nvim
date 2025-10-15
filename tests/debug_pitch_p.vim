set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(p)')
"              123456789

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check position 6 which should be 'p'
call cursor(2, 6)
let char_at_6 = getline(2)[col('.') - 1]
let stack6 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Char at pos 6: "' . char_at_6 . '"'
echo 'Stack at pos 6: ' . string(stack6)

if index(stack6, 'gabcPitch') >= 0
    echo 'gabcPitch FOUND'
else
    echo 'gabcPitch NOT FOUND'
endif

qall!
