" Smoke test for GABC pitch suffix highlighting
" Validates that pitch inclinatum suffixes (0, 1, 2) are recognized

" Set up runtime path
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Create buffer with test content
enew
call setline(1, 'name: Test Pitch Suffixes;')
call setline(2, '%%')
call setline(3, 'Left(A0B0C0) Right(D1E1F1) None(G2H2I2)')
call setline(4, 'Mixed(A0B1C2) All(J0K1L2M0N1P2)')
call setline(5, 'Lower(abc) NoSuffix(ABC)')

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

" Test 1: Suffix '0' after 'A' (line 3, position 6)
let syn_A0_suffix = GetSyntaxAt(3, 7)
if index(syn_A0_suffix, 'gabcPitchSuffix') >= 0
    echom 'HAS_SUFFIX_0=PASS'
else
    echom 'HAS_SUFFIX_0=FAIL'
endif

" Test 2: Suffix '1' after 'D' (line 3, position 21)
let syn_D1_suffix = GetSyntaxAt(3, 21)
if index(syn_D1_suffix, 'gabcPitchSuffix') >= 0
    echom 'HAS_SUFFIX_1=PASS'
else
    echom 'HAS_SUFFIX_1=FAIL'
endif

" Test 3: Suffix '2' after 'G' (line 3, position 33)
let syn_G2_suffix = GetSyntaxAt(3, 34)
if index(syn_G2_suffix, 'gabcPitchSuffix') >= 0
    echom 'HAS_SUFFIX_2=PASS'
else
    echom 'HAS_SUFFIX_2=FAIL'
endif

" Test 4: Mixed suffixes - '0' after 'A' (line 4, position 7)
let syn_mix_0 = GetSyntaxAt(4, 8)
if index(syn_mix_0, 'gabcPitchSuffix') >= 0
    echom 'HAS_MIXED_0=PASS'
else
    echom 'HAS_MIXED_0=FAIL'
endif

" Test 5: Mixed suffixes - '1' after 'B' (line 4, position 9)
let syn_mix_1 = GetSyntaxAt(4, 10)
if index(syn_mix_1, 'gabcPitchSuffix') >= 0
    echom 'HAS_MIXED_1=PASS'
else
    echom 'HAS_MIXED_1=FAIL'
endif

" Test 6: Mixed suffixes - '2' after 'C' (line 4, position 11)
let syn_mix_2 = GetSyntaxAt(4, 12)
if index(syn_mix_2, 'gabcPitchSuffix') >= 0
    echom 'HAS_MIXED_2=PASS'
else
    echom 'HAS_MIXED_2=FAIL'
endif

" Test 7: All suffixes - '0' after 'J' (line 4, position 20)
let syn_all_0 = GetSyntaxAt(4, 20)
if index(syn_all_0, 'gabcPitchSuffix') >= 0
    echom 'HAS_ALL_0=PASS'
else
    echom 'HAS_ALL_0=FAIL'
endif

" Test 8: All suffixes - '1' after 'K' (line 4, position 22)
let syn_all_1 = GetSyntaxAt(4, 22)
if index(syn_all_1, 'gabcPitchSuffix') >= 0
    echom 'HAS_ALL_1=PASS'
else
    echom 'HAS_ALL_1=FAIL'
endif

" Test 9: All suffixes - '2' after 'L' (line 4, position 24)
let syn_all_2 = GetSyntaxAt(4, 24)
if index(syn_all_2, 'gabcPitchSuffix') >= 0
    echom 'HAS_ALL_2=PASS'
else
    echom 'HAS_ALL_2=FAIL'
endif

" Test 10: Verify lowercase pitches don't get suffix (position 7, 'a')
let syn_lower = GetSyntaxAt(5, 7)
if index(syn_lower, 'gabcPitch') >= 0 && index(syn_lower, 'gabcPitchSuffix') < 0
    echom 'LOWERCASE_NO_SUFFIX=PASS'
else
    echom 'LOWERCASE_NO_SUFFIX=FAIL'
endif

" Test 11: Verify uppercase without suffix (position 21, 'A')
let syn_no_suffix = GetSyntaxAt(5, 21)
if index(syn_no_suffix, 'gabcPitch') >= 0
    echom 'UPPERCASE_PITCH=PASS'
else
    echom 'UPPERCASE_PITCH=FAIL'
endif

" Test 12: Verify pitch before suffix is recognized (position 6, 'A' before '0')
let syn_pitch_before_suffix = GetSyntaxAt(3, 6)
if index(syn_pitch_before_suffix, 'gabcPitch') >= 0
    echom 'PITCH_BEFORE_SUFFIX=PASS'
else
    echom 'PITCH_BEFORE_SUFFIX=FAIL'
endif

" Test 13: Verify highlight group for suffix
call cursor(3, 7)
let suffix_id = synID(line('.'), col('.'), 1)
let suffix_trans = synIDattr(synIDtrans(suffix_id), 'name')
echom 'SUFFIX_HIGHLIGHT=' . suffix_trans

qall!
