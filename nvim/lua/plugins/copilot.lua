return {
  {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_filetypes = {
        ["*"] = false,
      }

      vim.cmd([[
        nmap <Leader>lce :Copilot enable<CR>
        nmap <Leader>lcd :Copilot disable<CR>
        nmap <Leader>lcs :Copilot status<CR>
        nmap <Leader>lcp :Copilot panel<CR>

        imap <C-]>         <Plug>(copilot-dismiss)
        imap <M-C-Right>   <Plug>(copilot-accept-line)
        imap <M-Right>     <Plug>(copilot-accept-word)
        imap <M-Bslash>    <Plug>(copilot-suggest)
        imap <M-[>         <Plug>(copilot-previous)
        imap <M-]>         <Plug>(copilot-next)
      ]])
    end,
  },
}
