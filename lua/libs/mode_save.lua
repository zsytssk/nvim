local libs = require 'libs'

function Mode(name, mappings)
  local name_fn = type(name) == 'string' and function() return name end or name
  local off_fns = {}
  local lualine = require('lualine')
  local is_run = false
  local is_bind = false

  function bind_lualine()
    local config = lualine.get_config()
    table.insert(config.sections.lualine_a, { function()
      if is_run then
        return name_fn()
      else
        return ''
      end
    end })
    lualine.setup(config)
  end

  local function bind_map()
    local local_off_fns = {}
    for key, map in pairs(mappings) do
      local is_bind_buf = type(map[2]) == 'table' and map[2].buffer ~= nil
      local cur_buffer = vim.api.nvim_get_current_buf()
      local ori_map
      if is_bind_buf then
        ori_map = libs.get_map_buf(cur_buffer, 'n', key)
        libs.map('n', key, map[1], map[2])
      else
        ori_map = libs.get_map('n', key)
        libs.map('n', key, map[1], { desc = map[2] })
      end
      table.insert(local_off_fns, function()
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
    off_fns = local_off_fns
  end

  local function off_map()
    for _, item in ipairs(off_fns) do
      pcall(item)
    end
  end

  local function update_status()
    lualine.refresh()
  end

  local function enter()
    is_run = true

    if not is_bind then
      bind_lualine()
      is_bind = true
    end

    update_status()
    bind_map()
  end

  local function exit()
    is_run = false
    update_status()
    off_map()
  end


  return {
    is_run = function()
      return is_run
    end,
    update_status = update_status,
    enter = enter,
    exit = exit,
  }
end

return Mode
