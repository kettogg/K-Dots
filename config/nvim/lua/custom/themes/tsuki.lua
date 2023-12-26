local M = {}

M.base_30 = {
  white = "#dfdddd",
  darker_black = "#0c0c0c",
  black = "#0d0d0d", --  nvim bg
  black2 = "#141414",
  lighter_black = "#121212",
  one_bg = "#161616",
  one_bg2 = "#1f1f1f",
  one_bg3 = "#282828",
  grey = "#343434",
  grey_fg = "#404040",
  grey_fg2 = "#494949",
  light_grey = "#515151",
  red = "#DF5B61",
  baby_pink = "#EE6A70",
  pink = "#e8646a",
  line = "#1b1d1e", -- for lines like vertsplit
  green = "#78B892",
  vibrant_green = "#81c19b",
  nord_blue = "#5A84BC",
  blue = "#6791C9",
  yellow = "#ecd28b",
  sun = "#f6dc95",
  purple = "#c58cec",
  dark_purple = "#BC83E3",
  teal = "#70b8ca",
  orange = "#E89982",
  cyan = "#67AFC1",
  statusline_bg = "#101010",
  lightbg = "#1d1d1d",
  pmenu_bg = "#78B892",
  folder_bg = "#729bc4",
}

M.base_16 = {
  base00 = "#0d0d0d",
  base01 = "#121212",
  base02 = "#161616",
  base03 = "#1f1f1f",
  base04 = "#282828",
  base05 = "#dfdddd",
  base06 = "#e5e5e5",
  base07 = "#f3f3f3",
  base08 = "#f26e74",
  base09 = "#ecd28b",
  base0A = "#e79881",
  base0B = "#82c29c",
  base0C = "#6791C9",
  base0D = "#709ad2",
  base0E = "#c58cec",
  base0F = "#e8646a",
}

M.type = "dark"

M = require("base46").override_theme(M, "yoru")

return M
