local utils = require 'custom.utils'

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- unfoucus时自动保存
local group = vim.api.nvim_create_augroup('AutoSave', {})
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*' },
  callback = function(e1)
    if e1.file == '' then
      return
    end
    -- print(string.format('BufNew: %s', vim.inspect(e1.buf)))
    vim.api.nvim_clear_autocmds { group = group, buffer = e1.buf }
    vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
      buffer = e1.buf,
      group = group,
      callback = function(e2)
        local buffer_changed = utils.is_buffer_changed(e2.buf)
        if not buffer_changed then
          return
        end

        vim.schedule(function()
          vim.api.nvim_buf_call(e2.buf, function()
            vim.cmd 'w'
          end)
        end)

        if e2.event == 'BufLeave' then
          vim.api.nvim_clear_autocmds { group = group, buffer = e1.buf }
        end
      end,
    })
  end,
})
