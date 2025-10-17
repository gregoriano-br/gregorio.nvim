" Smoke test for lyric centering {} and translation [] delimiters
" Validates that delimiters and their contents are highlighted correctly

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test Delimiters;')
call setline(2, '%%')
call setline(3, 'Simple(f) {centered}(g) text(h)')
call setline(4, 'Sed[Mas](fg) li[but](gh)bra(i)')
call setline(5, 'Both{cent}[trad](jk) here(l)')

" Set filetype and force syntax reload
let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax
sleep 300m

" Test 1: Lyric centering delimiter {
call cursor(3, 9)
let cent_delim_open = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 2: Lyric centering text
call cursor(3, 10)
let cent_text = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 3: Lyric centering delimiter }
call cursor(3, 18)
let cent_delim_close = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 4: Translation delimiter [
call cursor(4, 4)
let trans_delim_open = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 5: Translation text
call cursor(4, 5)
let trans_text = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 6: Translation delimiter ]
call cursor(4, 7)
let trans_delim_close = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 7: Check stack for centering (should contain gabcLyricCentering)
call cursor(3, 10)
let cent_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
let has_cent = (index(cent_stack, 'gabcLyricCentering') >= 0 ? 'PASS' : 'FAIL')

" Test 8: Check stack for translation (should contain gabcTranslation)
call cursor(4, 5)
let trans_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
let has_trans = (index(trans_stack, 'gabcTranslation') >= 0 ? 'PASS' : 'FAIL')

" Test 9: Verify no leakage - text after } should be plain syllable
call cursor(3, 19)
let after_cent = synIDattr(synID(line('.'), col('.'), 1), 'name')
let after_cent_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 10: Verify no leakage - text after ] should be plain syllable
call cursor(4, 8)
let after_trans = synIDattr(synID(line('.'), col('.'), 1), 'name')
let after_trans_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 11: Both delimiters in same syllable (line 5)
call cursor(5, 6)
let both_cent = synIDattr(synID(line('.'), col('.'), 1), 'name')
call cursor(5, 11)
let both_trans = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Write results
let output = [
	\ 'CENT_DELIM_OPEN=' . cent_delim_open,
	\ 'CENT_TEXT=' . cent_text,
	\ 'CENT_DELIM_CLOSE=' . cent_delim_close,
	\ 'TRANS_DELIM_OPEN=' . trans_delim_open,
	\ 'TRANS_TEXT=' . trans_text,
	\ 'TRANS_DELIM_CLOSE=' . trans_delim_close,
	\ 'HAS_CENT=' . has_cent,
	\ 'HAS_TRANS=' . has_trans,
	\ 'AFTER_CENT=' . after_cent,
	\ 'AFTER_CENT_STACK=' . string(after_cent_stack),
	\ 'AFTER_TRANS=' . after_trans,
	\ 'AFTER_TRANS_STACK=' . string(after_trans_stack),
	\ 'BOTH_CENT=' . both_cent,
	\ 'BOTH_TRANS=' . both_trans
	\ ]

call writefile(output, 'tests/smoke_gabc_delimiters.out')

" Exit
quitall!
