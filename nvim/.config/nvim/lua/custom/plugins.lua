---@type NvPluginSpec[]
return {
  {
    "NvChad/nvterm",
    enabled = false,
  },
  { "folke/which-key.nvim", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },
  { "NvChad/nvim-colorizer.lua", enabled = false },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = {
      mapping = {
        ["<C-k>"] = require("cmp").mapping.select_prev_item(),
        ["<C-j>"] = require("cmp").mapping.select_next_item(),
        ["<CR>"] = require("cmp").mapping.confirm {
          behavior = require("cmp").ConfirmBehavior.Insert,
          select = true,
        },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
      },
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
          },
        },
      },
    },
  },
  { "lewis6991/gitsigns.nvim", opts = {
    current_line_blame_opts = {
      delay = 0,
    },
  } },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "▏",
      context_char = "▏",
      show_current_context = false,
      show_current_context_start = false,
      filetype_exclude = {
        "help",
        "terminal",
        "lazy",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "nvdash",
        "nvcheatsheet",
        "noice",
        "",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          local null_ls = require "null-ls"
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
          local b = null_ls.builtins

          null_ls.setup {
            debug = false,
            sources = {
              b.formatting.prettierd.with {
                extra_filetypes = { "astro", "svelte" },
              },
              b.formatting.stylua,
              b.formatting.gofmt,
              b.formatting.black,
              b.formatting.rustfmt,
              b.diagnostics.eslint_d,
            },
            filter = function(client)
              return client.name == "null-ls"
            end,
            on_attach = function(client, bufnr)
              if client.supports_method "textDocument/formatting" then
                vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = augroup,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format { bufnr = bufnr }
                  end,
                })
              end
            end,
          }
        end,
      },
      { "b0o/schemastore.nvim" },
      { "jose-elias-alvarez/typescript.nvim" },
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
        keys = {
          {
            "<leader>n",
            function()
              require("nvim-navbuddy").open()
            end,
            { silent = true },
          },
        },
        config = function()
          require("nvim-navbuddy").setup()
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"

      vim.diagnostic.config {
        virtual_text = false,
      }

      local navbuddy = require "nvim-navbuddy"
      local core_on_attach = require("plugins.configs.lspconfig").on_attach
      local capabilities = require("plugins.configs.lspconfig").capabilities

      local function on_attach(client, bufnr)
        core_on_attach(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navbuddy.attach(client, bufnr)
        end
      end

      local servers = {
        "cssls",
        "html",
        "jsonls",
        -- "eslint",
        "tailwindcss",
        "prismals",
        "rust_analyzer",
        "svelte",
        "dockerls",
        "pyright",
        "taplo",
        "astro",
        "gopls",
      }

      local typescript = require "typescript"
      typescript.setup {
        disable_commands = false,
        debug = false,
        server = {
          on_attach = on_attach,
          capabilities = capabilities,
        },
      }

      for _, server in pairs(servers) do
        local opts = {
          on_attach = on_attach,
          capabilities = capabilities,
        }

        if server == "tailwindcss" then
          opts = vim.tbl_deep_extend("keep", {
            filetypes = {
              "astro",
              "astro-markdown",
              "django-html",
              "htmldjango",
              "html",
              "mdx",
              "css",
              "less",
              "postcss",
              "sass",
              "scss",
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "vue",
              "svelte",
            },
            settings = {
              tailwindCSS = {
                experimental = {
                  classRegex = {
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  },
                },
              },
            },
          }, opts)
        end

        if server == "jsonls" then
          opts = vim.tbl_deep_extend("keep", {
            on_attach = function(client)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end,
            settings = {
              json = {
                schemas = require("schemastore").json.schemas(),
              },
            },
          }, opts)
        end

        require("lspconfig")[server].setup(opts)
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- "typescript-language-server",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "eslint_d",
        -- "eslint-lsp",
        "prettierd",
        "tailwindcss-language-server",
        "prisma-language-server",
        "rust-analyzer",
        "lua-language-server",
        "stylua",
        "svelte-language-server",
        "dockerfile-language-server",
        "pyright",
        "taplo",
        "astro-language-server",
        "gopls",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
      config = function()
        require("nvim-ts-autotag").setup {
          filetypes = {
            "html",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "astro",
            "vue",
            "tsx",
            "jsx",
            "rescript",
            "xml",
            "php",
            "markdown",
            "glimmer",
            "handlebars",
            "hbs",
          },
        }
      end,
    },
    opts = {
      ensure_installed = "all",
      ignore_install = { "jsonc", "fusion", "blueprint" },
      autotag = {
        enable = true,
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    init = function()
      require("core.utils").lazy_load "nvim-treesitter-context"
    end,
    config = function()
      require("treesitter-context").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd [[colorscheme tokyonight-night]]
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "numToStr/Navigator.nvim",
    keys = {
      { "<C-h>", "<CMD>NavigatorLeft<CR>", mode = { "n", "t" } },
      {
        "<C-l>",
        "<CMD>NavigatorRight<CR>",
        mode = { "n", "t" },
      },
      {
        "<C-j>",
        "<CMD>NavigatorDown<CR>",
        mode = { "n", "t" },
      },
      {
        "<C-k>",
        "<CMD>NavigatorUp<CR>",
        mode = { "n", "t" },
      },
    },
    config = function()
      require("Navigator").setup {
        disable_on_zoom = true,
      }
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup {
        log_level = "error",
      }
    end,
  },
  {
    "Bekaboo/dropbar.nvim",
    init = function()
      require("core.utils").lazy_load "dropbar.nvim"
    end,
    config = function()
      require("dropbar").setup {}
    end,
  },
  {
    "ThePrimeagen/harpoon",
    keys = {
      {
        "gm",
        function()
          require("harpoon.mark").add_file()
        end,
      },
      {
        "<leader>m",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
      },
    },
    config = function()
      require("harpoon").setup {
        global_settings = {
          save_on_toggle = true,
          save_on_change = true,
          enter_on_sendcmd = true,
          tmux_autoclose_windows = false,
          excluded_filetypes = { "harpoon" },
          mark_branch = false,
        },
      }
    end,
  },
  {
    "lewis6991/satellite.nvim",
    init = function()
      require("core.utils").lazy_load "satellite.nvim"
    end,
    config = function()
      require("satellite").setup {
        excluded_filetypes = { "NvimTree" },
        handlers = {
          gitsigns = {
            enable = false,
          },
          marks = {
            enable = false,
          },
        },
      }
    end,
  },
  {
    "folke/noice.nvim",
    lazy = false,
    config = function()
      require("noice").setup {
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },
        },
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "echasnovski/mini.move",
    init = function()
      require("core.utils").lazy_load "mini.move"
    end,
    config = function()
      require("mini.move").setup()
    end,
  },
  {
    "echasnovski/mini.ai",
    init = function()
      require("core.utils").lazy_load "mini.ai"
    end,
    config = function()
      require("mini.ai").setup()
    end,
  },
  {
    "echasnovski/mini.bracketed",
    init = function()
      require("core.utils").lazy_load "mini.bracketed"
    end,
    config = function()
      require("mini.bracketed").setup()
    end,
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup()
    end,
  },
  {
    "echasnovski/mini.surround",
    init = function()
      require("core.utils").lazy_load "mini.surround"
    end,
    config = function()
      require("mini.surround").setup()
    end,
  },
  {
    "echasnovski/mini.misc",
    lazy = false,
    config = function()
      require("mini.misc").setup_auto_root { ".git", "Makefile", "LICENSE" }
      require("mini.misc").setup_restore_cursor()
    end,
  },
  {
    "echasnovski/mini.align",
    keys = { "sp", "sP" },
    config = function()
      require("mini.align").setup {
        mappings = {
          start = "sp",
          start_with_preview = "sP",
        },
      }
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    config = function()
      local hi = require "mini.hipatterns"
      local colors = require "custom.colors"
      local ft = { "typescriptreact", "javascriptreact", "css", "html", "astro", "svelte" }
      local highlights = {}

      require("mini.hipatterns").setup {
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color { priority = 2000 },
          tailwind = {
            pattern = function()
              if not vim.tbl_contains(ft, vim.bo.filetype) then
                return
              end
              return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
            end,
            group = function(_, _, m)
              ---@type string
              local match = m.full_match
              ---@type string, number
              local color, shade = match:match "[%w-]+%-([a-z%-]+)%-(%d+)"
              shade = assert(tonumber(shade))
              local bg = vim.tbl_get(colors, color, shade)
              if bg then
                local hl = "MiniHipatternsTailwind" .. color .. shade
                if not highlights[hl] then
                  highlights[hl] = true
                  local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                  local fg = vim.tbl_get(colors, color, bg_shade)
                  vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
                end
                return hl
              end
            end,
            priority = 2000,
          },
        },
      }
    end,
  },
}