local libs = require 'libs'

local test = function()
  local str = "123[456]789"
  for start_pos, _, end_pos in str:gmatch("()%[(.-)%]()") do
    print(start_pos, end_pos, string.sub(str, start_pos, end_pos - 1))
  end
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
