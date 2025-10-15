" Headless smoke test for gabc tag name highlighting
set rtp+=.
filetype plugin on
syntax on

" Build a temporary buffer with minimal gabc content
enew
call setline(1, ['name: Test;', '%%', '<b>TEXTO</b>'])
let g:gabc_devmode = 1
syntax clear
unlet! b:current_syntax
setlocal filetype=gabc buftype=nofile bufhidden=wipe noswapfile
runtime! syntax/gabc.vim
setlocal nomodified

" Probe syntax groups at different positions in <b>TEXTO</b>
" Line 3: <b>TEXTO</b>
" Columns: 1=<, 2=b, 3=>, 4-9=TEXTO, 10=<, 11=/, 12=b, 13=>
let s:bracket_open = synIDattr(synID(3, 1, 1), 'name')
let s:name_open    = synIDattr(synID(3, 2, 1), 'name')
let s:bracket_gt   = synIDattr(synID(3, 3, 1), 'name')
let s:text         = synIDattr(synID(3, 5, 1), 'name')
let s:bracket_close_lt = synIDattr(synID(3, 10, 1), 'name')
let s:slash        = synIDattr(synID(3, 11, 1), 'name')
let s:name_close   = synIDattr(synID(3, 12, 1), 'name')
let s:bracket_close_gt = synIDattr(synID(3, 13, 1), 'name')

" Also get the actual characters at those positions for validation
let line = getline(3)
let s:char_1 = line[0]
let s:char_2 = line[1]
let s:char_10 = line[9]
let s:char_11 = line[10]
let s:char_12 = line[11]

call writefile([
      \ 'LINE=' . getline(3),
      \ 'CHAR_1=' . s:char_1,
      \ 'CHAR_2=' . s:char_2,
      \ 'CHAR_10=' . s:char_10,
      \ 'CHAR_11=' . s:char_11,
      \ 'CHAR_12=' . s:char_12,
      \ 'BRACKET_OPEN=' . s:bracket_open,
      \ 'NAME_OPEN=' . s:name_open,
      \ 'BRACKET_GT=' . s:bracket_gt,
      \ 'TEXT=' . s:text,
      \ 'BRACKET_CLOSE_LT=' . s:bracket_close_lt,
      \ 'SLASH=' . s:slash,
      \ 'NAME_CLOSE=' . s:name_close,
      \ 'BRACKET_CLOSE_GT=' . s:bracket_close_gt,
      \ ], 'scripts/smoke_gabc_tagname.out')

qall!
