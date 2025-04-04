local build_cmd ---@type string?
for _, cmd in ipairs({ "make", "cmake", "gmake" }) do
  if vim.fn.executable(cmd) == 1 then
    build_cmd = cmd
    break
  end
end

local function pick(builtin, opts)
  return function()
    opts = opts or {}
    opts.follow = opts.follow ~= false
    if opts.buffer_dir == true then
      opts.cwd = require("telescope.utils").buffer_dir()
      opts.buffer_dir = nil
    end
    if opts.cwd and opts.cwd ~= vim.uv.cwd() then
      -- TODO: what's the point of this?
      local function open_cwd_dir()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        pick(
          builtin,
          vim.tbl_deep_extend("force", {}, opts or {}, {
            root = false,
            default_text = line,
          })
        )()
      end
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        -- opts.desc is overridden by telescope, until it's changed there is this fix
        map("n", "<C-\\>", open_cwd_dir, { desc = "Open cwd Directory" })
        return true
      end
    end

    require("telescope.builtin")[builtin](opts)
  end
end

local function is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
local function on_load(name, fn)
  if is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
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
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = build_cmd ~= nil,
        config = function(plugin)
          on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf.so"
              if not vim.uv.fs_stat(lib) then
                vim.notify(
                  "telescope-fzf-native.nvim not built. Rebuilding...",
                  vim.log.levels.WARN
                )
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  vim.notify(
                    "Rebuilding telescope-fzf-native.nvim done.\nPlease restart Neovim.",
                    vim.log.levels.INFO
                  )
                end)
              else
                vim.notify(
                  "Failed to load telescope-fzf-native.nvim:\n" .. err,
                  vim.log.levels.ERROR
                )
              end
            end
          end)
        end,
      },
    },
    -- stylua: ignore
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/",    pick("live_grep"),                              desc = "Grep (Root Dir)" },
      { "<leader>:",    "<cmd>Telescope command_history<cr>",           desc = "Command History" },
      { "<C-p>p",       pick("find_files"),                             desc = "Find Files (Root Dir)" },
      { "<C-p>b",       pick("find_files", { buffer_dir = true }),      desc = "Find Files (Buffer Dir)" },
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
      { "<leader>fg", "<cmd>Telescope git_files<cr>",                   desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                    desc = "Recent" },
      { "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd() }),         desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>",                 desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",                  desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>",                   desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>",                desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>",   desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>",             desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>",                    desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>",         desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>",                 desc = "Workspace Diagnostics" },
      { "<leader>sg", pick("live_grep"),                                desc = "Grep (Root Dir)" },
      { "<leader>sG", pick("live_grep", { buffer_dir = true }),         desc = "Grep (Buffer Dir)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>",                   desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>",                  desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>",                    desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>",                     desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>",                     desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>",                   desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>",                       desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>",                 desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>",                      desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>",                    desc = "Quickfix List" },
      { "<leader>sw", pick("grep_string", { word_match = "-w" }),       desc = "Word (Root Dir)" },
      { "<leader>sw", pick("grep_string"), mode = "v",                  desc = "Selection (Root Dir)" },
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
    init = function()
      vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")
    end,
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
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-i>"] = find_files_no_ignore,
              ["<C-h>"] = find_files_with_hidden,
              ["<PageDown>"] = actions.cycle_history_next,
              ["<PageUp>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.close,
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
}
