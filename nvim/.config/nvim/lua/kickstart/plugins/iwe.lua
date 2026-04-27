return {
  {
    'iwe-org/iwe.nvim',
    ft = 'markdown',
    config = function()
      require('iwe').setup {
        lsp = {
          cmd = { 'iwes' },
          filetypes = { 'markdown' },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern '.iwe'(fname) or require('lspconfig.util').find_git_ancestor(fname) or vim.loop.os_homedir()
          end,
          capabilities = require('blink.cmp').get_lsp_capabilities(),
          settings = {
            iwe = {
              debug = vim.env.IWE_DEBUG == 'true',
              trace = 'off',
            },
          },
          handlers = {
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
              border = 'rounded',
            }),
          },
        },
        keybindings = {
          enable = false,
        },
        telescope = {
          enable = true,
          extensions = {
            iwe = {
              search = {
                prompt_title = 'IWE Search',
                results_title = 'Documents',
              },
              backlinks = {
                prompt_title = 'Backlinks',
                results_title = 'References',
              },
            },
          },
        },
        preview = {
          output_dir = '~/tmp/preview',
          temp_dir = '/tmp',
          auto_open = false,
        },
        health = {
          check_iwes_binary = true,
          check_iwe_config = true,
        },
      }

      local map = vim.keymap.set
      map('n', '<leader>ia', '<cmd>lua vim.lsp.buf.code_action()<cr>', { desc = 'IWE Code Actions' })
      map('n', '<leader>ig', '<cmd>lua vim.lsp.buf.definition()<cr>', { desc = 'IWE Go to Definition' })
      map('n', '<leader>ir', '<cmd>lua vim.lsp.buf.references()<cr>', { desc = 'IWE Find References' })
      map('n', '<leader>is', '<cmd>Telescope iwe search<cr>', { desc = 'IWE Search' })
      map('n', '<leader>ib', '<cmd>Telescope iwe backlinks<cr>', { desc = 'IWE Backlinks' })
      map('n', '<leader>if', '<cmd>lua vim.lsp.buf.format()<cr>', { desc = 'IWE Format' })
      map('n', '<leader>in', '<cmd>lua vim.lsp.buf.rename()<cr>', { desc = 'IWE Rename' })

      -- Plugin loaded after FileType fired — start LSP for current buffer if markdown
      if vim.bo.filetype == 'markdown' then
        require('iwe.lsp').start()
      end

      require('which-key').add {
        { '<leader>i', group = 'IWE' },
        { '<leader>ia', desc = 'Code Actions' },
        { '<leader>ig', desc = 'Go to Definition' },
        { '<leader>ir', desc = 'Find References' },
        { '<leader>is', desc = 'Search' },
        { '<leader>ib', desc = 'Backlinks' },
        { '<leader>if', desc = 'Format Document' },
        { '<leader>in', desc = 'Rename' },
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
