local path = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles"
if vim.fn.isdirectory(path) == 0 then
  return {}
end
return {
  name = "ghostty",
  dir = path,
}
