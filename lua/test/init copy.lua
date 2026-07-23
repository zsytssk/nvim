local libs = require 'libs'
local block = require("custom.youtube.block")

local function get_text_area_width()
  local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
  return win_info.width - win_info.textoff
end

local function set_multiline_virt_text2(bufnr, ns_id, line_num, s_idx, e_idx)
  local win_width = get_text_area_width()

  -- 2. 计算显示宽度（使用推荐的 Lua API）
  local width = vim.api.nvim_strwidth(sub_text)

  local end_pos = start_pos + #text
  local start_col = 0
  -- 计算需要多少行来显示
  local display_lines = math.ceil(line_width / win_width)
  for i = 0, display_lines - 1 do
    local next_start = start_col + win_width

    if start_pos > next_start then
      start_col = next_start
      goto continue
    end
    if start_col > end_pos then
      break
    end

    local start_index = math.max(start_pos, start_col)
    local end_index = math.min(start_col + win_width, end_pos)
    local display_text = string.rep('*', end_index - start_index)

    local text = vim.api.nvim_buf_get_text(bufnr, line_num, start_index, line_num, end_index, {})
    print(text[1])
    -- print(start_index, display_text)

    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, start_index, {
      virt_text = { { display_text, "Normal" } },
      virt_text_pos = "overlay",
      virt_text_win_col = nil,
    })
    start_col = next_start

    ::continue::
  end
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
