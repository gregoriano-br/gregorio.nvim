set runtimepath+=/home/laercio/Documentos/gregorio.nvim
edit test_latex_manual.gabc
set filetype=gabc
syntax on
sleep 300m

" Test position 18 (backslash of \textbf)
call cursor(3, 18)
let synname = synIDattr(synID(line('.'), col('.'), 1), 'name')
echo 'Backslash at pos 18: ' . synname

" Test position 19 (t of textbf)
call cursor(3, 19)
echo 'textbf at pos 19: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test position 30 (x of x^2)
call cursor(3, 30)
echo 'x at pos 30: ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
