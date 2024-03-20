return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "mvllow/modes.nvim" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "codeium" } }, 1, 1))
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    keys = {
      { "<Leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    config = true,
  },
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        on_highlights = function(hl)
          hl.WinSeparator = { fg = "orange" }
          hl.Cursor = { bg = "orange" }
          hl.CursorLine = { bg = "#444444" }
        end,
      })
    end,
  },
}
