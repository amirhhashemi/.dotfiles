local M = {}

M.better_escape = function()
  local present, better_escape = pcall(require, "better_escape")

  if not present then
    return
  end

  better_escape.setup {
    mapping = { "jk" }, -- a table with mappings to use
    timeout = vim.o.timeoutlen,
    clear_empty_lines = false, -- clear line after escaping if there is only whitespace
    keys = "<Esc>",
  }
end

M.project = function()
  local present, project = pcall(require, "project_nvim")

  if not present then
    return
  end

  local options = {
    {
      manual_mode = false,
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml" },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = true,
      silent_chdir = true,
      datapath = vim.fn.stdpath "data",
    },
  }
  project.setup(options)
end

M.indent_o_matic = function()
  local present, indent_o_matic = pcall(require, "indent-o-matic")

  if not present then
    return
  end

  indent_o_matic.setup {
    max_lines = 2048,
    standard_widths = { 2, 4, 8 },

    -- Only detect 4 spaces and tabs for Rust files
    filetype_rust = {
      standard_widths = { 4 },
    },

    filetype_python = {
      standard_widths = { 4 },
    },

    -- Don't detect 8 spaces indentations inside files without a filetype
    filetype_ = {
      standard_widths = { 2, 4 },
    },
  }
end

M.harpoon = function()
  local present, harpoon = pcall(require, "harpoon")

  if not present then
    return
  end

  harpoon.setup {
    global_settings = {
      save_on_toggle = true,
      save_on_change = true,
      enter_on_sendcmd = true,
      tmux_autoclose_windows = false,
      excluded_filetypes = { "harpoon" },
      mark_branch = false,
    },
  }
end

M.scrollbar = function()
  local present, scrollbar = pcall(require, "scrollbar")

  if not present then
    return
  end

  scrollbar.setup {
    handle = {
      highlight = "CursorLine",
    },
    marks = {
      Error = {
        highlight = "DiagnosticError",
      },
      Warn = {
        highlight = "DiagnosticWarn",
      },
      Info = {
        highlight = "DiagnosticInfo",
      },
      Hint = {
        highlight = "DiagnosticHint",
      },
    },
    excluded_buftypes = {
      "terminal",
    },
    excluded_filetypes = {
      "packer",
      "prompt",
      "TelescopePrompt",
      "NvimTree",
    },
  }
end

M.neogit = function()
  local neogit = require "neogit"
end

M.surround = function()
  local present, surround = pcall(require, "nvim-surround")

  if not present then
    return
  end

  surround.setup {
    move_cursor = false,
    keymaps = {
      normal = "sa",
      visual = "S",
      delete = "sd",
      change = "sr",
    },
  }
end

return M