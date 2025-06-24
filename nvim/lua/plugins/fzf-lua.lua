-- plugins/fzf-lua.lua
return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      fzf_bin = "fzf",
      winopts = { height = 0.85, width = 0.80, border = "rounded" },
      preview = { default = "bat" },
    })

    -- files in project
    vim.keymap.set("n", "<leader>pf", fzf.files,     { desc = "fzf-lua: find files" })
    -- git-tracked files
    vim.keymap.set("n", "<C-p>",      fzf.git_files, { desc = "fzf-lua: git files" })
    -- live grep (no extra prompt)
    vim.keymap.set("n", "<leader>ps", fzf.live_grep, { desc = "fzf-lua: live grep" })
  end,
}
