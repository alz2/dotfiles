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
