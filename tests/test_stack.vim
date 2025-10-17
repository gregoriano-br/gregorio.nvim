set runtimepath+=/home/laercio/Documentos/gregorio.nvim
edit test_latex_manual.gabc
set filetype=gabc
syntax on
sleep 300m

" Check what's at position 15 (inside <v>)
call cursor(3, 15)
let stack15 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack at pos 15 (<v>): ' . string(stack15)

" Check what's at position 16 (right after >)
call cursor(3, 16)
let stack16 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack at pos 16 (after >): ' . string(stack16)

" Check what's at position 18 (backslash)
call cursor(3, 18)
let stack18 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Stack at pos 18 (backslash): ' . string(stack18)

quitall!
