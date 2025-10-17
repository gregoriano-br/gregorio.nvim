" Headless smoke test for new GABC tags
set rtp+=.
filetype plugin on
syntax on

" Build a temporary buffer with test content for new tags
enew
call setline(1, [
      \ 'name: Test;',
      \ '%%',
      \ '<clear>clear text</clear>',
      \ '<e>elision text</e>',
      \ '<eu>euouae</eu>',
      \ '<nlba>no line break</nlba>',
      \ '<pr>protrusion default</pr>',
      \ '<pr:0>protrusion zero</pr>',
      \ '<pr:.5>protrusion half</pr>',
      \ '<pr:1>protrusion one</pr> normal text after',
      \ '<alt>above lines text</alt>',
      \ '<sp>special text</sp>',
      \ '<v>verbatim</v>',
      \ 'plain text without tags',
      \ ])
let g:gabc_devmode = 1
syntax clear
unlet! b:current_syntax
setlocal filetype=gabc buftype=nofile bufhidden=wipe noswapfile
runtime! syntax/gabc.vim
setlocal nomodified

" Probe syntax groups for each tag type
" Line 3: <clear>clear text</clear>
let s:clear_name = synIDattr(synID(3, 2, 1), 'name')
let s:clear_text = synIDattr(synID(3, 8, 1), 'name')

" Line 4: <e>elision text</e>
let s:elision_name = synIDattr(synID(4, 2, 1), 'name')
let s:elision_text = synIDattr(synID(4, 5, 1), 'name')

" Line 5: <eu>euouae</eu>
let s:eu_name = synIDattr(synID(5, 2, 1), 'name')

" Line 6: <nlba>no line break</nlba>
let s:nlba_name = synIDattr(synID(6, 2, 1), 'name')

" Line 7: <pr>protrusion default</pr>
let s:pr_name = synIDattr(synID(7, 2, 1), 'name')

" Line 8: <pr:0>protrusion zero</pr>
let s:pr0_pr = synIDattr(synID(8, 2, 1), 'name')
let s:pr0_colon = synIDattr(synID(8, 4, 1), 'name')
let s:pr0_number = synIDattr(synID(8, 5, 1), 'name')

" Line 9: <pr:.5>protrusion half</pr>
let s:pr5_pr = synIDattr(synID(9, 2, 1), 'name')
let s:pr5_colon = synIDattr(synID(9, 4, 1), 'name')
let s:pr5_dot = synIDattr(synID(9, 5, 1), 'name')
let s:pr5_num = synIDattr(synID(9, 6, 1), 'name')

" Line 10: <pr:1>protrusion one</pr> normal text after
let s:pr1_pr = synIDattr(synID(10, 2, 1), 'name')
let s:pr1_colon = synIDattr(synID(10, 4, 1), 'name')
let s:pr1_number = synIDattr(synID(10, 5, 1), 'name')
let s:pr1_close = synIDattr(synID(10, 24, 1), 'name')
let s:pr1_after = synIDattr(synID(10, 29, 1), 'name')
let s:pr1_after_stack = map(synstack(10, 29), 'synIDattr(v:val, "name")')

" Line 11: <alt>above lines text</alt>
let s:alt_name = synIDattr(synID(11, 2, 1), 'name')
let s:alt_text = synIDattr(synID(11, 6, 1), 'name')

" Line 12: <sp>special text</sp>
let s:sp_name = synIDattr(synID(12, 2, 1), 'name')
let s:sp_text = synIDattr(synID(12, 5, 1), 'name')

" Line 13: <v>verbatim</v>
let s:v_name = synIDattr(synID(13, 2, 1), 'name')

" Line 14: plain text without tags
let s:plain_text = synIDattr(synID(14, 1, 1), 'name')
let s:plain_stack = map(synstack(14, 1), 'synIDattr(v:val, "name")')

" Get actual line content for debugging
let s:line10 = getline(10)
let s:line14 = getline(14)

call writefile([
      \ 'CLEAR_NAME=' . s:clear_name,
      \ 'CLEAR_TEXT=' . s:clear_text,
      \ 'ELISION_NAME=' . s:elision_name,
      \ 'ELISION_TEXT=' . s:elision_text,
      \ 'EU_NAME=' . s:eu_name,
      \ 'NLBA_NAME=' . s:nlba_name,
      \ 'PR_NAME=' . s:pr_name,
      \ 'PR0_PR=' . s:pr0_pr,
      \ 'PR0_COLON=' . s:pr0_colon,
      \ 'PR0_NUMBER=' . s:pr0_number,
      \ 'PR5_PR=' . s:pr5_pr,
      \ 'PR5_COLON=' . s:pr5_colon,
      \ 'PR5_DOT=' . s:pr5_dot,
      \ 'PR5_NUM=' . s:pr5_num,
      \ 'PR1_PR=' . s:pr1_pr,
      \ 'PR1_COLON=' . s:pr1_colon,
      \ 'PR1_NUMBER=' . s:pr1_number,
      \ 'PR1_CLOSE=' . s:pr1_close,
      \ 'PR1_AFTER=' . s:pr1_after,
      \ 'PR1_AFTER_STACK=' . string(s:pr1_after_stack),
      \ 'ALT_NAME=' . s:alt_name,
      \ 'ALT_TEXT=' . s:alt_text,
      \ 'SP_NAME=' . s:sp_name,
      \ 'SP_TEXT=' . s:sp_text,
      \ 'V_NAME=' . s:v_name,
      \ 'PLAIN_TEXT=' . s:plain_text,
      \ 'PLAIN_STACK=' . string(s:plain_stack),
      \ 'LINE10=' . s:line10,
      \ 'LINE14=' . s:line14,
      \ ], 'tests/smoke_gabc_newtags.out')

qall!
