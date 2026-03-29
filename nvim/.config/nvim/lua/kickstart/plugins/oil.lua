return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
    },
    config = function()
      local function open_external()
        local oil = require 'oil'
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry or not dir then
          return
        end

        local filepath = dir .. entry.name
        local opener = vim.fn.executable 'rifle' == 1 and 'rifle'
          or vim.fn.executable 'xdg-open' == 1 and 'xdg-open'
          or vim.fn.executable 'open' == 1 and 'open'

        if opener then
          vim.fn.jobstart({ opener, filepath }, { detach = true })
        end
      end

      local function extract_archive()
        local oil = require 'oil'
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry then
          return
        end

        vim.fn.jobstart({ 'aunpack', entry.name }, {
          cwd = dir,
          on_exit = function(_, code)
            if code == 0 then
              require('oil').refresh()
            end
          end,
        })
      end

      local bookmarks = {
        ['/'] = '/',
        b = '/bin/',
        t = '/tmp/',
        s = vim.fn.expand '~/src',
        h = vim.fn.expand '~/',
        d = vim.fn.expand '~/Downloads',
        e = vim.fn.expand '~/.config/nvim/',
      }

      local bookmark_maps = {}
      for key, path in pairs(bookmarks) do
        bookmark_maps["'" .. key] = {
          desc = 'Jump to ' .. path,
          callback = function()
            require('oil').open(path)
          end,
        }
      end

      require('oil').setup {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = false,
        cleanup_delay_ms = 2000,
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, _)
            return name == '..'
          end,
        },
        keymaps = vim.tbl_extend('force', {
          ['q'] = 'actions.close',
          ['<CR>'] = { desc = 'Open external', callback = open_external },
          ['<S-h>'] = { 'actions.parent', mode = 'n' },
          ['<S-l>'] = 'actions.select',
          ['s'] = { 'actions.change_sort', mode = 'n' },
          ['?'] = { 'actions.show_help', mode = 'n' },
          ['x'] = { desc = 'Extract archive', callback = extract_archive },
        }, bookmark_maps),
        columns = {
          'icon',
          'permissions',
          'size',
          'mtime',
        },
        buf_options = {
          buflisted = false,
          bufhidden = 'hide',
        },
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
