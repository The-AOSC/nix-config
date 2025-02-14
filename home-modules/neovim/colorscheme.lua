local hi = function(name, val)
  -- Force links
  val.force = true
  -- Make sure that `cterm` attribute is not populated from `gui`
  val.cterm = val.cterm or {}
  -- Define global highlight
  vim.api.nvim_set_hl(0, name, val)
end

hi('DiffAdd',    { fg = 'DarkGreen',   ctermfg = 'DarkGreen' })
hi('DiffChange', { fg = 'DarkMagenta', ctermfg = 'DarkMagenta' })
hi('DiffDelete', { fg = 'DarkRed',     ctermfg = 'DarkRed' })
hi('SignColumn', { fg = 'Cyan',        ctermfg = 'Cyan' })
