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
