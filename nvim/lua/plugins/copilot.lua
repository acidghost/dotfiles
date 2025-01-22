return {
  {
    "github/copilot.vim",
    -- stylua: ignore
    keys = {
      { "<Leader>lce", "<cmd>Copilot enable<cr>",     mode = "n", desc = "Copilot enable" },
      { "<Leader>lcd", "<cmd>Copilot disable<cr>",    mode = "n", desc = "Copilot disable" },
      { "<Leader>lcs", "<cmd>Copilot status<cr>",     mode = "n", desc = "Copilot status" },
      { "<Leader>lcp", "<cmd>Copilot panel<cr>",      mode = "n", desc = "Copilot panel" },
      { "<C-]>",       "<Plug>(copilot-dismiss)",     mode = "i", desc = "Copilot dismiss" },
      { "<M-Bslash>",  "<Plug>(copilot-suggest)",     mode = "i", desc = "Copilot suggest" },
      { "<M-C-Right>", "<Plug>(copilot-accept-line)", mode = "i", desc = "Copilot accept line" },
      { "<M-Right>",   "<Plug>(copilot-accept-word)", mode = "i", desc = "Copilot accept word" },
      { "<M-[>",       "<Plug>(copilot-previous)",    mode = "i", desc = "Copilot previous" },
      { "<M-]>",       "<Plug>(copilot-next)",        mode = "i", desc = "Copilot next" },
    },
    init = function()
      -- disable copilot for all filetypes
      -- enable it for specific filetypes on-demand
      -- see also nvim-copilot in shell/functions.sh
      vim.g.copilot_filetypes = {
        ["*"] = false,
      }
    end,
  },
}
