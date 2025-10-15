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
syntax region gabcHeaders start=/\%1l/ end=/^%%$/me=s-1 keepend
syntax region gabcNotes  start=/^/ end=/\%$/ keepend contained

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
" Must be defined before gabcSyllable and appear before () in syllables
syntax region gabcTranslation matchgroup=gabcTranslationDelim start=/\[/ end=/\]/ keepend oneline containedin=gabcNotes

" Musical notation: (...) contains alternating GABC and NABC snippets separated by |
" Structure: (gabc1|nabc1|gabc2|nabc2|...)
syntax region gabcNotation matchgroup=gabcNotationDelim start=/(/ end=/)/ keepend oneline containedin=gabcNotes contains=gabcSnippet,nabcSnippet transparent

" GABC snippet: First snippet after ( up to | or )
" This is a container for future GABC-specific notation elements  
" Use a simpler pattern: match everything that's not | or )
syntax match gabcSnippet /(\@<=[^|)]\+/ contained containedin=gabcNotation contains=gabcAccidental,gabcInitioDebilis,gabcPitch,gabcPitchSuffix,gabcOriscus,gabcOriscusSuffix,gabcModifierCompound,gabcModifierSimple,gabcModifierSpecial transparent

" Snippet delimiter: | separates GABC and NABC snippets
" Must be defined after gabcSnippet to not interfere with it
syntax match gabcSnippetDelim /|/ contained containedin=gabcNotation

" NABC snippet: Snippets after | delimiter up to next | or )
" This is a container for future NABC-specific notation elements
" Pattern matches after | up to next | or ) boundary
syntax match nabcSnippet /|\@<=[^|)]\+/ contained containedin=gabcNotation transparent

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
" Must be defined before other modifiers to take precedence

" Accidentals with parentheses: x?, #?, y? followed by pitch
" Parentheses indicate cautionary/editorial accidentals
syntax match gabcAccidental /[x#y]?[a-npA-NP]/ contained containedin=gabcSnippet

" Double sharp: ## followed by pitch (soft sharp)
syntax match gabcAccidental /##[a-npA-NP]/ contained containedin=gabcSnippet

" Soft natural: Y followed by pitch
syntax match gabcAccidental /Y[a-npA-NP]/ contained containedin=gabcSnippet

" Basic accidentals: x (flat), # (sharp), y (natural) followed by pitch
syntax match gabcAccidental /[x#y][a-npA-NP]/ contained containedin=gabcSnippet

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
" NOTE: These are defined BEFORE compound modifiers so compounds take precedence
syntax match gabcModifierSimple /[qwWvVs~<>=rR]/ contained containedin=gabcSnippet

" Punctum cavum surrounded by lines: r0
" Must be defined after simple 'r' so it takes precedence
syntax match gabcModifierSpecial /r0/ contained containedin=gabcSnippet

" Compound modifiers: multi-character sequences
" MUST be defined AFTER simple modifiers to take precedence in Vim syntax matching
" Order matters: longer patterns last to take highest precedence
syntax match gabcModifierCompound /vv/ contained containedin=gabcSnippet   " bivirga
syntax match gabcModifierCompound /ss/ contained containedin=gabcSnippet   " distropha
syntax match gabcModifierCompound /vvv/ contained containedin=gabcSnippet  " trivirga
syntax match gabcModifierCompound /sss/ contained containedin=gabcSnippet  " tristropha

" Syllables: any run of characters outside parentheses within notes (exclude tag brackets)
syntax match gabcSyllable /[^()<>]\+/ containedin=gabcNotes contains=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag,gabcClearTag,gabcElisionTag,gabcEuouaeTag,gabcNoLineBreakTag,gabcProtrusionTag,gabcAboveLinesTextTag,gabcSpecialTag,gabcVerbatimTag,gabcLyricCentering,gabcTranslation transparent

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

" GABC accidentals: symbols indicating pitch alteration (includes pitch letter for position)
highlight link gabcAccidental Function

" GABC and NABC snippet containers (transparent - no direct highlighting)
" These will contain future specific notation syntax

let b:current_syntax = 'gabc'
