-- Treesitter configuration for GABC
-- This file provides optional Treesitter queries for enhanced highlighting
-- Note: Requires a custom GABC parser to be installed

-- If you want to use Treesitter instead of the built-in syntax highlighting,
-- you can configure it like this:

--[[
require('nvim-treesitter.configs').setup({
  ensure_installed = { "gabc" }, -- Custom parser needed
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "gabc" },
  },
})
--]]

-- For now, we rely on the comprehensive Vim syntax file provided
-- The syntax highlighting is very complete and performant

-- Future enhancement: Create a proper Treesitter grammar for GABC
-- This would enable better:
-- - Code navigation
-- - Text objects
-- - Incremental selection
-- - Advanced folding

return {}