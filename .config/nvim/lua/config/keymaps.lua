vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })
vim.keymap.set("n", "<leader>t", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("<leader>t is only configured for Go buffers", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.cmd, "GoTest")

  if not ok then
    vim.notify(err or "Failed to run GoTest", vim.log.levels.ERROR, {
      title = "go test",
    })
  end
end, { desc = "Run go test for current package" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    local client = args.data and args.data.client_id and vim.lsp.get_client_by_id(args.data.client_id) or nil
    local position_encoding = (client and client.offset_encoding) or "utf-16"

    local function goto_definition()
      local params = vim.lsp.util.make_position_params(0, position_encoding)

      vim.lsp.buf_request(args.buf, "textDocument/definition", params, function(err, result)
        if err then
          vim.notify(err.message or "Failed to jump to definition", vim.log.levels.ERROR)
          return
        end

        if not result or vim.tbl_isempty(result) then
          vim.notify("No definition found", vim.log.levels.INFO)
          return
        end

        local location = vim.islist(result) and result[1] or result
        local opened = vim.lsp.util.show_document(location, position_encoding, {
          focus = true,
          reuse_win = true,
        })

        if not opened then
          vim.notify("Failed to open definition location", vim.log.levels.WARN)
        end
      end)
    end

    vim.keymap.set("n", "gd", goto_definition, vim.tbl_extend("force", opts, {
      desc = "Go to definition",
    }))
    vim.keymap.set("n", "<leader>gr", function()
      require("telescope.builtin").lsp_references()
    end, vim.tbl_extend("force", opts, {
      desc = "Go to references",
    }))
    vim.keymap.set("n", "<leader>gi", function()
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.lsp_implementations()
        return
      end
      vim.lsp.buf.implementation()
    end, vim.tbl_extend("force", opts, {
      desc = "Go to implementations",
    }))
    vim.keymap.set("n", "<leader>cr", function()
      vim.lsp.buf.rename()
    end, vim.tbl_extend("force", opts, {
      desc = "Rename symbol",
    }))
  end,
})

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      focusable = false,
      border = "rounded",
      source = "if_many",
    })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local view = vim.fn.winsaveview()
    pcall(function()
      require("go.format").goimports()
    end)
    vim.fn.winrestview(view)
  end,
})

local latexindent_missing_notified = false

local function format_latex(bufnr)
  if vim.fn.executable("latexindent") == 0 then
    if not latexindent_missing_notified then
      vim.notify("latexindent is not installed; skipping LaTeX format on save", vim.log.levels.WARN, {
        title = "latex",
      })
      latexindent_missing_notified = true
    end
    return
  end

  local view = vim.fn.winsaveview()
  local tmp = vim.fn.tempname() .. ".tex"
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local ok = vim.fn.writefile(lines, tmp) == 0

  if not ok then
    vim.notify("Failed to write temporary file for latexindent", vim.log.levels.ERROR, {
      title = "latex",
    })
    return
  end

  local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
  local result = vim.system({ "latexindent", "-g", "/dev/null", tmp }, {
    cwd = cwd ~= "" and cwd or nil,
    text = true,
  }):wait()
  vim.fn.delete(tmp)

  if result.code ~= 0 then
    vim.notify(result.stderr ~= "" and result.stderr or "latexindent failed", vim.log.levels.ERROR, {
      title = "latex",
    })
    return
  end

  local formatted = vim.split(result.stdout, "\n", { plain = true })
  if formatted[#formatted] == "" then
    table.remove(formatted)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
  vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.tex",
  callback = function(args)
    format_latex(args.buf)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<cr>", vim.tbl_extend("force", opts, {
      desc = "Compile LaTeX",
    }))
    vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<cr>", vim.tbl_extend("force", opts, {
      desc = "View LaTeX PDF",
    }))
    vim.keymap.set("n", "<leader>lk", "<cmd>VimtexStop<cr>", vim.tbl_extend("force", opts, {
      desc = "Stop LaTeX compiler",
    }))
    vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<cr>", vim.tbl_extend("force", opts, {
      desc = "Show LaTeX errors",
    }))
  end,
})
