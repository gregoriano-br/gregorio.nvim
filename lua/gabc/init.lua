-- Main GABC module
-- Provides unified access to all GABC functionality

local M = {}

-- Import submodules
M.markup = require('gabc.markup')
M.transpose = require('gabc.transpose')
M.utils = require('gabc.utils')
M.nabc = require('gabc.nabc')

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
  }
  
  -- Merge user options with defaults
  for k, v in pairs(defaults) do
    if opts[k] == nil then
      opts[k] = v
    end
  end
  
  -- Store options globally
  vim.g.gabc_options = opts
  
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
  }
  
  if vim.bo.filetype == 'gabc' then
    info.nabc = M.nabc.get_nabc_info()
  end
  
  return info
end

return M