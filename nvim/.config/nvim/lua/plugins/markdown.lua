return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local cfg = vim.fn.expand("~/.markdownlint.yaml")
      if vim.fn.filereadable(cfg) == 1 then
        opts.linters = opts.linters or {}
        opts.linters["markdownlint-cli2"] = {
          args = { "--config", cfg, "--stdin-filename", function()
            return vim.api.nvim_buf_get_name(0)
          end, "-" },
        }
      end
      return opts
    end,
  },
}
