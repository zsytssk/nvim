local libs = require 'libs'

local test = function()
  local str = "[legal|leagal] [repercussions|repocations] for the bad actors."
local result = str:gsub("%[([^|]+)|[^%]]+%]", "%1")
print(result)
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
