local lspconfig_version = "*"
local mason_version = "*"
local mason_lspconfig_version = "*"
if not vim.fn.has("nvim-0.10") then
  mason_version = "1.11.0"
  mason_lspconfig_version = "1.32.0"
end
if not vim.fn.has("nvim-0.11") then
  lspconfig_version = "2.5.0"
end

return {

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    version = lspconfig_version,
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      {
        "mason-org/mason-lspconfig.nvim",
        version = mason_lspconfig_version,
        opts = {
          automatic_enable = true,
        },
      },
      "b0o/schemastore.nvim",
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
            -- prefix = "icons",
          },
          severity_sort = true,
        },
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the inlay hints.
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = {
          enabled = false,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overridden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        ---@type lspconfig.options
        servers = {
          bashls = {},
          biome = {},
          clangd = {},
          gopls = {},
          helm_ls = {},
          jsonls = {
            init_options = {
              -- since we use prettier to format json
              provideFormatter = false,
            },
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
          nushell = {},
          lua_ls = {
            -- Use this to add any additional keymaps
            -- for specific lsp servers
            -- ---@type LazyKeysSpec[]
            -- keys = {},
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                format = {
                  -- since we're using stylua
                  enable = false,
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  loadOutDirsFromCheck = true,
                },
                procMacro = {
                  enable = true,
                },
              },
            },
          },
          ruff = {},
          shellcheck = {},
          ts_ls = {},
          ty = {},
          yamlls = {
            settings = {
              yaml = {
                schemaStore = {
                  -- You must disable built-in schemaStore support if you want to use
                  -- this plugin and its advanced options like `ignore`.
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = "",
                },
                schemas = require("schemastore").yaml.schemas(),
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup keymaps
      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        --Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Mappings.
        local opts = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set("n", "<leader>led", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>lep", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>len", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>leq", vim.diagnostic.setloclist, opts)

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)
        -- vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>ld", function()
          require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end, opts)
        -- vim.keymap.set('n', '<leader>lvd', '<cmd>vs<CR><Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.keymap.set("n", "<leader>lvd", function()
          vim.cmd("vs")
          vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, opts)
        -- vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>li", function()
          require("telescope.builtin").lsp_implementations({ reuse_win = true })
        end, opts)
        vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ls", vim.lsp.buf.document_symbol, opts)
        vim.keymap.set("n", "<leader>lws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<leader>lwl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        -- vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<leader>lt", function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
        end, opts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
        -- vim.keymap.set("n", "<leader>lx", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>lx", "<cmd>Telescope lsp_references<cr>", opts)
        vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, opts)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf ---@type number
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            return on_attach(client, buffer)
          end
        end,
      })

      -- diagnostics signs
      if vim.fn.has("nvim-0.10.0") == 0 then
        if type(opts.diagnostics.signs) ~= "boolean" then
          for severity, icon in pairs(opts.diagnostics.signs.text) do
            local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
            name = "DiagnosticSign" .. name
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
          end
        end
      end

      if vim.fn.has("nvim-0.10") == 1 then
        local function on_supports_method(method, fn)
          return vim.api.nvim_create_autocmd("User", {
            pattern = "LspSupportsMethod",
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              local buffer = args.data.buffer ---@type number
              if client and method == args.data.method then
                return fn(client, buffer)
              end
            end,
          })
        end

        -- inlay hints
        if opts.inlay_hints.enabled then
          on_supports_method("textDocument/inlayHint", function(client, buffer)
            if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ""
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end)
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens then
          on_supports_method("textDocument/codeLens", function(client, buffer)
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buffer,
              callback = vim.lsp.codelens.refresh,
            })
          end)
        end
      end

      if
        type(opts.diagnostics.virtual_text) == "table"
        and opts.diagnostics.virtual_text.prefix == "icons"
      then
        opts.diagnostics.virtual_text.prefix = "●"
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        if server_opts.enabled == false then
          return
        end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        if vim.fn.has("nvim-0.11") then
          vim.lsp.config(server, server_opts)
          vim.lsp.enable(server)
        else
          require("lspconfig")[server].setup(server_opts)
        end
      end

      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            setup(server)
          end
        end
      end
    end,
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = { "mason.nvim" },
    event = "LazyFile",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(
          ".null-ls-root",
          ".neoconf.json",
          "Makefile",
          ".git"
        )
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.clang_format,
        nls.builtins.formatting.prettier.with({
          filetypes = { "html", "yaml", "markdown" },
        }),
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.shfmt.with({
          extra_args = { "-s", "-bn", "-i=4" },
        }),
      })
    end,
  },

  {

    "mason-org/mason.nvim",
    version = mason_version,
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    ---@type MasonSettings
    opts = {
      -- Manually manage path so mise-managed tools come first
      PATH = "skip",
    },
  },

  {
    "folke/lazydev.nvim",
    version = "*",
    dependencies = {
      "nvim-lspconfig",
      "none-ls.nvim",
    },
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  {
    "folke/trouble.nvim",
    version = "*",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    keys = {
      { "<leader>v", "<cmd>VenvSelect<cr>" },
    },
    opts = {},
  },
}
