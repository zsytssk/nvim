local libs = require 'libs'

--- @class Mode
--- @field is_run boolean 是否启动
--- @field name_fn function
--- @field mappings table 保存的keyMap
--- @field off_fns table exit时候重置快捷键
local Mode = {}

--- @param name string|fun():string
--- @param mappings table
--- @return Mode
function Mode:new(name, mappings)
  local obj = {}
  setmetatable(obj, self)
  self.__index = self

  if type(name) == 'string' then
    obj.name_fn = function()
      return name
    end
  elseif type(name) == 'function' then
    obj.name_fn = name
  end

  obj.mappings = mappings
  return obj
end

--- @param is_run boolean
function Mode:set_status(is_run)
  local config = require('lualine').get_config()

  if is_run then
    table.insert(config.sections.lualine_a, { self.name_fn })
  else
    local remove_index = 0
    for i, comp in ipairs(config.sections.lualine_a) do
      if #comp >= 0 and comp[1] == self.name_fn then
        remove_index = i
        break
      end
    end
    table.remove(config.sections.lualine_a, remove_index)
  end
  require('lualine').setup(config)
end

function Mode:update_status()
  local config = require('lualine').get_config()
  require('lualine').setup(config)
end

function Mode:bind_map()
  local mappings = self.mappings
  local off_fns = {}
  for key, map in pairs(mappings) do
    local ori_map = libs.get_map('n', key)
    local is_bind_buf = type(map[2]) == 'table' and map[2].buffer ~= nil
    local cur_buffer = vim.api.nvim_get_current_buf()
    if is_bind_buf then
      ori_map = libs.get_map_buf(cur_buffer, 'n', key)
      libs.map('n', key, map[1], map[2])
    else
      libs.map('n', key, map[1], { desc = map[2] })
    end
    table.insert(off_fns, function()
      if is_bind_buf then
        libs.unmap_buf(cur_buffer, 'n', key)
      else
        libs.unmap('n', key)
      end

      if ori_map ~= nil then
        if is_bind_buf then
          local buffer, lhs, rhs, keymap = libs.unpack_buf_map_lhs(ori_map)
          libs.map_buf(buffer, 'n', lhs, rhs, keymap)
        else
          local lhs, rhs, keymap = libs.unpack_map_lhs(ori_map)
          libs.map('n', lhs, rhs, keymap)
        end
      end
    end)
  end
  self.off_fns = off_fns
end

function Mode:off_map()
  for _, item in ipairs(self.off_fns) do
    pcall(item)
  end
end

function Mode:enter()
  self:set_status(true)
  self:bind_map()
  self.is_run = true
end

function Mode:exit()
  self:set_status(false)
  self:off_map()
  self.is_run = false
end

return Mode
