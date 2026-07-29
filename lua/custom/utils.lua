local tb = require('libs.table')

local M = {}

M.insert_cur_time = function()
  local mode = vim.fn.mode()
  local text = vim.fn.strftime '%Y-%m-%d %H:%M:%S'
  vim.api.nvim_put({ text }, 'c', mode == 'n', true)
end

M.open_external_term = function()
  local path = vim.fn.getcwd()
  vim.fn.jobstart('kitty --directory ' .. path, { detach = true })
end

M.toggle_wrap = function()
  if vim.wo.wrap == false then
    vim.wo.wrap = true
  else
    vim.wo.wrap = false
  end
end

M.get_buffer_info = function(buffer)
  local info
  local list = vim.fn.getbufinfo()
  for _, v in pairs(list) do
    if v.bufnr == buffer then
      info = v
      break
    end
  end
  return info
end

M.is_buffer_changed = function(buffer)
  local info = M.get_buffer_info(buffer)
  if info == nil or info.changed == 0 then
    return false
  end
  return true
end

M.test = function()
  vim.cmd '!kitty'
  -- vim.api.nvim_command 'terminal htop'
  -- vim.print(vim.inspect(require('custom.youtube.block').get_block()))
end

M.setTimeout = function(fn, time)
  local timer = vim.loop.new_timer()
  local closed = false

  -- 启动定时器
  timer:start(time, 0, function()
    fn()
    timer:stop()
    timer:close()
    closed = true
  end)

  return function()
    if closed then
      return
    end
    timer:stop()
    timer:close()
    closed = true
  end
end

M.toggle_qf = function()
  local windows = vim.fn.getwininfo()
  local qf_exists = false
  for _, win in pairs(windows) do
    if win.quickfix == 1 then
      qf_exists = true
      break
    end
  end

  -- 如果已打开则关闭，否则打开
  if qf_exists then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end

M.bind = function(fn, ...)
  local bound_args = { ... }
  return function(...)
    local args = { ... }
    return fn(tb.unpack(bound_args), tb.unpack(args))
  end
end


return M
