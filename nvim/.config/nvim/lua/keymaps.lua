local map = vim.keymap.set

-- require("which-key").add({
-- 	{ "t", group = "+t-prefix" },
-- })

-- Swap q and Q for macro recording
map("n", "q", "<Nop>", { desc = "Disabled (use Q for macros)" })
map("n", "Q", "q", { desc = "Record macro" })

map("n", "t-", "<cmd>split<cr>", { desc = "Split window horizontally" })
map("n", "t'", "<cmd>vsplit<cr>", { desc = "Split window vertically" })

map("n", "th", "<C-w>h", { desc = "Go to left window" })
map("n", "tj", "<C-w>j", { desc = "Go to lower window" })
map("n", "tk", "<C-w>k", { desc = "Go to upper window" })
map("n", "tl", "<C-w>l", { desc = "Go to right window" })

map("n", "tq", ":close<CR>", { desc = "close current window", noremap = true, silent = true })
map("n", "td", ":bdelete<CR>", { desc = "delete current window", noremap = true, silent = true })
map("n", "tm", "<C-w>o", { desc = "Close other windows" })

map("n", "t=", "<C-w>=", { desc = "equalize window sizes" })

map("n", "t_", "<cmd>resize -5<cr>", { desc = "Decrease window height" })
map("n", "t+", "<cmd>resize +5<cr>", { desc = "Increase window height" })

map("n", "tc", "gcc", { desc = "Toggle comment line", remap = true })
map("v", "tc", "gc", { desc = "Togle comment selection", remap = true })

map("i", "<Esc>", "<Esc>`^", { desc = "Exit insert mode without moving cursor" })
map("n", "a", "A", { desc = "Append at end of line" })

map("n", ";", ":", { desc = "Command mode", noremap = true })
map("v", ";", ":", { desc = "Command mode", noremap = true })

map("n", "U", "<C-r>", { desc = "Redo", noremap = true })

-- vim.keymap.set({ "n", "i", "v" }, "<C-f>", function()
-- 	require("snacks").picker.grep_buffers()
-- end, { desc = "Grep buffers" })

vim.keymap.set({ "n", "i", "v" }, "<C-b>", function()
	vim.cmd("buffer #")
end, { desc = "Switch to last buffer" })

map("n", "<C-j>", "<C-d>zz", { desc = "Scroll down half page" })
map("n", "<C-k>", "<C-u>zz", { desc = "Scroll up half page" })
-- Insert mode에서도 스크롤 가능 (C-o로 normal mode 명령어 실행)
map("i", "<C-j>", "<C-o><C-d>zz", { desc = "Scroll down half page" })
map("i", "<C-k>", "<C-o><C-u>zz", { desc = "Scroll up half page" })
map("v", "<C-j>", "<C-d>zz", { desc = "Scroll down half page" })
map("v", "<C-k>", "<C-u>zz", { desc = "Scroll up half page" })

map("n", "j", "jzz", { desc = "move cursor down" })
map("n", "k", "kzz", { desc = "move cursor up" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", ",e", function()
	vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit init.lua" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Auto change directory to current buffer's directory
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		-- Skip for oil buffers
		if vim.bo.filetype == "oil" then
			return
		end

		-- Check if the buffer has a valid file path
		local filepath = vim.fn.expand("%:p:h")
		if filepath ~= "" and vim.fn.isdirectory(filepath) == 1 then
			vim.cmd("lcd " .. filepath)
		end
	end,
})
