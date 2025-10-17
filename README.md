# gregorio.nvim

🎵 **Complete Gregorio Plugin for Neovim**

A comprehensive plugin for Neovim that implements full support for [Gregorio](https://gregorio-project.github.io) project files, including advanced syntax highlighting, intelligent snippets, powerful editing commands, Tree-sitter integration, and LSP support. This plugin brings all the functionality of [vscode-gregorio](https://github.com/AISCGre-BR/vscode-gregorio) to Neovim with enhanced performance through modular Lua implementation.

## Features

- **Complete syntax highlighting** for GABC files (including NABC extension)
- **Tree-sitter integration** for advanced parsing and text objects
- **LSP support** with semantic validation and auto-completion
- **Intelligent snippets** to accelerate GABC code writing
- **Markup commands** to add formatting (bold, italic, color, etc.)
- **Musical transposition** to raise/lower notes
- **Ligature conversion** between Unicode symbols (æ, œ) and `<sp>` tags
- **Automatic filling** of empty parentheses
- **NABC extension detection** with statusline indication
- **Advanced validation** of GABC syntax and NABC alternation patterns
- **Auto-formatting** and code cleanup
- **LaTeX syntax highlighting** in headers

## New Integration Features

### Tree-sitter Support
- Enhanced syntax highlighting with semantic understanding
- GABC-specific text objects (`af`, `if`, `as`, `is`, `an`, `in`)
- Incremental selection for precise editing
- Navigation commands between syllables and notation

### LSP Integration
- Real-time semantic validation
- Intelligent auto-completion for headers and notation
- NABC alternation pattern validation
- Hover documentation
- Code actions and diagnostics

See [Integration Documentation](docs/INTEGRATION.md) for detailed setup instructions.

## Plugin Structure

```
gregorio.nvim/
├── plugin/gregorio.vim          # Main plugin file
├── ftdetect/gabc.vim            # Filetype detection
├── ftplugin/gabc.vim            # GABC-specific settings
├── syntax/gabc.vim              # Complete syntax highlighting
├── lua/gabc/                    # Lua modules for functionalities
│   ├── init.lua                 # Main module with integration setup
│   ├── markup.lua               # Text markup commands
│   ├── transpose.lua            # Musical transposition
│   ├── utils.lua                # Utilities (ligatures, validation)
│   ├── nabc.lua                 # NABC detection and management
│   ├── treesitter.lua           # Tree-sitter integration
│   └── lsp.lua                  # LSP integration
├── snippets/gabc.snippets       # Snippets for UltiSnips/vim-snippets
├── templates/                   # Pre-filled GABC templates
│   ├── basic_gabc_template.gabc
│   ├── nabc_gabc_template.gabc
│   └── advanced_gabc_template.gabc
├── docs/INTEGRATION.md          # Integration setup documentation
├── doc/gregorio.txt             # Vim help documentation
├── example.gabc                 # Example file for testing
└── test-plugin.sh               # Plugin testing script
```

## Installation

### Using vim-plug

```vim
Plug 'AISCGre-BR/gregorio.nvim'
```

### Using packer.nvim

```lua
use 'AISCGre-BR/gregorio.nvim'
```

### Using lazy.nvim

```lua
{
  'AISCGre-BR/gregorio.nvim',
  ft = 'gabc',
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- Optional: for enhanced parsing
    'neovim/nvim-lspconfig',           -- Optional: for LSP support
  },
  config = function()
    require('gabc').setup({
      treesitter = {
        enabled = true,
        highlighting = true,
        textobjects = true,
      },
      lsp = {
        enabled = true,
        auto_attach = true,
      },
    })
  end,
}
```

### Manual installation

1. Clone the repository:
```bash
git clone https://github.com/AISCGre-BR/gregorio.nvim ~/.config/nvim/pack/plugins/start/gregorio.nvim
```

2. Restart Neovim or run `:PackerSync` / `:PlugInstall`

## Configuration

### Basic configuration

```lua
require('gabc').setup()
```

### Advanced configuration

```lua
require('gabc').setup({
  -- Disable default keymaps (default: true)
  enable_default_keymaps = true,
  
  -- Show NABC status in statusline (default: true)
  statusline_nabc = true,
  
  -- Auto-format on save (default: false)
  auto_format = false,
  
  -- Auto-validate on save (default: false)
  auto_validate = false,
  
  -- Tree-sitter integration (optional)
  treesitter = {
    enabled = true,           -- Enable tree-sitter integration
    auto_install = false,     -- Auto-install parser
    highlighting = true,      -- Enhanced syntax highlighting
    textobjects = true,       -- GABC-specific text objects
    incremental_selection = true, -- Incremental selection
  },
  
  -- LSP integration (optional)
  lsp = {
    enabled = true,           -- Enable LSP integration
    auto_attach = true,       -- Auto-attach to GABC buffers
    cmd = nil,                -- Custom server command (optional)
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
    },
  },
})
  
  -- Auto-validate on save (default: false)
  auto_validate = false,
})
```

### Statusline integration

To show NABC status in your statusline, add the `GabcStatusNabc()` function:

```vim
" For Vim/Neovim statusline
set statusline+=%{GabcStatusNabc()}
```

```lua
-- For lualine
require('lualine').setup({
  sections = {
    lualine_x = { 
      function()
        return require('gabc').statusline()
      end
    }
  }
})
```

## Commands

### Markup Commands

| Command | Default Keymap | Description |
|---------|----------------|-------------|
| `:GabcAddBold` | `<C-A-b>` | Adds `<b>` markup to syllable text |
| `:GabcAddItalic` | `<C-A-i>` | Adds `<i>` markup to syllable text |
| `:GabcAddColor` | `<C-A-c>` | Adds `<c>` markup to syllable text |
| `:GabcAddSmallCaps` | `<C-A-s>` | Adds `<sc>` markup to syllable text |
| `:GabcAddUnderline` | `<C-A-u>` | Adds `<ul>` markup to syllable text |
| `:GabcAddTeletype` | `<C-A-t>` | Adds `<tt>` markup to syllable text |
| `:GabcRemoveMarkup` | `<C-A-r>` | Removes all markup from text |

### Transposition Commands

| Command | Default Keymap | Description |
|---------|----------------|-------------|
| `:GabcTransposeUp` | `<C-A-=>` | Transposes notes up |
| `:GabcTransposeDown` | `<C-A-->` | Transposes notes down |

### Utility Commands

| Command | Default Keymap | Description |
|---------|----------------|-------------|
| `:GabcFillParens` | `<C-A-l>` | Fills empty parentheses with default note |
| `:GabcConvertLigaturesToTags` | `<C-A-L>` | Converts æ, œ to `<sp>` tags |
| `:GabcConvertTagsToLigatures` | `<C-A-T>` | Converts `<sp>` tags to æ, œ |
| `:GabcValidate` | - | Validates GABC file syntax |
| `:GabcCleanFormat` | - | Cleans formatting and unnecessary spaces |

### NABC Commands

| Command | Description |
|---------|-------------|
| `:GabcToggleNabc` | Toggles NABC extension in file |
| `:GabcAddNabc` | Adds NABC extension to file |
| `:GabcRemoveNabc` | Removes NABC extension from file |

### Information Command

| Command | Description |
|---------|-------------|
| `:GabcInfo` | Shows plugin and current file information |

## Snippets

The plugin includes various snippets to accelerate GABC code writing:

### Responses and Verses

- `a/.` → `<sp>A/</sp>.` (Antiphon response)
- `r/.` → `<sp>R/</sp>.` (Responsory response)  
- `v/.` → `<sp>V/</sp>.` (Verse)
- `ca/.`, `cr/.`, `cv/.` → Colored versions

### Special Symbols

- `c+` → `<c>+</c>` (Colored plus)
- `c*` → `<c>*</c>` (Colored asterisk)
- `\~` → `<sp>~</sp>` (Special tilde)
- `\-`, `\\`, `\&`, `\#`, `\_` → Special characters

### Verbatim Parentheses and Brackets

- `\(`, `\)`, `\[`, `\]` → Verbatim versions
- `c\(`, `c\)`, `c\[`, `c\]` → Colored versions

### Markup Tags

- `bold` → `<b>$1</b>`
- `italic` → `<i>$1</i>`
- `color` → `<c>$1</c>`
- `smallcaps` → `<sc>$1</sc>`
- `underline` → `<ul>$1</ul>`
- `teletype` → `<tt>$1</tt>`

### GABC Headers

- `gabcheader` → Complete GABC header template
- `nabcheader` → Header template with NABC extension

### Common Neumes

- `punctum` → `$1($2)`
- `pes` → `$1($2$3)`
- `clivis` → `$1($2$3)`
- `torculus` → `$1($2$3$4)`
- `porrectus` → `$1($2$3$4)`

### Clefs and Divisions

- `clef` → `(${1:c}${2:4})`
- `virgula` → `(`)`
- `divisio` → `(${1:,})`
- `finalis` → `(::)`

## Syntax Highlighting

The plugin provides complete highlighting for:

- **GABC Header** (fields like name:, annotation:, etc.)
- **Musical notes** (a-n, p, with accidentals #, x, y)
- **Neume shapes** (virga, stropha, oriscus, etc.)
- **Auxiliary symbols** (episema, ictus, punctum mora, etc.)
- **Spacing** (/, //, !, etc.)
- **Separation bars** (virgula, divisions)
- **Clefs** (c1, c2, c3, c4, f1, f2, f3, f4)
- **Line breaks** (z, Z)
- **Markup tags** (`<b>`, `<i>`, `<c>`, etc.)
- **NABC extension** (complete adiastematic notation)

## Technical Features

- **Modular Lua implementation** - Superior performance with separate modules for each functionality
- **Intelligent caching** - Optimized NABC detection and processing
- **Robust error handling** - Comprehensive error handling and user feedback
- **Header-aware operations** - All commands respect GABC file structure
- **Wide compatibility** - Neovim 0.5+ with VimScript fallback support

## Usage Examples

### Basic GABC file example

```gabc
name: Kyrie eleison;
annotation: XVII;
mode: 1;
%%
Ký(f)ri(gfg)e(h.) *() e(ixjvIH'GhvF'E)lé(ghg')i(g)son.(f.) (::)
```

### Using markup commands

1. Select text: `Ký(f)ri(gfg)e(h.)`
2. Press `<C-A-b>` or run `:GabcAddBold`
3. Result: `<b>Ký</b>(f)<b>ri</b>(gfg)<b>e</b>(h.)`

### Note transposition

1. Select: `Ký(f)ri(gfg)e(h.)`
2. Press `<C-A-=>` to transpose up
3. Result: `Ký(g)ri(hgh)e(i.)`

### Parentheses filling

1. Text: `Ký(f)ri(gfg)e() ele()`
2. Run `:GabcFillParens`
3. Result: `Ký(f)ri(gfg)e(f) ele(f)`

## Customization

### Disabling default keymaps

```lua
require('gabc').setup({
  enable_default_keymaps = false
})

-- Define your own keymaps
vim.api.nvim_set_keymap('n', '<leader>gb', ':GabcAddBold<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>gb', ':GabcAddBold<CR>gv', { noremap = true, silent = true })
```

### Custom keymaps

```lua
local function gabc_keymaps()
  local opts = { noremap = true, silent = true, buffer = true }
  
  -- Markup
  vim.keymap.set({'n', 'v'}, '<leader>gb', ':GabcAddBold<CR>', opts)
  vim.keymap.set({'n', 'v'}, '<leader>gi', ':GabcAddItalic<CR>', opts)
  vim.keymap.set({'n', 'v'}, '<leader>gc', ':GabcAddColor<CR>', opts)
  
  -- Transposition
  vim.keymap.set({'n', 'v'}, '<leader>g+', ':GabcTransposeUp<CR>', opts)
  vim.keymap.set({'n', 'v'}, '<leader>g-', ':GabcTransposeDown<CR>', opts)
  
  -- Utilities
  vim.keymap.set({'n', 'v'}, '<leader>gf', ':GabcFillParens<CR>', opts)
  vim.keymap.set('n', '<leader>gv', ':GabcValidate<CR>', opts)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gabc',
  callback = gabc_keymaps,
})
```

## Integration with other tools

### With LuaSnip

The plugin is compatible with LuaSnip. Make sure you have LuaSnip installed and configured.

### With telescope.nvim

```lua
-- Add command to search for GABC files
vim.api.nvim_create_user_command('TelescopeGabc', function()
  require('telescope.builtin').find_files({
    prompt_title = "GABC Files",
    find_command = {"find", ".", "-name", "*.gabc", "-type", "f"},
  })
end, {})
```

## Project Status

All vscode-gregorio functionalities have been successfully implemented for Neovim:

- ✅ **Syntax highlighting** - Complete GABC + NABC support
- ✅ **Intelligent snippets** - 30+ snippets for faster coding  
- ✅ **Markup commands** - Full text formatting support
- ✅ **Musical transposition** - Note transposition with accidentals
- ✅ **Ligature conversion** - Unicode ↔ GABC tag conversion
- ✅ **Parentheses filling** - Automatic empty parentheses completion
- ✅ **NABC detection** - Automatic extension recognition with statusline
- ✅ **Validation and formatting** - Syntax checking and code cleanup
- ❌ **Live preview** - Intentionally excluded (use external tools)

This plugin aims to maintain feature parity with the vscode-gregorio extension for Visual Studio Code while providing a native, optimized experience for Neovim users.

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on [vscode-gregorio](https://github.com/AISCGre-BR/vscode-gregorio) by Laércio de Sousa
- Inspired by the Gregorian Chant tradition and tools like [Gregorio](http://gregorio-project.github.io/)
- Neovim community for the excellent development platform

## Related Resources

- [Gregorio Project](http://gregorio-project.github.io/) - Typography tool for gregorian chant
- [GABC Tutorial](http://gregorio-project.github.io/gabc/index.html) - GABC notation guide
- [GABC Documentation](http://mirrors.ctan.org/support/gregoriotex/doc/GregorioRef.pdf) - Full GABC documentation
- [NABC Documentation](http://mirrors.ctan.org/support/gregoriotex/doc/GregorioNabcRef.pdf) - NABC extension documentation