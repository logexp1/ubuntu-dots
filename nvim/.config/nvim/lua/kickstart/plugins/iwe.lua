return {
  {
    'iwe-org/iwe.nvim',
    ft = 'markdown',
    opts = {
      lsp = {
        auto_format_on_save = true,
        enable_inlay_hints = true,
      },
      mappings = {
        enable_markdown_mappings = true,
        enable_picker_keybindings = true,
        enable_lsp_keybindings = true,
        enable_preview_keybindings = false,
      },
      picker = {
        backend = 'snacks',
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
