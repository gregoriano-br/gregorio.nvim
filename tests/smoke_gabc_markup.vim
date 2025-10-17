" Headless smoke test for gabc markup
set rtp+=.
filetype plugin on
syntax on

" Build a temporary buffer with minimal gabc content
enew
call setline(1, ['name: Test;', '%%', '<b>TEXTO EM NEGRITO</b>', '<i>TEXTO EM ITÁLICO</i>'])
let g:gabc_devmode = 1
syntax clear
unlet! b:current_syntax
setlocal filetype=gabc buftype=nofile bufhidden=wipe noswapfile
runtime! syntax/gabc.vim
setlocal nomodified

" Probe syntax group names inside the inner text of the tags
" Column 4 should be the first char after <b>/<i>
let s:bold = synIDattr(synID(3, 4, 1), 'name')
let s:ital = synIDattr(synID(4, 4, 1), 'name')
let s:stack_b = map(synstack(3, 4), 'synIDattr(v:val, "name")')
let s:stack_i = map(synstack(4, 4), 'synIDattr(v:val, "name")')
call writefile([
	\ 'BOLD-GROUP=' . s:bold,
	\ 'ITALIC-GROUP=' . s:ital,
	\ 'STACK-B=' . string(s:stack_b),
	\ 'STACK-I=' . string(s:stack_i),
	\ ], 'tests/smoke_gabc_markup.out')
qall!
