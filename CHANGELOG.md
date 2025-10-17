# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-XX - Integration Release

### Added
- **Tree-sitter Integration**
  - Full integration with tree-sitter-gregorio parser
  - Enhanced syntax highlighting with semantic understanding
  - GABC-specific text objects (headers, syllables, notation)
  - Incremental selection for precise editing
  - Navigation commands between GABC elements
  
- **LSP Support**
  - Complete integration with gregorio-lsp server
  - Real-time semantic validation
  - Intelligent auto-completion for headers and notation
  - NABC alternation pattern validation
  - Hover documentation and diagnostics
  - Code actions for common GABC tasks

- **Enhanced Templates**
  - Pre-filled GABC templates for rapid development
  - Basic, NABC, and advanced template variants
  - Proper header structures with examples

- **LaTeX Integration**
  - Syntax highlighting for LaTeX commands in headers
  - Support for `\textbf{}`, `\textit{}`, `\emph{}` in name, annotation, commentary
  - Embedded TeX syntax highlighting

### Enhanced
- **Configuration System**
  - Unified setup function with tree-sitter and LSP options
  - Granular control over integration features
  - Fallback support when integrations unavailable

- **Command Interface**
  - New commands: `:GabcTreesitterInfo`, `:GabcLspInfo`
  - LSP validation commands: `:GabcLspValidate`, `:GabcLspValidateNabc`
  - Enhanced plugin information with integration status

- **Documentation**
  - Comprehensive integration setup guide
  - Troubleshooting section for common issues
  - Updated README with new features

### Technical
- **Module Structure**
  - New `lua/gabc/treesitter.lua` with full tree-sitter configuration
  - New `lua/gabc/lsp.lua` with complete LSP client setup
  - Enhanced `lua/gabc/init.lua` with integration support

- **Syntax Highlighting**
  - LaTeX embedding in GABC headers
  - Enhanced fallback when tree-sitter unavailable
  - Improved header value parsing

### Dependencies (Optional)
- `nvim-treesitter` - For tree-sitter integration
- `nvim-lspconfig` - For LSP integration  
- `tree-sitter-gregorio` parser
- `gregorio-lsp` server

### Breaking Changes
- None - All changes are additive and optional

### Migration Guide
Existing configurations continue to work unchanged. To use new features:

```lua
require('gabc').setup({
  -- Existing options work as before
  enable_default_keymaps = true,
  statusline_nabc = true,
  
  -- New optional integrations
  treesitter = { enabled = true },
  lsp = { enabled = true },
})
```

## [1.0.0] - 2025-10-14

### Added
- Initial release of gregorio.nvim plugin
- Complete syntax highlighting for GABC files
- NABC extended notation support with syntax highlighting
- Comprehensive snippet collection for rapid GABC entry
- Text markup commands (bold, italic, color, small caps, underline, teletype)
- Remove markup functionality for cleaning text
- Musical transposition commands (up/down)
- Ligature conversion between Unicode symbols (æ, œ) and `<sp>` tags
- Empty parentheses filling with default notes
- NABC extension detection with statusline indication
- Basic GABC syntax validation
- Auto-formatting and code cleanup utilities
- Configurable keymaps with sensible defaults
- Statusline integration for NABC status
- Comprehensive documentation in both Markdown and Vim help format
- Lua-based implementation for better performance and maintainability

### Features
- **Syntax Highlighting**: Complete coverage of GABC notation including:
  - Header fields and values
  - Musical notes (a-n, p) with accidentals (#, x, y)
  - Neume shapes (virga, stropha, oriscus, quilisma, etc.)
  - Symbols and modifiers (episema, ictus, punctum mora)
  - Spacing controls and separation bars
  - Clefs and line breaks
  - Markup tags and translation text
  - NABC extended notation with all neume types and modifiers

- **Snippets**: Over 30 intelligent snippets including:
  - Response and verse markings (A/, R/, V/)
  - Special characters and symbols
  - Markup tag templates
  - Complete header templates (with and without NABC)
  - Common neume patterns
  - Clefs and musical divisions

- **Commands**: 15+ commands for comprehensive GABC editing:
  - 7 markup addition commands
  - 1 markup removal command
  - 2 transposition commands
  - 5 utility commands (validation, formatting, ligature conversion)
  - 3 NABC management commands

- **Configuration**: Flexible setup with options for:
  - Disabling default keymaps
  - Statusline integration control
  - Auto-formatting on save
  - Auto-validation on save

### Technical Details
- Lua-based core for better performance
- VimScript compatibility layer for traditional Vim users  
- Modular architecture with separate modules for:
  - `markup`: Text formatting functionality
  - `transpose`: Musical transposition
  - `utils`: File utilities and validation
  - `nabc`: NABC extension management
- Comprehensive error handling and user feedback
- Cache system for NABC detection to improve performance
- Header-aware processing (commands respect GABC file structure)

### Compatibility
- Neovim 0.5+ (required for Lua functionality)
- Compatible with popular plugin managers (vim-plug, packer.nvim, lazy.nvim)
- Works with snippet engines (UltiSnips, LuaSnip)
- Integrates with statusline plugins (lualine, airline)

### Based On
- Inspired by and based on the excellent [vscode-gregorio](https://github.com/AISCGre-BR/vscode-gregorio) extension by Laércio de Sousa
- Maintains compatibility with GABC files created for the VS Code extension
- Preserves all functionality while adding Neovim-specific improvements