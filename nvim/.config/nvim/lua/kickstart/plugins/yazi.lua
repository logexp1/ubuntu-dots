return {
  {
    'mikavilpas/yazi.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
    },
    init = function()
      -- Prevent netrw from loading so yazi handles directory opening
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      { '<leader>-', '<cmd>Yazi cwd<cr>', desc = 'Open yazi in cwd' },
      { '<C-Up>', '<cmd>Yazi toggle<cr>', desc = 'Resume last yazi session' },
    },
    opts = {
      open_for_directories = true,
      clipboard_register = '+',
      yazi_floating_window_border = 'rounded',
      integrations = {
        grep_in_directory = 'snacks.picker',
        grep_in_selected_files = 'snacks.picker',
      },
    },
  },
}
