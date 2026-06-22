local keymapTable = require('libs').keymapTable

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('custom.plugin_config.telescope').init()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'c',
          'cpp',
          'go',
          'zig',
          'lua',
          'python',
          'rust',
          'tsx',
          'javascript',
          'typescript',
          'vimdoc',
          'vim',
          'bash',
          'query',
          'markdown',
          'markdown_inline',
        },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = false,

        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function()
      local libs = require 'libs'
      libs.map('n', '-', require('oil').open_float, { desc = 'open oil' })
    end,
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
          natural_order = true,
          is_always_hidden = function(name, _)
            return name == '..' or name == '.git'
          end,
        },
        keymaps = {
          ["q"] = { "actions.close", mode = "n" },
          ["<C-s>"] = nil,
          -- ["<C-w><C-s>"] = { "actions.select", opts = { vertical = true } },
          ["<C-w><C-v>"] = { "actions.select", opts = { horizontal = true } },
        },
        float = {
          padding = 2,
          max_width = 90,
          max_height = 0,
        },
        win_options = {
          wrap = true,
          winblend = 0,
        },
        confirmation = {
          winblend = 0,
        },
      }
    end,
  },
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      -- or if using `mini.icons`
      -- { "echasnovski/mini.icons" },
    },
    opts = {
      show_icons = true,
      leader_key = ';', -- Recommended to be a single key
      buffer_leader_key = 'm', -- Per Buffer Mappings
    }
  },
  {
    'folke/tokyonight.nvim',
    opts = {
      transparent = true,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    },
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup {
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
        session_lens = {
          buftypes_to_ignore = {},
          load_on_setup = true,
          theme_conf = { border = true },
          previewer = false,
        },
      }

      vim.keymap.set('n', '<Leader>ls', require('auto-session.session-lens').search_session, {
        noremap = true,
      })
    end,
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    init = function()
      vim.keymap.set('n', '<leader>sO', function()
        require('telescope').extensions.aerial.aerial()
      end)
    end,
    config = function()
      require('telescope').load_extension 'aerial'
      require('telescope').setup {
        extensions = {
          aerial = {
            -- How to format the symbols
            format_symbol = function(symbol_path, filetype)
              if filetype == 'json' or filetype == 'yaml' then
                return table.concat(symbol_path, '.')
              else
                return symbol_path[#symbol_path]
              end
            end,
            -- Available modes: symbols, lines, both
            show_columns = 'both',
          },
        },
      }
      require('aerial').setup {
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
        end,
      }
    end,
  },
  {
    -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim',
    opts = {},
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {}
    end,
  },
  {
    'f-person/git-blame.nvim',
    event = 'VeryLazy',
    opts = {
      enabled = true, -- if you want to enable the plugin
      message_template = "<summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
      date_format = "%Y/%m/%d %H:%M:%S", -- template for the date, check Date format section for more options
      virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
    },
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      }
    }
  },
  {
    'hedyhli/outline.nvim',
    cmd = { 'Outline' },
    config = function()
      require('outline').setup { outline_window = { auto_jump = true } }
    end,
    -- ["<leader>u"] = { "<cmd> UndotreeToggle <CR>", "undo tree" },
    init = function()
      keymapTable 'nv' {
        ['<leader>ot'] = { '<cmd> Outline <CR>', 'Outline toggle' },
      }
    end,
  },

}
