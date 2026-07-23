local libs = require 'libs'
local block = require("custom.youtube.block")

local function get_text_area_width()
  local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
  return win_info.width - win_info.textoff
end

-- 等0.13更新
local function set_multiline_virt_text2(bufnr, ns_id, line_num, s_idx, e_idx)
  local text = vim.api.nvim_buf_get_text(bufnr, line_num, s_idx - 1, line_num, e_idx, {})[1]
  local display_width = vim.api.nvim_strwidth(text)
  local display_text = string.rep('*', display_width)
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, s_idx - 1, {
    virt_text = { { display_text, "Normal" } },
    virt_text_pos = "overlay",
    virt_text_win_col = nil,
    virt_lines_overflow = 'wrap',
  })
end

local flag = false
local ns_id = vim.api.nvim_create_namespace("test")
local test = function()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  flag = not flag
  local info = block.get_block()
  for key, item in pairs(info) do
    if item.type ~= 'sentence' then goto continue end

    local content = item.content
    local row = tonumber(key) - 1
    local ranges = {}
    local start = content:match("^[A-Za-z%[]") and 1 or 3

    for s, _, e in content:gmatch("()%[(.-)%]()") do
      if flag then
        s = s + 1
        e = e - 1
        table.insert(ranges, { s, e - 1 })
      else
        s = s - 1
        table.insert(ranges, { start, s })
        start = e
      end
    end
    if not flag and start <= #content then
      table.insert(ranges, { start, #content })
    end

    for _, r in ipairs(ranges) do
      set_multiline_virt_text2(0, ns_id, row, r[1], r[2])
    end

    ::continue::
  end
end

libs.keymapTable 'in' {
  ['<A-S-t>'] = { test, 'test' },
}
