" Smoke test for GABC/NABC snippet alternation
" Validates that | delimiter and snippets are recognized within ()

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test Snippets;')
call setline(2, '%%')
call setline(3, 'Simple(gabc1) text(h)')
call setline(4, 'Alt(gabc1|nabc1) more(i)')
call setline(5, 'Multi(g1|n1|g2|n2) end(j)')

" Set filetype and force syntax reload
let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax
sleep 300m

" Test 1: Simple notation - opening delimiter (
call cursor(3, 7)
let open1 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 2: Simple notation - GABC snippet content
call cursor(3, 8)
let gabc_simple = synIDattr(synID(line('.'), col('.'), 1), 'name')
let gabc_simple_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 3: Simple notation - closing delimiter )
call cursor(3, 13)
let close1 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 4: Alternation - pipe delimiter |
call cursor(4, 10)
let pipe1 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 5: Alternation - NABC snippet after |
call cursor(4, 11)
let nabc1 = synIDattr(synID(line('.'), col('.'), 1), 'name')
let nabc1_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

" Test 6: Multi alternation - second pipe
call cursor(5, 10)
let pipe2 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 7: Multi alternation - second GABC (g2)
call cursor(5, 11)
let gabc2 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 8: Multi alternation - third pipe
call cursor(5, 13)
let pipe3 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 9: Multi alternation - second NABC (n2)
call cursor(5, 14)
let nabc2 = synIDattr(synID(line('.'), col('.'), 1), 'name')

" Test 10: Check that notation region is present in stack
call cursor(4, 8)
let in_notation_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
let has_notation = (index(in_notation_stack, 'gabcNotation') >= 0 ? 'PASS' : 'FAIL')

" Test 11: Verify no leakage after )
call cursor(3, 14)
let after_close = synIDattr(synID(line('.'), col('.'), 1), 'name')
let after_close_stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
let no_leak = (index(after_close_stack, 'gabcNotation') < 0 ? 'PASS' : 'FAIL')

" Write results
let output = [
	\ 'OPEN1=' . open1,
	\ 'GABC_SIMPLE=' . gabc_simple,
	\ 'GABC_SIMPLE_STACK=' . string(gabc_simple_stack),
	\ 'CLOSE1=' . close1,
	\ 'PIPE1=' . pipe1,
	\ 'NABC1=' . nabc1,
	\ 'NABC1_STACK=' . string(nabc1_stack),
	\ 'PIPE2=' . pipe2,
	\ 'GABC2=' . gabc2,
	\ 'PIPE3=' . pipe3,
	\ 'NABC2=' . nabc2,
	\ 'HAS_NOTATION=' . has_notation,
	\ 'AFTER_CLOSE=' . after_close,
	\ 'AFTER_CLOSE_STACK=' . string(after_close_stack),
	\ 'NO_LEAK=' . no_leak
	\ ]

call writefile(output, 'tests/smoke_gabc_snippets.out')

" Exit
quitall!
