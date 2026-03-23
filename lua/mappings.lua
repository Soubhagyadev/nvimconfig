require "nvchad.mappings"

-- Standard Neovim keymap API
local map = vim.keymap.set

-- Quick command mode access
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map("i", ";;", "\\", { desc = "Insert backslash" })

-- Your custom inverted movements (j=up, k=down)
map({ "n", "v" }, "j", "k", { desc = "Move up" })
map({ "n", "v" }, "k", "j", { desc = "Move down" })

-- File tree toggle with Ctrl+N
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Move lines up and down (Alt+j/k)
map("n", "<A-j>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("n", "<A-k>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("v", "<A-j>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
map("v", "<A-k>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })

-- Ctrl + j/k to go to previous/next line end (respecting your inverted j/k)
-- C-j = previous line end (moves up natively 'k', then '$' for end)
map("n", "<C-j>", "k$", { desc = "Go to previous line end" })
-- C-k = next line end (moves down natively 'j', then '$' for end)
map("n", "<C-k>", "j$", { desc = "Go to next line end" })
