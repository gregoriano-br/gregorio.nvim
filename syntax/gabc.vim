" Vim syntax file for GABC (fresh minimal)

" Guard: allow re-sourcing during dev if needed
if exists('b:current_syntax') && !exists('g:gabc_devmode')
	finish
endif

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

" Syllables: any run of characters outside parentheses within notes (exclude tag brackets)
syntax match gabcSyllable /[^()<>]\+/ containedin=gabcNotes contains=gabcBoldTag,gabcColorTag,gabcItalicTag,gabcSmallCapsTag,gabcTeletypeTag,gabcUnderlineTag,gabcClearTag,gabcElisionTag,gabcEuouaeTag,gabcNoLineBreakTag,gabcProtrusionTag,gabcAboveLinesTextTag,gabcSpecialTag,gabcVerbatimTag transparent

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
syntax region gabcVerbatimTag       start=+<v>+      end=+</v>+      keepend transparent containedin=gabcNotes contains=gabcTagBracket,gabcTagSlash,gabcTagName

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

let b:current_syntax = 'gabc'
