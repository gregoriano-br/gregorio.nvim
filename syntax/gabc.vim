" Vim syntax file
" Language: GABC (Gregorian Chant notation)
" Maintainer: Laércio de Sousa
" Latest Revision: 2025

if exists('b:current_syntax')
  finish
endif

" Comments
syntax match gabcComment /^%.*$/
highlight link gabcComment Comment

" Header separator - must come before header region
syntax match gabcHeaderSeparator /^%%.*$/

" Header section - starts at beginning of file, ends at line before %%
syntax region gabcHeader start=/\%^/ end=/\ze^%%/ contains=gabcHeaderField,gabcHeaderValue,gabcComment
syntax match gabcHeaderField /^[\w-]\+:/ contained
syntax match gabcHeaderValue /:\s*[^;]*;/ contained

highlight link gabcHeaderField Keyword  
highlight link gabcHeaderValue String
highlight link gabcHeaderSeparator Special

" Musical notes and neumes
syntax match gabcNotePitch /[a-np]/ contained
syntax match gabcNotePitchAccident /[a-np][#xy]/ contained
syntax match gabcNoteInclinatum /[A-NP][012]\?/ contained
syntax match gabcCustos /[a-np]\+/ contained

" Note shapes and modifiers
syntax match gabcOriscus /o[01]\?/ contained
syntax match gabcOriscusScapus /O[01]\?/ contained
syntax match gabcPesQuadratum /q/ contained
syntax match gabcQuilisma /w/ contained
syntax match gabcQuilismaQuadratum /W/ contained
syntax match gabcVirga /v/ contained
syntax match gabcVirgaReversa /V/ contained
syntax match gabcBivirga /vv/ contained
syntax match gabcTrivirga /vvv/ contained
syntax match gabcStropha /s/ contained
syntax match gabcDistropha /ss/ contained
syntax match gabcTristropha /sss/ contained
syntax match gabcLiquescentDeminutus /\~/ contained
syntax match gabcLiquescentAugmented />/ contained
syntax match gabcLiquescentDiminished /</ contained
syntax match gabcLinea /=/ contained
syntax match gabcCavum /r0\?/ contained
syntax match gabcQuadratumSurrounded /R/ contained
syntax match gabcInitioDebilis /-/ contained
syntax match gabcNoteFusion /@/ contained

" Additional symbols
syntax match gabcPunctumMora /\\./ contained
syntax match gabcEpisema /_[0-5]*/ contained
syntax match gabcIctus /'[01]\?/ contained
syntax match gabcAccentAbove /r[1-8]/ contained

" Spacing controls
syntax match gabcSpacingSmall /\// contained
syntax match gabcSpacingMedium /\/\// contained
syntax match gabcSpacingZero /!/ contained
syntax match gabcSpacingNonBreaking /! / contained
syntax region gabcSpacingFactored start=+/\\\[+ end=+\\\]+ contained

" Separation bars
syntax match gabcVirgula /`0\?/ contained
syntax match gabcDivisioMinimis /\^0\?/ contained
syntax match gabcDivisioMinima /,[0_]\?/ contained
syntax match gabcDivisioMinor /;[1-6]\?/ contained
syntax match gabcDivisioMaior /:?\?/ contained
syntax match gabcDivisioFinalis /::/ contained

" Clefs
syntax match gabcClef /[cf]b\?[1-5]/ contained
highlight link gabcClef Special

" Line breaks
syntax match gabcLineBreakJustified /z[+-]\?/ contained
syntax match gabcLineBreakRagged /Z[+-]\?/ contained

" Choral signs and braces
syntax region gabcChoralSign start=+\\\[ch:+ end=+\\\]+ contained
syntax region gabcChoralSignNabc start=+\\\[cn:+ end=+\\\]+ contained
syntax region gabcBraceRoundedOver start=+\\\[ob:+ end=+\\\]+ contained
syntax region gabcBraceRoundedUnder start=+\\\[ub:+ end=+\\\]+ contained
syntax region gabcBraceCurlyOver start=+\\\[ocb:+ end=+\\\]+ contained
syntax region gabcBraceCurlyAccentedOver start=+\\\[ocba:+ end=+\\\]+ contained

" Stem length controls
syntax match gabcStemLong +\\\[ll:1\\\]+ contained
syntax match gabcStemShort +\\\[ll:0\\\]+ contained

" Custom ledger lines
syntax region gabcLedgerLineOver start=+\\\[oll:+ end=+\\\]+ contained
syntax region gabcLedgerLineUnder start=+\\\[ull:+ end=+\\\]+ contained

" Slurs
syntax region gabcSlurOver start=+\\\[oslur:+ end=+\\\]+ contained
syntax region gabcSlurUnder start=+\\\[uslur:+ end=+\\\]+ contained

" Episema tuning
syntax region gabcEpisemaOver start=+\\\[oh:\?+ end=+\\\]+ contained
syntax region gabcEpisemaUnder start=+\\\[uh:\?+ end=+\\\]+ contained

" Above-lines text
syntax region gabcAboveLinesText start=+\\\[alt:+ end=+\\\]+ contained

" Macros
syntax region gabcNoteMacro start=+\\\[nm+ end=+\\\]+ contained
syntax region gabcGlyphMacro start=+\\\[gm+ end=+\\\]+ contained
syntax region gabcElementMacro start=+\\\[em+ end=+\\\]+ contained

" Verbatim sections in notes
syntax region gabcNoteVerbatim start=+\\\[nv:+ end=+\\\]+ contained
syntax region gabcGlyphVerbatim start=+\\\[gv:+ end=+\\\]+ contained
syntax region gabcElementVerbatim start=+\\\[ev:+ end=+\\\]+ contained

" Notes region (inside parentheses)
syntax region gabcNotesRegion start=/(/ end=/)/ contains=gabcNotePitch,gabcNotePitchAccident,gabcNoteInclinatum,gabcCustos,gabcOriscus,gabcOriscusScapus,gabcPesQuadratum,gabcQuilisma,gabcQuilismaQuadratum,gabcVirga,gabcVirgaReversa,gabcBivirga,gabcTrivirga,gabcStropha,gabcDistropha,gabcTristropha,gabcLiquescentDeminutus,gabcLiquescentAugmented,gabcLiquescentDiminished,gabcLinea,gabcCavum,gabcQuadratumSurrounded,gabcInitioDebilis,gabcNoteFusion,gabcPunctumMora,gabcEpisema,gabcIctus,gabcAccentAbove,gabcSpacingSmall,gabcSpacingMedium,gabcSpacingZero,gabcSpacingNonBreaking,gabcSpacingFactored,gabcVirgula,gabcDivisioMinimis,gabcDivisioMinima,gabcDivisioMinor,gabcDivisioMaior,gabcDivisioFinalis,gabcClef,gabcLineBreakJustified,gabcLineBreakRagged,gabcChoralSign,gabcChoralSignNabc,gabcBraceRoundedOver,gabcBraceRoundedUnder,gabcBraceCurlyOver,gabcBraceCurlyAccentedOver,gabcStemLong,gabcStemShort,gabcLedgerLineOver,gabcLedgerLineUnder,gabcSlurOver,gabcSlurUnder,gabcEpisemaOver,gabcEpisemaUnder,gabcAboveLinesText,gabcNoteMacro,gabcGlyphMacro,gabcElementMacro,gabcNoteVerbatim,gabcGlyphVerbatim,gabcElementVerbatim,gabcNabcRegion

" NABC extended notation
syntax region gabcNabcRegion start=/|/ end=/|\?/ contained contains=gabcNabcNeume,gabcNabcSubpunctis,gabcNabcPrepunctis,gabcNabcSignificantLetter,gabcNabcTironianLetter,gabcNabcSpacing
syntax match gabcNabcNeume /\(vi\|vs\|pu\|gr\|ta\|cl\|pe\|pq\|pt\|po\|pf\|to\|tr\|ci\|sc\|sf\|st\|ds\|ts\|tg\|bv\|tv\|pr\|pi\|or\|sa\|ql\|qi\|un\|oc\)[1-9]\?\([GMS>~-][1-9]\?\)\?\(h[a-np]\)\?\(!\)\?/ contained
syntax match gabcNabcSubpunctis /su\([nqtuvwxyz]\?\)\([1-9]\)/ contained
syntax match gabcNabcPrepunctis /pp\([nqtuvwxyz]\?\)\([1-9]\)/ contained
syntax match gabcNabcSignificantLetter /ls\(a\|al\|am\|b\|c\|cm\|co\|cw\|d\|e\|eq-\|eq\|equ\|ew\|f\|fid\|fr\|g\|h\|hn\|hp\|i\|im\|iv\|k\|l\|lb\|lc\|len\|lm\|lp\|lt\|m\|md\|moll\|n\|nl\|nt\|p\|par\|pfec\|pm\|pulcre\|s\|sb\|sc\|simil\|simp\|simpl\|simul\|sm\|sp\|st\|sta\|t\|tb\|th\|tm\|tw\|v\|vol\|x\)\([1-9]\)/ contained
syntax match gabcNabcTironianLetter /lt\(do\|dr\|dx\|i\|ps\|qm\|sb\|se\|sj\|sl\|sn\|sp\|sr\|st\|us\)\([1-9]\)/ contained
syntax match gabcNabcSpacing /\(\/\/\|\/\|``\|`\)/ contained

" Fusible notes region
syntax region gabcFusibleNotesRegion start=+@\\\[+ end=+\\\]+ contains=gabcNotePitch,gabcNotePitchAccident,gabcNoteInclinatum,gabcCustos,gabcOriscus,gabcOriscusScapus,gabcPesQuadratum,gabcQuilisma,gabcQuilismaQuadratum,gabcVirga,gabcVirgaReversa,gabcBivirga,gabcTrivirga,gabcStropha,gabcDistropha,gabcTristropha,gabcLiquescentDeminutus,gabcLiquescentAugmented,gabcLiquescentDiminished,gabcLinea,gabcCavum,gabcQuadratumSurrounded,gabcInitioDebilis,gabcNoteFusion,gabcPunctumMora,gabcEpisema,gabcIctus,gabcAccentAbove,gabcSpacingSmall,gabcSpacingMedium,gabcSpacingZero,gabcSpacingNonBreaking,gabcSpacingFactored,gabcVirgula,gabcDivisioMinimis,gabcDivisioMinima,gabcDivisioMinor,gabcDivisioMaior,gabcDivisioFinalis,gabcClef,gabcLineBreakJustified,gabcLineBreakRagged

" Text markup tags
syntax region gabcBoldTag start=/<b>/ end=/<\/b>/ contains=gabcSyllableContent
syntax region gabcItalicTag start=/<i>/ end=/<\/i>/ contains=gabcSyllableContent
syntax region gabcColorTag start=/<c>/ end=/<\/c>/ contains=gabcSyllableContent
syntax region gabcSmallCapsTag start=/<sc>/ end=/<\/sc>/ contains=gabcSyllableContent
syntax region gabcUnderlineTag start=/<ul>/ end=/<\/ul>/ contains=gabcSyllableContent
syntax region gabcTeletypeTag start=/<tt>/ end=/<\/tt>/ contains=gabcSyllableContent

" Special control tags
syntax region gabcClearTag start=/<clear>/ end=/<\/clear>/ contains=gabcSyllableContent,gabcNotesRegion
syntax region gabcElisionTag start=/<e>/ end=/<\/e>/ contains=gabcSyllableContent
syntax region gabcEuouaeTag start=/<eu>/ end=/<\/eu>/ contains=gabcSyllableContent,gabcNotesRegion
syntax region gabcNoLineBreakTag start=/<nlba>/ end=/<\/nlba>/ contains=gabcSyllableContent,gabcNotesRegion
syntax match gabcProtrusionTag /<pr\(:[0-9]\)\?\/\?>/ 

" Other syllable tags
syntax region gabcAboveLinesTextTag start=/<alt>/ end=/<\/alt>/ contains=gabcSyllableContent
syntax region gabcSpecialTag start=/<sp>/ end=/<\/sp>/ contains=gabcSyllableContent
syntax region gabcVerbatimTag start=/<v>/ end=/<\/v>/ contains=gabcLatexVerbatim

" Translation text
syntax region gabcTranslation start=/\[/ end=/\]/ 
highlight link gabcTranslation String

" LaTeX verbatim content
syntax match gabcLatexVerbatim /\\\\.*/ contained

" Syllable content (text between tags and notes)
syntax match gabcSyllableContent /[^<>()\\[\\]]\+/ contained

" Highlight groups
highlight link gabcNotePitch Constant
highlight link gabcNotePitchAccident Special
highlight link gabcNoteInclinatum Constant
highlight link gabcCustos Special

highlight link gabcOriscus Function
highlight link gabcOriscusScapus Function
highlight link gabcPesQuadratum Function
highlight link gabcQuilisma Function
highlight link gabcQuilismaQuadratum Function
highlight link gabcVirga Function
highlight link gabcVirgaReversa Function
highlight link gabcBivirga Function
highlight link gabcTrivirga Function
highlight link gabcStropha Function
highlight link gabcDistropha Function
highlight link gabcTristropha Function
highlight link gabcLiquescentDeminutus Function
highlight link gabcLiquescentAugmented Function
highlight link gabcLiquescentDiminished Function
highlight link gabcLinea Function
highlight link gabcCavum Function
highlight link gabcQuadratumSurrounded Function
highlight link gabcInitioDebilis Function
highlight link gabcNoteFusion Keyword

highlight link gabcPunctumMora Special
highlight link gabcEpisema Special
highlight link gabcIctus Special
highlight link gabcAccentAbove Special

highlight link gabcSpacingSmall Type
highlight link gabcSpacingMedium Type
highlight link gabcSpacingZero Type
highlight link gabcSpacingNonBreaking Type
highlight link gabcSpacingFactored Type

highlight link gabcVirgula Delimiter
highlight link gabcDivisioMinimis Delimiter
highlight link gabcDivisioMinima Delimiter
highlight link gabcDivisioMinor Delimiter
highlight link gabcDivisioMaior Delimiter
highlight link gabcDivisioFinalis Delimiter

highlight link gabcLineBreakJustified PreProc
highlight link gabcLineBreakRagged PreProc

highlight link gabcChoralSign String
highlight link gabcChoralSignNabc String
highlight link gabcBraceRoundedOver String
highlight link gabcBraceRoundedUnder String
highlight link gabcBraceCurlyOver String
highlight link gabcBraceCurlyAccentedOver String

highlight link gabcStemLong PreProc
highlight link gabcStemShort PreProc

highlight link gabcLedgerLineOver String
highlight link gabcLedgerLineUnder String

highlight link gabcSlurOver String
highlight link gabcSlurUnder String

highlight link gabcEpisemaOver String
highlight link gabcEpisemaUnder String

highlight link gabcAboveLinesText String

highlight link gabcNoteMacro Macro
highlight link gabcGlyphMacro Macro
highlight link gabcElementMacro Macro

highlight link gabcNoteVerbatim String
highlight link gabcGlyphVerbatim String
highlight link gabcElementVerbatim String

" NABC highlighting
highlight link gabcNabcNeume Identifier
highlight link gabcNabcSubpunctis Identifier
highlight link gabcNabcPrepunctis Identifier
highlight link gabcNabcSignificantLetter Identifier
highlight link gabcNabcTironianLetter Identifier
highlight link gabcNabcSpacing Type

" Markup tag highlighting
highlight link gabcBoldTag htmlBold
highlight link gabcItalicTag htmlItalic
highlight link gabcColorTag Special
highlight link gabcSmallCapsTag Special
highlight link gabcUnderlineTag htmlUnderline
highlight link gabcTeletypeTag Special

highlight link gabcClearTag PreProc
highlight link gabcElisionTag PreProc
highlight link gabcEuouaeTag PreProc
highlight link gabcNoLineBreakTag PreProc
highlight link gabcProtrusionTag PreProc

highlight link gabcAboveLinesTextTag String
highlight link gabcSpecialTag Special
highlight link gabcVerbatimTag String

highlight link gabcLatexVerbatim String
highlight link gabcSyllableContent Normal

" Regions highlighting
highlight link gabcNotesRegion Structure
highlight link gabcFusibleNotesRegion Structure
highlight link gabcNabcRegion Identifier

let b:current_syntax = 'gabc'