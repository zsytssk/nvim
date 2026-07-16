local M = {}

M.init = function()
  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
        },
      },
    },
    pickers = {
      colorscheme = {
        enable_preview = true,
      },
      buffers = {
        mappings = {
          i = {
            ['<c-d>'] = 'delete_buffer',
          },
        },
      },
    },
  }

  require('telescope').setup {
    defaults = require('telescope.themes').get_ivy(),
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'colors')

  local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == '' then
      current_dir = cwd
    else
      -- Extract the directory from the current file's path
      current_dir = vim.fn.fnamemodify(current_file, ':h')
    end

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
      print 'Not a git repository. Searching on current working directory'
      return cwd
    end
    return git_root
  end

  -- Custom live_grep function to search in git root
  local function live_grep_git_root()
    local conf = require('telescope.config').values
    local git_root = find_git_root()
    if git_root then
      require('telescope.builtin').live_grep {
        search_dirs = { git_root },
        vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
      }
    end
  end

  vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

  local function telescope_live_grep_open_files()
    local conf = require('telescope.config').values
    require('telescope.builtin').live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
      vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
    }
  end

  local function telescope_live_grep()
    local conf = require('telescope.config').values
    require('telescope.builtin').live_grep {
      vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
    }
  end

  vim.keymap.set('n', '<leader>so', function()
    require('telescope.builtin').treesitter()
  end, { desc = 'LSP function and method only' })

  vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
  vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
  vim.keymap.set('n', '<leader>sc', require('telescope.builtin').colorscheme, { desc = '[S]earch [C]olorScheme' })
  vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]map' })
  vim.keymap.set('n', '<leader>sg', telescope_live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
  -- vim.keymap.set('n', '<leader>sq', require('telescope.builtin').quickfix, { desc = '[Q]uick [F]ix' })

  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>/', function()
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })
end

return M
