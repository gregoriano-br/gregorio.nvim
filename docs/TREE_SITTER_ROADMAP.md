# Roadmap de Implementação Tree-sitter

## Motivação

O syntax highlighting do Vim tem limitações fundamentais que impedem parsing preciso da notação GABC, especificamente:

1. **Alternância GABC/NABC**: Não pode manter estado para contar delimitadores pipe
2. **Estruturas Aninhadas Complexas**: Matching baseado em regex tem dificuldade com aninhamento profundo
3. **Performance**: Arquivos grandes podem causar lentidão com padrões regex complexos
4. **Precisão**: Padrões context-sensitive impossíveis sem máquina de estados

Tree-sitter resolve isso fornecendo um parser completo com gerenciamento de estado.

## Visão Geral do Tree-sitter

Tree-sitter é uma ferramenta geradora de parsers que:
- Cria parsers incrementais a partir de especificações de gramática
- Mantém AST (Abstract Syntax Tree) completa
- Suporta recuperação de erros e parsing parcial
- Integra com sistema de highlighting nativo do Neovim
- Fornece highlighting baseado em queries (mais poderoso que regex)

## Plano de Implementação

### Fase 1: Desenvolvimento da Gramática (Estimativa: 2-3 semanas)

**Objetivo**: Criar `grammar.js` para formato GABC

**Tarefas**:
1. Estudar documentação e exemplos do Tree-sitter
2. Definir regras de gramática GABC:
   - Seção de cabeçalho (pares chave-valor)
   - Separador de seção (`%%`)
   - Seção de partitura (sílabas e notação)
   - Lógica de alternância de notação musical
   - Caracteres especiais e macros
3. Implementar rastreamento de estado para alternância GABC/NABC
4. Tratar casos extremos (comentários, tags especiais, etc.)

**Arquivos a criar**:
- `grammar.js` - Especificação principal da gramática
- `package.json` - Metadados do pacote Tree-sitter
- `src/parser.c` - Parser gerado (auto-gerado)

**Referências**:
- Documentação Tree-sitter: https://tree-sitter.github.io/tree-sitter/creating-parsers
- Gramáticas exemplo: https://github.com/tree-sitter
- Compilador Gregorio: https://github.com/gregorio-project/gregorio (implementação de referência)

### Fase 2: Teste do Parser (Estimativa: 1-2 semanas)

**Objetivo**: Validar gramática contra arquivos GABC reais

**Tarefas**:
1. Criar corpus de teste com padrões GABC diversos
2. Testar lógica de alternância com várias configurações
3. Testar recuperação de erro (entrada malformada)
4. Benchmark de performance do parser
5. Iterar na gramática baseado em resultados dos testes

**Arquivos a criar**:
- `test/corpus/` - Casos de teste
- `test/highlight/` - Testes de highlighting
- `queries/test-gabc.scm` - Testes de query

**Casos de teste**:
- Alternância simples: `(e|nabc|fgFE)`
- Padrões complexos: `(e|````vi-lse4|fgFE|pehhsu2)`
- Múltiplas linhas de NABC
- Estruturas aninhadas
- Casos extremos e entrada malformada

### Fase 3: Desenvolvimento de Queries (Estimativa: 1 semana)

**Objetivo**: Criar queries Tree-sitter para syntax highlighting

**Tarefas**:
1. Definir queries de highlight (`queries/highlights.scm`)
2. Mapear nós AST para grupos de highlight
3. Implementar highlighting context-sensitive
4. Testar queries com vários arquivos GABC

**Arquivos a criar**:
- `queries/highlights.scm` - Syntax highlighting
- `queries/locals.scm` - Variáveis/escopos locais
- `queries/folds.scm` - Code folding (opcional)
- `queries/indents.scm` - Auto-indentação (opcional)

**Grupos de highlight a definir**:
- Cabeçalhos (nomes de campo, valores)
- Separador de seção
- Letras (texto, estilos, tradução)
- Snippets GABC (pitches, modificadores, barras)
- Snippets NABC (neumas St. Gall)
- Comentários e anotações
- Erros (sintaxe inválida)

### Fase 4: Integração Neovim (Estimativa: 1 semana)

**Objetivo**: Integrar parser com Neovim/gregorio.nvim

**Tarefas**:
1. Configurar plugin para usar parser Tree-sitter
2. Configurar detecção de filetype
3. Mapear grupos de highlight para colorscheme
4. Adicionar opções de configuração
5. Atualizar documentação

**Arquivos a modificar**:
- `plugin/gregorio.lua` - Adicionar setup Tree-sitter
- `ftdetect/gabc.vim` - Manter detecção de filetype
- `after/queries/gabc/` - Instalar queries
- `README.md` - Documentar uso Tree-sitter

**Configuração**:
```lua
require('nvim-treesitter.configs').setup {
    ensure_installed = { "gabc" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
```

### Fase 5: Documentação & Lançamento (Estimativa: 1 semana)

**Objetivo**: Documentar uso Tree-sitter e caminho de migração

**Tarefas**:
1. Escrever documentação de uso
2. Criar guia de migração da sintaxe Vim
3. Documentar problemas conhecidos e limitações
4. Atualizar README com informações Tree-sitter
5. Publicar parser no registro Tree-sitter

**Seções de documentação**:
- Instruções de instalação
- Opções de configuração
- Comparação com sintaxe Vim
- Guia de troubleshooting
- Contribuindo para gramática

## Detalhes Técnicos de Implementação

### Máquina de Estados de Alternância

O desafio chave (alternância GABC/NABC) será resolvido com estado do parser:

```javascript
// Em grammar.js
notation: $ => seq(
    '(',
    optional($.gabc_snippet),
    repeat(seq('|', choice($.nabc_snippet, $.gabc_snippet))),
    ')'
),

// Rastreamento de estado em ações do parser
gabc_snippet: $ => {
    // Parser rastreia posição automaticamente
    // Posições ímpares = GABC, posições pares = NABC
},
```

O parser irá:
1. Entrar na regra `notation` em `(`
2. Primeiro snippet é GABC (posição 0)
3. Cada `|` incrementa contador de posição
4. Posições ímpares = GABC, posições pares = NABC
5. Sair em `)`

### Queries de Highlight

```scheme
; queries/highlights.scm

; Snippets GABC (posições ímpares)
(gabc_snippet) @gabc.snippet

; Snippets NABC (posições pares)  
(nabc_snippet) @nabc.snippet

; Pitches dentro de GABC
(gabc_snippet
  (pitch) @gabc.pitch)

; Highlighting context-sensitive
(notation
  delimiter: "|" @gabc.delimiter)
```

## Estratégia de Migração

### Compatibilidade Retroativa

Para suportar usuários sem Tree-sitter:
1. Manter sintaxe Vim como fallback
2. Auto-detectar disponibilidade Tree-sitter
3. Usar Tree-sitter se disponível, sintaxe Vim caso contrário

```lua
-- plugin/gregorio.lua
if pcall(require, 'nvim-treesitter') then
    -- Usar Tree-sitter
    require('nvim-treesitter.configs').setup { ... }
else
    -- Fall back para sintaxe Vim
    vim.cmd('runtime syntax/gabc.vim')
end
```

### Timeline de Deprecação

- **v1.0**: Lançamento com sintaxe Vim e Tree-sitter
- **v1.1-v1.5**: Manter ambos, recomendar Tree-sitter
- **v2.0**: Considerar deprecar sintaxe Vim (baseado em adoção)

## Requisitos de Recursos

### Tempo de Desenvolvimento

- Fase 1 (Gramática): 2-3 semanas
- Fase 2 (Testes): 1-2 semanas  
- Fase 3 (Queries): 1 semana
- Fase 4 (Integração): 1 semana
- Fase 5 (Documentação): 1 semana

**Total**: 6-8 semanas para implementação inicial

### Habilidades Necessárias

- JavaScript (para grammar.js)
- Noções básicas de teoria de parsers
- Conhecimento de notação GABC
- Linguagem de query Tree-sitter
- API Lua do Neovim
- Teste e documentação

### Dependências

- Node.js (para CLI Tree-sitter)
- Ferramenta CLI Tree-sitter
- Compilador C (para geração de parser)
- Neovim 0.9+ com suporte Tree-sitter

## Critérios de Sucesso

A implementação Tree-sitter será considerada bem-sucedida quando:

1. ✅ Alternância GABC/NABC perfeita funcionando
2. ✅ Todas as features da sintaxe Vim replicadas
3. ✅ Performance igual ou melhor que sintaxe Vim
4. ✅ Suite de testes com >95% de cobertura
5. ✅ Documentação completa
6. ✅ Zero breaking changes para usuários finais

## Referências

- Tree-sitter: https://tree-sitter.github.io/tree-sitter/
- Neovim Tree-sitter: https://neovim.io/doc/user/treesitter.html
- Tree-sitter GABC (este projeto): https://github.com/AISCGre-BR/tree-sitter-gabc
- Compilador Gregorio: https://github.com/gregorio-project/gregorio
- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter

## Próximos Passos

1. **Imediato**: Completar sintaxe Vim com limitações documentadas ✅
2. **Curto prazo**: Estudar Tree-sitter e criar gramática proof-of-concept
3. **Médio prazo**: Implementar gramática completa com suporte a alternância
4. **Longo prazo**: Lançar parser Tree-sitter e deprecar sintaxe Vim

## Envolvimento da Comunidade

Aceitamos contribuições para implementação Tree-sitter:
- Desenvolvimento e teste de gramática
- Refinamento de queries
- Documentação
- Relatórios de bugs e pedidos de features

Participe da discussão: [GitHub Discussions](https://github.com/AISCGre-BR/gregorio.nvim/discussions)

---

**Versão do Documento**: 1.0  
**Última Atualização**: Dezembro 2024  
**Mantido por**: AISCGre-BR/gregorio.nvim
