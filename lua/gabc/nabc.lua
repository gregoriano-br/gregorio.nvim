-- GABC NABC extension detection and status
-- Detects when a GABC file uses NABC extended notation

local M = {}

-- Cache for NABC status to avoid repeated parsing
local nabc_status_cache = {}
local last_changedtick = -1

-- Helper function to check if we're in a GABC file
local function is_gabc_file()
  return vim.bo.filetype == 'gabc'
end

-- Function to check for NABC extension in header
local function check_for_nabc_extension()
  if not is_gabc_file() then
    return false
  end
  
  local current_changedtick = vim.b.changedtick or 0
  local buffer = vim.api.nvim_get_current_buf()
  
  -- Use cache if buffer hasn't changed
  if nabc_status_cache[buffer] and last_changedtick == current_changedtick then
    return nabc_status_cache[buffer]
  end
  
  -- Find header section (ends at line containing only %%)
  local header_lines = {}
  for line_num = 1, vim.fn.line('$') do
    local line = vim.fn.getline(line_num)
    if string.match(line, '^%%+%s*$') then
      break
    end
    table.insert(header_lines, line)
  end
  
  -- Check if header contains "nabc-lines:" field
  local has_nabc = false
  for _, line in ipairs(header_lines) do
    if string.match(line, '^nabc%-lines%s*:') then
      has_nabc = true
      break
    end
  end
  
  -- Update cache
  nabc_status_cache[buffer] = has_nabc
  last_changedtick = current_changedtick
  
  return has_nabc
end

-- Function to get NABC status for statusline
function M.status()
  if not is_gabc_file() then
    return ''
  end
  
  if check_for_nabc_extension() then
    return 'GABC (NABC)'
  else
    return ''
  end
end

-- Function to update NABC status (called on buffer changes)
function M.update_status()
  if not is_gabc_file() then
    return
  end
  
  -- Clear cache to force re-check
  local buffer = vim.api.nvim_get_current_buf()
  nabc_status_cache[buffer] = nil
  
  -- Update statusline if it contains our function
  vim.cmd('redrawstatus')
end

-- Function to add NABC extension to current file
function M.add_nabc_extension()
  if not is_gabc_file() then
    vim.notify('GABC: Please open a GABC file to use this command.', vim.log.levels.ERROR)
    return
  end
  
  if check_for_nabc_extension() then
    vim.notify('GABC: File already has NABC extension enabled.', vim.log.levels.INFO)
    return
  end
  
  -- Find the header section
  local header_end_line = 1
  for line_num = 1, vim.fn.line('$') do
    local line = vim.fn.getline(line_num)
    if string.match(line, '^%%+%s*$') then
      header_end_line = line_num
      break
    end
  end
  
  -- Insert nabc-lines field before the %% separator
  local nabc_line = 'nabc-lines: 1;'
  vim.fn.append(header_end_line - 1, nabc_line)
  
  -- Clear cache and update status
  M.update_status()
  
  vim.notify('GABC: Added NABC extension to file.', vim.log.levels.INFO)
end

-- Function to remove NABC extension from current file
function M.remove_nabc_extension()
  if not is_gabc_file() then
    vim.notify('GABC: Please open a GABC file to use this command.', vim.log.levels.ERROR)
    return
  end
  
  if not check_for_nabc_extension() then
    vim.notify('GABC: File does not have NABC extension enabled.', vim.log.levels.INFO)
    return
  end
  
  -- Find and remove nabc-lines field
  local removed = false
  for line_num = 1, vim.fn.line('$') do
    local line = vim.fn.getline(line_num)
    if string.match(line, '^nabc%-lines%s*:') then
      vim.cmd(line_num .. 'delete')
      removed = true
      break
    end
    -- Stop at header end
    if string.match(line, '^%%+%s*$') then
      break
    end
  end
  
  if removed then
    -- Clear cache and update status
    M.update_status()
    vim.notify('GABC: Removed NABC extension from file.', vim.log.levels.INFO)
  else
    vim.notify('GABC: Could not find NABC extension to remove.', vim.log.levels.WARN)
  end
end

-- Function to toggle NABC extension
function M.toggle_nabc_extension()
  if check_for_nabc_extension() then
    M.remove_nabc_extension()
  else
    M.add_nabc_extension()
  end
end

-- Function to get NABC information
function M.get_nabc_info()
  if not is_gabc_file() then
    return nil
  end
  
  local has_nabc = check_for_nabc_extension()
  if not has_nabc then
    return { enabled = false }
  end
  
  -- Find nabc-lines value
  local nabc_lines = 1 -- default
  for line_num = 1, vim.fn.line('$') do
    local line = vim.fn.getline(line_num)
    local lines_value = string.match(line, '^nabc%-lines%s*:%s*(%d+)')
    if lines_value then
      nabc_lines = tonumber(lines_value)
      break
    end
    -- Stop at header end
    if string.match(line, '^%%+%s*$') then
      break
    end
  end
  
  return {
    enabled = true,
    lines = nabc_lines
  }
end

-- Clear cache when buffer is deleted
vim.api.nvim_create_autocmd('BufDelete', {
  pattern = '*.gabc',
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()
    nabc_status_cache[buffer] = nil
  end,
})

return M