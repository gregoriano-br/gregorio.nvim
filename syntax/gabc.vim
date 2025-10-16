" Vim syntax file for GABC (fresh minimal)

" Guard: allow re-sourcing during dev if needed
if exists('b:current_syntax') && !exists('g:gabc_devmode')
	finish
endif

" Include LaTeX syntax for embedded LaTeX in <v> tags
" Save current syntax state
let s:current_syntax_save = exists('b:current_syntax') ? b:current_syntax : ''
unlet! b:current_syntax

" Try to load tex syntax
try
	syntax include @texSyntax $VIMRUNTIME/syntax/tex.vim
catch
	" If tex.vim is not available, create an empty cluster
	syntax cluster texSyntax
endtry

" Don't restore b:current_syntax yet - let it stay unset until end of file

" 1) Section separator: a line that is exactly '%%' (must come before comment)
syntax match gabcSectionSeparator /^%%$/ nextgroup=gabcNotes skipnl skipwhite
" Dedicated one-line region covering only the separator line, to avoid inclusion in notes
" Separator line is matched but not assigned to a region; this avoids interfering with notes start

" 2) Comments: any % starts a comment (but not the standalone %% line)
"   - Line comments at BOL: '%%...' (non-separator) and '%...'
syntax match gabcComment /^%%.\+/ containedin=gabcHeaders,gabcNotes
syntax match gabcComment /^%[^%].*/ containedin=gabcHeaders,gabcNotes
"   - Single '%' line
syntax match gabcComment /^%$/ containedin=gabcHeaders,gabcNotes
"   - Inline comments: % anywhere after some preceding non-% character
syntax match gabcComment /\([^%]\)\@<=%.*/ contains=@NoSpell containedin=gabcHeaders,gabcNotes

" 3) Regions: header (from BOF up to just before %%), notes (from %% to EOF)
" Strategy: gabcHeaders goes from BOF to just before %%, gabcNotes goes from line after %% to EOF
" The %% line itself is handled by gabcSectionSeparator
syntax region gabcHeaders start=/\%^/ end=/^%%$/me=e-2 keepend
syntax match gabcSectionSeparator /^%%$/ nextgroup=gabcNotes skipnl skipwhite skipempty
syntax region gabcNotes start=/^/ end=/\%$/ keepend contains=gabcComment,gabcClef,gabcLyricCentering,gabcTranslation,gabcNotation,gabcSyllable contained

" Highlight groups (do not color the regions themselves)
highlight link gabcSectionSeparator Special
highlight link gabcComment Comment

" Header pairs inside gabcHeaders: HEADER:VALUE;
" - Field (before colon), Colon, Value (until semicolon), Semicolon
syntax match gabcHeaderField /^\s*[^%:][^:]*\ze:/ containedin=gabcHeaders nextgroup=gabcHeaderColon
syntax match gabcHeaderColon /:/ contained containedin=gabcHeaders nextgroup=gabcHeaderValue skipwhite
syntax match gabcHeaderValue /\%(:\s*\)\@<=[^;]*/ contained containedin=gabcHeaders nextgroup=gabcHeaderSemicolon
syntax match gabcHeaderSemicolon /;/ contained containedin=gabcHeaders

" Header highlight links (use default to avoid overriding colorschemes)
highlight default link gabcHeaderField Keyword
highlight default link gabcHeaderColon Operator
highlight default link gabcHeaderValue String
highlight default link gabcHeaderSemicolon Delimiter

" Clefs inside notes region: c1..c4 | cb1..cb4 | f1..f4 with optional @ connectors
" Restrict to whole parenthesized group so we don't match inside other note clusters
syntax match gabcClef /(\%(cb\|[cf]\)[1-4]\%(@\%(cb\|[cf]\)[1-4]\)*)/ containedin=gabcNotes contains=gabcClefLetter,gabcClefNumber,gabcClefConnector
syntax match gabcClefLetter /\(cb\|[cf]\)/ contained containedin=gabcClef
syntax match gabcClefNumber /[1-4]/ contained containedin=gabcClef
syntax match gabcClefConnector /@/ contained containedin=gabcClef

" Clef highlight links
highlight link gabcClefLetter Keyword
highlight link gabcClefNumber Number
highlight link gabcClefConnector Operator

" Lyric centering delimiters: {...} for centering a group of letters
" Must be defined before gabcSyllable to take precedence
syntax region gabcLyricCentering matchgroup=gabcLyricCenteringDelim start=/{/ end=/}/ keepend oneline containedin=gabcNotes

" Translation delimiters: [...] for alternative translation text
syntax region gabcTranslation matchgroup=gabcTranslationDelim start=/\[/ end=/\]/ keepend oneline containedin=gabcNotes

" Musical notation: (...) contains alternating GABC and NABC snippets separated by |
" Structure: (gabc1|nabc1|gabc2|nabc2|...)
syntax region gabcNotation matchgroup=gabcNotationDelim start=/(/ end=/)/ keepend oneline containedin=gabcNotes

" KNOWN LIMITATION: Perfect GABC/NABC alternation is not possible with Vim syntax
" Vim's regex-based syntax engine does not support stateful alternation (counting delimiters).
" Multiple approaches were attempted:
" 1. Regions with lookbehinds - failed (snippets not activated)
" 2. Matchgroup + nextgroup chains - failed (region conflicts)
" 3. Position-specific patterns with \@<= - failed (lookbehind doesn't work inside regions)
" 4. Numbered regions with nextgroup - failed (all matched to last region)
" 5. Variable-length lookbehind patterns - failed (incorrect matching)
"
" CURRENT APPROACH: Simple transparent groups for basic structure
" - gabcSnippet: matches first snippet (after opening paren)
" - nabcSnippet: matches subsequent snippets (after pipe delimiter)
" - Both are transparent to allow GABC elements to highlight correctly
" - Limitation: GABC elements may appear in NABC context (acceptable tradeoff)
"
" FUTURE IMPROVEMENT: Implement proper alternation using Tree-sitter parser

" GABC snippet: First position (immediately after opening paren)
syntax match gabcSnippet /(\@<=[^|)]\+/ contained containedin=gabcNotation transparent

" NABC snippet: All subsequent positions (after pipe delimiter)
" Contains St. Gall and Laon neume codes
" Note: NOT transparent - contains specific NABC syntax elements
syntax match nabcSnippet /|\@<=[^|)]\+/ contained containedin=gabcNotation contains=nabcBasicGlyphDescriptor,nabcComplexGlyphDelimiter

" ============================================================================
" NABC GLYPH DESCRIPTORS: Structured grouping of neume elements
" ============================================================================

" BASIC GLYPH DESCRIPTOR: neume + optional(glyph_modifier) + optional(pitch_descriptor)
" This is the fundamental unit of NABC notation, representing a single neume
" with its modifiers and pitch information.
" Examples:
"   vi       - simple neume (virga)
"   viS      - neume with modifier
"   viha     - neume with pitch descriptor
"   viS2ha   - neume with modifier and pitch descriptor
"
" Pattern: Match complete sequence as a region
" Region boundaries:
"   start: neume code (2 letters)
"   end: lookahead for non-modifier/non-pitch character or end of snippet
syntax match nabcBasicGlyphDescriptor 
  \ /\(vi\|pu\|ta\|gr\|cl\|pe\|po\|to\|ci\|sc\|pf\|sf\|tr\|st\|ds\|ts\|tg\|bv\|tv\|pq\|pr\|pi\|vs\|or\|sa\|ql\|qi\|pt\|ni\|oc\|un\)\([SGM\->~][1-9]\?\)\?\(h[a-np]\)\?/
  \ contained containedin=nabcSnippet
  \ contains=nabcNeume,nabcGlyphModifier,nabcGlyphModifierNumber,nabcPitchDescriptorH,nabcPitchDescriptorPitch
  \ transparent

" COMPLEX GLYPH DESCRIPTOR DELIMITER: '!' separates basic glyph descriptors
" Used to concatenate multiple basic glyph descriptors into a complex descriptor
" Example: vi!pu!ta (three basic descriptors forming a complex descriptor)
syntax match nabcComplexGlyphDelimiter /!/ contained containedin=nabcSnippet

" Highlight group for complex glyph descriptor delimiter
highlight link nabcComplexGlyphDelimiter Delimiter

" ============================================================================
" NABC NEUMES: St. Gall and Laon neume codes
" ============================================================================
" Unified list from St. Gall and Laon codifications
" These are keyword-like identifiers for specific neume shapes in early notation

" NABC neume codes (2-letter codes)
" Common to both St. Gall and Laon:
" vi=virga, pu=punctum, ta=tractulus, gr=gravis, cl=clivis, pe=pes, po=porrectus
" to=torculus, ci=climacus, sc=scandicus, pf=porrectus flexus, sf=scandicus flexus
" tr=torculus resupinus, or=oriscus, ds=distropha, ts=tristropha, tg=trigonus
" bv=bivirga, tv=trivirga, pr=pressus maior, pi=pressus minor, vs=virga strata
" sa=salicus, pq=pes quassus, ql=quilisma, pt=pes stratus, ni=nihil (placeholder)
"
" St. Gall specific:
" st=stropha
"
" Laon specific:
" oc=oriscus-clivis, un=uncinus
"
" Pattern: 2-letter codes, case-sensitive
" Must use simple pattern without word boundaries since NABC codes can be
" followed by modifiers (-, ~, ', etc.) without spaces
syntax match nabcNeume /\(vi\|pu\|ta\|gr\|cl\|pe\|po\|to\|ci\|sc\|pf\|sf\|tr\|st\|ds\|ts\|tg\|bv\|tv\|pq\|pr\|pi\|vs\|or\|sa\|ql\|qi\|pt\|ni\|oc\|un\)/ contained containedin=nabcSnippet

" NABC neume highlight group
highlight link nabcNeume Keyword

" NABC GLYPH MODIFIERS: Apply to St. Gall and Laon neumes
" These modifiers follow immediately after the neume code
" All can optionally take a numeric suffix 1-9
"
" S = modification of the mark
" G = modification of the grouping (neumatic break)
" M = melodic modification
" - = addition of episema
" > = augmentive liquescence
" ~ = diminutive liquescence
"
" Pattern: modifier character (simple match within nabcSnippet)
" Note: Uses same highlighting as GABC modifiers for consistency
syntax match nabcGlyphModifier /[SGM\->~]/ contained containedin=nabcSnippet

" NABC glyph modifier numeric suffix: 1-9 immediately after modifier
" Uses positive lookbehind to match digit only after a glyph modifier
syntax match nabcGlyphModifierNumber /\([SGM\->~]\)\@<=[1-9]/ contained containedin=nabcSnippet

" NABC highlight groups for modifiers (reuse GABC modifier styling)
highlight link nabcGlyphModifier SpecialChar
highlight link nabcGlyphModifierNumber Number

" NABC PITCH DESCRIPTOR: Elevates or lowers the neume relative to others
" Follows immediately after glyph modifier (if present) or neume code
" Format: 'h' followed by pitch letter [a-np]
" Example: viha (virga at pitch 'a'), puShb (punctum with S modifier at pitch 'b')
"
" 'h' = height/pitch descriptor indicator (highlighted as Function)
" [a-np] = target pitch (highlighted as parameter, like function argument)
syntax match nabcPitchDescriptorH /h/ contained containedin=nabcSnippet
syntax match nabcPitchDescriptorPitch /\(h\)\@<=[a-np]/ contained containedin=nabcSnippet

" NABC pitch descriptor highlight groups
highlight link nabcPitchDescriptorH Function
highlight link nabcPitchDescriptorPitch Identifier

" GABC pitches: a-p (excluding 'o'), both lowercase (punctum quadratum) and uppercase (punctum inclinatum)
" Lowercase: a b c d e f g h i j k l m n p (punctum quadratum - square note)
" Uppercase: A B C D E F G H I J K L M N P (punctum inclinatum - inclined note)
" Note: 'o' and 'O' are excluded as they are not valid pitch letters in GABC
" Character class approach: [a-np] gets a-n and p, [A-NP] gets A-N and P
syntax match gabcPitch /[a-npA-NP]/ contained containedin=gabcSnippet

" Pitch inclinatum suffix: optional 0, 1, or 2 after uppercase pitches (A-NP)
" 0: left-leaning (descending interval)
" 1: right-leaning (ascending interval)
" 2: no-leaning (unison/same pitch)
" Pattern matches the digit immediately after an uppercase pitch letter
syntax match gabcPitchSuffix /\([A-NP]\)\@<=[012]/ contained containedin=gabcSnippet

" GABC ACCIDENTALS: alter the pitch (includes pitch letter for position on staff)
" The pitch letter comes BEFORE the accidental symbol
" Example: (ixiv) = i + x (flat on i) + i + v (virga)
" NOTE: Accidentals use lowercase pitch letters ONLY to indicate staff position

" Accidentals with parentheses: pitch followed by x?, #?, y?
" Parentheses indicate cautionary/editorial accidentals
syntax match gabcAccidental /[a-np][x#y]?/ contained containedin=gabcSnippet

" Double sharp: pitch followed by ## (soft sharp)
syntax match gabcAccidental /[a-np]##/ contained containedin=gabcSnippet

" Soft natural: pitch followed by Y
syntax match gabcAccidental /[a-np]Y/ contained containedin=gabcSnippet

" Basic accidentals: pitch followed by x (flat), # (sharp), y (natural)
syntax match gabcAccidental /[a-np][x#y]/ contained containedin=gabcSnippet

" GABC PITCH MODIFIERS: symbols that modify note appearance/meaning

" Initio debilis: - before pitch (weakened start)
" Uses positive lookahead to match only when followed by a valid pitch
syntax match gabcInitioDebilis /-\([a-npA-NP]\)\@=/ contained containedin=gabcSnippet

" Oriscus modifiers: o (oriscus), O (oriscus scapus)
" Can be followed by optional suffix 0 or 1
syntax match gabcOriscus /[oO]/ contained containedin=gabcSnippet

" Oriscus suffix: 0 or 1 after o or O
syntax match gabcOriscusSuffix /\([oO]\)\@<=[01]/ contained containedin=gabcSnippet

" Simple single-character modifiers (after pitch)
" q: quadratum, w: quilisma, W: quilisma quadratum
" v: virga (stem right), V: virga (stem left)
" s: stropha, ~: liquescent deminutus
" <: augmented liquescent, >: diminished liquescent
" =: linea, r: punctum cavum, R: punctum quadratum surrounded by lines
" .: punctum mora vocis (rhythmic dot)
" NOTE: These are defined BEFORE compound modifiers so compounds take precedence
syntax match gabcModifierSimple /[qwWvVs~<>=rR.]/ contained containedin=gabcSnippet

" Special modifiers with numbers (r followed by digit)
" r0: punctum cavum surrounded by lines
" r1-r8: various signs above staff (musica ficta, accents, etc.)
" MUST be defined AFTER simple 'r' to take precedence
" Pattern captures 'r' followed by single digit 0-8
syntax match gabcModifierSpecial /r[0-8]/ contained containedin=gabcSnippet

" Horizontal episema: _ optionally followed by suffix 0-5
" The underscore is the main modifier, suffix indicates episema length/position
syntax match gabcModifierEpisema /_/ contained containedin=gabcSnippet

" Episema suffix number: digit 0-5 immediately after _
" Uses positive lookbehind to match digit only after _
syntax match gabcModifierEpisemaNumber /\(_\)\@<=[0-5]/ contained containedin=gabcSnippet

" Ictus: ' optionally followed by suffix 0 or 1
" The apostrophe is the main modifier, suffix indicates ictus type
syntax match gabcModifierIctus /'/ contained containedin=gabcSnippet

" Ictus suffix number: digit 0 or 1 immediately after '
" Uses positive lookbehind to match digit only after '
syntax match gabcModifierIctusNumber /\('\)\@<=[01]/ contained containedin=gabcSnippet

" Compound modifiers: multi-character sequences
" MUST be defined AFTER simple modifiers to take precedence in Vim syntax matching
" Order matters: longer patterns last to take highest precedence
syntax match gabcModifierCompound /vv/ contained containedin=gabcSnippet   " bivirga
syntax match gabcModifierCompound /ss/ contained containedin=gabcSnippet   " distropha
syntax match gabcModifierCompound /vvv/ contained containedin=gabcSnippet  " trivirga
syntax match gabcModifierCompound /sss/ contained containedin=gabcSnippet  " tristropha

" GABC SEPARATION BARS: Divisio marks for phrase/section boundaries
" Bars indicate liturgical divisions with varying weights
" Order matters: compound bars (::, :?) BEFORE simple bars to take precedence

" Compound bars (define first for higher precedence)
syntax match gabcBarDouble /::/ contained containedin=gabcSnippet          " divisio finalis (double full bar)
syntax match gabcBarDotted /:?/ contained containedin=gabcSnippet          " dotted divisio maior

" Simple bars
syntax match gabcBarMaior /:/ contained containedin=gabcSnippet            " divisio maior (full bar)
syntax match gabcBarMinor /;/ contained containedin=gabcSnippet            " divisio minor (half bar)
syntax match gabcBarMinima /,/ contained containedin=gabcSnippet           " divisio minima (quarter bar)
syntax match gabcBarMinimaOcto /\^/ contained containedin=gabcSnippet      " divisio minimis/eighth bar
syntax match gabcBarVirgula /`/ contained containedin=gabcSnippet          " virgula

" Bar numeric suffixes (use lookbehind to match only after specific bars)
" divisio minor (;) can have suffixes 1-8
syntax match gabcBarMinorSuffix /\(;\)\@<=[1-8]/ contained containedin=gabcSnippet

" divisio minima (,), minimis (^), and virgula (`) can have optional suffix 0
syntax match gabcBarZeroSuffix /\([,\^`]\)\@<=0/ contained containedin=gabcSnippet

" Bar modifiers
" ' = vertical episema (already defined as gabcModifierIctus in rhythmic section)
" _ = bar brace (already defined as gabcModifierEpisema in rhythmic section)
" These modifiers reuse existing highlight groups when applied to bars

" GABC CUSTOS: End-of-line guide indicating next pitch on following line
" Syntax: pitch+ (e.g., f+, g+, a+)
" The custos shows which pitch begins the next line
" Both pitch and + are highlighted as operators for visual consistency
" NOTE: Custos uses lowercase pitch letters ONLY to indicate staff position
syntax match gabcCustos /[a-np]+/ contained containedin=gabcSnippet

" GABC LINE BREAKS: Force line breaks in the score
" z = justified line break (text justified to width)
" Z = ragged line break (text not justified, ragged right edge)
" Suffixes:
"   + = forced automatic custos
"   - = no custos
"   0 = special case for clef changes (z only)
" Examples: z, Z, z+, Z+, z-, Z-, z0

" Line break base symbols (z = justified, Z = ragged)
syntax match gabcLineBreak /[zZ]/ contained containedin=gabcSnippet

" Line break suffixes: + (custos), - (no custos), 0 (clef change - z only)
" Use lookbehind to match only after line break symbols
syntax match gabcLineBreakSuffix /\([zZ]\)\@<=[+-]/ contained containedin=gabcSnippet
syntax match gabcLineBreakSuffix /\(z\)\@<=0/ contained containedin=gabcSnippet

" GABC NEUME FUSIONS: @ connector for fusing notes into single neume
" Two forms:
" 1. Individual pitch fusion: f@g@h (connector between pitches)
" 2. Collective pitch fusion: @[fghghi] (function-style with bracket group)

" Collective fusion: @[...] function-style fusion
" The @ symbol acts as a function, and the bracketed pitches are the argument
syntax region gabcFusionCollective matchgroup=gabcFusionFunction start=/@\[/ end=/\]/ keepend oneline contained containedin=gabcSnippet contains=gabcPitch,gabcAccidental,gabcModifierSimple,gabcModifierCompound,gabcModifierSpecial,gabcInitioDebilis,gabcOriscus,gabcOriscusSuffix,gabcPitchSuffix transparent

" Individual pitch fusion connector: @ between pitches (not before bracket)
" Uses negative lookahead to avoid matching @[ (which is collective fusion)
syntax match gabcFusionConnector /@\(\[\)\@!/ contained containedin=gabcSnippet

" GABC NEUME SPACING: operators for controlling space between neumes
" Simplified implementation: / is an operator, [...] is a suffix with brackets and number
" CRITICAL: In Vim, LAST defined pattern wins for overlapping matches

" Fixed spacing operators
" Define simple / FIRST, then override with more specific patterns
syntax match gabcSpacingSmall /\// contained containedin=gabcSnippet       " / = small separation
syntax match gabcSpacingHalf /\/0/ contained containedin=gabcSnippet       " /0 = half space (same neume) - overrides /
syntax match gabcSpacingSingle /\/!/ contained containedin=gabcSnippet     " /! = small separation (same neume) - overrides /
syntax match gabcSpacingDouble /\/\// contained containedin=gabcSnippet    " // = medium separation - overrides / (defined LAST!)

" Spacing suffix: [...] after / for scaled spacing
" Brackets act as delimiters, number inside is the scaling factor
" Use lookbehind to match [ only after / (to avoid conflict with shape hints)
syntax match gabcSpacingBracket /\(\/\)\@<=\[/ contained containedin=gabcSnippet     " [ delimiter for spacing factor (after /)
syntax match gabcSpacingBracket /\]/ contained containedin=gabcSnippet     " ] delimiter for spacing factor
syntax match gabcSpacingFactor /\(\[\)\@<=-\?\d\+\(\.\d\+\)\?/ contained containedin=gabcSnippet  " numeric factor AFTER [ (positive lookbehind)

" Zero-width space: ! (when alone or followed by space for non-breaking)
" Must come AFTER /! to not interfere
syntax match gabcSpacingZero /!/ contained containedin=gabcSnippet

" ============================================================================
" SPECIALIZED PITCH ATTRIBUTES: Semantic attribute types with specific meanings
" These MUST be defined BEFORE generic attributes to take precedence
" ============================================================================

" CHORAL SIGNS: Text annotations for choir directors
" [cs:text] - choral sign with custom text
" [cn:code] - choral sign with NABC neume code
syntax match gabcAttrChoralSign /\[cs:\([^\]]\+\)\]/ contained containedin=gabcSnippet
syntax match gabcAttrChoralNabc /\[cn:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" BRACES: Grouping indicators for neumes
" [ob:1] or [ob:0] - overbrace (above staff)
" [ub:1] or [ub:0] - underbrace (below staff)  
" [ocb:1] or [ocb:0] - overcurly brace
" [ocba:1] or [ocba:0] - overcurly brace with accent
syntax match gabcAttrBrace /\[ob:[01]\]/ contained containedin=gabcSnippet
syntax match gabcAttrBrace /\[ub:[01]\]/ contained containedin=gabcSnippet
syntax match gabcAttrBrace /\[ocb:[01]\]/ contained containedin=gabcSnippet
syntax match gabcAttrBrace /\[ocba:[01]\]/ contained containedin=gabcSnippet

" STEM LENGTH: Custom stem length for bottom line notes
" [ll:value] - adjusts vertical stem extension
syntax match gabcAttrStemLength /\[ll:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" CUSTOM LEDGER LINES: Manual ledger line positioning
" [oll:position] - over ledger lines (above staff)
" [ull:position] - under ledger lines (below staff)
syntax match gabcAttrLedgerLines /\[oll:\([^\]]\+\)\]/ contained containedin=gabcSnippet
syntax match gabcAttrLedgerLines /\[ull:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" SIMPLE SLURS: Manual slur/ligature marks
" [oslur:type] - over slur (above staff)
" [uslur:type] - under slur (below staff)
syntax match gabcAttrSlur /\[oslur:\([^\]]\+\)\]/ contained containedin=gabcSnippet
syntax match gabcAttrSlur /\[uslur:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" HORIZONTAL EPISEMA TUNING: Fine-tune episema positioning
" [oh:adjustment] - over horizontal episema
" [uh:adjustment] - under horizontal episema
syntax match gabcAttrEpisemaTune /\[oh:\([^\]]\+\)\]/ contained containedin=gabcSnippet
syntax match gabcAttrEpisemaTune /\[uh:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" ABOVE LINES TEXT: Text displayed above staff (alternative to <alt> tag)
" [alt:text] - text annotation above staff
syntax match gabcAttrAboveLinesText /\[alt:\([^\]]\+\)\]/ contained containedin=gabcSnippet

" VERBATIM TEX: Embedded TeX code at different scopes
" [nv:tex] - note level verbatim TeX
" [gv:tex] - glyph level verbatim TeX  
" [ev:tex] - element level verbatim TeX
" These use region syntax to enable LaTeX highlighting within the value
syntax region gabcAttrVerbatimNote matchgroup=gabcAttrVerbatimDelim start=/\[nv:/ end=/\]/ contained containedin=gabcSnippet oneline contains=@texSyntax
syntax region gabcAttrVerbatimGlyph matchgroup=gabcAttrVerbatimDelim start=/\[gv:/ end=/\]/ contained containedin=gabcSnippet oneline contains=@texSyntax
syntax region gabcAttrVerbatimElement matchgroup=gabcAttrVerbatimDelim start=/\[ev:/ end=/\]/ contained containedin=gabcSnippet oneline contains=@texSyntax

" NO CUSTOS: Suppress automatic custos rendering at line breaks
" [nocustos] - prevents custos generation at natural line break point
" Boolean flag attribute (no value required)
syntax match gabcAttrNoCustos /\[nocustos\]/ contained containedin=gabcSnippet

" MACROS: Predefined notation shortcuts at different scopes
" [nm#] - note level macro (# = 0-9)
" [gm#] - glyph level macro (# = 0-9)
" [em#] - element level macro (# = 0-9)
" Macro identifier (nm/gm/em) highlighted as Function
" Macro number (0-9) highlighted as Number (parameter)
syntax match gabcMacroNote /\[nm[0-9]\]/ contained containedin=gabcSnippet contains=gabcMacroIdentifier,gabcMacroNumber
syntax match gabcMacroGlyph /\[gm[0-9]\]/ contained containedin=gabcSnippet contains=gabcMacroIdentifier,gabcMacroNumber
syntax match gabcMacroElement /\[em[0-9]\]/ contained containedin=gabcSnippet contains=gabcMacroIdentifier,gabcMacroNumber

" Macro components (for fine-grained highlighting)
syntax match gabcMacroIdentifier /\[\@<=\(nm\|gm\|em\)/ contained
syntax match gabcMacroNumber /\([nge]m\)\@<=[0-9]/ contained

" ============================================================================
" GENERIC PITCH ATTRIBUTES: Fallback for unrecognized attribute types
" Defined AFTER specialized attributes to catch remaining cases
" ============================================================================

" GABC PITCH ATTRIBUTES: Generic [attribute:value] syntax
" This is a general mechanism for pitch-level metadata annotations
" Syntax: [attr:value] immediately after a pitch
" Examples: [shape:stroke], [shape:virga], [color:red], etc.
"
" Components:
" - Brackets: [ and ] (Delimiter)
" - Attribute name: any word before the colon (e.g., "shape", "color")
" - Colon: : (separator between attribute name and value)
" - Value: any non-bracket characters after the colon
"   Note: Paren matching is disabled in values (e.g., "1{" won't trigger missing "}" error)
"
" Implementation strategy:
" - Use lookahead/lookbehind to avoid conflicts with spacing brackets /[...]
" - Attribute brackets: [ must be followed by word:\w+:
" - Closing bracket: ] must be preceded by non-bracket content

" Pitch attribute brackets (delimiters)
" Opening bracket: [ followed by any attribute name and colon (e.g., [shape:, [color:)
" Use lookahead to match [ only when followed by "word characters + colon" pattern
syntax match gabcPitchAttrBracket /\[\(\w\+:\)\@=/ contained containedin=gabcSnippet

" Closing bracket: ] preceded by any non-whitespace (end of attribute value)
" Use lookbehind to match ] only when preceded by value content
syntax match gabcPitchAttrBracket /\(\S\)\@<=\]/ contained containedin=gabcSnippet

" Pitch attribute name: any word characters between [ and :
" Matches attribute name (e.g., "shape", "color", "custom")
" Pattern: word chars after [ and before :
syntax match gabcPitchAttrName /\(\[\)\@<=\w\+\(:\)\@=/ contained containedin=gabcSnippet

" Pitch attribute colon: ":" separator
" Matches : when preceded by [attribute_name
syntax match gabcPitchAttrColon /\(\[\w\+\)\@<=:/ contained containedin=gabcSnippet

" Pitch attribute value: content after ":" up to closing bracket
" Matches any non-bracket characters after attribute:
" Pattern: content after [attr: and before ]
" Uses region to disable paren matching within the value (via 'contained' and specific pattern)
syntax region gabcPitchAttrValue start=/\(\[\w\+:\)\@<=/ end=/\(\]\)\@=/ contained containedin=gabcSnippet oneline

" Note: The 'oneline' option ensures the region doesn't span multiple lines
" The region implicitly disables Vim's built-in paren matching for its contents

" Syllables: any run of characters outside parentheses within notes (exclude tag brackets)
syntax match gabcSyllable /[^()<>]\+/ contained containedin=gabcNotes contains=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag,gabcClearTag,gabcElisionTag,gabcEuouaeTag,gabcNoLineBreakTag,gabcProtrusionTag,gabcAboveLinesTextTag,gabcSpecialTag,gabcVerbatimTag,gabcLyricCentering,gabcTranslation transparent

" XML-like inline tags within syllables
" Tag regions (opening and closing) with inner text per markup type
syntax region gabcBoldTag      start=+<b>+   end=+</b>+   keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcBoldText
syntax region gabcColorTag     start=+<c>+   end=+</c>+   keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcColorText
syntax region gabcItalicTag    start=+<i>+   end=+</i>+   keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcItalicText
syntax region gabcSmallCapsTag start=+<sc>+  end=+</sc>+  keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcSmallCapsText
syntax region gabcTeletypeTag  start=+<tt>+  end=+</tt>+  keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcTeletypeText
syntax region gabcUnderlineTag start=+<ul>+  end=+</ul>+  keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcUnderlineText

" Additional GABC-specific tags
syntax region gabcClearTag          start=+<clear>+  end=+</clear>+  keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName
syntax region gabcElisionTag        start=+<e>+      end=+</e>+      keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcElisionText
syntax region gabcEuouaeTag         start=+<eu>+     end=+</eu>+     keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName
syntax region gabcNoLineBreakTag    start=+<nlba>+   end=+</nlba>+   keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName
syntax region gabcProtrusionTag     start=+<pr\%(:[.0-9]\+\)\?>+ end=+</pr>+ keepend oneline transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcProtrusionTagName
syntax region gabcAboveLinesTextTag start=+<alt>+    end=+</alt>+    keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcAboveLinesText
syntax region gabcSpecialTag        start=+<sp>+     end=+</sp>+     keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcSpecialText
" Verbatim tag with embedded LaTeX: matchgroup separates delimiters from content
syntax region gabcVerbatimTag matchgroup=gabcVerbatimDelim start=+<v>+ end=+</v>+ keepend containedin=gabcNotes contains=@texSyntax,gabcVerbatimText

" Tag components - define in order of decreasing specificity
" Brackets first (lowest priority for overlaps)
syntax match gabcTagBracket /[<>]/ contained containedin=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag
" Tag names next (medium priority)  
syntax match gabcTagName    /\%(<\|<\/\)\@<=\%(b\|c\|i\|sc\|tt\|ul\|clear\|e\|eu\|nlba\|alt\|sp\|v\)\ze>/ contained containedin=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag,gabcClearTag,gabcElisionTag,gabcEuouaeTag,gabcNoLineBreakTag,gabcAboveLinesTextTag,gabcSpecialTag,gabcVerbatimTag
" Protrusion tag name (without colon/number - those are handled separately)
syntax match gabcProtrusionTagName /<\@<=pr/ contained containedin=gabcProtrusionTag
" Slash last (highest priority - defined last wins in Vim)
syntax match gabcTagSlash   /<\@<=\// contained containedin=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag

" Protrusion tag components (define after general tag components for specificity)
syntax match gabcProtrusionColon  /:/ contained containedin=gabcProtrusionTag
syntax match gabcProtrusionNumber /[.0-9]\+/ contained containedin=gabcProtrusionTag

" Inner text: match content between '>' of opening tag and '<' of closing tag
" Using lookbehind/lookahead to exclude the tag delimiters from the match
syntax match gabcBoldText      /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcBoldTag
syntax match gabcColorText     /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcColorTag
syntax match gabcItalicText    /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcItalicTag
syntax match gabcSmallCapsText /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcSmallCapsTag
syntax match gabcTeletypeText  /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcTeletypeTag
syntax match gabcUnderlineText /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcUnderlineTag

" Inner text for additional tags
syntax match gabcElisionText      /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcElisionTag
syntax match gabcAboveLinesText   /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcAboveLinesTextTag
syntax match gabcSpecialText      /\(>\)\@<=[^<]\+\(<\)\@=/ contained containedin=gabcSpecialTag
" Note: gabcVerbatimText is not needed - LaTeX syntax is included directly in gabcVerbatimTag via @texSyntax

" Tag highlight links and styles
highlight link gabcTagBracket Delimiter
highlight link gabcTagSlash   Delimiter
highlight link gabcTagName    Keyword

highlight default gabcBoldText      term=bold cterm=bold gui=bold
highlight default gabcItalicText    term=italic cterm=italic gui=italic
highlight default gabcUnderlineText term=underline cterm=underline gui=underline
highlight default link gabcTeletypeText Constant
highlight default link gabcSmallCapsText Identifier
highlight default link gabcColorText    Special

" Additional tag text styles
highlight default gabcElisionText    term=italic cterm=italic gui=italic
highlight default link gabcAboveLinesText String
highlight default link gabcSpecialText Special

" Protrusion tag component highlights
highlight link gabcProtrusionTagName Keyword
highlight link gabcProtrusionColon Operator
highlight link gabcProtrusionNumber Number

" Verbatim tag delimiter highlight
highlight link gabcVerbatimDelim Delimiter

" Lyric centering delimiters and text
highlight link gabcLyricCenteringDelim Delimiter
highlight default link gabcLyricCentering Special

" Translation delimiters and text
highlight link gabcTranslationDelim Delimiter
highlight default link gabcTranslation String

" Musical notation delimiters
highlight link gabcNotationDelim Delimiter
highlight link gabcSnippetDelim Operator

" GABC pitches: note letters that specify pitch height
highlight link gabcPitch Character

" GABC pitch inclinatum suffix: direction indicator (0=left, 1=right, 2=none)
highlight link gabcPitchSuffix Number

" GABC pitch modifiers: symbols that modify the appearance/meaning of pitches
highlight link gabcInitioDebilis Identifier
highlight link gabcOriscus Identifier
highlight link gabcOriscusSuffix Number
highlight link gabcModifierSimple Identifier
highlight link gabcModifierCompound Identifier
highlight link gabcModifierSpecial Identifier

" GABC rhythmic and articulation modifiers
highlight link gabcModifierEpisema Identifier
highlight link gabcModifierEpisemaNumber Number
highlight link gabcModifierIctus Identifier
highlight link gabcModifierIctusNumber Number

" GABC separation bars: divisio marks for phrase/section boundaries
" Similar to semicolons in code - clear structural markers
highlight link gabcBarDouble Special
highlight link gabcBarDotted Special
highlight link gabcBarMaior Special
highlight link gabcBarMinor Special
highlight link gabcBarMinima Special
highlight link gabcBarMinimaOcto Special
highlight link gabcBarVirgula Special
highlight link gabcBarMinorSuffix Number
highlight link gabcBarZeroSuffix Number

" GABC custos: end-of-line guide showing next pitch
highlight link gabcCustos Operator

" GABC line breaks: force line breaks in the score
" Statement highlight for clear differentiation from separation bars (Special)
highlight link gabcLineBreak Statement
highlight link gabcLineBreakSuffix Identifier

" GABC accidentals: symbols indicating pitch alteration (includes pitch letter for position)
highlight link gabcAccidental Function

" GABC neume fusions: @ connector for fusing notes into single neume
highlight link gabcFusionConnector Operator
highlight link gabcFusionFunction Function

" GABC neume spacing: operators for controlling space between neumes
highlight link gabcSpacingDouble Operator
highlight link gabcSpacingSingle Operator
highlight link gabcSpacingHalf Operator
highlight link gabcSpacingSmall Operator
highlight link gabcSpacingZero Operator
highlight link gabcSpacingBracket Delimiter
highlight link gabcSpacingFactor Number

" GABC specialized pitch attributes: Semantic attribute types
" Choral signs: annotations for choir directors
highlight link gabcAttrChoralSign Type
highlight link gabcAttrChoralNabc Type

" Braces: grouping indicators
highlight link gabcAttrBrace Function

" Stem length: custom stem adjustment
highlight link gabcAttrStemLength Number

" Ledger lines: manual positioning
highlight link gabcAttrLedgerLines Function

" Slurs: manual ligature marks
highlight link gabcAttrSlur Function

" Episema tuning: fine positioning
highlight link gabcAttrEpisemaTune Number

" Above lines text: staff annotations
highlight link gabcAttrAboveLinesText String

" Verbatim TeX: embedded LaTeX code (delimiters only, content uses @texSyntax)
highlight link gabcAttrVerbatimDelim Special

" No custos: suppress automatic custos rendering
highlight link gabcAttrNoCustos Keyword

" Macros: predefined notation shortcuts (identifier as Function, number as Number)
highlight link gabcMacroIdentifier Function
highlight link gabcMacroNumber Number

" GABC pitch attributes: Generic [attribute:value] syntax for pitch-level metadata
" Examples: [shape:stroke], [color:red], [custom:data]
" These are fallback patterns for attributes not caught by specialized patterns above
highlight link gabcPitchAttrBracket Delimiter
highlight link gabcPitchAttrName PreProc
highlight link gabcPitchAttrColon Special
highlight link gabcPitchAttrValue String

" GABC and NABC snippet containers (transparent - no direct highlighting)
" These will contain future specific notation syntax

let b:current_syntax = 'gabc'
