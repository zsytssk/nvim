local M = {}



M.unpack = function(...)
  if table.unpack ~= nil then
    return table.unpack(...)
  end
  ---@diagnostic disable-next-line: deprecated
  return unpack(...)
end

M.split_str = function(str, sep)
  local sep, fields = sep or ':', {}
  local pattern = string.format('([^%s]+)', sep)
  str:gsub(pattern, function(c)
    fields[#fields + 1] = c
  end)
  return fields
end

M.split_str_to_char = function(str, sep)
  local fields = { str:match((str:gsub('.', '(.)'))) }
  return fields
end

--- remove and return the right-hand side of a `keymap`.
--- @param keymap table the keymap to unpack
--- @return string lhs, fun()|string rhs, table options
M.unpack_map_lhs = function(keymap)
  local lhs = keymap.lhs
  local rhs = keymap.rhs
  keymap.lhs = nil
  keymap.rhs = nil

  return lhs, rhs, keymap
end

M.unpack_buf_map_lhs = function(keymap)
  local buffer = keymap.buffer
  local lhs = keymap.lhs
  local rhs = keymap.rhs or ''
  local opts = {
    noremap = keymap.noremap,
    silent = keymap.silent,
    nowait = keymap.nowait,
    desc = keymap.desc,
    callback = keymap.callback,
  }
  return buffer, lhs, rhs, opts
end

--- remove and return the right-hand side of a `keymap`.
--- @param lhs string the keymap find
--- @return nil | table
M.get_map = function(mode, lhs)
  local mappings = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(mappings) do
    if map.lhs == lhs then
      return map
    end
  end
end

M.get_map_buf = function(buffer, mode, lhs)
  local mappings = vim.api.nvim_buf_get_keymap(buffer, mode)
  for _, map in ipairs(mappings) do
    if map.lhs == lhs then
      return map
    end
  end
end

M.map = function(mode, ...)
  local modeList = M.split_str_to_char(mode)
  for _, value in ipairs(modeList) do
    vim.keymap.set(value, ...)
  end
end
M.map_buf = function(buffer, mode, ...)
  local modeList = M.split_str_to_char(mode)
  for _, value in ipairs(modeList) do
    vim.api.nvim_buf_set_keymap(buffer, value, ...)
  end
end

M.unmap = function(mode, key)
  local modeList = M.split_str_to_char(mode)
  for _, value in ipairs(modeList) do
    vim.api.nvim_del_keymap(value, key)
  end
end

M.unmap_buf = function(buffer, mode, key)
  local modeList = M.split_str_to_char(mode)
  for _, value in ipairs(modeList) do
    vim.api.nvim_buf_del_keymap(buffer, value, key)
  end
end

M.keymapTable = function(mode)
  return function(table)
    for key, value in pairs(table) do
      local params = {
        key,
        value[1],
        {
          desc = value[2],
        },
      }
      M.map(mode, M.unpack(params))
    end
  end
end

return M
