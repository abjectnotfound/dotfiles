-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Paste and wrap at textwidth (160 chars)
vim.keymap.set('n', 'p', function()
  local start = vim.fn.line('.')
  vim.cmd('normal! p')
  local finish = vim.fn.line('.')
  if finish > start then
    vim.cmd(string.format('%d,%dnormal! gww', start, finish))
  end
end, { desc = "Paste and wrap at textwidth" })

vim.keymap.set('n', 'P', function()
  local start = vim.fn.line('.')
  vim.cmd('normal! P')
  local finish = vim.fn.line('.')
  if finish > start then
    vim.cmd(string.format('%d,%dnormal! gww', start, finish))
  end
end, { desc = "Paste before and wrap at textwidth" })
