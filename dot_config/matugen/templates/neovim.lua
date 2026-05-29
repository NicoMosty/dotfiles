-- Neovim Dynamic Color Theme
-- Generated dynamically by Matugen

local colors = {
  bg = "{{colors.surface.default.hex}}",
  fg = "{{colors.on_surface.default.hex}}",
  primary = "{{colors.primary.default.hex}}",
  secondary = "{{colors.secondary.default.hex}}",
  tertiary = "{{colors.tertiary.default.hex}}",
  error = "{{colors.error.default.hex}}",
  surface_container = "{{colors.surface_container.default.hex}}",
  outline = "{{colors.outline.default.hex}}",
}

-- Apply Neovim basic editor highlights
local hl = vim.api.nvim_set_hl

-- Editor fundamentals
hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
hl(0, "NormalFloat", { fg = colors.fg, bg = colors.surface_container })
hl(0, "FloatBorder", { fg = colors.outline, bg = colors.surface_container })
hl(0, "CursorLine", { bg = colors.surface_container })
hl(0, "Visual", { bg = colors.surface_container, fg = colors.primary, bold = true })
hl(0, "LineNr", { fg = colors.outline })
hl(0, "CursorLineNr", { fg = colors.primary, bold = true })

-- Syntax highlights
hl(0, "Comment", { fg = colors.outline, italic = true })
hl(0, "Constant", { fg = colors.tertiary })
hl(0, "String", { fg = colors.primary })
hl(0, "Character", { fg = colors.primary })
hl(0, "Number", { fg = colors.secondary })
hl(0, "Boolean", { fg = colors.secondary })
hl(0, "Float", { fg = colors.secondary })
hl(0, "Identifier", { fg = colors.fg })
hl(0, "Function", { fg = colors.primary })
hl(0, "Statement", { fg = colors.primary, bold = true })
hl(0, "Conditional", { fg = colors.primary, bold = true })
hl(0, "Repeat", { fg = colors.primary, bold = true })
hl(0, "Label", { fg = colors.primary })
hl(0, "Operator", { fg = colors.outline })
hl(0, "Keyword", { fg = colors.primary, bold = true })
hl(0, "Exception", { fg = colors.error, bold = true })
hl(0, "PreProc", { fg = colors.secondary })
hl(0, "Include", { fg = colors.primary })
hl(0, "Define", { fg = colors.primary })
hl(0, "Macro", { fg = colors.primary })
hl(0, "Type", { fg = colors.secondary })
hl(0, "StorageClass", { fg = colors.secondary })
hl(0, "Structure", { fg = colors.secondary })
hl(0, "Typedef", { fg = colors.secondary })
hl(0, "Special", { fg = colors.primary })
hl(0, "Error", { fg = colors.error, bold = true })
hl(0, "Todo", { fg = colors.primary, bold = true })

-- UI details
hl(0, "Pmenu", { fg = colors.fg, bg = colors.surface_container })
hl(0, "PmenuSel", { fg = colors.bg, bg = colors.primary })
hl(0, "Search", { fg = colors.bg, bg = colors.primary })
hl(0, "IncSearch", { fg = colors.bg, bg = colors.secondary })
hl(0, "VertSplit", { fg = colors.outline })
hl(0, "StatusLine", { fg = colors.fg, bg = colors.surface_container })
hl(0, "StatusLineNC", { fg = colors.outline, bg = colors.bg })
