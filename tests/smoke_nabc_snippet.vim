" Test NABC snippet syntax highlighting
" This test validates that nabcSnippet is correctly identified after | delimiters

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test NABC Snippet;')
call setline(2, '%%')
call setline(3, 'Sim(gabc1|nabc1)')
call setline(4, 'Tri(gabc1|nabc1|gabc2)')
call setline(5, 'Qua(gabc1|nabc1|gabc2|nabc2)')

" Set filetype and force syntax reload
let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim

" Wait for syntax
sleep 300m

" Helper function to get syntax groups at a position
function! GetSyntaxAt(line, col)
    let synstack = synstack(a:line, a:col)
    return map(synstack, 'synIDattr(v:val, "name")')
endfunction

" Test 1: Simple alternation (gabc1|nabc1)
" Line 3: Sim(gabc1|nabc1)
"         ^  ^    ^^    ^
"         |  |    ||    |
"         |  |    ||    ) - position 17
"         |  |    || - nabcSnippet - positions 13-17
"         |  |    | - delimiter - position 12
"         |  | - gabcSnippet - positions 5-9
"         |  ( - position 4
"         S - position 1

" Check gabcSnippet in simple pattern (position 6 = 'a' in 'gabc1')
let syn_simple_gabc = GetSyntaxAt(3, 6)
if index(syn_simple_gabc, 'gabcSnippet') >= 0
    echom 'HAS_GABC_SIMPLE=PASS'
else
    echom 'HAS_GABC_SIMPLE=FAIL'
endif

" Check nabcSnippet in simple pattern (position 14 = 'a' in 'nabc1')
let syn_simple_nabc = GetSyntaxAt(3, 14)
if index(syn_simple_nabc, 'nabcSnippet') >= 0
    echom 'HAS_NABC_SIMPLE=PASS'
else
    echom 'HAS_NABC_SIMPLE=FAIL'
endif

" Test 2: Triple alternation (gabc1|nabc1|gabc2)
" Line 4: Tri(gabc1|nabc1|gabc2)
"         ^  ^    ^^    ^^    ^
"         |  |    ||    ||    |
"         |  |    ||    || - nabcSnippet - positions 19-23
"         |  |    ||    | - delimiter - position 18
"         |  |    || - nabcSnippet - positions 13-17
"         |  |    | - delimiter - position 12
"         |  | - gabcSnippet - positions 5-9
"         T - position 1

" Check first nabcSnippet (position 14 = 'a' in first 'nabc1')
let syn_triple_nabc1 = GetSyntaxAt(4, 14)
if index(syn_triple_nabc1, 'nabcSnippet') >= 0
    echom 'HAS_NABC_TRIPLE_1=PASS'
else
    echom 'HAS_NABC_TRIPLE_1=FAIL'
endif

" Check second snippet after | (position 20 = 'a' in 'gabc2')
" Note: After the second |, we expect nabcSnippet, not gabcSnippet
" because the pattern alternates: gabc|NABC|NABC|NABC...
let syn_triple_gabc2 = GetSyntaxAt(4, 20)
if index(syn_triple_gabc2, 'nabcSnippet') >= 0
    echom 'HAS_NABC_TRIPLE_2=PASS (gabc2 is matched as nabcSnippet - expected)'
else
    echom 'HAS_NABC_TRIPLE_2=FAIL'
endif

" Test 3: Quad alternation (gabc1|nabc1|gabc2|nabc2)
" Line 5: Qua(gabc1|nabc1|gabc2|nabc2)
"         ^  ^    ^^    ^^    ^^    ^
"         |  |    ||    ||    ||    |
"         |  |    ||    ||    || - nabcSnippet - positions 25-29
"         |  |    ||    ||    | - delimiter - position 24
"         |  |    ||    || - nabcSnippet - positions 19-23
"         |  |    ||    | - delimiter - position 18
"         |  |    || - nabcSnippet - positions 13-17
"         |  |    | - delimiter - position 12
"         |  | - gabcSnippet - positions 5-9
"         Q - position 1

" Check first nabcSnippet (position 14 = 'a' in first 'nabc1')
let syn_quad_nabc1 = GetSyntaxAt(5, 14)
if index(syn_quad_nabc1, 'nabcSnippet') >= 0
    echom 'HAS_NABC_QUAD_1=PASS'
else
    echom 'HAS_NABC_QUAD_1=FAIL'
endif

" Check second snippet after | (position 20 = 'a' in 'gabc2')
let syn_quad_nabc2 = GetSyntaxAt(5, 20)
if index(syn_quad_nabc2, 'nabcSnippet') >= 0
    echom 'HAS_NABC_QUAD_2=PASS'
else
    echom 'HAS_NABC_QUAD_2=FAIL'
endif

" Check third snippet after | (position 26 = 'a' in 'nabc2')
let syn_quad_nabc3 = GetSyntaxAt(5, 26)
if index(syn_quad_nabc3, 'nabcSnippet') >= 0
    echom 'HAS_NABC_QUAD_3=PASS'
else
    echom 'HAS_NABC_QUAD_3=FAIL'
endif

qall!
