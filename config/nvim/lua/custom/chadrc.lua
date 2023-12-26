---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "tsuki",
  theme_toggle = { "tsuki", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,

  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal

    -- default/round/block/arrow (separators work only for "default" statusline theme;
    -- round and block will work for the minimal theme only)
    separator_style = "default",
    overriden_modules = nil,
  },
  nvdash = {
    load_on_startup = false,

    header = {
      "████████╗███████╗██╗   ██╗██╗  ██╗██╗",
      "╚══██╔══╝██╔════╝██║   ██║██║ ██╔╝██║",
      "   ██║   ███████╗██║   ██║█████╔╝ ██║",
      "   ██║   ╚════██║██║   ██║██╔═██╗ ██║",
      "   ██║   ███████║╚██████╔╝██║  ██╗██║",
      "   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝",
    },
  --   buttons = {
  --     { "  Find File", "Spc f f", "Telescope find_files" },
  --     { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
  --     { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
  --     { "  Bookmarks", "Spc m a", "Telescope marks" },
  --     { "  Themes", "Spc t h", "Telescope themes" },
  --     { "  Mappings", "Spc c h", "NvCheatsheet" },
  --   },
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
