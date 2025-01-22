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
    },
  },
}
