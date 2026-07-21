local libs = require 'libs'

local test = function()
  local str = "你好[中文]字[符串]的而"
  local start = 1;
  for start_pos, _, end_pos in str:gmatch("()%[(.-)%]()") do
    print(string.sub(str, start, start_pos - 1))
    print(string.sub(str, start_pos, end_pos - 1))
    start = end_pos
  end
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
