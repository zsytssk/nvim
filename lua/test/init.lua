local libs = require 'libs'

local ns_id = vim.api.nvim_create_namespace("hide_example")
local flag = false
local test = function()
  -- local current_buf = vim.api.nvim_get_current_buf()
  -- vim.print(vim.inspect(current_buf))
  -- vim.cmd '!kitty'
  -- vim.api.nvim_command 'terminal kitty'
  -- local path = vim.fn.getcwd()
  -- vim.fn.jobstart('kitty --directory ' .. path, { detach = true })
  if flag then
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    flag = false
    return
  end
  vim.api.nvim_buf_set_extmark(0, ns_id, 2, 0, {
    virt_text = { { "-------------------", "Comment" } },
    virt_text_pos = "overlay",
  })
  vim.api.nvim_buf_set_extmark(0, ns_id, 1, 0, {
    virt_text = { { "-------------------", "Normal" } },
    virt_text_pos = "overlay",
  })
  flag = true
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
