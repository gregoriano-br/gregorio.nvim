-- GABC transpose functions
-- Transposes musical notes up and down in GABC files

local M = {}

-- Note pitch mapping for transposition
local notes = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'p' }
local note_to_index = {}
local index_to_note = {}

-- Initialize note mappings
for i, note in ipairs(notes) do
  note_to_index[note] = i
  index_to_note[i] = note
end

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

-- Function to transpose a single note
local function transpose_note(note, direction)
  local current_index = note_to_index[note]
  if not current_index then
    return note -- Return unchanged if not a valid note
  end
  
  local new_index = current_index + direction
  
  -- Handle wraparound
  if new_index < 1 then
    new_index = #notes
  elseif new_index > #notes then
    new_index = 1
  end
  
  return index_to_note[new_index]
end

-- Function to transpose notes in a text string
local function transpose_text(text, direction)
  -- Simple approach: iterate through each character and transpose notes
  local result = {}
  local i = 1
  
  while i <= #text do
    local char = string.sub(text, i, i)
    
    -- Check if current character is a note
    if string.match(char, '[a-np]') then
      local next_char = string.sub(text, i + 1, i + 1)
      
      -- Handle notes with accidentals or custos
      if next_char == '#' or next_char == 'x' or next_char == 'y' then
        table.insert(result, transpose_note(char, direction) .. next_char)
        i = i + 2
      elseif next_char == '+' then
        table.insert(result, transpose_note(char, direction) .. '+')
        i = i + 2
      else
        -- Regular note
        table.insert(result, transpose_note(char, direction))
        i = i + 1
      end
    else
      -- Not a note, keep as is
      table.insert(result, char)
      i = i + 1
    end
  end
  
  return table.concat(result)
end

-- Function to check if line is part of header (before %%)
local function is_header_line(line_num)
  for i = 1, vim.fn.line('$') do
    local line = vim.fn.getline(i)
    if string.match(line, '^%%+%s*$') then
      return line_num <= i
    end
  end
  return true -- If no %% found, assume we're still in header
end

-- Main transpose function
local function transpose_range(line1, line2, direction)
  if not is_gabc_file() then
    show_error('Please open a GABC file to use this command.')
    return
  end
  
  local lines, start_line, end_line = get_text_range(line1, line2)
  local modified_lines = {}
  local notes_transposed = 0
  
  for i, line in ipairs(lines) do
    local line_num = start_line + i - 1
    
    -- Skip header lines
    if is_header_line(line_num) then
      table.insert(modified_lines, line)
    else
      -- Transpose notes in this line
      local original_line = line
      local transposed_line = transpose_text(line, direction)
      table.insert(modified_lines, transposed_line)
      
      -- Count changes
      if original_line ~= transposed_line then
        notes_transposed = notes_transposed + 1
      end
    end
  end
  
  -- Replace the lines in the buffer
  vim.fn.setline(start_line, modified_lines)
  
  if notes_transposed > 0 then
    local direction_str = direction > 0 and 'up' or 'down'
    show_info('Transposed ' .. notes_transposed .. ' line(s) ' .. direction_str .. '.')
  else
    show_info('No notes found to transpose.')
  end
end

-- Function to transpose up
function M.up(line1, line2)
  transpose_range(line1, line2, 1)
end

-- Function to transpose down
function M.down(line1, line2)
  transpose_range(line1, line2, -1)
end

return M