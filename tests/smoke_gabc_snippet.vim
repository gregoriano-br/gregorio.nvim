" Smoke test for gabcSnippet (first GABC snippet)
" Validates that the first snippet after ( is recognized as gabcSnippet

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test GABC Snippet;')
call setline(2, '%%')
call setline(3, 'Simple(abc) text(h)')
call setline(4, 'WithPipe(def|nabc) more(i)')
call setline(5, 'Multi(ghi|n1|jkl|n2) end(j)')

" Set filetype and force syntax reload
let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax
sleep 300m

" Test 1: Simple notation - first char after (
call cursor(3, 8)
let simple_char = synIDattr(synID(line('.'), col('.'), 1), 'name')
let simple_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 2: Simple notation - middle of snippet
call cursor(3, 9)
let simple_mid = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 3: Simple notation - last char before )
call cursor(3, 10)
let simple_end = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 4: With pipe - first char after (
call cursor(4, 11)
let pipe_char = synIDattr(synID(line('.'), col('.'), 1), 'name')
let pipe_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 5: With pipe - last char before |
call cursor(4, 13)
let pipe_end = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 6: With pipe - check | is not in gabcSnippet
call cursor(4, 14)
let pipe_delim = synIDattr(synID(line('.'), col('.'), 1), 'name')
let pipe_delim_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 7: After pipe - should NOT be gabcSnippet
call cursor(4, 15)
let after_pipe = synIDattr(synID(line('.'), col('.'), 1), 'name')
let after_pipe_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 8: Multi - first snippet should be gabcSnippet
call cursor(5, 7)
let multi_first = synIDattr(synID(line('.'), col('.'), 1), 'name')
let multi_first_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 9: Multi - third snippet (after 2nd |) should NOT be gabcSnippet initially
call cursor(5, 15)
let multi_third = synIDattr(synID(line('.'), col('.'), 1), 'name')
let multi_third_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 10: Check gabcSnippet is in stack for first snippet
let has_snippet_simple = (index(simple_stack, 'gabcSnippet') >= 0 ? 'PASS' : 'FAIL')
let has_snippet_pipe = (index(pipe_stack, 'gabcSnippet') >= 0 ? 'PASS' : 'FAIL')
let has_snippet_multi = (index(multi_first_stack, 'gabcSnippet') >= 0 ? 'PASS' : 'FAIL')
let no_snippet_after = (index(after_pipe_stack, 'gabcSnippet') < 0 ? 'PASS' : 'FAIL')

" Write results
let output = [
	\ 'SIMPLE_CHAR=' . simple_char,
	\ 'SIMPLE_STACK=' . string(simple_stack),
	\ 'SIMPLE_MID=' . simple_mid,
	\ 'SIMPLE_END=' . simple_end,
	\ 'PIPE_CHAR=' . pipe_char,
	\ 'PIPE_STACK=' . string(pipe_stack),
	\ 'PIPE_END=' . pipe_end,
	\ 'PIPE_DELIM=' . pipe_delim,
	\ 'PIPE_DELIM_STACK=' . string(pipe_delim_stack),
	\ 'AFTER_PIPE=' . after_pipe,
	\ 'AFTER_PIPE_STACK=' . string(after_pipe_stack),
	\ 'MULTI_FIRST=' . multi_first,
	\ 'MULTI_FIRST_STACK=' . string(multi_first_stack),
	\ 'MULTI_THIRD=' . multi_third,
	\ 'MULTI_THIRD_STACK=' . string(multi_third_stack),
	\ 'HAS_SNIPPET_SIMPLE=' . has_snippet_simple,
	\ 'HAS_SNIPPET_PIPE=' . has_snippet_pipe,
	\ 'HAS_SNIPPET_MULTI=' . has_snippet_multi,
	\ 'NO_SNIPPET_AFTER=' . no_snippet_after
	\ ]

call writefile(output, 'tests/smoke_gabc_snippet.out')

" Exit
quitall!
