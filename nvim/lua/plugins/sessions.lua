return {

  {
    "dhruvasagar/vim-prosession",
    dependencies = {
      "tpope/vim-obsession",
    },
    init = function()
      vim.g.prosession_tmux_title = 1
      vim.g.prosession_tmux_title_format = ":@@@"
      vim.g.prosession_on_startup = 1
    end,
  },
}
