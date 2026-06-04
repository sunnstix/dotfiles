-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.linebreak = true    -- wrap at word boundaries, not mid-word

-- Make j/k and Home/End move by visual line when wrap is on
vim.keymap.set({ "n", "x" }, "j",   "v:count == 0 ? 'gj' : 'j'",  { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k",   "v:count == 0 ? 'gk' : 'k'",  { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "$",   "g$",  { silent = true })
vim.keymap.set({ "n", "x" }, "0",   "g0",  { silent = true })
vim.keymap.set({ "n", "x" }, "^",   "g^",  { silent = true })
vim.keymap.set("i",          "<End>", "<C-o>g$", { silent = true })
