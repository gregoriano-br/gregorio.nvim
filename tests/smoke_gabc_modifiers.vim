" Smoke test for GABC pitch modifiers and accidentals
" Tests all pitch modifier types: initio debilis, oriscus, simple, compound, special, and accidentals

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

" Test content with various modifiers
call setline(1, 'name: Test;')
call setline(2, '%%')
call setline(3, '(g) Simple pitch')
call setline(4, '(-g) Initio debilis')
call setline(5, '(go) Oriscus')
call setline(6, '(gO1) Oriscus scapus with suffix')
call setline(7, '(gq) Quadratum')
call setline(8, '(gw) Quilisma')
call setline(9, '(gW) Quilisma quadratum')
call setline(10, '(gv) Virga right')
call setline(11, '(gV) Virga left')
call setline(12, '(gvv) Bivirga')
call setline(13, '(gvvv) Trivirga')
call setline(14, '(gs) Stropha')
call setline(15, '(gss) Distropha')
call setline(16, '(gsss) Tristropha')
call setline(17, '(g~) Liquescent deminutus')
call setline(18, '(g<) Augmented liquescent')
call setline(19, '(g>) Diminished liquescent')
call setline(20, '(g=) Linea')
call setline(21, '(gr) Punctum cavum')
call setline(22, '(gR) Punctum quadratum lines')
call setline(23, '(gr0) Punctum cavum lines')
call setline(24, '(xg) Flat')
call setline(25, '(#g) Sharp')
call setline(26, '(yg) Natural')
call setline(27, '(x?g) Parenthesized flat')
call setline(28, '(#?g) Parenthesized sharp')
call setline(29, '(y?g) Parenthesized natural')
call setline(30, '(##g) Soft sharp')
call setline(31, '(Yg) Soft natural')

" Clear and explicitly load syntax
syntax clear
unlet! b:current_syntax
set runtimepath+=/home/laercio/Documentos/gregorio.nvim
source /home/laercio/Documentos/gregorio.nvim/syntax/gabc.vim

" Test 1: Simple pitch should be Character (translates to Constant in default colorscheme)
let result = GetHighlightAt(3, 2)
if result ==# 'Constant'
  echom 'HAS_PITCH=PASS'
else
  echom 'HAS_PITCH=FAIL (expected Constant, got ' . result . ')'
  cquit
endif

" Test 2: Initio debilis - should be on position 2 (the dash before g)
let syntax = GetSyntaxAt(4, 2)
if syntax ==# 'gabcInitioDebilis'
  echom 'HAS_INITIO_DEBILIS=PASS'
else
  echom 'HAS_INITIO_DEBILIS=FAIL (expected gabcInitioDebilis, got ' . syntax . ')'
  cquit
endif

" Test 3: Initio debilis highlight should be Identifier
let highlight = GetHighlightAt(4, 2)
if highlight ==# 'Identifier'
  echom 'INITIO_DEBILIS_HIGHLIGHT=PASS'
else
  echom 'INITIO_DEBILIS_HIGHLIGHT=FAIL (expected Identifier, got ' . highlight . ')'
  cquit
endif

" Test 4: Oriscus (lowercase o)
let syntax = GetSyntaxAt(5, 3)
if syntax ==# 'gabcOriscus'
  echom 'HAS_ORISCUS=PASS'
else
  echom 'HAS_ORISCUS=FAIL (expected gabcOriscus, got ' . syntax . ')'
  cquit
endif

" Test 5: Oriscus scapus (uppercase O)
let syntax = GetSyntaxAt(6, 3)
if syntax ==# 'gabcOriscus'
  echom 'HAS_ORISCUS_SCAPUS=PASS'
else
  echom 'HAS_ORISCUS_SCAPUS=FAIL (expected gabcOriscus, got ' . syntax . ')'
  cquit
endif

" Test 6: Oriscus suffix
let syntax = GetSyntaxAt(6, 4)
if syntax ==# 'gabcOriscusSuffix'
  echom 'HAS_ORISCUS_SUFFIX=PASS'
else
  echom 'HAS_ORISCUS_SUFFIX=FAIL (expected gabcOriscusSuffix, got ' . syntax . ')'
  cquit
endif

" Test 7: Oriscus suffix highlight should be Number (translates to Constant)
let highlight = GetHighlightAt(6, 4)
if highlight ==# 'Constant'
  echom 'ORISCUS_SUFFIX_HIGHLIGHT=PASS'
else
  echom 'ORISCUS_SUFFIX_HIGHLIGHT=FAIL (expected Constant, got ' . highlight . ')'
  cquit
endif

" Test 8: Quadratum modifier
let syntax = GetSyntaxAt(7, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_QUADRATUM=PASS'
else
  echom 'HAS_QUADRATUM=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 9: Quilisma modifier
let syntax = GetSyntaxAt(8, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_QUILISMA=PASS'
else
  echom 'HAS_QUILISMA=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 10: Quilisma quadratum modifier
let syntax = GetSyntaxAt(9, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_QUILISMA_QUAD=PASS'
else
  echom 'HAS_QUILISMA_QUAD=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 11: Virga right
let syntax = GetSyntaxAt(10, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_VIRGA_RIGHT=PASS'
else
  echom 'HAS_VIRGA_RIGHT=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 12: Virga left
let syntax = GetSyntaxAt(11, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_VIRGA_LEFT=PASS'
else
  echom 'HAS_VIRGA_LEFT=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 13: Bivirga compound modifier (position 3 is first 'v' of 'vv')
let syntax = GetSyntaxAt(12, 3)
if syntax ==# 'gabcModifierCompound'
  echom 'HAS_BIVIRGA=PASS'
else
  echom 'HAS_BIVIRGA=FAIL (expected gabcModifierCompound, got ' . syntax . ')'
  cquit
endif

" Test 14: Trivirga compound modifier
let syntax = GetSyntaxAt(13, 3)
if syntax ==# 'gabcModifierCompound'
  echom 'HAS_TRIVIRGA=PASS'
else
  echom 'HAS_TRIVIRGA=FAIL (expected gabcModifierCompound, got ' . syntax . ')'
  cquit
endif

" Test 15: Stropha
let syntax = GetSyntaxAt(14, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_STROPHA=PASS'
else
  echom 'HAS_STROPHA=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 16: Distropha compound modifier
let syntax = GetSyntaxAt(15, 3)
if syntax ==# 'gabcModifierCompound'
  echom 'HAS_DISTROPHA=PASS'
else
  echom 'HAS_DISTROPHA=FAIL (expected gabcModifierCompound, got ' . syntax . ')'
  cquit
endif

" Test 17: Tristropha compound modifier
let syntax = GetSyntaxAt(16, 3)
if syntax ==# 'gabcModifierCompound'
  echom 'HAS_TRISTROPHA=PASS'
else
  echom 'HAS_TRISTROPHA=FAIL (expected gabcModifierCompound, got ' . syntax . ')'
  cquit
endif

" Test 18: Liquescent deminutus
let syntax = GetSyntaxAt(17, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_LIQUESCENT_DEMINUTUS=PASS'
else
  echom 'HAS_LIQUESCENT_DEMINUTUS=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 19: Augmented liquescent
let syntax = GetSyntaxAt(18, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_AUGMENTED_LIQUESCENT=PASS'
else
  echom 'HAS_AUGMENTED_LIQUESCENT=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 20: Diminished liquescent
let syntax = GetSyntaxAt(19, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_DIMINISHED_LIQUESCENT=PASS'
else
  echom 'HAS_DIMINISHED_LIQUESCENT=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 21: Linea
let syntax = GetSyntaxAt(20, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_LINEA=PASS'
else
  echom 'HAS_LINEA=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 22: Punctum cavum
let syntax = GetSyntaxAt(21, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_PUNCTUM_CAVUM=PASS'
else
  echom 'HAS_PUNCTUM_CAVUM=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 23: Punctum quadratum surrounded
let syntax = GetSyntaxAt(22, 3)
if syntax ==# 'gabcModifierSimple'
  echom 'HAS_PUNCTUM_QUAD_SURR=PASS'
else
  echom 'HAS_PUNCTUM_QUAD_SURR=FAIL (expected gabcModifierSimple, got ' . syntax . ')'
  cquit
endif

" Test 24: Punctum cavum surrounded (r0) - special compound
let syntax = GetSyntaxAt(23, 3)
if syntax ==# 'gabcModifierSpecial'
  echom 'HAS_PUNCTUM_CAVUM_SURR=PASS'
else
  echom 'HAS_PUNCTUM_CAVUM_SURR=FAIL (expected gabcModifierSpecial, got ' . syntax . ')'
  cquit
endif

" Test 25: Flat accidental (includes pitch)
let syntax = GetSyntaxAt(24, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_FLAT=PASS'
else
  echom 'HAS_FLAT=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 26: Flat highlight should be Function
let highlight = GetHighlightAt(24, 2)
if highlight ==# 'Function'
  echom 'FLAT_HIGHLIGHT=PASS'
else
  echom 'FLAT_HIGHLIGHT=FAIL (expected Function, got ' . highlight . ')'
  cquit
endif

" Test 27: Sharp accidental
let syntax = GetSyntaxAt(25, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_SHARP=PASS'
else
  echom 'HAS_SHARP=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 28: Natural accidental
let syntax = GetSyntaxAt(26, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_NATURAL=PASS'
else
  echom 'HAS_NATURAL=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 29: Parenthesized flat
let syntax = GetSyntaxAt(27, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_PAREN_FLAT=PASS'
else
  echom 'HAS_PAREN_FLAT=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 30: Parenthesized sharp
let syntax = GetSyntaxAt(28, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_PAREN_SHARP=PASS'
else
  echom 'HAS_PAREN_SHARP=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 31: Parenthesized natural
let syntax = GetSyntaxAt(29, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_PAREN_NATURAL=PASS'
else
  echom 'HAS_PAREN_NATURAL=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 32: Soft sharp (##)
let syntax = GetSyntaxAt(30, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_SOFT_SHARP=PASS'
else
  echom 'HAS_SOFT_SHARP=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 33: Soft natural (Y)
let syntax = GetSyntaxAt(31, 2)
if syntax ==# 'gabcAccidental'
  echom 'HAS_SOFT_NATURAL=PASS'
else
  echom 'HAS_SOFT_NATURAL=FAIL (expected gabcAccidental, got ' . syntax . ')'
  cquit
endif

" Test 34: Modifier highlight should be Identifier
let highlight = GetHighlightAt(7, 3)
if highlight ==# 'Identifier'
  echom 'MODIFIER_HIGHLIGHT=PASS'
else
  echom 'MODIFIER_HIGHLIGHT=FAIL (expected Identifier, got ' . highlight . ')'
  cquit
endif

echom 'All tests passed!'
qall!
