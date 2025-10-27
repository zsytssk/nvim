local M = {}

M.len = function(ta)
  local count = 0
  for _ in pairs(ta) do
    count = count + 1
  end
  return count
end

M.unpack = function(...)
  if table.unpack ~= nil then
    return table.unpack(...)
  end
  ---@diagnostic disable-next-line: deprecated
  return unpack(...)
end

M.findIndex = function(t, item)
  for index, value in ipairs(t) do
    if value == item then
      return index
    end
  end
  return nil
end

M.dulplicate = function(tab)
  local t2 = {}
  local len = M.len(tab)
  for k, v in pairs(tab) do
    t2[k] = v
    t2[len + k] = v
  end
  return t2
end
return M
