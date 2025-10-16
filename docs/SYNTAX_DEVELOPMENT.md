# GABC Syntax Highlighting Development Guide

**Author**: AI-assisted development (GitHub Copilot)  
**Date**: October 15, 2025  
**Target Platform**: Neovim/Vim (VimScript)  
**Language**: GABC (Gregorian Chant notation)

---

## Table of Contents

1. [Overview](#overview)
2. [Development Philosophy](#development-philosophy)
3. [Iteration History](#iteration-history)
   - [Iteration 0: Project Structure Setup](#iteration-0-project-structure-setup-pre-existing)
   - [Iteration 1: Comments and File Structure](#iteration-1-comments-and-file-structure)
   - [Iteration 2: Header Field Parsing](#iteration-2-header-field-parsing)
   - [Iteration 3: Clef Notation](#iteration-3-clef-notation)
   - [Iteration 4: Lyric Centering and Translation](#iteration-4-lyric-centering-and-translation)
   - [Iteration 5: GABC Markup Tags](#iteration-5-gabc-markup-tags)
   - [Iteration 6: GABC/NABC Snippet Containers](#iteration-6-gabcnabc-snippet-containers)
   - [Iteration 7: GABC Pitch Letters](#iteration-7-gabc-pitch-letters)
   - [Iteration 8: Pitch Inclinatum Suffixes](#iteration-8-pitch-inclinatum-suffixes)
   - [Iteration 9: Pitch Modifiers](#iteration-9-pitch-modifiers)
   - [Iteration 10: Accidentals (Initial)](#iteration-10-accidentals-initial-implementation)
   - [Iteration 11: Accidentals (Corrected)](#iteration-11-accidentals-corrected)
   - [Iteration 12: Highlight Group Refinement](#iteration-12-highlight-group-refinement)
4. [Syntax Highlighting Reference Table](#syntax-highlighting-reference-table)
5. [Technical Patterns and Best Practices](#technical-patterns-and-best-practices)
6. [Testing Strategy](#testing-strategy)
7. [Porting to Other Platforms](#porting-to-other-platforms)

---

## Overview

This document chronicles the complete development process of a syntax highlighting system for GABC (Gregorian Chant) notation in Neovim/Vim. The development followed an iterative, test-driven approach where each feature was:

1. Implemented with careful pattern matching
2. Tested thoroughly with automated smoke tests
3. Debugged using purpose-built debug scripts
4. Committed atomically with semantic messages

The goal is to provide a reference for developers (human or AI) building similar syntax highlighting systems for other platforms like VS Code, Emacs, Sublime Text, etc.

### Development Journey

The syntax highlighting system was built through **13 iterations** starting from the absolute basics:

**Foundation** (Iterations 0-2):
- File structure and comments
- Header/body separation with `%%` delimiter  
- Header field parsing (key:value; format)

**Structure Elements** (Iterations 3-5):
- Clef notation `(c4)`, `(f3)`, etc.
- Lyric centering `{text}` and translation `[text]`
- XML-like markup tags `<b>`, `<i>`, `<v>` with LaTeX embedding

**Musical Notation** (Iterations 6-9):
- GABC/NABC snippet containers and delimiters
- Pitch letters (a-p, A-P) excluding o/O
- Pitch inclinatum suffixes (0, 1, 2)
- Comprehensive modifiers (30+ symbols)

**Refinement** (Iterations 10-12):
- Accidentals (initial incorrect implementation)
- Accidentals (corrected with pitch BEFORE symbol)
- Highlight group optimization for visual contrast

Each iteration is documented with problem analysis, implementation details, testing strategy, challenges encountered, and solutions discovered.

---

## Development Philosophy

### Core Principles

1. **Iterative Development**: Build one feature at a time, test thoroughly before moving on
2. **Test-Driven**: Write comprehensive tests for each feature
3. **Atomic Commits**: Each commit represents a single, complete feature
4. **Debug-Friendly**: Create debug scripts to troubleshoot pattern matching issues
5. **Documentation-First**: Comment extensively in code and maintain external docs

### Key Insights

- **Pattern Order Matters**: In Vim, later patterns can override earlier ones (last-match-wins)
- **Transparent Containers Need Explicit Contains**: Transparent syntax groups require explicit `contains=` lists
- **Test in Isolation**: Use `--noplugin -u NONE` to avoid interference from user configs
- **Position Debugging**: Use `synstack()` instead of `synID()` for transparent containers
- **Highlight Group Translation**: Some groups (Character, Number) translate to Constant in default colorschemes

---

## Iteration History

### Iteration 0: Project Structure Setup (Pre-existing)

**Goal**: Establish basic GABC file type detection and structure

**Files Created**:
- `ftdetect/gabc.vim`: File type detection for `.gabc` files
- `syntax/gabc.vim`: Main syntax file (skeleton)
- `ftplugin/gabc.vim`: File type plugin settings

**Key Decisions**:
- Use `.gabc` extension for file detection
- Follow Vim plugin directory structure
- Separate syntax, filetype, and plugin concerns

---

### Iteration 1: Comments and File Structure

**Goal**: Implement the most fundamental GABC syntax elements: comments and file structure

**Commit**: `bb1c804` - "syntax(gabc): bootstrap comments and header/notes sections with %% separator"

#### Problem Analysis

GABC files have a specific structure:
```gabc
name: Example;
% This is a comment
%%
(notes here)
```

**Key Requirements**:
1. **Comments**: Lines starting with `%`
2. **Section Separator**: Exactly `%%` on its own line separates header from body
3. **Header Region**: From beginning of file to `%%`
4. **Notes/Body Region**: From `%%` to end of file

**Challenge**: The separator `%%` is both a comment marker AND a structural delimiter!

#### Implementation

**Pattern Order Strategy**:
Must define section separator BEFORE comment patterns to prevent `%%` from being captured as a comment.

**Pattern 1: Section Separator (defined FIRST)**
```vim
syntax match gabcSectionSeparator /^%%$/ nextgroup=gabcNotes skipnl skipwhite
```
- `^%%$`: Exactly `%%` with nothing else on the line
- Must be defined before comment patterns

**Pattern 2: Comment Patterns (defined AFTER separator)**
```vim
" Line comments at beginning of line
syntax match gabcComment /^%%.\+/ containedin=gabcHeaders,gabcNotes
syntax match gabcComment /^%[^%].*/ containedin=gabcHeaders,gabcNotes
syntax match gabcComment /^%$/ containedin=gabcHeaders,gabcNotes

" Inline comments (after non-% character)
syntax match gabcComment /\([^%]\)\@<=%.*/ contains=@NoSpell 
  \ containedin=gabcHeaders,gabcNotes
```

**Why This Order?**
- `^%%$` matches only the separator (no following characters)
- `^%%.\+` matches `%%` with at least one more character (comment)
- `^%[^%].*` matches `%` followed by non-`%` (comment)
- `^%$` matches single `%` alone (comment)

**Pattern 3: Region Definitions**
```vim
" Header region: from line 1 to just before %%
syntax region gabcHeaders start=/\%1l/ end=/^%%$/me=s-1 keepend

" Notes region: from current position to end of file
syntax region gabcNotes start=/^/ end=/\%$/ keepend contained
```

**Regex Breakdown**:
- `\%1l`: Start at line 1 (beginning of file)
- `/^%%$/me=s-1`: End match at `%%` line, but exclude it (`me=s-1` = match end at start minus 1)
- `\%$`: End of file

#### Testing

**Manual Testing Approach**:
1. Create test GABC file with comments in various positions
2. Open in Neovim
3. Verify comment highlighting
4. Verify `%%` separator highlighted differently
5. Verify regions correctly delimit header vs body

**Test Cases**:
```gabc
% Comment at start
name: Test;
%% Comment that looks like separator
%%
% Comment in body
(notes)
```

**Expected Behavior**:
- Line 1: Comment
- Line 2: Header field
- Line 3: Comment (not separator)
- Line 4: Section separator
- Line 5: Comment
- Line 6: Notes

#### Challenges

**Problem 1**: `%%` being captured as comment instead of separator

**Solution**: Define separator pattern BEFORE comment patterns

**Problem 2**: Header region including the `%%` line

**Solution**: Use `me=s-1` (match end at start minus 1) to exclude separator from region

**Problem 3**: `gabcNotes` region not starting at correct position

**Solution**: Use `nextgroup=gabcNotes` in separator pattern to trigger notes region

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `%` comments | gabcComment | Comment | Comment color (gray) |
| `%%` separator | gabcSectionSeparator | Special | Special color (distinct) |
| Header region | gabcHeaders | (transparent) | No direct color |
| Notes region | gabcNotes | (transparent) | No direct color |

---

### Iteration 2: Header Field Parsing

**Goal**: Parse header fields with their key-value structure

**Commit**: `4a14177` - "Add separate syntax highlighting for header delimiters"

#### Problem Analysis

GABC headers have a specific format:
```gabc
field_name: field value;
annotation: IV;
mode: 4;
```

**Structure**:
- **Field name**: Text before `:`
- **Colon**: `:` delimiter
- **Field value**: Text between `:` and `;`
- **Semicolon**: `;` terminator

#### Implementation

**Pattern Strategy**: Use `nextgroup` to chain patterns together

**Pattern 1: Header Field**
```vim
syntax match gabcHeaderField /^\s*[^%:][^:]*\ze:/ 
  \ containedin=gabcHeaders nextgroup=gabcHeaderColon
```
- `^\s*`: Optional leading whitespace
- `[^%:]`: First character must not be `%` or `:` (avoid comments/empty fields)
- `[^:]*`: Any characters except `:`
- `\ze:`: Zero-width assertion before `:` (don't capture the colon)
- `nextgroup=gabcHeaderColon`: Next pattern to match

**Pattern 2: Header Colon**
```vim
syntax match gabcHeaderColon /:/ contained containedin=gabcHeaders 
  \ nextgroup=gabcHeaderValue skipwhite
```
- `contained`: Only match within parent context
- `skipwhite`: Skip whitespace before next group

**Pattern 3: Header Value**
```vim
syntax match gabcHeaderValue /\%(:\s*\)\@<=[^;]*/ 
  \ contained containedin=gabcHeaders nextgroup=gabcHeaderSemicolon
```
- `\%(:\s*\)\@<=`: Positive lookbehind for `:` and optional whitespace
- `[^;]*`: Any characters except `;`

**Pattern 4: Header Semicolon**
```vim
syntax match gabcHeaderSemicolon /;/ contained containedin=gabcHeaders
```

#### Testing

**Test File**:
```gabc
name: Kyrie;
annotation: IV;
mode: 4;
initial-style: 1;
%%
(notes)
```

**Verification**:
- Field names highlighted as Keyword
- Colons highlighted as Operator
- Values highlighted as String
- Semicolons highlighted as Delimiter

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| Field name | gabcHeaderField | Keyword | Keyword color |
| `:` | gabcHeaderColon | Operator | Operator color |
| Field value | gabcHeaderValue | String | String color |
| `;` | gabcHeaderSemicolon | Delimiter | Delimiter color |

**Note**: Using `default` links to respect user colorschemes:
```vim
highlight default link gabcHeaderField Keyword
```

---

### Iteration 3: Clef Notation

**Goal**: Implement syntax highlighting for clef specifications in the notes region

**Commit**: `1d961a7` - "syntax(gabc): restrict clef match to (c|cb|f)[1-4]"

#### Problem Analysis

GABC uses clefs to indicate pitch reference:
```gabc
(c4) (f3) (cb4) (c3@cb4)
```

**Clef Format**:
- Letter: `c`, `cb`, or `f`
- Number: `1`, `2`, `3`, or `4`
- Optional connector: `@` for clef changes
- Wrapped in parentheses

**Challenge**: Distinguish clefs from other note patterns like `(cde)` or `(fgh)`

#### Implementation

**Pattern 1: Clef Container**
```vim
syntax match gabcClef /(\%(cb\|[cf]\)[1-4]\%(@\%(cb\|[cf]\)[1-4]\)*)/ 
  \ containedin=gabcNotes 
  \ contains=gabcClefLetter,gabcClefNumber,gabcClefConnector
```

**Regex Breakdown**:
- `(`: Literal opening parenthesis
- `\%(cb\|[cf]\)`: Non-capturing group for `cb`, `c`, or `f`
- `[1-4]`: Digit 1-4
- `\%(...\)*`: Zero or more clef changes with `@` connector
- `)`: Literal closing parenthesis

**Why This Works**:
- Requires specific pattern: letter + digit
- Excludes random note patterns
- Allows clef changes: `(c4@f3)`

**Pattern 2: Clef Components**
```vim
syntax match gabcClefLetter /\(cb\|[cf]\)/ 
  \ contained containedin=gabcClef

syntax match gabcClefNumber /[1-4]/ 
  \ contained containedin=gabcClef

syntax match gabcClefConnector /@/ 
  \ contained containedin=gabcClef
```

#### Testing

**Test Cases**:
```gabc
(c4) Valid clef
(cb2) Valid clef with b
(f3) Valid f clef
(c4@f3) Valid clef change
(cde) NOT a clef (should be notes)
(c5) NOT valid (5 not in range)
```

**Verification Method**:
Use `:echo synIDattr(synID(line('.'), col('.'), 1), 'name')` to check syntax group at cursor

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `c`, `cb`, `f` | gabcClefLetter | Keyword | Keyword color |
| `1-4` | gabcClefNumber | Number | Number color |
| `@` | gabcClefConnector | Operator | Operator color |

---

### Iteration 4: Lyric Centering and Translation

**Goal**: Implement delimiters for lyric centering and translation text

**Commit**: `9130480` - "feat(syntax): add support for {} lyric centering and [] translation delimiters"

#### Problem Analysis

GABC supports special text formatting:

**Lyric Centering** (`{}`):
```gabc
a{lle}lu(g)ia
```
Centers "lle" under the note

**Translation** (`[]`):
```gabc
Ky[Lord]ri(g)e
```
Displays "Lord" as translation/gloss

#### Implementation

**Pattern 1: Lyric Centering**
```vim
syntax region gabcLyricCentering 
  \ matchgroup=gabcLyricCenteringDelim 
  \ start=/{/ end=/}/ 
  \ keepend oneline 
  \ containedin=gabcNotes
```

**Pattern 2: Translation**
```vim
syntax region gabcTranslation 
  \ matchgroup=gabcTranslationDelim 
  \ start=/\[/ end=/\]/ 
  \ keepend oneline 
  \ containedin=gabcNotes
```

**Why `matchgroup`?**
- Allows delimiters to have different highlight than content
- `matchgroup=X`: Delimiters get group `X`
- Content inside gets group from `syntax region` name

**Why `keepend`?**
- Prevents pattern from extending beyond closing delimiter
- Important for `}` and `]` which could appear in other contexts

**Why `oneline`?**
- These constructs should not span multiple lines
- Prevents runaway matching if closing delimiter missing

#### Testing

**Test File**:
```gabc
name: Test;
%%
a{lle}lu(g)ia
Ky[Lord]ri(e)e
san{c}tus[holy]
```

**Expected Behavior**:
- `{` and `}`: Highlighted as delimiters
- `lle`: Normal text inside centering
- `[` and `]`: Highlighted as delimiters  
- `Lord`: Highlighted as string inside translation

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `{` `}` | gabcLyricCenteringDelim | Delimiter | Delimiter color |
| Centered text | gabcLyricCentering | Special | Special color |
| `[` `]` | gabcTranslationDelim | Delimiter | Delimiter color |
| Translation text | gabcTranslation | String | String color |

---

### Iteration 5: GABC Markup Tags

**Goal**: Implement XML-like markup tags for text formatting

**Commit**: `c910866` - "feat(syntax): implement complete GABC markup tag support"

#### Problem Analysis

GABC supports various markup tags:
```gabc
<b>bold</b>
<i>italic</i>
<sc>small caps</sc>
<c>colored</c>
<ul>underline</ul>
<tt>teletype</tt>
<v>LaTeX verbatim</v>
<sp>special</sp>
<alt>alternative</alt>
<e>elision</e>
<nlba>no line break</nlba>
```

**Requirements**:
- Match opening and closing tags
- Highlight tag delimiters separately from content
- Apply appropriate highlighting to tag content

#### Implementation

**Pattern Strategy**: Use `syntax region` with `matchgroup` for each tag type

**Example: Bold Tag**
```vim
syntax region gabcBoldTag 
  \ start=+<b>+ end=+</b>+ 
  \ keepend transparent 
  \ containedin=gabcNotes 
  \ contains=gabcTagBracket,gabcTagSlash,gabcTagName,gabcBoldText
```

**Tag Components**:
```vim
" Tag delimiters
syntax match gabcTagBracket /[<>]/ contained
syntax match gabcTagSlash /\// contained  
syntax match gabcTagName /[a-z]\+/ contained

" Tag content (specific to each tag type)
syntax match gabcBoldText /\(>\)\@<=[^<]\+\(<\)\@=/ 
  \ contained containedin=gabcBoldTag
```

**Content Pattern Breakdown**:
- `\(>\)\@<=`: Positive lookbehind for `>`
- `[^<]\+`: One or more non-`<` characters
- `\(<\)\@=`: Positive lookahead for `<`

**Why This Pattern?**
- Captures only content between tags
- Excludes tag delimiters from content match
- Works for nested structures

#### Special Case: LaTeX Verbatim Tags

**Problem**: `<v>` tags contain LaTeX code that needs LaTeX syntax highlighting

**Solution**: Embed LaTeX syntax
```vim
" Load LaTeX syntax
syntax include @texSyntax $VIMRUNTIME/syntax/tex.vim

" Verbatim tag with LaTeX syntax
syntax region gabcVerbatimTag 
  \ start=+<v>+ end=+</v>+ 
  \ keepend 
  \ containedin=gabcNotes 
  \ contains=@texSyntax
```

**Loading Strategy**:
```vim
" Save current syntax state
let s:current_syntax_save = b:current_syntax
unlet! b:current_syntax

" Load tex syntax
try
  syntax include @texSyntax $VIMRUNTIME/syntax/tex.vim
catch
  syntax cluster texSyntax
endtry

" Don't restore yet (do it at end of file)
```

#### Testing

**Test File**:
```gabc
name: Markup Test;
%%
<b>bold text</b>
<i>italic</i> normal <sc>small caps</sc>
<v>\textit{latex}</v>
<e>elisio</e>n
```

**Verification**:
- Tag brackets highlighted as delimiters
- Tag names highlighted appropriately
- Content highlighted according to tag type
- LaTeX code has LaTeX syntax highlighting

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `<` `>` | gabcTagBracket | Delimiter | Delimiter color |
| `/` | gabcTagSlash | Delimiter | Delimiter color |
| Tag name | gabcTagName | Type | Type color |
| Bold content | gabcBoldText | Bold | Bold style |
| Italic content | gabcItalicText | Italic | Italic style |
| SC content | gabcSmallCapsText | Type | Type color |
| LaTeX content | (from @texSyntax) | Various | LaTeX colors |

---

### Iteration 6: GABC/NABC Snippet Containers

**Goal**: Implement containers for GABC and NABC notation snippets within parentheses

**Commit**: `980a35a` - "feat(syntax): add nabcSnippet container for NABC notation snippets"

#### Problem Analysis

GABC notation uses parentheses to delimit musical notation:
```gabc
(gabc_snippet|nabc_snippet)
```

- First snippet (before `|`): GABC notation
- Subsequent snippets (after `|`): NABC notation (alternative notation system)

#### Implementation

**Pattern 1: Notation Region**
```vim
syntax region gabcNotation matchgroup=gabcNotationDelim start=/(/ end=/)/ 
  \ keepend oneline containedin=gabcNotes contains=gabcSnippet,nabcSnippet transparent
```

**Pattern 2: GABC Snippet (first snippet)**
```vim
syntax match gabcSnippet /(\@<=[^|)]\+/ 
  \ contained containedin=gabcNotation transparent
```
- `(\@<=`: Positive lookbehind for `(`
- `[^|)]\+`: Match anything except `|` or `)`

**Pattern 3: Snippet Delimiter**
```vim
syntax match gabcSnippetDelim /|/ contained containedin=gabcNotation
```

**Pattern 4: NABC Snippet (after `|`)**
```vim
syntax match nabcSnippet /|\@<=[^|)]\+/ 
  \ contained containedin=gabcNotation transparent
```
- `|\@<=`: Positive lookbehind for `|`

#### Testing

**Test File**: `tests/smoke_nabc_snippet.vim`

**Test Cases** (7 tests):
1. `HAS_GABC_SIMPLE`: Simple GABC snippet recognition
2. `HAS_NABC_SIMPLE`: Simple NABC snippet after `|`
3. `HAS_NABC_QUAD_3`: Third NABC snippet in sequence
4. `GABC_NOT_IN_NABC`: Verify GABC pattern doesn't match NABC
5. `NABC_AFTER_PIPE`: Verify NABC only matches after `|`
6. `DELIMITER_SYNTAX`: Verify `|` is recognized as delimiter
7. `DELIMITER_HIGHLIGHT`: Verify delimiter highlights as Operator

**Challenges**:
- Initially, `nabcSnippet` wasn't appearing in syntax stack
- **Solution**: Add `nabcSnippet` to `gabcNotation` contains list

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `(` `)` | gabcNotationDelim | Delimiter | Delimiter color |
| `\|` | gabcSnippetDelim | Operator | Operator color |
| GABC snippet | gabcSnippet | (transparent) | No direct color |
| NABC snippet | nabcSnippet | (transparent) | No direct color |

---

### Iteration 7: GABC Pitch Letters

**Goal**: Implement syntax highlighting for musical pitch letters

**Commit**: `2f60a82` - "feat(syntax): add GABC pitch letter highlighting"

#### Problem Analysis

GABC uses letters to indicate pitch height:
- **Lowercase** (`a-n`, `p`): punctum quadratum (square notes)
- **Uppercase** (`A-N`, `P`): punctum inclinatum (inclined notes)
- **Excluded**: `o` and `O` (reserved for oriscus modifier)

#### Implementation

**Pattern**:
```vim
syntax match gabcPitch /[a-npA-NP]/ contained containedin=gabcSnippet
```

**Character Class Breakdown**:
- `[a-n]`: Lowercase a through n
- `p`: Lowercase p (explicitly added)
- `[A-N]`: Uppercase A through N  
- `P`: Uppercase P (explicitly added)

**Initial Mistake**:
```vim
" WRONG: Looks for two consecutive characters
syntax match gabcPitch /[a-np][A-NP]/
```

**Corrected**:
```vim
" CORRECT: Single character from combined class
syntax match gabcPitch /[a-npA-NP]/
```

#### Testing

**Test File**: `tests/smoke_gabc_pitch.vim`

**Test Cases** (12 tests):
1. `HAS_PITCH_A`: Lowercase 'a' recognized
2. `HAS_PITCH_N`: Lowercase 'n' recognized
3. `HAS_PITCH_P`: Lowercase 'p' recognized
4. `NO_PITCH_O`: Lowercase 'o' NOT recognized as pitch
5. `HAS_PITCH_A_UPPER`: Uppercase 'A' recognized
6. `HAS_PITCH_N_UPPER`: Uppercase 'N' recognized
7. `HAS_PITCH_P_UPPER`: Uppercase 'P' recognized
8. `NO_PITCH_O_UPPER`: Uppercase 'O' NOT recognized as pitch
9. `IN_SNIPPET`: Pitch must be inside snippet container
10. `NOT_OUTSIDE`: Pitch not recognized outside parentheses
11. `MULTIPLE_PITCHES`: Multiple pitches in sequence
12. `PITCH_HIGHLIGHT`: Highlight group verification

**Debug Scripts**:
- `tests/debug_pitch.vim`: Inspect pitch syntax at specific positions
- `tests/debug_pitch_p.vim`: Debug specific issue with 'p' character
- `tests/debug_syntax_list.vim`: List all syntax groups in buffer

**Challenges**:
- Character class pattern initially wrong (two-character match)
- Position calculations off by one in tests
- **Solution**: Created debug scripts to verify exact column positions

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `a-n`, `p` (lowercase) | gabcPitch | Character → Constant | Constant color |
| `A-N`, `P` (uppercase) | gabcPitch | Character → Constant | Constant color |

---

### Iteration 8: Pitch Inclinatum Suffixes

**Goal**: Implement direction indicators for inclined notes

**Commit**: `7f8eb84` - "feat(syntax): add pitch inclinatum suffix highlighting"

#### Problem Analysis

Uppercase pitches (punctum inclinatum) can have optional suffixes indicating visual direction:
- `0`: Left-leaning (descending interval)
- `1`: Right-leaning (ascending interval)
- `2`: No-leaning (unison/same pitch)

**Examples**:
- `(A0)`: A with left-leaning inclination
- `(G1)`: G with right-leaning inclination
- `(M2)`: M with no-leaning inclination

#### Implementation

**Pattern**:
```vim
syntax match gabcPitchSuffix /\([A-NP]\)\@<=[012]/ 
  \ contained containedin=gabcSnippet
```

**Regex Breakdown**:
- `\([A-NP]\)\@<=`: Positive lookbehind for uppercase pitch
- `[012]`: Match one of the three suffix digits

**Why Lookbehind?**
- Ensures suffix only matches after valid uppercase pitch
- Prevents `0`, `1`, `2` from matching standalone
- Lowercase pitches cannot have suffixes

**Container Update**:
```vim
" Must add gabcPitchSuffix to contains list
syntax match gabcSnippet /(\@<=[^|)]\+/ 
  \ contained containedin=gabcNotation 
  \ contains=gabcPitch,gabcPitchSuffix transparent
```

#### Testing

**Test File**: `tests/smoke_gabc_pitch_suffix.vim`

**Test Cases** (13 tests):
1. `HAS_SUFFIX_0`: Suffix '0' after uppercase pitch
2. `HAS_SUFFIX_1`: Suffix '1' after uppercase pitch
3. `HAS_SUFFIX_2`: Suffix '2' after uppercase pitch
4. `UPPERCASE_A_SUFFIX`: Suffix on 'A'
5. `UPPERCASE_N_SUFFIX`: Suffix on 'N'
6. `UPPERCASE_P_SUFFIX`: Suffix on 'P'
7. `LOWERCASE_NO_SUFFIX`: Lowercase pitch cannot have suffix
8. `NO_SUFFIX_ALONE`: Digit alone is not suffix
9. `PITCH_BEFORE_SUFFIX`: Verify pitch is recognized before suffix
10. `MULTIPLE_SUFFIXES`: Multiple suffixed pitches in sequence
11. `SUFFIX_IN_SNIPPET`: Suffix must be in snippet container
12. `SUFFIX_HIGHLIGHT`: Verify Number highlight group
13. Position validation tests

**Debug Scripts**:
- `tests/debug_suffix.vim`: Inspect suffix patterns
- `tests/debug_suffix_pos.vim`: Validate exact positions

**Challenges**:
- Initial position calculations incorrect in tests
- **Solution**: Debug scripts to find exact column indices

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `0`, `1`, `2` (after uppercase) | gabcPitchSuffix | Number → Constant | Constant color |

---

### Iteration 9: Pitch Modifiers

**Goal**: Implement comprehensive pitch modifier symbols

**Commit**: `ea8d637` - "feat(syntax): add comprehensive pitch modifiers and accidentals"

#### Problem Analysis

GABC supports numerous symbols that modify note appearance and meaning:

**Categories**:
1. **Initio Debilis**: `-` (before pitch) - weakened note start
2. **Oriscus**: `o`, `O` (special note types with optional 0/1 suffix)
3. **Simple Modifiers**: Single-character symbols after pitch
4. **Compound Modifiers**: Multi-character sequences (vv, vvv, ss, sss)
5. **Special**: `r0` (punctum cavum surrounded by lines)

#### Implementation Strategy

**Key Insight**: Pattern definition order matters in Vim!

**Order of Definition**:
1. Simple modifiers FIRST (so they can be overridden)
2. Compound modifiers AFTER (to take precedence)
3. Longer compounds LAST (highest precedence)

**Pattern 1: Initio Debilis**
```vim
syntax match gabcInitioDebilis /-\([a-npA-NP]\)\@=/ 
  \ contained containedin=gabcSnippet
```
- Uses lookahead `\@=` to match only when followed by pitch
- Only modifier that comes BEFORE pitch

**Pattern 2: Oriscus**
```vim
syntax match gabcOriscus /[oO]/ contained containedin=gabcSnippet
```

**Pattern 3: Oriscus Suffix**
```vim
syntax match gabcOriscusSuffix /\([oO]\)\@<=[01]/ 
  \ contained containedin=gabcSnippet
```
- Similar to pitch suffix, but only `0` or `1` (not `2`)

**Pattern 4: Simple Modifiers (defined FIRST)**
```vim
syntax match gabcModifierSimple /[qwWvVs~<>=rR]/ 
  \ contained containedin=gabcSnippet
```

**Symbols**:
- `q`: quadratum
- `w`: quilisma, `W`: quilisma quadratum
- `v`: virga (stem right), `V`: virga (stem left)
- `s`: stropha
- `~`: liquescent deminutus
- `<`: augmented liquescent, `>`: diminished liquescent
- `=`: linea
- `r`: punctum cavum, `R`: punctum quadratum surrounded

**Pattern 5: Special Compound**
```vim
syntax match gabcModifierSpecial /r0/ contained containedin=gabcSnippet
```

**Pattern 6: Compound Modifiers (defined AFTER simple)**
```vim
syntax match gabcModifierCompound /vv/ contained containedin=gabcSnippet
syntax match gabcModifierCompound /ss/ contained containedin=gabcSnippet
syntax match gabcModifierCompound /vvv/ contained containedin=gabcSnippet
syntax match gabcModifierCompound /sss/ contained containedin=gabcSnippet
```

**Why This Order Works**:
- When Vim sees `vvv`, it first matches three times with `gabcModifierSimple`
- Then `vv` pattern matches the first two characters (overriding simple)
- Finally `vvv` pattern matches all three (overriding `vv`)
- Result: `vvv` is recognized as `gabcModifierCompound`, not three separate `v`s

**Initial Mistake**:
```vim
" WRONG ORDER: Defined compounds before simples
syntax match gabcModifierCompound /vvv/ ...
syntax match gabcModifierCompound /vv/ ...
syntax match gabcModifierSimple /[...vVs...]/ ...
```

Result: Simple pattern would override compounds!

**Corrected Order**:
```vim
" CORRECT: Simple first, then compounds (longer last)
syntax match gabcModifierSimple /[qwWvVs~<>=rR]/ ...
syntax match gabcModifierCompound /vv/ ...
syntax match gabcModifierCompound /ss/ ...
syntax match gabcModifierCompound /vvv/ ...
syntax match gabcModifierCompound /sss/ ...
```

#### Testing

**Test File**: `tests/smoke_gabc_modifiers.vim`

**Test Cases** (34 tests covering all modifiers):
1. `HAS_PITCH`: Pitch recognition (baseline)
2. `HAS_INITIO_DEBILIS`: `-` before pitch
3. `INITIO_DEBILIS_HIGHLIGHT`: Identifier highlight
4. `HAS_ORISCUS`: Lowercase `o`
5. `HAS_ORISCUS_SCAPUS`: Uppercase `O`
6. `HAS_ORISCUS_SUFFIX`: Suffix after oriscus
7. `ORISCUS_SUFFIX_HIGHLIGHT`: Number highlight
8-12. Simple modifiers: `q`, `w`, `W`, `v`, `V`
13-14. Compound modifiers: `vv`, `vvv`
15. Simple modifier: `s`
16-17. Compound modifiers: `ss`, `sss`
18-21. Special modifiers: `~`, `<`, `>`, `=`
22-24. Cavum variants: `r`, `R`, `r0`
25-34. Accidentals (see Iteration 5)

**Challenges**:
- Compound patterns initially not matching (wrong order)
- Test environment interference from plugins
- **Solution**: Use `--noplugin -u NONE` and explicit syntax loading

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `-` (before pitch) | gabcInitioDebilis | Identifier | Identifier color |
| `o`, `O` | gabcOriscus | Identifier | Identifier color |
| `0`, `1` (after o/O) | gabcOriscusSuffix | Number → Constant | Constant color |
| `q`, `w`, `W`, `v`, `V`, `s`, `~`, `<`, `>`, `=`, `r`, `R` | gabcModifierSimple | Identifier | Identifier color |
| `vv`, `vvv`, `ss`, `sss` | gabcModifierCompound | Identifier | Identifier color |
| `r0` | gabcModifierSpecial | Identifier | Identifier color |

---

### Iteration 10: Accidentals (Initial Implementation)

**Goal**: Implement musical accidentals (flats, sharps, naturals)

**Commit**: `ea8d637` - "feat(syntax): add comprehensive pitch modifiers and accidentals"

#### Problem Analysis

Accidentals indicate pitch alterations:
- `x`: flat (♭)
- `#`: sharp (♯)
- `y`: natural (♮)
- `x?`, `#?`, `y?`: parenthesized (cautionary/editorial)
- `##`: soft sharp
- `Y`: soft natural

**Initial (Incorrect) Understanding**:
Pattern: accidental symbol + pitch letter
Example: `(xg)` = x (flat) + g (pitch)

#### Initial Implementation

**Patterns** (INCORRECT):
```vim
" Parenthesized accidentals
syntax match gabcAccidental /[x#y]?[a-npA-NP]/ ...

" Double sharp
syntax match gabcAccidental /##[a-npA-NP]/ ...

" Soft natural
syntax match gabcAccidental /Y[a-npA-NP]/ ...

" Basic accidentals
syntax match gabcAccidental /[x#y][a-npA-NP]/ ...
```

#### Testing (Initial)

Tests were written for incorrect pattern:
```vim
call setline(24, '(xg) Flat')
call setline(25, '(#g) Sharp')
call setline(26, '(yg) Natural')
```

Tests passed, but implementation was wrong!

---

### Iteration 11: Accidentals (Corrected)

**Goal**: Fix accidental pattern to match GABC specification

**Commit**: `91b5b94` - "fix(syntax): correct accidental pattern to pitch BEFORE symbol"

#### Problem Discovery

User feedback revealed the error:
> "The pitch letter indicating accidental height comes BEFORE the symbol, NOT AFTER"

**Correct Pattern**: pitch letter + accidental symbol  
**Correct Example**: `(gx)` = g (pitch) + x (flat on g)

**Real-world Example**: `(ixiv)`
- `ix`: i (pitch) + x (flat) = i with flat
- `i`: standalone pitch i
- `v`: virga modifier

#### Corrected Implementation

**Patterns** (CORRECTED):
```vim
" Parenthesized accidentals: pitch + x?, #?, y?
syntax match gabcAccidental /[a-npA-NP][x#y]?/ 
  \ contained containedin=gabcSnippet

" Double sharp: pitch + ##
syntax match gabcAccidental /[a-npA-NP]##/ 
  \ contained containedin=gabcSnippet

" Soft natural: pitch + Y
syntax match gabcAccidental /[a-npA-NP]Y/ 
  \ contained containedin=gabcSnippet

" Basic accidentals: pitch + x, #, y
syntax match gabcAccidental /[a-npA-NP][x#y]/ 
  \ contained containedin=gabcSnippet
```

**Key Change**:
- Before: `[x#y][pitch]` ❌
- After: `[pitch][x#y]` ✅

#### Updated Testing

**Test File**: `tests/smoke_gabc_modifiers.vim` (updated)

Changed test content:
```vim
call setline(24, '(gx) Flat')   " was (xg)
call setline(25, '(g#) Sharp')  " was (#g)
call setline(26, '(gy) Natural') " was (yg)
```

**New Test File**: `tests/smoke_accidental_order.vim`

**Test Cases** (10 tests):
1. `ACCIDENTAL_IX`: Verify `ix` pattern
2. `PITCH_I`: Verify standalone `i` after accidental
3. `MODIFIER_V`: Verify `v` modifier works after
4. `ACCIDENTAL_GX`: Flat on g
5. `ACCIDENTAL_GSHARP`: Sharp on g
6. `ACCIDENTAL_GY`: Natural on g
7. `ACCIDENTAL_AXQ`: Parenthesized flat
8. `ACCIDENTAL_CDSHARP`: Soft sharp
9. `ACCIDENTAL_EY`: Soft natural
10. `ACCIDENTAL_HIGHLIGHT`: Function highlight verification

**Debug Script**: `tests/debug_accidental_order.vim`

Validates position-by-position:
```
(ixiv)
 123456

Pos 2-3: ix = gabcAccidental
Pos 4:   i  = gabcPitch  
Pos 5:   v  = gabcModifierSimple
```

#### Highlight Groups

| Element | Syntax Group | Highlight Link | Visual Appearance |
|---------|--------------|----------------|-------------------|
| `gx`, `g#`, `gy` (pitch+accidental) | gabcAccidental | Function | Function color |
| `gx?`, `g#?`, `gy?` (parenthesized) | gabcAccidental | Function | Function color |
| `g##` (soft sharp) | gabcAccidental | Function | Function color |
| `gY` (soft natural) | gabcAccidental | Function | Function color |

**Important**: Accidental includes BOTH pitch letter and symbol, because the pitch letter indicates WHERE on the staff the accidental applies.

---

### Iteration 12: Highlight Group Refinement

**Goal**: Optimize visual contrast between syntax elements

**Commit**: `ea8d637` (same commit as iteration 4)

#### Problem Analysis

Initial highlight scheme had poor contrast:
- Pitches: `Identifier`
- Modifiers: `Identifier`

Result: Pitches and modifiers looked identical!

#### Solution

**Changed Pitch Highlight**:
```vim
" Before
highlight link gabcPitch Identifier

" After
highlight link gabcPitch Character
```

**Rationale**:
- `Character` translates to `Constant` in default colorschemes
- `Identifier` remains as-is
- Creates visual contrast between pitch letters and modifiers

#### Testing Impact

Tests needed updating:
```vim
" Before
if highlight ==# 'Identifier'

" After  
if highlight ==# 'Constant'  " Character → Constant translation
```

**Lesson**: Highlight group translation varies by colorscheme. Tests should verify translated group, not linked group.

---

## Syntax Highlighting Reference Table

### Complete Element-to-Highlight Mapping

| GABC Element | Example | Syntax Group | Highlight Link | Default Color | Semantic Purpose |
|--------------|---------|--------------|----------------|---------------|------------------|
| **File Structure** |
| Comment | `% comment` | `gabcComment` | `Comment` | Comment | Comments (any line starting with %) |
| Inline comment | `text % comment` | `gabcComment` | `Comment` | Comment | Comments after content |
| Section separator | `%%` | `gabcSectionSeparator` | `Special` | Special | Separates header from notes |
| Header region | (whole section) | `gabcHeaders` | (transparent) | - | Container for header fields |
| Notes region | (whole section) | `gabcNotes` | (transparent) | - | Container for musical notation |
| **Header Fields** |
| Field name | `name:` | `gabcHeaderField` | `Keyword` | Keyword | Header field name |
| Colon | `:` | `gabcHeaderColon` | `Operator` | Operator | Separator between name and value |
| Field value | `Example` | `gabcHeaderValue` | `String` | String | Header field value |
| Semicolon | `;` | `gabcHeaderSemicolon` | `Delimiter` | Delimiter | Field terminator |
| **Clefs** |
| Clef letter | `c` `cb` `f` | `gabcClefLetter` | `Keyword` | Keyword | Clef type indicator |
| Clef number | `1` `2` `3` `4` | `gabcClefNumber` | `Number` | Number | Staff line number |
| Clef connector | `@` | `gabcClefConnector` | `Operator` | Operator | Clef change connector |
| **Text Formatting** |
| Lyric centering delim | `{` `}` | `gabcLyricCenteringDelim` | `Delimiter` | Delimiter | Lyric centering boundaries |
| Centered text | `{text}` | `gabcLyricCentering` | `Special` | Special | Centered lyric text |
| Translation delim | `[` `]` | `gabcTranslationDelim` | `Delimiter` | Delimiter | Translation boundaries |
| Translation text | `[text]` | `gabcTranslation` | `String` | String | Alternative translation |
| **Markup Tags** |
| Tag bracket | `<` `>` | `gabcTagBracket` | `Delimiter` | Delimiter | Tag delimiters |
| Tag slash | `/` | `gabcTagSlash` | `Delimiter` | Delimiter | Closing tag indicator |
| Tag name | `b` `i` `sc` | `gabcTagName` | `Type` | Type | Tag type identifier |
| Bold text | `<b>text</b>` | `gabcBoldText` | `Bold` | Bold | Bold formatted text |
| Italic text | `<i>text</i>` | `gabcItalicText` | `Italic` | Italic | Italic formatted text |
| Small caps text | `<sc>text</sc>` | `gabcSmallCapsText` | `Type` | Type | Small capitals text |
| LaTeX verbatim | `<v>\LaTeX</v>` | (from @texSyntax) | Various | Various | Embedded LaTeX code |
| **Musical Notation** |
| Notation delimiters | `(` `)` | `gabcNotationDelim` | `Delimiter` | Delimiter | Mark notation boundaries |
| Snippet delimiter | `\|` | `gabcSnippetDelim` | `Operator` | Operator | Separate GABC/NABC |
| GABC snippet container | `(gabc\|` | `gabcSnippet` | (transparent) | - | Container for GABC elements |
| NABC snippet container | `\|nabc)` | `nabcSnippet` | (transparent) | - | Container for NABC elements |
| **Pitches** |
| Lowercase pitch | `a` `b` `c` ... `n` `p` | `gabcPitch` | `Character` | Constant | Punctum quadratum (square note) |
| Uppercase pitch | `A` `B` `C` ... `N` `P` | `gabcPitch` | `Character` | Constant | Punctum inclinatum (inclined note) |
| Inclinatum suffix | `A0` `G1` `M2` | `gabcPitchSuffix` | `Number` | Constant | Direction indicator (0=left, 1=right, 2=none) |
| **Modifiers** |
| Initio debilis | `-g` | `gabcInitioDebilis` | `Identifier` | Identifier | Weakened note start |
| Oriscus | `go` `gO` | `gabcOriscus` | `Identifier` | Identifier | Special note type |
| Oriscus suffix | `go0` `gO1` | `gabcOriscusSuffix` | `Number` | Constant | Oriscus direction (0=left, 1=right) |
| Quadratum | `gq` | `gabcModifierSimple` | `Identifier` | Identifier | Square note head |
| Quilisma | `gw` | `gabcModifierSimple` | `Identifier` | Identifier | Quilisma note |
| Quilisma quadratum | `gW` | `gabcModifierSimple` | `Identifier` | Identifier | Square quilisma |
| Virga (right) | `gv` | `gabcModifierSimple` | `Identifier` | Identifier | Virga with stem on right |
| Virga (left) | `gV` | `gabcModifierSimple` | `Identifier` | Identifier | Virga with stem on left |
| Stropha | `gs` | `gabcModifierSimple` | `Identifier` | Identifier | Stropha note |
| Liquescent deminutus | `g~` | `gabcModifierSimple` | `Identifier` | Identifier | Liquescent diminished |
| Augmented liquescent | `g<` | `gabcModifierSimple` | `Identifier` | Identifier | Liquescent augmented |
| Diminished liquescent | `g>` | `gabcModifierSimple` | `Identifier` | Identifier | Liquescent diminished |
| Linea | `g=` | `gabcModifierSimple` | `Identifier` | Identifier | Horizontal line |
| Punctum cavum | `gr` | `gabcModifierSimple` | `Identifier` | Identifier | Hollow note |
| Punctum quadratum surrounded | `gR` | `gabcModifierSimple` | `Identifier` | Identifier | Square note with lines |
| Bivirga | `gvv` | `gabcModifierCompound` | `Identifier` | Identifier | Two virgas |
| Trivirga | `gvvv` | `gabcModifierCompound` | `Identifier` | Identifier | Three virgas |
| Distropha | `gss` | `gabcModifierCompound` | `Identifier` | Identifier | Two strophas |
| Tristropha | `gsss` | `gabcModifierCompound` | `Identifier` | Identifier | Three strophas |
| Punctum cavum surrounded | `gr0` | `gabcModifierSpecial` | `Identifier` | Identifier | Hollow note with lines |
| **Accidentals** |
| Flat | `gx` | `gabcAccidental` | `Function` | Function | Flat (♭) on pitch g |
| Sharp | `g#` | `gabcAccidental` | `Function` | Function | Sharp (♯) on pitch g |
| Natural | `gy` | `gabcAccidental` | `Function` | Function | Natural (♮) on pitch g |
| Parenthesized flat | `gx?` | `gabcAccidental` | `Function` | Function | Cautionary flat |
| Parenthesized sharp | `g#?` | `gabcAccidental` | `Function` | Function | Cautionary sharp |
| Parenthesized natural | `gy?` | `gabcAccidental` | `Function` | Function | Cautionary natural |
| Soft sharp | `g##` | `gabcAccidental` | `Function` | Function | Soft sharp (less prominent) |
| Soft natural | `gY` | `gabcAccidental` | `Function` | Function | Soft natural (less prominent) |

### Highlight Group Rationale

| Highlight Group | Purpose | Visual Characteristics |
|-----------------|---------|------------------------|
| `Character` | Core musical content (pitches) | Constant color - stands out as primary content |
| `Number` | Numeric suffixes/indicators | Constant color - secondary numeric data |
| `Identifier` | Modifiers that change note appearance | Identifier color - modifies but doesn't replace |
| `Function` | Accidentals (pitch alterations) | Function color - strong visual distinction for important alterations |
| `Delimiter` | Structural boundaries | Delimiter color - subtle but clear structure |
| `Operator` | Snippet separators | Operator color - clear separation between GABC/NABC |

---

## Technical Patterns and Best Practices

### Vim Regex Patterns

#### 1. Positive Lookbehind

**Pattern**: `\(pattern\)\@<=`

**Use Case**: Match something that comes AFTER a specific pattern

**Example**:
```vim
" Match digits that come after uppercase pitch
syntax match gabcPitchSuffix /\([A-NP]\)\@<=[012]/
```

**Why**: Ensures suffix doesn't match standalone digits

#### 2. Positive Lookahead

**Pattern**: `\(pattern\)\@=`

**Use Case**: Match something that comes BEFORE a specific pattern

**Example**:
```vim
" Match dash that comes before a pitch
syntax match gabcInitioDebilis /-\([a-npA-NP]\)\@=/
```

**Why**: Ensures `-` only matches when followed by valid pitch

#### 3. Character Classes

**Pattern**: `[abc]` or `[a-z]`

**Combining Ranges**:
```vim
" Match a-n OR p (but not o)
[a-np]

" Match a-n, p, A-N, P (all in one class)
[a-npA-NP]
```

**Why**: More efficient than alternation `(a|b|c|...)`

#### 4. Transparent Containers

**Pattern**: `transparent` keyword

**Example**:
```vim
syntax match gabcSnippet /pattern/ transparent contains=...
```

**Why**: Container doesn't have its own highlighting, only contains other elements

**Critical Rule**: MUST specify `contains=` list explicitly!

### Pattern Order Strategy

#### Last-Match-Wins Principle

In Vim, when multiple patterns can match the same text, the LAST defined pattern wins.

**Example Problem**:
```vim
" Define simple 'v' first
syntax match gabcModifierSimple /[vV]/

" Then compound 'vvv'
syntax match gabcModifierCompound /vvv/
```

Result: `vvv` is recognized as compound ✅

**Reverse Order** (WRONG):
```vim
" Define compound first
syntax match gabcModifierCompound /vvv/

" Then simple
syntax match gabcModifierSimple /[vV]/
```

Result: `vvv` is recognized as three separate simple modifiers ❌

**Best Practice**:
1. Define simple/short patterns FIRST
2. Define compound/long patterns AFTER
3. Within compounds, define longer patterns LAST

### Testing Patterns

#### synstack() vs synID()

**Problem**: `synID()` returns 0 for transparent containers

**Solution**: Use `synstack()` to get ALL syntax groups at position

**Example**:
```vim
function! GetSyntaxAt(line, col) abort
  let synstack = synstack(a:line, a:col)
  if empty(synstack)
    return 'NONE'
  endif
  " Return last (innermost) syntax group
  return synIDattr(synstack[-1], 'name')
endfunction
```

#### Position Debugging

**Problem**: Off-by-one errors in position calculations

**Solution**: Create debug scripts that show exact positions

**Example**:
```vim
echo 'Positions in line 3: (ixiv)'
echo '                     123456'
echo ''
for col in range(1, 6)
  echo 'Pos ' . col . ': ' . GetSyntaxAt(3, col)
endfor
```

#### Isolated Testing

**Problem**: User plugins interfere with syntax testing

**Solution**: Use clean Neovim environment

**Command**:
```bash
nvim --headless --noplugin -u NONE -S test_script.vim
```

**Flags**:
- `--headless`: No GUI
- `--noplugin`: Don't load plugins
- `-u NONE`: Don't load vimrc
- `-S script.vim`: Source test script

### Container Hierarchy

**Rule**: Child elements must be listed in parent's `contains=`

**Example**:
```vim
" Parent container
syntax match gabcSnippet /pattern/ 
  \ contained containedin=gabcNotation
  \ contains=gabcPitch,gabcPitchSuffix,gabcModifierSimple
  \ transparent

" Child elements
syntax match gabcPitch /[a-npA-NP]/ 
  \ contained containedin=gabcSnippet

syntax match gabcPitchSuffix /\([A-NP]\)\@<=[012]/ 
  \ contained containedin=gabcSnippet
```

**Why**: Transparent containers don't automatically contain nested elements

---

## Testing Strategy

### Test Pyramid

```
        /\
       /  \
      / 10 \    Integration Tests (test-plugin.sh)
     /______\
    /        \
   /    76    \  Unit Tests (smoke_*.vim files)
  /____________\
 /              \
/      Debug      \ Debug Scripts (debug_*.vim files)
/__________________\
```

### Layer 1: Debug Scripts

**Purpose**: Interactive exploration and troubleshooting

**Characteristics**:
- Show syntax stack at specific positions
- Display highlight group translations
- Print detailed pattern matching info
- NOT automated (run manually)

**Examples**:
- `debug_pitch.vim`: Inspect pitch syntax
- `debug_accidental_order.vim`: Verify accidental pattern order
- `debug_suffix_pos.vim`: Find exact suffix positions

**When to Use**:
- Pattern not matching as expected
- Position calculations seem wrong
- Highlight groups not appearing correctly

### Layer 2: Smoke Tests

**Purpose**: Automated validation of individual features

**Characteristics**:
- One test file per feature
- 7-34 test cases per file
- Exit with `cquit` on failure
- Exit with `qall!` on success
- Emit `PASS`/`FAIL` messages

**Structure**:
```vim
" Setup
call setline(1, 'test content')
syntax clear
source /path/to/syntax/file.vim

" Test cases
if condition
  echom 'TEST_NAME=PASS'
else
  echom 'TEST_NAME=FAIL (details)'
  cquit  " Exit with error
endif

" Success
echom 'All tests passed!'
qall!
```

**Test Files**:
- `smoke_nabc_snippet.vim`: 7 tests
- `smoke_gabc_pitch.vim`: 12 tests
- `smoke_gabc_pitch_suffix.vim`: 13 tests
- `smoke_gabc_modifiers.vim`: 34 tests
- `smoke_accidental_order.vim`: 10 tests

**Total**: 76 automated tests

### Layer 3: Integration Tests

**Purpose**: Ensure all features work together in full environment

**Implementation**: `test-plugin.sh`

**Structure**:
```bash
# For each smoke test
echo "Running [feature] smoke test..."
./scripts/nvim-watchdog.sh 8 -- --headless -S tests/smoke_*.vim

# Verify key test cases
if timeout 5s nvim --headless -S test.vim | grep -q "KEY_TEST=PASS"; then
  echo "✓ Test passed"
else
  echo "! Test failed"
fi
```

**Features**:
- Runs all smoke tests in sequence
- Uses watchdog timer to prevent hangs
- Validates multiple key assertions per test
- Provides summary of pass/fail status

### Test-Driven Development Workflow

1. **Write Test**: Create smoke test with expected behavior
2. **Run Test**: Verify it fails (no implementation yet)
3. **Implement**: Write syntax pattern
4. **Debug**: Use debug scripts if test fails
5. **Iterate**: Adjust pattern until test passes
6. **Commit**: Atomic commit with passing test

**Example Cycle** (Pitch Suffixes):
```
1. Write smoke_gabc_pitch_suffix.vim (13 tests)
2. Run → all FAIL (no pattern yet)
3. Implement gabcPitchSuffix pattern
4. Run → some FAIL (position issues)
5. Create debug_suffix_pos.vim
6. Find correct positions, update test
7. Run → all PASS
8. Commit: "feat(syntax): add pitch inclinatum suffix highlighting"
```

### Test Coverage Goals

✅ **Pattern Matching**:
- Positive cases (should match)
- Negative cases (should NOT match)
- Boundary cases (edges of valid input)

✅ **Position Validation**:
- Element recognized at correct column
- Element inside correct container
- Element NOT recognized outside container

✅ **Highlight Groups**:
- Syntax group name correct
- Highlight link correct
- Translated highlight correct (Constant vs Identifier)

✅ **Complex Scenarios**:
- Multiple elements in sequence
- Overlapping patterns (accidental + pitch)
- Compound vs simple (vvv vs v+v+v)

---

## Porting to Other Platforms

### VS Code (TextMate Grammar)

**File**: `.tmLanguage.json` or `.tmLanguage.yaml`

**Key Differences**:
1. **JSON/YAML format** instead of VimScript
2. **Oniguruma regex** instead of Vim regex
3. **Scopes** instead of highlight groups
4. **Repository patterns** for reusability

**Example Translation**:

**Vim**:
```vim
syntax match gabcPitch /[a-npA-NP]/ contained containedin=gabcSnippet
highlight link gabcPitch Character
```

**TextMate Grammar** (JSON):
```json
{
  "patterns": [
    {
      "name": "constant.character.pitch.gabc",
      "match": "[a-npA-NP]",
      "comment": "GABC pitch letters (excluding o/O)"
    }
  ]
}
```

**Scope Naming Convention**:
- `constant.character.pitch.gabc` (pitch)
- `constant.numeric.suffix.gabc` (suffix)
- `entity.name.function.accidental.gabc` (accidental)
- `keyword.operator.modifier.gabc` (modifier)

**Pattern Order**: Use `begin`/`end` for containers and `include` for nested patterns

**Resources**:
- [TextMate Grammar Guide](https://macromates.com/manual/en/language_grammars)
- [VS Code Syntax Highlighting Guide](https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide)

### Emacs (Major Mode)

**File**: `gabc-mode.el`

**Key Differences**:
1. **Emacs Lisp** instead of VimScript
2. **Font-lock** system for highlighting
3. **Regex** with Emacs dialect
4. **Faces** instead of highlight groups

**Example Translation**:

**Vim**:
```vim
syntax match gabcPitch /[a-npA-NP]/ contained
highlight link gabcPitch Character
```

**Emacs**:
```elisp
(defvar gabc-font-lock-keywords
  '(
    ;; Pitch letters
    ("[a-npA-NP]" . font-lock-constant-face)
    
    ;; Accidentals (pitch + symbol)
    ("\\([a-npA-NP]\\)[x#yY]\\??" . font-lock-function-name-face)
    )
  "Keyword highlighting for GABC mode.")

(define-derived-mode gabc-mode fundamental-mode "GABC"
  "Major mode for editing GABC files."
  (setq font-lock-defaults '(gabc-font-lock-keywords)))
```

**Face Mapping**:
- `font-lock-constant-face` → Character (pitch)
- `font-lock-builtin-face` → Number (suffix)
- `font-lock-variable-name-face` → Identifier (modifier)
- `font-lock-function-name-face` → Function (accidental)

**Resources**:
- [Emacs Font Lock Mode](https://www.gnu.org/software/emacs/manual/html_node/elisp/Font-Lock-Mode.html)
- [Writing Major Modes](https://www.gnu.org/software/emacs/manual/html_node/elisp/Major-Modes.html)

### Sublime Text / TextMate

**File**: `GABC.sublime-syntax` (YAML format)

**Key Features**:
- YAML-based syntax definition
- Similar to VS Code but different format
- Supports inheritance and includes

**Example**:
```yaml
name: GABC
file_extensions: [gabc]
scope: source.gabc

contexts:
  main:
    - match: '\('
      scope: punctuation.section.notation.begin.gabc
      push: notation
      
  notation:
    - match: '\)'
      scope: punctuation.section.notation.end.gabc
      pop: true
      
    - match: '[a-npA-NP]'
      scope: constant.character.pitch.gabc
      
    - match: '[a-npA-NP][x#y]'
      scope: entity.name.function.accidental.gabc
```

**Resources**:
- [Sublime Text Syntax Definitions](https://www.sublimetext.com/docs/syntax.html)

### Tree-sitter (Modern Approach)

**File**: `grammar.js` (JavaScript)

**Key Features**:
- Generates incremental parser
- Works across multiple editors (Neovim, Emacs, etc.)
- Better performance for large files
- More complex to write

**Example Skeleton**:
```javascript
module.exports = grammar({
  name: 'gabc',
  
  rules: {
    source_file: $ => repeat($._item),
    
    _item: $ => choice(
      $.notation,
      $.text
    ),
    
    notation: $ => seq(
      '(',
      optional($.gabc_snippet),
      repeat(seq('|', $.nabc_snippet)),
      ')'
    ),
    
    gabc_snippet: $ => repeat1(choice(
      $.pitch,
      $.modifier,
      $.accidental
    )),
    
    pitch: $ => /[a-npA-NP]/,
    
    accidental: $ => seq(
      $.pitch,
      choice('x', '#', 'y', 'x?', '#?', 'y?', '##', 'Y')
    ),
    
    modifier: $ => choice(
      /[qwWvVs~<>=rR]/,
      'vv',
      'vvv',
      'ss',
      'sss',
      'r0'
    )
  }
});
```

**Highlight Queries** (`queries/highlights.scm`):
```scheme
(pitch) @constant.character
(accidental) @function
(modifier) @variable
```

**Resources**:
- [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/)
- [Tree-sitter Neovim Integration](https://github.com/nvim-treesitter/nvim-treesitter)

### General Porting Guidelines

#### 1. Understand Pattern Matching Differences

| Platform | Regex Flavor | Lookbehind | Lookahead | Character Classes |
|----------|--------------|------------|-----------|-------------------|
| Vim | Vim regex | `\@<=` | `\@=` | `[a-z]` |
| VS Code | Oniguruma | `(?<=)` | `(?=)` | `[a-z]` |
| Emacs | Emacs regex | Limited | Limited | `[a-z]` |
| Tree-sitter | JavaScript | Not regex-based | Not regex-based | Not regex-based |

#### 2. Map Highlight Groups

**Create Mapping Table**:

| Vim Group | VS Code Scope | Emacs Face | Sublime Scope |
|-----------|---------------|------------|---------------|
| Character | constant.character | font-lock-constant-face | constant.character |
| Number | constant.numeric | font-lock-builtin-face | constant.numeric |
| Identifier | variable.other | font-lock-variable-name-face | variable.other |
| Function | entity.name.function | font-lock-function-name-face | entity.name.function |
| Delimiter | punctuation.delimiter | font-lock-delimiter-face | punctuation.delimiter |
| Operator | keyword.operator | font-lock-operator-face | keyword.operator |

#### 3. Adapt Container Strategy

**Vim** uses `contains=` and `containedin=`:
```vim
syntax region container start=/(/ end=/)/
syntax match element /pattern/ contained containedin=container
```

**VS Code** uses `begin`/`end` with nested `patterns`:
```json
{
  "begin": "\\(",
  "end": "\\)",
  "patterns": [
    { "include": "#element" }
  ]
}
```

**Tree-sitter** uses grammar rules:
```javascript
container: $ => seq('(', $.element, ')')
```

#### 4. Test Incrementally

1. Start with simplest patterns (pitch letters)
2. Add containers (notation delimiters)
3. Add modifiers (one category at a time)
4. Add complex patterns (accidentals, compounds)
5. Test with real-world files

#### 5. Document Pattern Order

Different platforms handle pattern precedence differently:
- **Vim**: Last defined wins
- **VS Code**: Order in patterns array matters
- **Tree-sitter**: Grammar precedence rules

Document your ordering decisions!

---

## Lessons Learned

### Critical Insights

1. **Pattern Order is Crucial**: Always define simple patterns before complex ones in Vim

2. **Transparent Containers Need Explicit Contains**: Don't assume nested elements are automatically included

3. **Test in Isolation**: User configurations can interfere with syntax testing

4. **Position Debugging is Essential**: Off-by-one errors are common, use debug scripts

5. **Highlight Group Translation**: Groups may appear different in various colorschemes

6. **Lookbehind/Lookahead are Powerful**: Use them to enforce context without capturing

7. **Iterative Development Works**: Build one feature at a time with full testing

8. **Real-world Examples are Gold**: User feedback revealed accidental pattern error

9. **Documentation Prevents Regression**: Well-commented code explains WHY patterns are ordered a certain way

10. **Automated Testing Saves Time**: 76 tests catch regressions immediately

### Common Pitfalls

❌ **Defining patterns in wrong order**
```vim
" WRONG: Compound before simple
syntax match compound /vvv/
syntax match simple /v/
```

❌ **Forgetting to update contains list**
```vim
syntax match container /.../ contains=elementA
" Added elementB but forgot to update contains!
syntax match elementB /.../ contained containedin=container
```

❌ **Using wrong regex syntax**
```vim
" WRONG: Standard regex lookbehind
syntax match suffix /(?<=[A-N])[012]/

" RIGHT: Vim regex lookbehind  
syntax match suffix /\([A-N]\)\@<=[012]/
```

❌ **Testing with plugins loaded**
```bash
# WRONG: May have interference
nvim --headless -S test.vim

# RIGHT: Clean environment
nvim --headless --noplugin -u NONE -S test.vim
```

❌ **Not handling edge cases**
```vim
" Forgot to exclude 'o' and 'O' from pitch class
syntax match pitch /[a-pA-P]/  " WRONG: includes o/O
syntax match pitch /[a-npA-NP]/ " RIGHT: excludes o/O
```

---

## Conclusion

Building a syntax highlighting system requires:

1. **Deep understanding** of the target language's structure
2. **Careful pattern design** with attention to order and precedence
3. **Comprehensive testing** at multiple levels
4. **Iterative refinement** based on real-world usage
5. **Clear documentation** for future maintainers

This guide provides a blueprint for developing similar systems across any platform or language. The key is systematic, test-driven iteration with continuous validation.

---

## Additional Resources

### GABC Specification
- [Gregorio Project](https://gregorio-project.github.io/)
- [GABC Tutorial](https://gregorio-project.github.io/gabc/index.html)

### Syntax Highlighting Development
- [Vim Syntax Highlighting](https://vimhelp.org/syntax.txt.html)
- [VS Code Language Extensions](https://code.visualstudio.com/api/language-extensions/overview)
- [Emacs Major Modes](https://www.gnu.org/software/emacs/manual/html_node/elisp/Major-Modes.html)
- [Tree-sitter](https://tree-sitter.github.io/)

### Testing Tools
- [Vim Test Framework](https://github.com/junegunn/vader.vim)
- [VS Code Extension Testing](https://code.visualstudio.com/api/working-with-extensions/testing-extension)

---

**Document Version**: 1.0  
**Last Updated**: October 15, 2025  
**Maintained by**: AISCGre-BR/gregorio.nvim
