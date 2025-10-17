set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(abc)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" Check each position
call cursor(2, 5)
echo 'Pos 5 ((): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(2, 6)
let id6 = synID(line('.'), col('.'), 1)
let stack6 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Pos 6 (a): id=' . id6 . ' name=' . synIDattr(id6, 'name') . ' stack: ' . string(stack6)
" Check if gabcPitch is in stack
if index(stack6, 'gabcPitch') >= 0
    echo '  -> gabcPitch FOUND IN STACK'
else
    echo '  -> gabcPitch NOT in stack'
endif

call cursor(2, 7)
let id7 = synID(line('.'), col('.'), 1)
let stack7 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Pos 7 (b): id=' . id7 . ' name=' . synIDattr(id7, 'name') . ' stack: ' . string(stack7)
if index(stack7, 'gabcPitch') >= 0
    echo '  -> gabcPitch FOUND IN STACK'
else
    echo '  -> gabcPitch NOT in stack'
endif

call cursor(2, 8)
let id8 = synID(line('.'), col('.'), 1)
let stack8 = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
echo 'Pos 8 (c): id=' . id8 . ' name=' . synIDattr(id8, 'name') . ' stack: ' . string(stack8)
if index(stack8, 'gabcPitch') >= 0
    echo '  -> gabcPitch FOUND IN STACK'
else
    echo '  -> gabcPitch NOT in stack'
endif

" Test the pattern directly
echo ''
echo 'Testing pattern [a-np][A-NP]:'
echo 'Match a: ' . (match('a', '[a-np]') >= 0 ? 'YES' : 'NO')
echo 'Match p: ' . (match('p', '[a-np]') >= 0 ? 'YES' : 'NO')
echo 'Match A: ' . (match('A', '[A-NP]') >= 0 ? 'YES' : 'NO')
echo 'Match P: ' . (match('P', '[A-NP]') >= 0 ? 'YES' : 'NO')

qall!
