return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { example = 'doom' },
      picker = {
        enabled = true,
        layout = {
          preset = 'ivy',
        },
        matcher = {
          frecency = true,
        },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            },
          },
        },
      },
      scroll = {
        -- conflicts with stay-centered.nvim
        enabled = true,
      },
    },
    keys = {
      {
        '<leader><space>',
        function()
          Snacks.picker.smart()
        end,
        desc = 'Smart Find Files',
      },
      {
        '<leader>s',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'switch to buffers',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.git_grep()
        end,
        desc = 'grep in git preojects',
      },
      {
        '<leader>:',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'Command history',
      },
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = 'Find Files from home directory',
      },
      {
        '<leader>p',
        function()
          Snacks.picker.git_files()
        end,
        desc = 'find files (in projects)',
      },
      {
        '<leader>fb',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>fr',
        function()
          Snacks.picker.recent()
        end,
        desc = 'Recent Files',
      },
      {
        '<leader>c',
        function()
          Snacks.picker.projects()
        end,
        desc = 'change project',
      },
      {
        '<leader>:',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'Command History',
      },
    },
  },
}
