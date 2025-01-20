if not vim.fn.isdirectory("/Applications/Ghostty.app/Contents/Resources/vim/vimfiles") then
  return {}
end

return {
  {
    dir = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles",
  },
}
