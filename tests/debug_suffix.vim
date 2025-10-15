set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(A0B1C2D1)')
"              12345678901234567

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

echo 'Line: ' . getline(2)
echo ''

" Check each position
let pos = 6
while pos <= 14
    call cursor(2, pos)
    let char = getline(2)[pos - 1]
    let stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    echo 'Pos ' . pos . ' (' . char . '): ' . string(stack)
    let pos += 1
endwhile

qall!
