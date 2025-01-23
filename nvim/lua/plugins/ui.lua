return {

  {
    "tinted-theming/base16-vim",
  },

  {
    "echasnovski/mini.icons",
    version = "*",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "tinted-theming/base16-vim",
    },
    opts = {
      options = {
        theme = "base16",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        always_show_tabline = false,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path
            symbols = {
              modified = "+",
              readonly = "RO",
              unnamed = "[No Name]",
              newfile = "New",
            },
          },
        },
        lualine_x = {
          "encoding",
          {
            "fileformat",
            symbols = {
              unix = "",
              dos = "",
              mac = "",
            },
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path
          },
        },
        lualine_x = { "progress" },
        lualine_y = { "location" },
        lualine_z = {},
      },
      tabline = {
        lualine_a = {
          {
            "tabs",
            tab_max_length = 40, -- Maximum width of each tab
            max_length = vim.o.columns, -- Maximum width of tabs component
            mode = 2, -- Shows tab_nr + tab_name
            path = 0, -- Shows just the filename

            -- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
            use_mode_colors = true,

            -- Shows a symbol next to the tab number if the file has been modified.
            show_modified_status = true,
            symbols = {
              modified = "+",
            },

            fmt = function(name, context)
              local buflist = vim.fn.tabpagebuflist(context.tabnr)
              -- local active = vim.api.nvim_get_current_tabpage() == context.tabnr
              if #buflist > 1 then
                -- defined in my base16 customizations
                return name .. " %#MyTablinePlus# +" .. (#buflist - 1)
              end
              return name
            end,
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
}
