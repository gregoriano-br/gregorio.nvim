set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Low(abcdefg) mid(hijklmn) high(p)')
"              123456789012345678901234567890123456

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Count positions
let line = getline(2)
echo 'Line: ' . line
echo 'Length: ' . len(line)

" Find 'p'
let idx = 0
while idx < len(line)
    if line[idx] == 'p'
        echo 'Found p at index ' . idx . ' (column ' . (idx + 1) . ')'
    endif
    let idx += 1
endwhile

" Check position 33
call cursor(2, 33)
let char_at_33 = getline(2)[col('.') - 1]
let stack33 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Char at pos 33: "' . char_at_33 . '"'
echo 'Stack at pos 33: ' . string(stack33)

qall!
