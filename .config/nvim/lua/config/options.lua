local opt = vim.opt

opt.number = true
opt.mouse = "r"
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "auto:1"
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

local function update_numberwidth()
  local line_count = vim.api.nvim_buf_line_count(0)
  local width = math.max(1, #tostring(line_count))
  vim.opt_local.numberwidth = width
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TextChanged", "TextChangedI", "BufWritePost" }, {
  callback = update_numberwidth,
})
