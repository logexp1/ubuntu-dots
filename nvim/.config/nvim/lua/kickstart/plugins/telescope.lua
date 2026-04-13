return {
  {
    'nvim-telescope/telescope.nvim',
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
    },
    config = function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'
      local actions = require 'telescope.actions'

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
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'projects')

      vim.keymap.set('n', '<leader><space>', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>p', builtin.git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>s', builtin.buffers, { desc = 'Switch Buffers' })
      vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = 'Command History' })
      vim.keymap.set('n', '<leader>c', telescope.extensions.projects.projects, { desc = 'Projects' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
