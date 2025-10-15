set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Left(A0B0C0) Right(D1E1F1) None(G2H2I2)')
call setline(3, 'Mixed(A0B1C2) All(J0K1L2M0N1P2)')
call setline(4, 'Lower(abc) NoSuffix(ABC)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Line 3
echo 'Line 3: ' . getline(3)
let line = getline(3)
let idx = 0
while idx < len(line)
    if line[idx] =~ '[ABCJKLMNP]'
        echo 'Found ' . line[idx] . ' at index ' . idx . ' (column ' . (idx + 1) . ')'
    endif
    let idx += 1
endwhile

echo ''
" Line 4
echo 'Line 4: ' . getline(4)
let line = getline(4)
let idx = 0
while idx < len(line)
    if line[idx] =~ '[ABC]'
        echo 'Found ' . line[idx] . ' at index ' . idx . ' (column ' . (idx + 1) . ')'
    endif
    let idx += 1
endwhile

qall!
