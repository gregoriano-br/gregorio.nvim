" Smoke test for LaTeX syntax inside <v> tags
" Validates that LaTeX commands are highlighted within verbatim tags

" Set up runtime path to include current plugin
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create a buffer with LaTeX content inside <v> tags
enew
call setline(1, '%%')
call setline(2, 'A()B(c3) syl<v>\textbf{bold}</v>la(f)ble(g)')

" Set filetype to trigger syntax (force reload)
let g:gabc_devmode = 1
set filetype=gabc
" Force syntax reload
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax to load
sleep 300m

" Test 1: Check that \textbf is recognized as a LaTeX command
" Position cursor on the backslash of \textbf (line 2, column 18)
call cursor(2, 18)
let synid = synID(line('.'), col('.'), 1)
let synname = synIDattr(synid, 'name')
let result1 = (synname =~# 'tex\|Statement' ? 'PASS' : 'FAIL')

" Test 2: Check that content is inside gabcVerbatimTag region
" Check synstack to see if gabcVerbatimTag is present
let stack = synstack(line('.'), col('.'))
let stack_names = map(copy(stack), 'synIDattr(v:val, "name")')
let has_verbatim = (index(stack_names, 'gabcVerbatimTag') >= 0 ? 'PASS' : 'FAIL')

" Test 3: Verify tags don't contaminate syllables after </v>
" Position on 'la' after </v> (should be in gabcSyllable only)
call cursor(2, 36)
let stack_after = synstack(line('.'), col('.'))
let stack_after_names = map(copy(stack_after), 'synIDattr(v:val, "name")')
let no_leak = (index(stack_after_names, 'gabcVerbatimTag') < 0 ? 'PASS' : 'FAIL')

" Write results
let output = [
	\ 'LATEX_COMMAND=' . synname,
	\ 'TEST_LATEX=' . result1,
	\ 'IN_VERBATIM=' . has_verbatim,
	\ 'AFTER_STACK=' . string(stack_after_names),
	\ 'NO_LEAK=' . no_leak
	\ ]

call writefile(output, 'tests/smoke_gabc_latex.out')

" Exit
quitall!
