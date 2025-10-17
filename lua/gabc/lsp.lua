-- LSP integration for GABC
-- Integrates with gregorio-lsp for semantic analysis and enhanced editing

local M = {}

-- Configuration for gregorio-lsp
local default_config = {
  cmd = { 'node', 'path/to/gregorio-lsp/dist/server.js', '--stdio' },
  filetypes = { 'gabc' },
  root_dir = nil, -- Will be set by nvim-lspconfig
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
  capabilities = nil, -- Will be set during setup
  on_attach = nil, -- User-provided function
}

-- Check if LSP is available
local function is_lsp_available()
  local has_lsp, _ = pcall(require, 'lspconfig')
  return has_lsp
end

-- Check if gregorio-lsp server is available
local function is_gregorio_lsp_available(cmd)
  if not cmd or #cmd == 0 then
    return false
  end
  
  -- Try to run the command to check if it's available
  local handle = io.popen(table.concat(cmd, ' ') .. ' --help 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()
    return result and #result > 0
  end
  
  return false
end

-- Setup LSP client
function M.setup(user_config)
  if not is_lsp_available() then
    vim.notify('nvim-lspconfig not found. Install it for LSP support.', vim.log.levels.WARN)
    return false
  end
  
  local lspconfig = require('lspconfig')
  local util = require('lspconfig.util')
  
  -- Merge user config with defaults
  local config = vim.tbl_deep_extend('force', default_config, user_config or {})
  
  -- Set capabilities if available
  local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if has_cmp then
    config.capabilities = cmp_nvim_lsp.default_capabilities()
  end
  
  -- Set root directory function
  config.root_dir = util.find_git_ancestor or util.path.dirname
  
  -- Check if gregorio-lsp is available
  if not is_gregorio_lsp_available(config.cmd) then
    vim.notify('gregorio-lsp server not found. Please ensure it is installed and accessible.', vim.log.levels.WARN)
    vim.notify('Command tried: ' .. table.concat(config.cmd, ' '), vim.log.levels.DEBUG)
    return false
  end
  
  -- Enhanced on_attach function
  local function enhanced_on_attach(client, bufnr)
    -- Call user's on_attach if provided
    if config.on_attach then
      config.on_attach(client, bufnr)
    end
    
    -- Set buffer-local keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    
    -- GABC-specific keymaps
    vim.keymap.set('n', '<leader>gv', function()
      vim.lsp.buf.execute_command({
        command = 'gregorio.validate',
        arguments = { vim.uri_from_bufnr(bufnr) }
      })
    end, opts)
    
    vim.keymap.set('n', '<leader>gn', function()
      vim.lsp.buf.execute_command({
        command = 'gregorio.validateNabcAlternation',
        arguments = { vim.uri_from_bufnr(bufnr) }
      })
    end, opts)
    
    -- Enable auto-formatting on save if requested
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('GregorioLspFormat', { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
    
    vim.notify('gregorio-lsp attached successfully!', vim.log.levels.INFO)
  end
  
  config.on_attach = enhanced_on_attach
  
  -- Create the LSP configuration
  local configs = require('lspconfig.configs')
  if not configs.gregorio_lsp then
    configs.gregorio_lsp = {
      default_config = config,
    }
  end
  
  -- Setup the LSP
  lspconfig.gregorio_lsp.setup(config)
  
  vim.notify('gregorio-lsp configured successfully!', vim.log.levels.INFO)
  return true
end

-- Get LSP client info
function M.get_client()
  local clients = vim.lsp.get_active_clients({ name = 'gregorio_lsp' })
  return #clients > 0 and clients[1] or nil
end

-- Check if LSP is attached to current buffer
function M.is_attached()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  
  for _, client in ipairs(clients) do
    if client.name == 'gregorio_lsp' then
      return true
    end
  end
  
  return false
end

-- Manual validation commands
function M.validate_document()
  local client = M.get_client()
  if not client then
    vim.notify('gregorio-lsp not attached', vim.log.levels.WARN)
    return
  end
  
  local buf = vim.api.nvim_get_current_buf()
  client.request('workspace/executeCommand', {
    command = 'gregorio.validate',
    arguments = { vim.uri_from_bufnr(buf) }
  })
end

function M.validate_nabc_alternation()
  local client = M.get_client()
  if not client then
    vim.notify('gregorio-lsp not attached', vim.log.levels.WARN)
    return
  end
  
  local buf = vim.api.nvim_get_current_buf()
  client.request('workspace/executeCommand', {
    command = 'gregorio.validateNabcAlternation',
    arguments = { vim.uri_from_bufnr(buf) }
  })
end

-- Get LSP information
function M.get_info()
  local client = M.get_client()
  if not client then
    return { available = false, reason = "gregorio-lsp not attached" }
  end
  
  return {
    available = true,
    client = client,
    server_capabilities = client.server_capabilities,
    attached_buffers = vim.lsp.get_buffers_by_client_id(client.id),
  }
end

return M