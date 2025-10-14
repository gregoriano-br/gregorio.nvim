-- GABC utility functions
-- Handles ligature conversion, parentheses filling, and other utilities

local M = {}

-- Helper function to check if we're in a GABC file
local function is_gabc_file()
  return vim.bo.filetype == 'gabc'
end

-- Helper function to show error message
local function show_error(msg)
  vim.notify('GABC: ' .. msg, vim.log.levels.ERROR)
end

-- Helper function to show info message
local function show_info(msg)
  vim.notify('GABC: ' .. msg, vim.log.levels.INFO)
end

-- Helper function to find header end (line containing only %%)
local function find_header_end()
  for i = 1, vim.fn.line('$') do
    local line = vim.fn.getline(i)
    if string.match(line, '^%%+%s*$') then
      return i
    end
  end
  return 1 -- If no %% found, assume line 1 is end of header
end

-- Helper function to get text range or current line
local function get_text_range(line1, line2)
  local lines
  if line1 == line2 and vim.fn.mode() ~= 'v' and vim.fn.mode() ~= 'V' then
    -- No selection, use current line
    lines = { vim.fn.getline(line1) }
  else
    -- Use selection or range
    lines = vim.fn.getline(line1, line2)
  end
  return lines, line1, line2
end

-- Convert ligatures to <sp> tags
function M.convert_ligatures_to_tags()
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local header_end = find_header_end()
  local total_lines = vim.fn.line('$')
  local conversions = 0
  
  -- Process only lines after header
  for line_num = header_end + 1, total_lines do
    local line = vim.fn.getline(line_num)
    local original_line = line
    
    -- Replace ligatures with <sp> tags
    line = string.gsub(line, 'æ', '<sp>ae</sp>')
    line = string.gsub(line, 'ǽ', '<sp>\'ae</sp>')  -- æ with acute accent
    line = string.gsub(line, 'œ', '<sp>oe</sp>')
    
    if line ~= original_line then
      vim.fn.setline(line_num, line)
      conversions = conversions + 1
    end
  end
  
  if conversions > 0 then
    show_info('Converted ligatures to <sp> tags in ' .. conversions .. ' line(s).')
  else
    show_info('No ligatures found to convert.')
  end
end

-- Convert <sp> tags to ligatures
function M.convert_tags_to_ligatures()
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local header_end = find_header_end()
  local total_lines = vim.fn.line('$')
  local conversions = 0
  
  -- Process only lines after header
  for line_num = header_end + 1, total_lines do
    local line = vim.fn.getline(line_num)
    local original_line = line
    
    -- Replace <sp> tags with ligatures
    line = string.gsub(line, '<sp>ae</sp>', 'æ')
    line = string.gsub(line, '<sp>\'ae</sp>', 'ǽ')  -- æ with acute accent
    line = string.gsub(line, '<sp>oe</sp>', 'œ')
    
    if line ~= original_line then
      vim.fn.setline(line_num, line)
      conversions = conversions + 1
    end
  end
  
  if conversions > 0 then
    show_info('Converted <sp> tags to ligatures in ' .. conversions .. ' line(s).')
  else
    show_info('No <sp> tags found to convert.')
  end
end

-- Fill empty parentheses with placeholder notes
function M.fill_parens(line1, line2)
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local lines, start_line, end_line = get_text_range(line1, line2)
  local modified_lines = {}
  local filled_count = 0
  
  for _, line in ipairs(lines) do
    local original_line = line
    
    -- Pattern to match empty parentheses: ()
    -- Replace with (f) as a default note
    local new_line = string.gsub(line, '%(%s*%)', '(f)')
    
    -- Count how many were filled
    local _, count = string.gsub(original_line, '%(%s*%)', '')
    filled_count = filled_count + count
    
    table.insert(modified_lines, new_line)
  end
  
  -- Replace the lines in the buffer
  vim.fn.setline(start_line, modified_lines)
  
  if filled_count > 0 then
    show_info('Filled ' .. filled_count .. ' empty parentheses with default note (f).')
  else
    show_info('No empty parentheses found to fill.')
  end
end

-- Function to validate GABC syntax (basic validation)
function M.validate()
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local errors = {}
  local header_end = find_header_end()
  
  -- Check for common issues
  for line_num = 1, vim.fn.line('$') do
    local line = vim.fn.getline(line_num)
    
    if line_num <= header_end then
      -- Header validation
      if not string.match(line, '^%s*$') and 
         not string.match(line, '^%%') and 
         not string.match(line, '^%w+:') then
        table.insert(errors, 'Line ' .. line_num .. ': Invalid header format')
      end
    else
      -- Body validation
      -- Check for unmatched parentheses
      local open_count = 0
      local close_count = 0
      for char in line:gmatch('.') do
        if char == '(' then
          open_count = open_count + 1
        elseif char == ')' then
          close_count = close_count + 1
        end
      end
      
      if open_count ~= close_count then
        table.insert(errors, 'Line ' .. line_num .. ': Unmatched parentheses')
      end
      
      -- Check for unmatched markup tags
      for tag in line:gmatch('<(%w+)>') do
        local close_pattern = '</' .. tag .. '>'
        if not string.find(line, close_pattern, 1, true) then
          table.insert(errors, 'Line ' .. line_num .. ': Unclosed <' .. tag .. '> tag')
        end
      end
    end
  end
  
  if #errors > 0 then
    show_error('Validation found ' .. #errors .. ' error(s):')
    for _, error in ipairs(errors) do
      print('  ' .. error)
    end
  else
    show_info('GABC file validation passed!')
  end
end

-- Function to clean up common formatting issues
function M.clean_format()
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local header_end = find_header_end()
  local total_lines = vim.fn.line('$')
  local changes = 0
  
  -- Process only lines after header
  for line_num = header_end + 1, total_lines do
    local line = vim.fn.getline(line_num)
    local original_line = line
    
    -- Remove extra spaces inside parentheses
    line = string.gsub(line, '%(%s+', '(')
    line = string.gsub(line, '%s+%)', ')')
    
    -- Normalize spaces around markup tags
    line = string.gsub(line, '%s+<', '<')
    line = string.gsub(line, '>%s+', '>')
    
    -- Remove trailing whitespace
    line = string.gsub(line, '%s+$', '')
    
    if line ~= original_line then
      vim.fn.setline(line_num, line)
      changes = changes + 1
    end
  end
  
  if changes > 0 then
    show_info('Cleaned formatting in ' .. changes .. ' line(s).')
  else
    show_info('No formatting issues found.')
  end
end

return M