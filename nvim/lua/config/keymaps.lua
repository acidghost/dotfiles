-- terminal
---@class TermOpts
---@field new? boolean
---@field float? boolean
---@param opts? TermOpts
---@return fun()
local function terminal(opts)
  opts = opts or {}
  local fn = Snacks.terminal.toggle
  if opts.new then
    fn = Snacks.terminal.open
  end
  local terminal_opts = {}
  if opts.float then
    terminal_opts.win = { position = "float" }
  end
  return function()
    fn(nil, terminal_opts)
  end
end
vim.keymap.set("n", "<leader>tt", terminal(), { desc = "Terminal" })
vim.keymap.set("n", "<leader>tn", terminal({ new = true }), { desc = "Terminal open" })
vim.keymap.set("n", "<leader>tf", terminal({ float = true }), { desc = "Terminal float" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
