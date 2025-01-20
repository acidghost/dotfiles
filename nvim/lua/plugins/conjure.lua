if not vim.fn.has("nvim-0.7") then
  return {}
end

return {
  {
    "Olical/conjure",
    ft = {
      "lua",
      "python",
    }, -- etc
    lazy = true,
    init = function()
      vim.g["conjure#filetypes"] = {
        "clojure",
        "fennel",
        "janet",
        "hy",
        "julia",
        "racket",
        "scheme",
        "lua",
        "lisp",
        "python",
      }
    end,
  },
}
