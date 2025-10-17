# Integração com Tree-sitter e LSP

O projeto `gregorio.nvim` agora inclui suporte completo para integração com `tree-sitter-gregorio` e `gregorio-lsp`.

## Requisitos

### Tree-sitter
- `nvim-treesitter` plugin instalado
- Tree-sitter parser `gregorio` (instalado automaticamente ou manualmente)

### LSP
- `nvim-lspconfig` plugin instalado  
- `gregorio-lsp` server instalado e acessível

## Configuração

### Configuração Básica

```lua
require('gabc').setup({
  -- Tree-sitter configuration
  treesitter = {
    enabled = true,           -- Habilita integração tree-sitter
    auto_install = false,     -- Instala parser automaticamente
    highlighting = true,      -- Syntax highlighting avançado
    textobjects = true,       -- Text objects para GABC
    incremental_selection = true, -- Seleção incremental
  },
  
  -- LSP configuration
  lsp = {
    enabled = true,           -- Habilita integração LSP
    auto_attach = true,       -- Anexa automaticamente aos buffers GABC
    cmd = nil,                -- Comando customizado (opcional)
    settings = {
      validation = {
        enabled = true,
        nabc_alternation = true,
        header_validation = true,
        notation_validation = true,
      },
      completion = {
        enabled = true,
        headers = true,
        notation = true,
        nabc_glyphs = true,
      },
      hover = {
        enabled = true,
        show_documentation = true,
      },
    },
  },
})
```

### Configuração Avançada

```lua
require('gabc').setup({
  treesitter = {
    enabled = true,
    highlighting = true,
    textobjects = true,
    incremental_selection = true,
  },
  
  lsp = {
    enabled = true,
    -- Comando customizado para gregorio-lsp
    cmd = { 'node', '/path/to/gregorio-lsp/dist/server.js', '--stdio' },
    settings = {
      gregorio = {
        validation = {
          enabled = true,
          nabc_alternation = true,
          header_validation = true,
          notation_validation = true,
        },
        completion = {
          enabled = true,
          headers = true,
          notation = true,
          nabc_glyphs = true,
        },
        hover = {
          enabled = true,
          show_documentation = true,
        },
        diagnostics = {
          enabled = true,
          real_time = true,
        },
      },
    },
    -- Função customizada on_attach
    on_attach = function(client, bufnr)
      -- Suas configurações customizadas aqui
      print("gregorio-lsp attached to buffer " .. bufnr)
    end,
  },
})
```

## Comandos Disponíveis

### Tree-sitter
- `:GabcTreesitterInfo` - Exibe informações sobre o parser tree-sitter

### LSP
- `:GabcLspInfo` - Exibe informações sobre o servidor LSP
- `:GabcLspValidate` - Executa validação manual do documento
- `:GabcLspValidateNabc` - Valida alternância NABC especificamente

## Keymaps do LSP

Quando o LSP está anexado, os seguintes keymaps são configurados automaticamente:

- `gd` - Ir para definição
- `K` - Mostrar hover/documentação
- `gi` - Ir para implementação
- `<C-k>` - Assinatura de ajuda
- `<leader>rn` - Renomear símbolo
- `<leader>ca` - Ações de código
- `gr` - Mostrar referências
- `<leader>f` - Formatar documento
- `<leader>gv` - Validar documento GABC
- `<leader>gn` - Validar alternação NABC

## Text Objects (Tree-sitter)

Com tree-sitter habilitado, você ganha acesso a text objects específicos para GABC:

- `af`/`if` - Header externo/interno
- `as`/`is` - Sílaba externa/interna  
- `an`/`in` - Notação externa/interna

## Navegação (Tree-sitter)

Keymaps para navegar entre elementos:

- `]s`/`[s` - Próxima/anterior sílaba (início)
- `]S`/`[S` - Próxima/anterior sílaba (fim)
- `]n`/`[n` - Próxima/anterior notação (início)
- `]N`/`[N` - Próxima/anterior notação (fim)

## Instalação do Parser Tree-sitter

### Automática (recomendado)
O parser será configurado automaticamente. Use `:TSInstall gregorio` se necessário.

### Manual
```bash
cd tree-sitter-gregorio
npm install
npm run build
```

## Instalação do LSP Server

### Requisitos
- Node.js
- gregorio-lsp compilado e acessível

### Configuração do Comando
Se o gregorio-lsp não estiver no PATH, configure o comando manualmente:

```lua
require('gabc').setup({
  lsp = {
    cmd = { 'node', '/home/user/gregorio-lsp/dist/server.js', '--stdio' },
  },
})
```

## Troubleshooting

### Tree-sitter não funciona
1. Verifique se `nvim-treesitter` está instalado
2. Execute `:GabcTreesitterInfo` para diagnosticar
3. Tente `:TSInstall gregorio` manualmente

### LSP não conecta
1. Verifique se `nvim-lspconfig` está instalado
2. Execute `:GabcLspInfo` para diagnosticar  
3. Verifique se o comando do servidor está correto
4. Teste o servidor manualmente: `node /path/to/server.js --help`

### Fallback para Syntax Highlighting
Se tree-sitter não estiver disponível, o plugin usará automaticamente o syntax highlighting do Vim como fallback.

## Dependências

### Obrigatórias
- Neovim 0.8+
- gregorio.nvim

### Opcionais  
- `nvim-treesitter` - Para tree-sitter integration
- `nvim-lspconfig` - Para LSP integration
- `nvim-cmp` - Para completion avançado (recomendado)
- Tree-sitter parser `gregorio`
- `gregorio-lsp` server

## Exemplo de Configuração Completa

```lua
-- init.lua ou equivalent
require('gabc').setup({
  enable_default_keymaps = true,
  statusline_nabc = true,
  auto_format = false,
  auto_validate = true,
  
  treesitter = {
    enabled = true,
    auto_install = false,
    highlighting = true,
    textobjects = true,
    incremental_selection = true,
  },
  
  lsp = {
    enabled = true,
    auto_attach = true,
    settings = {
      validation = {
        enabled = true,
        nabc_alternation = true,
        header_validation = true,
        notation_validation = true,
      },
      completion = {
        enabled = true,
        headers = true,
        notation = true,
        nabc_glyphs = true,
      },
      hover = {
        enabled = true,
        show_documentation = true,
      },
    },
  },
})
```