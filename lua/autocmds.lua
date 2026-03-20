require "nvchad.autocmds"

-- Override Nvdash's j/k mappings to match your inverted movement
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nvdash",
  callback = function()
    -- Nvdash internally maps <up> and <down> to its movements,
    -- so mapping j and k to <up> and <down> with `remap = true` works perfectly!
    vim.keymap.set("n", "j", "<Up>", { buffer = true, remap = true })
    vim.keymap.set("n", "k", "<Down>", { buffer = true, remap = true })
  end,
})

-- Smart comment continuation for Rust and C/C++
-- Auto-comment on Enter is only enabled when the previous 2 lines are both comments.
-- This prevents Neovim from blindly adding "//" every time you press Enter in a comment.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust", "c", "cpp" },
  callback = function()
    -- Step 1: Always strip auto-comment flags by default for these file types.
    --   'r' = insert comment leader after <Enter> in insert mode
    --   'o' = insert comment leader after 'o'/'O' in normal mode
    vim.opt_local.formatoptions:remove({ "r", "o" })

    -- Helper: check if a line is a line-comment (// ...) in Rust/C style.
    local function is_line_comment(line)
      return line ~= nil and line:match("^%s*//") ~= nil
    end

    -- Step 2: Watch cursor movement in insert mode.
    -- Each time the cursor moves, check if the current AND previous lines
    -- are both comments. If yes -> enable 'r' so the NEXT Enter auto-continues.
    vim.api.nvim_create_autocmd({ "CursorMovedI", "InsertEnter" }, {
      buffer = 0,
      callback = function()
        local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed

        if row < 2 then
          vim.opt_local.formatoptions:remove({ "r" })
          return
        end

        local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
        local prev_line    = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""

        -- If BOTH current and previous lines are comments, the user has manually
        -- written 2+ comment lines in a row -> enable auto-continue on next Enter.
        if is_line_comment(current_line) and is_line_comment(prev_line) then
          vim.opt_local.formatoptions:append("r")
        else
          vim.opt_local.formatoptions:remove({ "r" })
        end
      end,
    })

    -- Step 3: When leaving insert mode, always reset to no auto-comment.
    vim.api.nvim_create_autocmd("InsertLeave", {
      buffer = 0,
      callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
      end,
    })
  end,
})
