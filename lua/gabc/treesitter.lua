-- Tree-sitter integration for GABC
-- Integrates with tree-sitter-gregorio parser for enhanced functionality

local M = {}

-- Check if tree-sitter-gregorio is available
local function is_treesitter_available()
  local has_ts, ts = pcall(require, 'nvim-treesitter.parsers')
  if not has_ts then
    return false
  end
  
  -- Check if gregorio parser is available
  local parsers = ts.get_parser_configs()
  return parsers.gregorio ~= nil
end

-- Configure tree-sitter-gregorio parser
function M.setup_parser()
  local has_ts, ts = pcall(require, 'nvim-treesitter.parsers')
  if not has_ts then
    vim.notify('nvim-treesitter not found. Install it for enhanced GABC support.', vim.log.levels.WARN)
    return false
  end
  
  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  
  -- Configure gregorio parser
  parser_config.gregorio = {
    install_info = {
      url = "https://github.com/AISCGre-BR/tree-sitter-gregorio",
      files = {"src/parser.c"},
      branch = "main",
      generate_requires_npm = false,
    },
    filetype = "gabc",
    maintainers = {"@AISCGre-BR"},
  }
  
  vim.notify('Tree-sitter gregorio parser configured successfully!', vim.log.levels.INFO)
  return true
end

-- Setup tree-sitter highlighting
function M.setup_highlighting()
  if not is_treesitter_available() then
    vim.notify('Tree-sitter gregorio parser not installed. Using fallback syntax highlighting.', vim.log.levels.INFO)
    return false
  end
  
  local has_configs, configs = pcall(require, 'nvim-treesitter.configs')
  if not has_configs then
    return false
  end
  
  -- Enhanced configuration for GABC
  configs.setup({
    ensure_installed = vim.list_extend(configs.get_config().ensure_installed or {}, { "gregorio" }),
    
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "gabc" }, -- Keep vim syntax as fallback
    },
    
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = "<C-s>",
        node_decremental = "<C-backspace>",
      },
    },
    
    indent = {
      enable = false, -- GABC has specific indentation rules
    },
    
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@header.outer",
          ["if"] = "@header.inner",
          ["as"] = "@syllable.outer",
          ["is"] = "@syllable.inner",
          ["an"] = "@notation.outer",
          ["in"] = "@notation.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]s"] = "@syllable.outer",
          ["]n"] = "@notation.outer",
        },
        goto_next_end = {
          ["]S"] = "@syllable.outer",
          ["]N"] = "@notation.outer",
        },
        goto_previous_start = {
          ["[s"] = "@syllable.outer",
          ["[n"] = "@notation.outer",
        },
        goto_previous_end = {
          ["[S"] = "@syllable.outer",
          ["[N"] = "@notation.outer",
        },
      },
    },
  })
  
  return true
end

-- Get tree-sitter info for current buffer
function M.get_info()
  if not is_treesitter_available() then
    return { available = false, reason = "Tree-sitter gregorio parser not installed" }
  end
  
  local buf = vim.api.nvim_get_current_buf()
  local has_ts_utils, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
  
  if not has_ts_utils then
    return { available = false, reason = "nvim-treesitter.ts_utils not available" }
  end
  
  local parser = vim.treesitter.get_parser(buf, 'gregorio')
  if not parser then
    return { available = false, reason = "No gregorio parser for current buffer" }
  end
  
  return {
    available = true,
    parser = parser,
    tree = parser:parse()[1],
    root = parser:parse()[1]:root(),
  }
end

-- Initialize tree-sitter integration
function M.init()
  -- Setup parser configuration
  M.setup_parser()
  
  -- Setup highlighting if tree-sitter is available
  vim.defer_fn(function()
    M.setup_highlighting()
  end, 100)
end

return M