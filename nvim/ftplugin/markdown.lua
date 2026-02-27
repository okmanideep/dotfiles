-- Disable diagnostics by default for markdown files
-- Too much spell check noise
vim.diagnostic.enable(false, { bufnr = 0 })

vim.keymap.set("n", "gt", function()
  local current_line = vim.api.nvim_get_current_line()
  local updated_line

  if current_line:match("%- %[%s%]") then
    updated_line = current_line:gsub("%- %[%s%]", "- [x]", 1)
  elseif current_line:match("%- %[[xX]%]") then
    updated_line = current_line:gsub("%- %[[xX]%]", "- [ ]", 1)
  else
    return
  end

  vim.api.nvim_set_current_line(updated_line)
end, { buffer = true, desc = "Toggle markdown checkbox" })
