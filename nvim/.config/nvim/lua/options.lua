-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Use spaces instead of tabs
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 1000

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
-- vim.o.confirm = true

-- Enable visual line wrapping (like Emacs visual-line-mode)
vim.o.wrap = true
vim.o.linebreak = true
vim.o.showbreak = '↪ '

-- Disable swap files (like Emacs behavior)
vim.o.swapfile = false -- No swap files
vim.o.backup = false -- No backup files
vim.o.writebackup = false -- No backup before overwriting file

-- Fine-tune wrapped line display
vim.opt.breakindentopt = 'shift:2,min:40,sbr'

-- Equalize splits when terminal is resized (e.g. toggling fullscreen in Hyprland)
vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    vim.cmd 'wincmd ='
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto change directory to current buffer's directory
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    -- Skip for oil buffers
    if vim.bo.filetype == 'oil' then
      return
    end

    -- Check if the buffer has a valid file path
    local filepath = vim.fn.expand '%:p:h'
    if filepath ~= '' and vim.fn.isdirectory(filepath) == 1 then
      vim.cmd('lcd ' .. filepath)
    end
  end,
})

-- Open all folds by default
vim.o.foldlevelstart = 99

-- Markdown: header-based folding + Tab to toggle
function _G.markdown_foldexpr()
  local line = vim.fn.getline(vim.v.lnum)
  local level = line:match '^(#+)%s'
  if level then return '>' .. #level end
  return '='
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(ev)
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.markdown_foldexpr()'
    vim.schedule(function()
      vim.keymap.set('n', '-', function() require('oil').open() end, { buffer = ev.buf, desc = 'Open parent directory' })
    end)
    vim.keymap.set('n', '<Tab>', function()
      if vim.api.nvim_get_current_line():match '^#' then
        pcall(vim.cmd, 'normal! za')
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
      end
    end, { buffer = ev.buf, desc = 'Toggle fold on header' })
  end,
})

-- vim: ts=2 sts=2 sw=2 et
