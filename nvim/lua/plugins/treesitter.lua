local treesitter_commit
if vim.fn.has("nvim-0.10") then
  treesitter_commit = nil
elseif vim.fn.has("nvim-0.9.2") then
  treesitter_commit = "cfc6f2c117aaaa82f19bcce44deec2c194d900ab"
elseif vim.fn.has("nvim-0.9.1") then
  treesitter_commit = "f197a15b0d1e8d555263af20add51450e5aaa1f0"
else
  treesitter_commit = "63260da18bf273c76b8e2ea0db84eb901cab49ce"
end

return {

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    commit = treesitter_commit,
    opts = {
      ensure_installed = {
        "awk",
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
      },
      highlight = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "gnn",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
