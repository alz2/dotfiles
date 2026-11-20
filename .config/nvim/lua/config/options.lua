local opt = vim.opt

opt.number = true
opt.mouse = "r"
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "auto:1"
-- ponytail: iTerm mis-renders synchronized output (stale chars after `o`). Re-enable if iTerm fixes it.
opt.termsync = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smarttab = true

-- Keep the number column as narrow as possible. numberwidth is only a minimum;
-- Neovim auto-expands it to fit the largest line number, so 1 yields a gutter
-- that is always exactly wide enough. (Recomputing this per-keystroke in a
-- TextChangedI autocmd previously resized the gutter mid-redraw, which could
-- paint a typed character into the number column.)
opt.numberwidth = 1
