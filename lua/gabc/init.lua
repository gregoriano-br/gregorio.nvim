-- Main GABC module
-- Provides unified access to all GABC functionality

local M = {}

-- Import submodules
M.markup = require('gabc.markup')
M.transpose = require('gabc.transpose')
M.utils = require('gabc.utils')
M.nabc = require('gabc.nabc')
M.treesitter = require('gabc.treesitter')
M.lsp = require('gabc.lsp')

-- Setup function for plugin initialization
function M.setup(opts)
  opts = opts or {}
  
  -- Set default options
  local defaults = {
    -- Default keymaps (can be disabled by setting enable_default_keymaps = false)
    enable_default_keymaps = true,
    
    -- Status line integration
    statusline_nabc = true,
    
    -- Auto commands
    auto_format = false,  -- Auto-format on save
    auto_validate = false,  -- Auto-validate on save
    
    -- Tree-sitter integration
    treesitter = {
      enabled = true,
      auto_install = false,
      highlighting = true,
      textobjects = true,
      incremental_selection = true,
    },
    
    -- LSP integration
    lsp = {
      enabled = true,
      auto_attach = true,
      cmd = nil, -- Will use default or user-provided command
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
  }
  
  -- Merge user options with defaults
  for k, v in pairs(defaults) do
    if opts[k] == nil then
      opts[k] = v
    end
  end
  
  -- Store options globally
  vim.g.gabc_options = opts
  
  -- Initialize tree-sitter integration
  if opts.treesitter and opts.treesitter.enabled then
    M.treesitter.init()
  end
  
  -- Initialize LSP integration
  if opts.lsp and opts.lsp.enabled then
    vim.defer_fn(function()
      M.lsp.setup(opts.lsp)
    end, 500) -- Delay to ensure LSP is available
  end
  
  -- Set up autocmds if requested
  if opts.auto_format then
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.gabc',
      callback = function()
        M.utils.clean_format()
      end,
    })
  end
  
  if opts.auto_validate then
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.gabc',
      callback = function()
        M.utils.validate()
      end,
    })
  end
  
  -- Set up user commands
  M.create_commands()
  
  vim.notify('GABC plugin loaded successfully!', vim.log.levels.INFO)
end

-- Create user commands
function M.create_commands()
  -- Markup commands
  vim.api.nvim_create_user_command('GabcAddBold', function(opts)
    M.markup.add('b', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcAddItalic', function(opts)
    M.markup.add('i', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcAddColor', function(opts)
    M.markup.add('c', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcAddSmallCaps', function(opts)
    M.markup.add('sc', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcAddUnderline', function(opts)
    M.markup.add('ul', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcAddTeletype', function(opts)
    M.markup.add('tt', opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcRemoveMarkup', function(opts)
    M.markup.remove(opts.line1, opts.line2)
  end, { range = true })
  
  -- Transpose commands
  vim.api.nvim_create_user_command('GabcTransposeUp', function(opts)
    M.transpose.up(opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcTransposeDown', function(opts)
    M.transpose.down(opts.line1, opts.line2)
  end, { range = true })
  
  -- Utility commands
  vim.api.nvim_create_user_command('GabcFillParens', function(opts)
    M.utils.fill_parens(opts.line1, opts.line2)
  end, { range = true })
  
  vim.api.nvim_create_user_command('GabcConvertLigaturesToTags', function()
    M.utils.convert_ligatures_to_tags()
  end, {})
  
  vim.api.nvim_create_user_command('GabcConvertTagsToLigatures', function()
    M.utils.convert_tags_to_ligatures()
  end, {})
  
  vim.api.nvim_create_user_command('GabcValidate', function()
    M.utils.validate()
  end, {})
  
  vim.api.nvim_create_user_command('GabcCleanFormat', function()
    M.utils.clean_format()
  end, {})
  
  -- NABC commands
  vim.api.nvim_create_user_command('GabcToggleNabc', function()
    M.nabc.toggle_nabc_extension()
  end, {})
  
  vim.api.nvim_create_user_command('GabcAddNabc', function()
    M.nabc.add_nabc_extension()
  end, {})
  
  vim.api.nvim_create_user_command('GabcRemoveNabc', function()
    M.nabc.remove_nabc_extension()
  end, {})
  
  -- Tree-sitter commands
  vim.api.nvim_create_user_command('GabcTreesitterInfo', function()
    local info = M.treesitter.get_info()
    if info.available then
      vim.notify('Tree-sitter gregorio parser is available and working', vim.log.levels.INFO)
    else
      vim.notify('Tree-sitter gregorio parser: ' .. info.reason, vim.log.levels.WARN)
    end
  end, {})
  
  -- LSP commands  
  vim.api.nvim_create_user_command('GabcLspInfo', function()
    local info = M.lsp.get_info()
    if info.available then
      vim.notify('gregorio-lsp is attached and working', vim.log.levels.INFO)
    else
      vim.notify('gregorio-lsp: ' .. info.reason, vim.log.levels.WARN)
    end
  end, {})
  
  vim.api.nvim_create_user_command('GabcLspValidate', function()
    M.lsp.validate_document()
  end, {})
  
  vim.api.nvim_create_user_command('GabcLspValidateNabc', function()
    M.lsp.validate_nabc_alternation()
  end, {})
end

-- Convenience functions for statusline integration
function M.statusline()
  return M.nabc.status()
end

-- Function to get plugin info
function M.info()
  local info = {
    version = '1.0.0',
    author = 'Laércio de Sousa',
    description = 'GABC Gregorian Chant Notation plugin for Neovim',
    integrations = {
      treesitter = M.treesitter.get_info(),
      lsp = M.lsp.get_info(),
    },
  }
  
  if vim.bo.filetype == 'gabc' then
    info.nabc = M.nabc.get_nabc_info()
  end
  
  return info
end

return M