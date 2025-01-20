return {
  {
    "zk-org/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "telescope",
      })
      vim.cmd([[
        nmap <Leader>zo    :ZkNotes { sort = { "modified" }, excludeHrefs = { "daily" } }<CR>
        nmap <Leader>zD    :ZkNotes { sort = { "path-" }, hrefs = { "daily" } }<CR>
        nmap <Leader>zi    :ZkNotes { sort = { "modified" }, tags = { "issue" } }<CR>
        nmap <Leader>znn   :ZkNew<CR>
        vmap <Leader>znn   :'<,'>ZkNewFromTitleSelection<CR>
        vmap <Leader>zni   :'<,'>ZkNewFromTitleSelection { template = "issue.md" }<CR>
        nmap <Leader>zd    :ZkNew { dir = "daily" }<CR>
        nmap <Leader>zt    :ZkTags<CR>
        nmap <Leader>zx    :ZkIndex<CR>
      ]])
    end,
  },
}
