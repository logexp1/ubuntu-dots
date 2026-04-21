return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
    },
    config = function()
      -- ── Mark system ─────────────────────────────────────────────────────
      local marks = {}
      local ns = vim.api.nvim_create_namespace 'oil_marks'

      local function get_entry_path()
        local oil = require 'oil'
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry or not dir then return nil end
        return dir .. entry.name
      end

      local function refresh_marks(buf)
        local ok, oil = pcall(require, 'oil')
        if not ok then return end
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local dir = oil.get_current_dir(buf)
        if not dir then return end
        for i = 1, vim.api.nvim_buf_line_count(buf) do
          local entry = oil.get_entry_on_line(buf, i)
          if entry and marks[dir .. entry.name] then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
              virt_text = { { '●', 'DiagnosticWarn' } },
              virt_text_pos = 'right_align',
            })
          end
        end
      end

      local function toggle_mark()
        local path = get_entry_path()
        if not path then return end
        if marks[path] then marks[path] = nil else marks[path] = true end
        local buf = vim.api.nvim_get_current_buf()
        refresh_marks(buf)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        if row < vim.api.nvim_buf_line_count(buf) then
          vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
        end
      end

      local function clear_marks()
        marks = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
          end
        end
        vim.notify('Marks cleared')
      end

      local function paste_marks(move)
        local oil = require 'oil'
        local dest = oil.get_current_dir()
        if not dest then
          vim.notify('Not in an oil buffer', vim.log.levels.ERROR)
          return
        end
        local paths = vim.tbl_keys(marks)
        if #paths == 0 then
          vim.notify('No marked files', vim.log.levels.WARN)
          return
        end
        local errors = {}
        for _, src in ipairs(paths) do
          local cmd = move and { 'mv', src, dest } or { 'cp', '-r', src, dest }
          local result = vim.system(cmd):wait()
          if result.code ~= 0 then
            table.insert(errors, result.stderr)
          end
        end
        if #errors > 0 then
          vim.notify('Errors:\n' .. table.concat(errors, '\n'), vim.log.levels.ERROR)
        else
          vim.notify((move and 'Moved' or 'Copied') .. ' ' .. #paths .. ' file(s) to ' .. dest)
          if move then clear_marks() end
        end
        oil.open(dest)
      end

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'oil://*',
        callback = function(ev) refresh_marks(ev.buf) end,
      })

      -- ── Misc actions ────────────────────────────────────────────────────
      local function open_external()
        local oil = require 'oil'
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry or not dir then return end
        local filepath = dir .. entry.name
        local opener = vim.fn.executable 'rifle' == 1 and 'rifle'
          or vim.fn.executable 'xdg-open' == 1 and 'xdg-open'
          or vim.fn.executable 'open' == 1 and 'open'
        if opener then vim.fn.jobstart({ opener, filepath }, { detach = true }) end
      end

      local function extract_archive()
        local oil = require 'oil'
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry then return end
        vim.fn.jobstart({ 'aunpack', entry.name }, {
          cwd = dir,
          on_exit = function(_, code)
            if code == 0 then require('oil').refresh() end
          end,
        })
      end

      -- ── Bookmarks ───────────────────────────────────────────────────────
      local bookmarks = {
        ['/'] = '/',
        b = '/bin/',
        t = '/tmp/',
        s = vim.fn.expand '~/src',
        h = vim.fn.expand '~/',
        d = vim.fn.expand '~/Downloads',
        e = vim.fn.expand '~/.config/nvim/',
        p = vim.fn.expand '~/Pictures/Screenshots/',
      }
      local bookmark_maps = {}
      for key, path in pairs(bookmarks) do
        bookmark_maps["'" .. key] = {
          desc = 'Jump to ' .. path,
          callback = function() require('oil').open(path) end,
        }
      end

      -- ── Setup ────────────────────────────────────────────────────────────
      require('oil').setup {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = false,
        cleanup_delay_ms = 2000,
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, _) return name == '..' end,
        },
        keymaps = vim.tbl_extend('force', {
          ['q'] = 'actions.close',
          ['<CR>'] = { desc = 'Open with system app', callback = open_external },
          ['<S-h>'] = { 'actions.parent', mode = 'n' },
          ['<S-l>'] = 'actions.select',
          ['s'] = { 'actions.change_sort', mode = 'n' },
          ['?'] = { 'actions.show_help', mode = 'n' },
          ['x'] = { desc = 'Extract archive', callback = extract_archive },
          ['cd'] = {
            desc = 'Create directory',
            callback = function()
              local dir = require('oil').get_current_dir()
              if not dir then return end
              vim.ui.input({ prompt = 'New directory: ' }, function(name)
                if not name or name == '' then return end
                vim.system({ 'mkdir', '-p', dir .. name }):wait()
                require('oil').open(dir)
              end)
            end,
          },
          -- Two-pane workflow
          ['m'] = { desc = 'Toggle mark', callback = toggle_mark },
          ['M'] = { desc = 'Clear all marks', callback = clear_marks },
          ['p'] = { desc = 'Paste (copy) marked files here', callback = function() paste_marks(false) end },
          ['P'] = { desc = 'Paste (move) marked files here', callback = function() paste_marks(true) end },
          ['gs'] = {
            desc = 'Open vertical split',
            callback = function()
              local dir = require('oil').get_current_dir()
              vim.cmd 'vsplit'
              require('oil').open(dir)
            end,
          },
        }, bookmark_maps),
        columns = { 'icon', 'permissions', 'size', 'mtime' },
        buf_options = { buflisted = false, bufhidden = 'hide' },
        win_options = {
          wrap = false,
          signcolumn = 'no',
          cursorcolumn = false,
          foldcolumn = '0',
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = 'nvic',
        },
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
