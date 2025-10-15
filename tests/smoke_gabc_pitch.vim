" Smoke test for GABC pitch highlighting
" Validates that pitch letters (a-p excluding o) are recognized

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test Pitches;')
call setline(2, '%%')
call setline(3, 'Low(abcdefg) mid(hijklmn) high(p)')
call setline(4, 'Inc(ABCDEFG) MID(HIJKLMN) HIGH(P)')
call setline(5, 'Mixed(aBcDeFg) test(HiJkLmNp)')

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

" Test 1: Lowercase pitch 'a' (line 3, position 5)
let syn_a = GetSyntaxAt(3, 5)
if index(syn_a, 'gabcPitch') >= 0
    echom 'HAS_PITCH_A=PASS'
else
    echom 'HAS_PITCH_A=FAIL'
endif

" Test 2: Lowercase pitch 'g' (line 3, position 11)
let syn_g = GetSyntaxAt(3, 11)
if index(syn_g, 'gabcPitch') >= 0
    echom 'HAS_PITCH_G=PASS'
else
    echom 'HAS_PITCH_G=FAIL'
endif

" Test 3: Lowercase pitch 'n' (line 3, position 24)
let syn_n = GetSyntaxAt(3, 24)
if index(syn_n, 'gabcPitch') >= 0
    echom 'HAS_PITCH_N=PASS'
else
    echom 'HAS_PITCH_N=FAIL'
endif

" Test 4: Lowercase pitch 'p' (line 3, position 32)
let syn_p = GetSyntaxAt(3, 32)
if index(syn_p, 'gabcPitch') >= 0
    echom 'HAS_PITCH_P=PASS'
else
    echom 'HAS_PITCH_P=FAIL'
endif

" Test 5: Uppercase pitch 'A' (line 4, position 5)
let syn_A = GetSyntaxAt(4, 5)
if index(syn_A, 'gabcPitch') >= 0
    echom 'HAS_PITCH_A_UPPER=PASS'
else
    echom 'HAS_PITCH_A_UPPER=FAIL'
endif

" Test 6: Uppercase pitch 'G' (line 4, position 11)
let syn_G = GetSyntaxAt(4, 11)
if index(syn_G, 'gabcPitch') >= 0
    echom 'HAS_PITCH_G_UPPER=PASS'
else
    echom 'HAS_PITCH_G_UPPER=FAIL'
endif

" Test 7: Uppercase pitch 'N' (line 4, position 24)
let syn_N = GetSyntaxAt(4, 24)
if index(syn_N, 'gabcPitch') >= 0
    echom 'HAS_PITCH_N_UPPER=PASS'
else
    echom 'HAS_PITCH_N_UPPER=FAIL'
endif

" Test 8: Uppercase pitch 'P' (line 4, position 32)
let syn_P = GetSyntaxAt(4, 32)
if index(syn_P, 'gabcPitch') >= 0
    echom 'HAS_PITCH_P_UPPER=PASS'
else
    echom 'HAS_PITCH_P_UPPER=FAIL'
endif

" Test 9: Mixed case - lowercase 'a' (line 5, position 7)
let syn_mixed_a = GetSyntaxAt(5, 7)
if index(syn_mixed_a, 'gabcPitch') >= 0
    echom 'HAS_PITCH_MIXED_A=PASS'
else
    echom 'HAS_PITCH_MIXED_A=FAIL'
endif

" Test 10: Mixed case - uppercase 'B' (line 5, position 8)
let syn_mixed_B = GetSyntaxAt(5, 8)
if index(syn_mixed_B, 'gabcPitch') >= 0
    echom 'HAS_PITCH_MIXED_B=PASS'
else
    echom 'HAS_PITCH_MIXED_B=FAIL'
endif

" Test 11: Verify pitches are within gabcSnippet
let syn_in_snippet = GetSyntaxAt(3, 5)
if index(syn_in_snippet, 'gabcSnippet') >= 0
    echom 'IN_SNIPPET=PASS'
else
    echom 'IN_SNIPPET=FAIL'
endif

" Test 12: Verify actual highlight group (using synIDtrans)
call cursor(3, 5)
let pitch_id = synID(line('.'), col('.'), 1)
let pitch_trans = synIDattr(synIDtrans(pitch_id), 'name')
echom 'PITCH_HIGHLIGHT=' . pitch_trans

qall!
