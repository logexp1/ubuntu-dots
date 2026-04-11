return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline",  -- classic bottom bar instead of floating popup
      },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
      },
    },
    keys = {
      { '<leader>m', '<cmd>Noice<cr>', desc = 'Messages history' },
    },
  },
}
