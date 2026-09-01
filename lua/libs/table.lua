local M = {}

M.extend = function(base, extra)
  local t = {}
  for k, v in pairs(base) do t[k] = v end
  for k, v in pairs(extra) do t[k] = v end
  return t
end

M.len = function(ta)
  local count = 0
  for _ in pairs(ta) do
    count = count + 1
  end
  return count
end

M.unpack = function(...)
  ---@diagnostic disable-next-line: deprecated
  unpack = table.unpack or unpack
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

M.duplicate = function(tab)
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

M.mergeArrays = function(...)
  local result = {}
  for _, arr in ipairs({ ... }) do
    for i, v in ipairs(arr) do
      table.insert(result, v)
    end
  end
  return result
end

M.filter = function(arr, fn)
  local result = {}
  for _, item in ipairs(arr) do
    if fn(item) then
      table.insert(result, item)
    end
  end
  return result
end

M.clear_after = function(arr, idx)
  local result = {}
  local endIdx = math.min(idx, #arr)
  for i = 0, endIdx do
    table.insert(result, arr[i])
  end
  return result
end


M.remove_by_value = function(arr, value)
  local remove = false
  for i = #arr, 1, -1 do
    if arr[i] == value then
      table.remove(arr, i)
      remove = true
    end
  end
  return remove
end

return M
