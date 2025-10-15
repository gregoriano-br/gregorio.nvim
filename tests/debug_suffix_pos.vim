set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Left(A0B0C0) Right(D1E1F1) None(G2H2I2)')
"              123456789012345678901234567890123456789012

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

echo 'Line: ' . getline(2)
echo 'Length: ' . len(getline(2))
echo ''

" Find all positions with D, E, F
let line = getline(2)
let idx = 0
while idx < len(line)
    let char = line[idx]
    if char =~ '[DEF]'
        echo 'Found ' . char . ' at index ' . idx . ' (column ' . (idx + 1) . ')'
    endif
    let idx += 1
endwhile

echo ''
" Check position 19 (should be D)
call cursor(2, 19)
let char19 = getline(2)[18]
echo 'Pos 19: "' . char19 . '"'

" Check position 20 (should be 1)
call cursor(2, 20)
let char20 = getline(2)[19]
let stack20 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Pos 20: "' . char20 . '" stack: ' . string(stack20)

qall!
