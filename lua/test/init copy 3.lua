local libs = require 'libs'
local block = require("custom.youtube.block")

local function get_text_area_width()
  local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
  return win_info.width - win_info.textoff
end

local function get_line_wrap_idx(bufnr, line_num)
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)
  local text = lines[1] or ""
  local win_width = get_text_area_width()
  local list = {}
  local text_width = vim.api.nvim_strwidth(text)

  if win_width <= 0 or text_width < win_width then
    return list
  end

  -- 使用 vim.fn 的字符串处理函数
  local total_chars = vim.fn.strchars(text)
  local line_start = 0
  local width = 0;
  for char_pos = 1, total_chars do
    -- 获取前 char_pos 个字符
    local sub_text = vim.fn.strcharpart(text, line_start, char_pos)
    local local_width = vim.api.nvim_strwidth(sub_text)

    if local_width > win_width then
      local prev_pos = vim.str_byteindex(text, char_pos - 1)
      if width < win_width then
        prev_pos = prev_pos + win_width - width
      end
      print(vim.inspect({ width = width, win_width = win_width, prev_pos = prev_pos }))
      table.insert(list, prev_pos)

      line_start = char_pos
      local remaining = vim.fn.strcharpart(text, char_pos)
      local remaining_width = vim.api.nvim_strwidth(remaining)
      if remaining_width <= win_width then
        break
      end
    end
    width = local_width
  end

  return list
end

local function split_interval_by_end(start_num, end_num, split_points)
  local result = {}
  local points = {}

  -- 收集所有有效的分割点（作为区间的结束）
  for _, v in ipairs(split_points) do
    if v >= start_num and v < end_num then
      table.insert(points, v)
    end
  end

  table.sort(points)

  -- 去重
  local unique = {}
  local last = nil
  for _, v in ipairs(points) do
    if last == nil or v ~= last then
      table.insert(unique, v)
      last = v
    end
  end
  points = unique

  -- 构建区间对
  local current = start_num
  for _, point in ipairs(points) do
    if current <= point then
      table.insert(result, { current, point })
      current = point + 1
    end
  end

  -- 添加最后一个区间
  if current <= end_num then
    table.insert(result, { current, end_num })
  end

  return result
end

-- 等0.13更新
local function set_multiline_virt_text2(bufnr, ns_id, line_num, s_idx, e_idx)
  local line_breaks_idx = get_line_wrap_idx(bufnr, line_num)
  local split_list = split_interval_by_end(s_idx, e_idx, line_breaks_idx)
  print(vim.inspect({ line_breaks_idx = line_breaks_idx, list = split_list }))
  for _, item in ipairs(split_list) do
    local text = vim.api.nvim_buf_get_text(bufnr, line_num, item[1] - 1, line_num, item[2], {})[1]
    local display_width = vim.api.nvim_strwidth(text)
    local display_text = string.rep('*', display_width)
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, item[1] - 1, {
      virt_text = { { display_text, "Normal" } },
      virt_text_pos = "overlay",
      virt_text_win_col = nil,
    })
  end
end


local flag = false
local ns_id = vim.api.nvim_create_namespace("test")
local test = function()
  flag = not flag
  local info = block.get_block()
  if not flag then
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    return
  end
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
