return {

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      {
        "<C-n>n",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<C-n>g",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<C-n>b",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    init = function()
      -- load neo-tree on BufEnter, if we're opening a directory
      vim.api.nvim_create_autocmd("BufEnter", {
        -- make a group to be able to delete it later
        group = vim.api.nvim_create_augroup("NeoTreeInit", { clear = true }),
        callback = function()
          local f = vim.fn.expand("%:p")
          if vim.fn.isdirectory(f) ~= 0 then
            vim.cmd("Neotree current dir=" .. f)
            -- neo-tree is loaded now, delete the init autocmd
            vim.api.nvim_clear_autocmds({ group = "NeoTreeInit" })
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
      },
    },
  },

  {
    "echasnovski/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "sa",            -- Add surrounding in Normal and Visual modes
        delete = "sd",         -- Delete surrounding
        find = "sf",           -- Find surrounding (to the right)
        find_left = "sF",      -- Find surrounding (to the left)
        highlight = "sh",      -- Highlight surrounding
        replace = "sr",        -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },
}
