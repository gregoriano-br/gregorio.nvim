" Comprehensive test for accidental order validation
" Verifies that pitch comes BEFORE accidental symbol

function! GetSyntaxAt(line, col) abort
  let synstack = synstack(a:line, a:col)
  if empty(synstack)
    return 'NONE'
  endif
  return synIDattr(synstack[-1], 'name')
endfunction

function! GetHighlightAt(line, col) abort
  let synstack = synstack(a:line, a:col)
  if empty(synstack)
    return 'NONE'
  endif
  return synIDattr(synIDtrans(synstack[-1]), 'name')
endfunction

call setline(1, 'name: Accidental Order Test;')
call setline(2, '%%')
call setline(3, '(ixiv) Example from spec')
call setline(4, '(gxg#gy) Multiple accidentals')
call setline(5, '(ax?b) Parenthesized flat')
call setline(6, '(c##d) Soft sharp')
call setline(7, '(eYf) Soft natural')

" Clear and explicitly load syntax
syntax clear
unlet! b:current_syntax
set runtimepath+=/home/laercio/Documentos/gregorio.nvim
source /home/laercio/Documentos/gregorio.nvim/syntax/gabc.vim

" Test 1: (ixiv) - i with flat
let syn_ix_i = GetSyntaxAt(3, 2)
let syn_ix_x = GetSyntaxAt(3, 3)
if syn_ix_i ==# 'gabcAccidental' && syn_ix_x ==# 'gabcAccidental'
  echom 'ACCIDENTAL_IX=PASS'
else
  echom 'ACCIDENTAL_IX=FAIL (got ' . syn_ix_i . ' and ' . syn_ix_x . ')'
  cquit
endif

" Test 2: (ixiv) - standalone i
let syn_i = GetSyntaxAt(3, 4)
if syn_i ==# 'gabcPitch'
  echom 'PITCH_I=PASS'
else
  echom 'PITCH_I=FAIL (expected gabcPitch, got ' . syn_i . ')'
  cquit
endif

" Test 3: (ixiv) - virga
let syn_v = GetSyntaxAt(3, 5)
if syn_v ==# 'gabcModifierSimple'
  echom 'MODIFIER_V=PASS'
else
  echom 'MODIFIER_V=FAIL (expected gabcModifierSimple, got ' . syn_v . ')'
  cquit
endif

" Test 4: (gxg#gy) - first accidental gx
let syn_gx = GetSyntaxAt(4, 2)
if syn_gx ==# 'gabcAccidental'
  echom 'ACCIDENTAL_GX=PASS'
else
  echom 'ACCIDENTAL_GX=FAIL (expected gabcAccidental, got ' . syn_gx . ')'
  cquit
endif

" Test 5: (gxg#gy) - second accidental g#
let syn_gsharp = GetSyntaxAt(4, 4)
if syn_gsharp ==# 'gabcAccidental'
  echom 'ACCIDENTAL_GSHARP=PASS'
else
  echom 'ACCIDENTAL_GSHARP=FAIL (expected gabcAccidental, got ' . syn_gsharp . ')'
  cquit
endif

" Test 6: (gxg#gy) - third accidental gy
let syn_gy = GetSyntaxAt(4, 6)
if syn_gy ==# 'gabcAccidental'
  echom 'ACCIDENTAL_GY=PASS'
else
  echom 'ACCIDENTAL_GY=FAIL (expected gabcAccidental, got ' . syn_gy . ')'
  cquit
endif

" Test 7: Parenthesized flat ax?
let syn_axq = GetSyntaxAt(5, 2)
if syn_axq ==# 'gabcAccidental'
  echom 'ACCIDENTAL_AXQ=PASS'
else
  echom 'ACCIDENTAL_AXQ=FAIL (expected gabcAccidental, got ' . syn_axq . ')'
  cquit
endif

" Test 8: Soft sharp c##
let syn_cdsharp = GetSyntaxAt(6, 2)
if syn_cdsharp ==# 'gabcAccidental'
  echom 'ACCIDENTAL_CDSHARP=PASS'
else
  echom 'ACCIDENTAL_CDSHARP=FAIL (expected gabcAccidental, got ' . syn_cdsharp . ')'
  cquit
endif

" Test 9: Soft natural eY
let syn_eY = GetSyntaxAt(7, 2)
if syn_eY ==# 'gabcAccidental'
  echom 'ACCIDENTAL_EY=PASS'
else
  echom 'ACCIDENTAL_EY=FAIL (expected gabcAccidental, got ' . syn_eY . ')'
  cquit
endif

" Test 10: Accidentals should highlight as Function
let hl = GetHighlightAt(3, 2)
if hl ==# 'Function'
  echom 'ACCIDENTAL_HIGHLIGHT=PASS'
else
  echom 'ACCIDENTAL_HIGHLIGHT=FAIL (expected Function, got ' . hl . ')'
  cquit
endif

echom 'All accidental order tests passed!'
qall!
