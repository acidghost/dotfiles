return {
  {
    "vim-latex/vim-latex",
    ft = { "latex", "tex", "bib" },
    init = function()
      vim.g.tex_flavor = "latex"
    end,
  },
}
