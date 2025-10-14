-- GABC markup functions
-- Adds and removes markup tags around syllables in GABC files

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

-- Helper function to get selected text or current line
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

-- Helper function to split text into syllables while preserving structure
local function get_syllables(text)
  -- Split GABC text into components: syllable text + musical notation
  local syllables = {}
  local current_pos = 1
  
  while current_pos <= #text do
    -- Skip whitespace
    local ws_start, ws_end = string.find(text, '^%s+', current_pos)
    if ws_start then
      table.insert(syllables, { type = 'whitespace', content = string.sub(text, ws_start, ws_end) })
      current_pos = ws_end + 1
    else
      -- Look for syllable text followed by optional musical notation
      -- Pattern: text_part(musical_notation)text_part(musical_notation)...
      local segment_start = current_pos
      local segment_end = current_pos
      
      -- Find the end of current non-whitespace segment
      while segment_end <= #text and not string.match(string.sub(text, segment_end, segment_end), '%s') do
        segment_end = segment_end + 1
      end
      segment_end = segment_end - 1
      
      if segment_end >= segment_start then
        local segment = string.sub(text, segment_start, segment_end)
        
        -- Check if it's pure punctuation or musical notation without text
        if string.match(segment, '^[%(%),%.:%|;%-*]*$') then
          table.insert(syllables, { type = 'punctuation', content = segment })
        else
          -- Parse syllable with embedded musical notation
          local parsed_syllable = parse_syllable_with_notation(segment)
          for _, part in ipairs(parsed_syllable) do
            table.insert(syllables, part)
          end
        end
        current_pos = segment_end + 1
      else
        break
      end
    end
  end
  
  return syllables
end

-- Helper function to parse a syllable with embedded musical notation
local function parse_syllable_with_notation(syllable)
  local parts = {}
  local current_pos = 1
  
  while current_pos <= #syllable do
    -- Look for text before parentheses
    local text_start = current_pos
    local paren_start = string.find(syllable, '%(', current_pos)
    
    if paren_start then
      -- Extract text part before parentheses
      if paren_start > current_pos then
        local text_part = string.sub(syllable, current_pos, paren_start - 1)
        if text_part ~= '' then
          table.insert(parts, { type = 'syllable', content = text_part })
        end
      end
      
      -- Find matching closing parenthesis
      local paren_end = string.find(syllable, '%)', paren_start)
      if paren_end then
        -- Extract musical notation (including parentheses)
        local notation = string.sub(syllable, paren_start, paren_end)
        table.insert(parts, { type = 'notation', content = notation })
        current_pos = paren_end + 1
      else
        -- No closing parenthesis found, treat rest as text
        local remaining = string.sub(syllable, current_pos)
        if remaining ~= '' then
          table.insert(parts, { type = 'syllable', content = remaining })
        end
        break
      end
    else
      -- No more parentheses, rest is text
      local remaining = string.sub(syllable, current_pos)
      if remaining ~= '' then
        table.insert(parts, { type = 'syllable', content = remaining })
      end
      break
    end
  end
  
  return parts
end

-- Helper function to check if syllable already has markup
local function has_markup(syllable, tag)
  local pattern = '^<' .. tag .. '>.*</' .. tag .. '>$'
  return string.match(syllable, pattern) ~= nil
end

-- Helper function to add markup to a single syllable
local function add_markup_to_syllable(syllable, open_tag, close_tag)
  -- Don't add markup to syllables that already have it
  local tag = string.match(open_tag, '<(%w+)>')
  if tag and has_markup(syllable, tag) then
    return syllable
  end
  
  -- Don't add markup to pure punctuation or musical notation
  if string.match(syllable, '^[%(%),%.:%|;%-%%s]+$') then
    return syllable
  end
  
  return open_tag .. syllable .. close_tag
end

-- Helper function to remove all markup from text
local function remove_all_markup_from_text(text)
  -- Remove common GABC markup tags
  local patterns = { 'b', 'i', 'c', 'sc', 'ul', 'tt', 'v', 'r', 'alt' }
  local result = text
  
  for _, tag in ipairs(patterns) do
    result = string.gsub(result, '<' .. tag .. '>', '')
    result = string.gsub(result, '</' .. tag .. '>', '')
  end
  
  return result
end

-- Main function to add markup to syllables
function M.add(tag, line1, line2)
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local lines, start_line, end_line = get_text_range(line1, line2)
  local open_tag = '<' .. tag .. '>'
  local close_tag = '</' .. tag .. '>'
  local modified_lines = {}
  
  for _, line in ipairs(lines) do
    local syllables = get_syllables(line)
    local result_parts = {}
    
    for _, syll in ipairs(syllables) do
      if syll.type == 'syllable' then
        table.insert(result_parts, add_markup_to_syllable(syll.content, open_tag, close_tag))
      else
        -- For whitespace, punctuation, and notation, keep as-is
        table.insert(result_parts, syll.content)
      end
    end
    
    table.insert(modified_lines, table.concat(result_parts))
  end
  
  -- Replace the lines in the buffer
  vim.fn.setline(start_line, modified_lines)
  
  show_info('Added ' .. tag .. ' markup to syllables.')
end

-- Function to remove all markup from syllables
function M.remove(line1, line2)
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local lines, start_line, end_line = get_text_range(line1, line2)
  local modified_lines = {}
  
  for _, line in ipairs(lines) do
    table.insert(modified_lines, remove_all_markup_from_text(line))
  end
  
  -- Replace the lines in the buffer
  vim.fn.setline(start_line, modified_lines)
  
  show_info('Removed markup from syllables.')
end

return M