# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Inspired by and based on the excellent [vscode-gabc](https://github.com/gregoriano-br/vscode-gabc) extension by Laércio de Sousa
- Maintains compatibility with GABC files created for the VS Code extension
- Preserves all functionality while adding Neovim-specific improvements