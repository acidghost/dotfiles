return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    version = "*",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      completions = {
        lsp = { enabled = true },
      },
      callout = {
        ai = {
          raw = "[!AI]",
          rendered = " AI",
          highlight = "RenderMarkdownHint",
          category = "custom",
        },
      },
      code = {
        border = "thin",
        border_virtual = true,
        left_pad = 1,
        min_width = 100,
        width = "block",
      },
      heading = {
        border = true,
        border_virtual = true,
        left_pad = 1,
        min_width = 100,
        width = "block",
      },
      sign = {
        enabled = false,
      },
      yaml = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          vim.keymap.set(
            "n",
            "<leader>rm",
            "<cmd>RenderMarkdown toggle<cr>",
            { buffer = args.buf, desc = "Toggle Render Markdown" }
          )
        end,
      })
    end,
  },
}
