local path = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles"
if not vim.fn.isdirectory(path) then
  return {}
end
return { dir = path }
