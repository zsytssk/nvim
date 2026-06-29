local libs = require 'libs'

local test = function()
  local str = "do you see [?acting] precident statements."
local result = str:gsub("%[([^%]]*)%]", function(content)
    -- 检查是否包含 |
    if content:find("|") then
      return content:match("([^|]+)|.*")  -- 取 | 前面的部分
    else
      return content  -- 没有 | 就返回内容（去掉括号）
    end
  end)
print(result)
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
