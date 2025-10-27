vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup {
  spec = {
    { import = 'custom.plugins' },
    { import = 'test.plugins' },
  },
  git = {
    log = { '-8' }, -- show the last 8 commits
    timeout = 120,  -- kill processes that take more than 2 minutes
    -- url_format = 'https://github.com/%s.git',
    url_format = 'git@github.com:%s.git',
    filter = true,
  },
}

require 'custom'
require 'test'

vim.cmd 'colorscheme tokyonight-moon'
