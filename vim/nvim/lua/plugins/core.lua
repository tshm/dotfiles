return {
  {
    "jcdickinson/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },
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
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gf", "<cmd>G<cr>", { desc = "fugitive", silent = true })
    end,
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
