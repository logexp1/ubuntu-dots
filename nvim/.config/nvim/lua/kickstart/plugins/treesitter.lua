return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
    opts = {
      -- Neovim 0.10+ bundles: bash, c, lua, markdown, markdown_inline,
      -- python, query, vim, vimdoc — do NOT list those here or nvim-treesitter
      -- will install an older parser that conflicts with the bundled queries.
      ensure_installed = {
        'diff',
        'html',
        'luadoc',
        'regex',
        'toml',
        'yaml',
      },
      -- Neovim 0.10+ bundles its own parsers; auto_install would overwrite
      -- them with older nvim-treesitter versions and break bundled queries.
      auto_install = false,
      highlight = {
        enable = true,
        -- Neovim 0.10+ auto-enables treesitter for these with its own
        -- matching parser+queries. nvim-treesitter's queries for these
        -- languages conflict with the bundled parser, so skip them here.
        disable = { 'python', 'bash', 'c', 'lua', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      },
      -- Disabled: nvim-treesitter indent is incompatible with Neovim 0.12
      indent = { enable = false },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
