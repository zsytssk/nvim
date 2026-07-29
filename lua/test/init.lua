local libs = require 'libs'
local block = require("custom.youtube.block")

local function is_cursor_in_match(pattern)
  -- 'c' 标志：接受当前位置的匹配
  -- 'n' 标志：不移动光标
  local pos = vim.fn.searchpos(pattern, 'bcn')
  print(vim.inspect({ pos = pos }))
  return pos[1] ~= 0
end

-- 在 init.lua 中
local jump_to_match_center = function(direction)
  local pattern = vim.fn.getreg('/')
  if pattern == '' then return vim.notify('no match', vim.log.levels.WARN) end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local next_start = vim.fn.searchpos(pattern, 'n')
  local next_end = vim.fn.searchpos(pattern, 'ne')
  local prev_start = vim.fn.searchpos(pattern, 'bn')
  local prev_end = vim.fn.searchpos(pattern, 'bne')
  print(vim.inspect({ next_start = next_start, next_end = next_end, prev_start = prev_start, prev_end = prev_end, }))


  -- if pos[1] == 0 then return end
  -- -- 找到匹配后，跳到中心
  -- local sx, sy = pos[1], pos[2]
  -- vim.api.nvim_win_set_cursor(0, { sx, sy })
  -- vim.cmd('nohlsearch | set hlsearch')
end



-- 使用

local test = function()
  flag = not flag
  if not flag then
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    return
  end

  local info = block.get_block()
  for key, item in pairs(info) do
    local line_num = tonumber(key) - 1
    local start_p = 100
    local end_p = 102
    local text = vim.api.nvim_buf_get_text(0, line_num, start_p - 1, line_num, end_p, {})[1]
    local display_width = vim.api.nvim_strwidth(text)
    local display_text = string.rep('*', display_width)

    print(vim.inspect({ text = text }))
    vim.api.nvim_buf_set_extmark(0, ns_id, line_num, start_p - 1, {
      virt_text = { { display_text, "Comment" } },
      virt_text_pos = "overlay",
      virt_text_repeat_linebreak = true
    })
  end
end


libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
