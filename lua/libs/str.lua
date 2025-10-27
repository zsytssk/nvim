local M = {}

M.start_with = function(str, start)
  return str:sub(1, #start) == start
end

return M
