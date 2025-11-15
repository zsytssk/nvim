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

-- 数组有交集
M.hasIntersection = function(a, b)
  if a == nil or b == nil then
    return false
  end

  local map = {}

  -- 把 a 的元素放入 map
  for _, v in ipairs(a) do
    map[v] = true
  end

  -- 查看 b 中是否有相同元素
  for _, v in ipairs(b) do
    if map[v] then
      return true -- 找到相同元素，返回 true 和该元素
    end
  end

  return false
end
return M
