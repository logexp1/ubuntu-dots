local M = {}

local function open_file(path)
  vim.cmd('edit ' .. vim.fn.fnameescape(vim.fn.fnamemodify(path, ':p')))
end

local function resolve(fname, dir)
  local same = dir .. '/' .. fname
  if vim.fn.filereadable(same) == 1 then return same end
  local down = vim.fn.findfile(fname, dir .. '/**')
  if down ~= '' then return down end
  local up = vim.fn.findfile(fname, dir .. ';')
  if up ~= '' then return up end
end

-- Follow the Markdown link under the cursor.
-- Returns true if a link was found and acted on, false otherwise.
function M.follow()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local dir = vim.fn.expand '%:p:h'

  -- [[wiki-link]] or [[wiki-link|display]]
  local pos = 1
  while true do
    local ls, le = line:find('%[%[.-%]%]', pos)
    if not ls then break end
    if col >= ls and col <= le then
      local target = line:match('%[%[(.-)%]%]', ls):gsub('|.*$', '')
      local path = resolve(target .. '.md', dir)
      if path then open_file(path) end
      return true
    end
    pos = le + 1
  end

  -- [text](url) standard links
  pos = 1
  while true do
    local ls, le = line:find('%[.-%]%(.-%)', pos)
    if not ls then break end
    if col >= ls and col <= le then
      local target = line:match('%[.-%]%((.-)%)', ls):gsub('#.*$', '')
      if target:match('^https?://') then
        vim.ui.open(target)
      elseif target ~= '' then
        local path = resolve(target, dir)
        if path then open_file(path) else open_file(dir .. '/' .. target) end
      end
      return true
    end
    pos = le + 1
  end

  return false
end

return M
