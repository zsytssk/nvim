local libs = require 'libs'



-- 使用

local test = function()
  -- function cleanBackticks(s)
  --   s = s:gsub("%[.-%]", "")
  --   return s:gsub("`([^`]-)`", function(inner)
  --     -- 如果内部有 |，只取第一个 | 之前的部分
  --     local chosen = inner:match("^([^|]+)") or inner
  --     -- 去掉开头的非字母/数字符号（如 !、@、# 等）
  --     chosen = chosen:gsub("^[^%w]+", "")
  --     return chosen
  --   end)
  -- end

  -- local str =
  -- "I `!broadly` couldn’t tell you what Indonesia music sounds like or Indonesia film looks like.[generally, without considering details^broad=wide]"
  -- local str2 = "and it comes with `a|the` few `!caveats|caviets`.(89.84-91.55)"
  -- print(cleanBackticks(str))
  -- print(cleanBackticks(str2))
  require('custom.jump_list').debug()
end


libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
