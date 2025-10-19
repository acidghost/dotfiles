local treesitter_commit = nil
local treesitter_branch = nil
if vim.fn.has("nvim-0.11") then
  -- remove when main becomes default branch
  treesitter_branch = "main"
elseif vim.fn.has("nvim-0.10") then
  treesitter_branch = "master"
elseif vim.fn.has("nvim-0.9.2") then
  treesitter_commit = "cfc6f2c117aaaa82f19bcce44deec2c194d900ab"
elseif vim.fn.has("nvim-0.9.1") then
  treesitter_commit = "f197a15b0d1e8d555263af20add51450e5aaa1f0"
else
  treesitter_commit = "63260da18bf273c76b8e2ea0db84eb901cab49ce"
end

local languages = {
  "awk",
  "bash",
  "c",
  "go",
  "just",
  "latex",
  "llvm",
  "lua",
  "markdown",
  "markdown_inline",
  "nu",
  "perl",
  "python",
  "rust",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

local incremental_selection_keymap = {
  init_selection = "gnn",
  node_incremental = "gnn",
  scope_incremental = false,
  node_decremental = "<BS>",
}

if treesitter_branch == "main" then
  return {

    {
      "MeanderingProgrammer/treesitter-modules.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      ---@module 'treesitter-modules'
      ---@type ts.mod.UserConfig
      opts = {
        ensure_installed = languages,
        fold = { enable = true },
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = incremental_selection_keymap,
        },
        indent = { enable = true },
      },
    },

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      commit = treesitter_commit,
      branch = treesitter_branch,
      lazy = false,
    },
  }
else
  return {

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      commit = treesitter_commit,
      branch = treesitter_branch,
      event = "LazyFile",
      lazy = vim.fn.argc(-1) == 0,
      opts = {
        ensure_installed = languages,
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = incremental_selection_keymap,
        },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
  }
end
