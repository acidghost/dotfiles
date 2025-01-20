local build_cmd ---@type string?
for _, cmd in ipairs({ "make", "cmake", "gmake" }) do
  if vim.fn.executable(cmd) == 1 then
    build_cmd = cmd
    break
  end
end

local pick = function(builtin, opts)
  return function()
    opts = opts or {}
    opts.follow = opts.follow ~= false
    if opts.cwd and opts.cwd ~= vim.uv.cwd() then
      local function open_cwd_dir()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        pick(
          builtin,
          vim.tbl_deep_extend("force", {}, opts or {}, {
            root = false,
            default_text = line,
          })
        )
      end
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        -- opts.desc is overridden by telescope, until it's changed there is this fix
        map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
        return true
      end
    end

    require("telescope.builtin")[builtin](opts)
  end
end

return {
  -- Fuzzy finder.
  -- The default key bindings to find files will use Telescope's
  -- `find_files` or `git_files` depending on whether the
  -- directory is a git repo.
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = (build_cmd ~= "cmake") and "make"
            or
            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = build_cmd ~= nil,
      },
    },
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/",       pick("live_grep"),                    desc = "Grep (Root Dir)" },
      { "<leader>:",       "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader><space>", pick("find_files"),                   desc = "Find Files (Root Dir)" },
      -- find
      {
        "<leader>fb",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
        desc = "Buffers",
      },
      {
        "<leader>fc",
        pick("find_files", { cwd = vim.fn.stdpath("config") }),
        desc = "Find Config File",
      },
      { "<leader>fF", pick("find_files", { root = false }),           desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>",                 desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent" },
      { "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd() }),       desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>",               desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",                desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>",                 desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>",              desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>",           desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>",                  desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>",       desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>",               desc = "Workspace Diagnostics" },
      { "<leader>sG", pick("live_grep", { root = false }),            desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>",                 desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>",                desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>",                  desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>",                   desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>",                   desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>",                 desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>",                     desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>",               desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>",                    desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>",                  desc = "Quickfix List" },
      { "<leader>sw", pick("grep_string", { word_match = "-w" }),     desc = "Word (Root Dir)" },
      {
        "<leader>sW",
        pick("grep_string", { root = false, word_match = "-w" }),
        desc = "Word (cwd)",
      },
      { "<leader>sw", pick("grep_string"),                   mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", pick("grep_string", { root = false }), mode = "v", desc = "Selection (cwd)" },
      {
        "<leader>uC",
        pick("colorscheme", { enable_preview = true }),
        desc = "Colorscheme with Preview",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = {
              "Class",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
            },
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = {
              "Class",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
            },
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")

      local find_files_no_ignore = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        pick("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        pick("find_files", { hidden = true, default_text = line })()
      end

      local function find_command()
        if 1 == vim.fn.executable("rg") then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable("fd") then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("fdfind") then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable("where") then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      }
    end,
  },

  -- better vim.ui with telescope
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function()
  --     if LazyVim.pick.want() ~= "telescope" then
  --       return
  --     end
  --     local Keys = require("lazyvim.plugins.lsp.keymaps").get()
  --     -- stylua: ignore
  --     vim.list_extend(Keys, {
  --       { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition", has = "definition" },
  --       { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
  --       { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
  --       { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
  --     })
  --   end,
  -- },
}
