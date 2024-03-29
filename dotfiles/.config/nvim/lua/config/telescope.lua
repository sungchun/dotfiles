-- Telescope.nvim configuration
local ts = require("telescope")
local actions = require("telescope.actions")

ts.setup({
  defaults = {
    file_ignore_patterns = {
      "^node_modules/",
      "^%.git/",
      "^%.venv/",
    },
    layout_strategy = "flex",
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-u>"] = false,
	["<C-j>"] = actions.move_selection_next,
	["<C-k>"] = actions.move_selection_previous,
      },
    },
    prompt_prefix = " ",
  },
})
