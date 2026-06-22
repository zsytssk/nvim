local libs = require 'libs'

local test = function()
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
