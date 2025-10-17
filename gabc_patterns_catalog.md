# PADRÕES GABC IMPLEMENTADOS NO VIMSCRIPT (syntax/gabc.vim)

## PADRÕES containedin=gabcSnippet

### Pitches (Notas)
- gabcPitch: /[a-npA-NP]/ - Notas básicas
- gabcPitchSuffix: /\([A-NP]\)\@<=[012]/ - Sufixos de pitch (inclinatum)

### Accidentals (Acidentes)
- gabcAccidental: /[a-np][x#y]?/ - Acidentes básicos
- gabcAccidental: /[a-np]##/ - Duplo sustenido
- gabcAccidental: /[a-np]Y/ - Flat natural
- gabcAccidental: /[a-np][x#y]/ - Acidentes específicos

### Initio Debilis
- gabcInitioDebilis: /-\([a-npA-NP]\)\@=/ - Initio debilis (-)

### Oriscus
- gabcOriscus: /[oO]/ - Oriscus básico
- gabcOriscusSuffix: /\([oO]\)\@<=[01]/ - Variantes de oriscus

### Modifiers (Modificadores)
- gabcModifierSimple: /[qwWvVs~<>=rR.]/ - Modificadores simples
- gabcModifierSpecial: /r[0-8]/ - Modificadores especiais r0-r8
- gabcModifierEpisema: /_/ - Episema
- gabcModifierEpisemaNumber: /\(_\)\@<=[0-5]/ - Números episema
- gabcModifierIctus: /'/ - Ictus
- gabcModifierIctusNumber: /\('\)\@<=[01]/ - Números ictus
- gabcModifierCompound: /vv/ - Bivirga
- gabcModifierCompound: /ss/ - Distropha
- gabcModifierCompound: /vvv/ - Trivirga
- gabcModifierCompound: /sss/ - Tristropha

### Bars/Divisions (Barras/Divisões)
- gabcBarDouble: /::/ - Divisio finalis (barra dupla)
- gabcBarDotted: /:?/ - Divisio maior pontilhada
- gabcBarMaior: /:/ - Divisio maior (barra completa)
- gabcBarMinor: /;/ - Divisio minor (meia barra)
- gabcBarMinima: /,/ - Divisio minima (quarto de barra)
- gabcBarMinimaOcto: /\^/ - Divisio minimis/oitavo de barra
- gabcBarVirgula: /`/ - Vírgula
- gabcBarMinorSuffix: /\(;\)\@<=[1-8]/ - Sufixos barra menor
- gabcBarZeroSuffix: /\([,\^`]\)\@<=0/ - Sufixo zero para barras

### Spacing (Espaçamento)
- gabcSpacingSmall: /\// - Separação pequena
- gabcSpacingHalf: /\/0/ - Meio espaço
- gabcSpacingSingle: /\/!/ - Separação pequena (mesmo neuma)
- gabcSpacingDouble: /\/\// - Separação média
- gabcSpacingBracket: /\(\/\)\@<=\[/ - Delimitador [ para fator
- gabcSpacingBracket: /\]/ - Delimitador ] para fator
- gabcSpacingFactor: /\(\[\)\@<=-\?\d\+\(\.\d\+\)\?/ - Fator numérico
- gabcSpacingZero: /!/ - Espaço zero

### Attributes (Atributos)
- gabcAttrAboveLinesText: /\[alt:\([^\]]\+\)\]/ - Texto acima das linhas

## TOTAL DE PADRÕES GABC: 30+ padrões implementados