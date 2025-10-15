set rtp+=/home/laercio/Documentos/gregorio.nvim

" Test with different delimiters first
syntax region testBracket matchgroup=testDelim start=/\[/ end=/\]/ keepend
highlight link testDelim Delimiter
highlight link testBracket Special

enew!
set syntax=test
call setline(1, 'test [inside] outside')
syntax enable
sleep 200m

call cursor(1, 6)
echo 'Pos 6 ([): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(1, 7)
echo 'Pos 7 (i): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(1, 13)
echo 'Pos 13 (]): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
