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

  local dir = vim.fn.expand("%:p:h")
  local output = {}

  vim.notify("Running go test in " .. dir, vim.log.levels.INFO)

  vim.system({ "go", "test", "." }, { cwd = dir, text = true }, function(result)
    if result.stdout and result.stdout ~= "" then
      table.insert(output, result.stdout)
    end
    if result.stderr and result.stderr ~= "" then
      table.insert(output, result.stderr)
    end

    vim.schedule(function()
      local message = table.concat(output, "\n")

      if result.code == 0 then
        vim.notify(message ~= "" and message or "go test passed", vim.log.levels.INFO, {
          title = "go test",
        })
      else
        vim.notify(message ~= "" and message or "go test failed", vim.log.levels.ERROR, {
          title = "go test",
        })
      end
    end)
  end)
end, { desc = "Run go test for current package" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    local function goto_definition()
      local params = vim.lsp.util.make_position_params()

      vim.lsp.buf_request(args.buf, "textDocument/definition", params, function(err, result)
        if err then
          vim.notify(err.message or "Failed to jump to definition", vim.log.levels.ERROR)
          return
        end

        if not result or vim.tbl_isempty(result) then
          vim.notify("No definition found", vim.log.levels.INFO)
          return
        end

        local location = vim.tbl_islist(result) and result[1] or result
        vim.lsp.util.jump_to_location(location, "utf-8", true)
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
    vim.cmd("silent keepjumps keepmarks %!gofmt")
    vim.fn.winrestview(view)
  end,
})
