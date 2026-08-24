local keymapTable = require('libs').keymapTable

return {
  {
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    event = 'VeryLazy',
    version = '*',
    config = function()
      require('barbecue').setup {}
    end,
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons', -- optional dependency
    },
  },
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    init = function()
      keymapTable 'nv' {
        ['<leader>od'] = { '<cmd> UndotreeToggle <CR>', 'undotree toggle' },
      }
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    -- stylua: ignore
    keys = {
      { "<M-s>", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "<M-S>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    'ThePrimeagen/vim-be-good',
    cmd = { 'VimBeGood' },
    init = function()
      keymapTable 'nv' {
        ['<leader>gg'] = { '<cmd> VimBeGood <CR>', 'VimBeGood open' },
      }
    end,
  },
}
