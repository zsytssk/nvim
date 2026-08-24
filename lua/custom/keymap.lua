local libs = require 'libs'

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
-- 禁用 Insert 模式下的 Ctrl+Space
vim.api.nvim_set_keymap('i', '<C-Space>', '<nop>', { noremap = true, silent = true })

libs.keymapTable 'int' {
  ['<C-i>'] = { require('custom.jump_list').next, 'jump_list next' },
  ['<C-o>'] = { require('custom.jump_list').prev, 'jump_list prev' },
  ['<A-q>'] = { require('custom.utils').toggle_qf, 'toggle youtube control' },
  ['<A-y>'] = { require('custom.youtube').toggle, 'toggle youtube control' },
  ['<C-S-i>'] = { require('custom.utils').insert_cur_time, 'insert time' },
  ['<A-S-`>'] = { require('custom.utils').open_external_term, 'open external terminal' },
  ['<C-`>'] = { require('custom.plugin_config.toggleterm').toggle_terminal, 'toggle terminal' },
  ['<C-s>'] = { '<cmd> w <CR>', 'save file' },
  -- ['<C-q>'] = { require('custom.utils').toggle_qf, 'save file' },
}

libs.keymapTable 'n' {
  ['<Esc>'] = { '<cmd>:nohlsearch<CR>', 'clear search highlight' },
  ['<leader>sx'] = { '<cmd>source %<CR>', 'lua run current file' },
  ['<leader>x'] = { ':.lua<CR>', 'lua run current line' },
  -- ['<leader>sq'] = { require('custom.utils').toggle_qf, 'toggle quick fix' },
  ['<leader>ef'] = { "<cmd> echo expand('%:p') <CR>", 'show current file name' },
  ['<leader>ew'] = { '<cmd> pwd <CR>', 'show current workspace' },
  ['<A-m>'] = { '<cmd> messages <CR>', 'toggle message panel' },
  ['<C-d>'] = { '<C-d>zz', 'move down' },
  ['<C-u>'] = { '<C-u>zz', 'move up' },
  ['<C-h>'] = { '<C-w>h', 'move to panel left' },
  ['<C-j>'] = { '<C-w>j', 'move to panel down' },
  ['<C-k>'] = { '<C-w>k', 'move to panel up' },
  ['<C-l>'] = { '<C-w>l', 'move to panel right' },

  ['<A-z>'] = {
    require('custom.utils').toggle_wrap,
    'toggle wrap',
  },
}

libs.keymapTable 'v' {
  ['<leader>x'] = { ':lua<CR>', 'lua run current select' },
  ['<leader>p'] = { [["_dP]], 'paste content not change register' },
  ['<A-p>'] = { 'yP<esc>gv', 'copy lines down', opts = { silent = true } },
  ['<A-S-P>'] = { 'ygv<esc>pgv', 'copy lines up', opts = { silent = true } },
  ['J'] = { ":m '>+1<CR>gv=gv", 'move lines down', opts = { silent = true } },
  ['K'] = { ":m '<-2<CR>gv=gv", 'move lines up', opts = { silent = true } },

}
