return {
  {
    'nvim-telescope/telescope.nvim',
    enabled = false,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      {
        'ahmedkhalf/project.nvim',
        main = 'project_nvim',
        opts = {
          detection_methods = { 'pattern' },
          patterns = { '.git', 'pyproject.toml', 'setup.py', 'Cargo.toml', 'package.json' },
        },
      },
      { 'nvim-telescope/telescope-frecency.nvim', version = '*' },
    },
    config = function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'
      local actions = require 'telescope.actions'

      -- Create a new file from the current prompt text
      local function create_file(prompt_bufnr)
        local state = require 'telescope.actions.state'
        local prompt = state.get_current_picker(prompt_bufnr):_get_prompt()
        actions.close(prompt_bufnr)
        if prompt == '' then
          return
        end
        local dir = vim.fn.fnamemodify(prompt, ':h')
        if dir ~= '.' then
          vim.fn.mkdir(dir, 'p')
        end
        vim.cmd('edit ' .. vim.fn.fnameescape(prompt))
      end

      telescope.setup {
        defaults = {
          preview = {
            treesitter = false,
          },
          mappings = {
            i = {
              ['<Esc>'] = actions.close,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
            n = {
              ['<Esc>'] = actions.close,
              ['q'] = actions.close,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
          },
        },
        extensions = {
          frecency = {
            db_safe_mode = false,
            default_workspace = 'CWD',
            path_display = { 'filename_first' },
            show_unindexed = true,
          },
        },
        pickers = {
          find_files = {
            mappings = {
              i = { ['<C-e>'] = create_file },
              n = { ['<C-e>'] = create_file },
            },
          },
        },
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'projects')
      pcall(telescope.load_extension, 'frecency')

      vim.keymap.set('n', '<leader><space>', builtin.keymaps, { desc = 'Keymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fn', function()
        vim.ui.input({ prompt = 'Open/create file: ', default = vim.fn.getcwd() .. '/', completion = 'file' }, function(path)
          if not path or path == '' then
            return
          end
          local abs = vim.fn.fnamemodify(path, ':p')
          local dir = vim.fn.fnamemodify(abs, ':h')
          vim.fn.mkdir(dir, 'p')
          vim.cmd('edit ' .. vim.fn.fnameescape(abs))
        end)
      end, { desc = 'New/open file by path' })
      vim.keymap.set('n', '<leader>p', builtin.git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>fr', telescope.extensions.frecency.frecency, { desc = 'Recent Files (frecency)' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>s', builtin.buffers, { desc = 'Switch Buffers' })
      vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = 'Command History' })
      vim.keymap.set('n', '<leader>c', telescope.extensions.projects.projects, { desc = 'Projects' })
      vim.keymap.set('n', '<leader>h', builtin.help_tags, { desc = 'Help' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
