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
" Note: The /\@ construct is a negative zero-width assertion in Vim regex
" Matches content inside parentheses (entire musical snippet), excluding the parentheses themselves
" This allows for highlighting of its contained elements (pitches, modifiers, etc.)
syntax match gabcSnippet /(\@<=[^|)]\+/ contained containedin=gabcNotation contains=gabcAccidental,gabcInitioDebilis,gabcPitch,gabcPitchSuffix,gabcOriscus,gabcOriscusSuffix,gabcModifierCompound,gabcModifierSimple,gabcModifierSpecial,gabcModifierEpisema,gabcModifierEpisemaNumber,gabcModifierIctus,gabcModifierIctusNumber,gabcFusionCollective,gabcFusionConnector,gabcSpacingDouble,gabcSpacingSingle,gabcSpacingHalf,gabcSpacingSmall,gabcSpacingZero,gabcSpacingBracket,gabcSpacingFactor,gabcPitchAttrBracket,gabcPitchAttrName,gabcPitchAttrColon,gabcPitchAttrValue transparent

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
" The pitch letter comes BEFORE the accidental symbol
" Example: (ixiv) = i + x (flat on i) + i + v (virga)

" Accidentals with parentheses: pitch followed by x?, #?, y?
" Parentheses indicate cautionary/editorial accidentals
syntax match gabcAccidental /[a-npA-NP][x#y]?/ contained containedin=gabcSnippet

" Double sharp: pitch followed by ## (soft sharp)
syntax match gabcAccidental /[a-npA-NP]##/ contained containedin=gabcSnippet

" Soft natural: pitch followed by Y
syntax match gabcAccidental /[a-npA-NP]Y/ contained containedin=gabcSnippet

" Basic accidentals: pitch followed by x (flat), # (sharp), y (natural)
syntax match gabcAccidental /[a-npA-NP][x#y]/ contained containedin=gabcSnippet

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

" GABC rhythmic and articulation modifiers
highlight link gabcModifierEpisema Identifier
highlight link gabcModifierEpisemaNumber Number
highlight link gabcModifierIctus Identifier
highlight link gabcModifierIctusNumber Number

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

" GABC pitch attributes: Generic [attribute:value] syntax for pitch-level metadata
" Examples: [shape:stroke], [color:red], [custom:data]
highlight link gabcPitchAttrBracket Delimiter
highlight link gabcPitchAttrName PreProc
highlight link gabcPitchAttrColon Special
highlight link gabcPitchAttrValue String

" GABC and NABC snippet containers (transparent - no direct highlighting)
" These will contain future specific notation syntax

let b:current_syntax = 'gabc'
