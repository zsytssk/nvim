local tb = require("libs.table")

local M = {}

local function is_match_url(url)
	local pattern = "https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+"

	local match = string.match(url, pattern)
	return match ~= nil
end

local function get_block_range(block)
	local keys = {}
	for k, _ in pairs(block) do
		table.insert(keys, k)
	end
	table.sort(keys)

	local first = keys[1]
	local last  = keys[#keys]

	return tonumber(first), tonumber(last)
end

local function is_time_overlap(time1, time2)
	if #time1 < 2 or #time2 < 2 then
		return false
	end
	local dist1 = math.max(time2[2], time1[2]) - math.min(time2[1], time1[1])
	local dist2 = time1[2] - time1[1] + time2[2] - time2[1]
	return dist1 < dist2
end

local function get_content_seconds(line_str)
	local time_str = string.match(line_str, "%((.-)%)")
	if time_str == nil then
		return {}
	end
	-- local start_time, end_time = string.match(time_str, "(%d+)-(%d+)")
	local start_time, end_time = string.match(time_str, "([^-)]+)-([^-)]+)")
	start_time = start_time or tonumber(time_str)
	return { tonumber(start_time), tonumber(end_time) }
end

local function find_match(line_num, line_info, block)
	local cur_time = line_info.time
	if line_info.type == 'link' or cur_time == nil then
		return nil
	end
	local findKeys = {}
	for key, item in pairs(block) do
		if key == line_num or item.time == nil or item.link ~= line_info.link then
			goto continue
		end

		if is_time_overlap(cur_time, item.time) then
			table.insert(findKeys, key)
		end

		::continue::
	end

	return findKeys
end

M.get_raw_block = function()
	local strMap = {}
	local total_lines = vim.api.nvim_buf_line_count(0) -- 获取当前 buffer 的总行数
	local current_line = vim.fn.line(".")           -- 获取当前光标所在行


	-- 向上查找目标行（以 "##" 开头或者文件开头）
	for line = current_line, 1, -1 do
		local content = vim.fn.getline(line)
		if vim.startswith(content, "##") or line == 0 then
			break
		else
			if content ~= "" then
				strMap[line] = content
			end
		end
	end

	-- 向下查找目标行（以 "##" 开头或者文件结尾）
	for line = current_line, total_lines + 1 do
		local content = vim.fn.getline(line) -- 获取该行内容
		if vim.startswith(content, "##") or line == total_lines + 1 then
			break
		else
			if content ~= "" then
				strMap[line] = content
			end
		end
	end

	return strMap
end

M.get_block = function()
	local strMap = M.get_raw_block()
	local block = {}
	local group = 0

	local cur_link = ''
	local start_key, end_key = get_block_range(strMap)


	for key = start_key, end_key do
		local value = strMap[key]
		if value == nil then
			goto continue
		end
		if value == "---" then
			group = group + 1
			goto continue
		end
		if is_match_url(value) then
			block[key] = { content = value, link = value, type = 'link', group = group }
			cur_link = value
			goto continue
		end

		block[key] = {
			content = string.gsub(value, "%(.-%)$", ""),
			type = "sentence",
			time = get_content_seconds(value),
			group = group,
			link = cur_link,
		}
		::continue::
	end

	for key, item in pairs(block) do
		if item.type == "sentence" then
			local matchKeys = find_match(key, item, block)
			if matchKeys ~= nil and #matchKeys > 0 then
				table.insert(matchKeys, key)
				table.sort(matchKeys, function(a, b)
					return a < b
				end)
				item.matchKeys = matchKeys
			end
		end
	end

	return block
end

M.get_group = function(line_num)
	local block = M.get_block()
	local line_info = block[line_num]
	if line_info.type ~= 'sentence' then
		return
	end
	local list = {}
	for line, item in pairs(block) do
		if item.group == line_info.group then
			table.insert(list, { line = tonumber(line), item = item })
		end
	end

	table.sort(list, function(a, b)
		return a.line < b.line
	end)

	return list
end

M.get_match_items = function(line_info, block)
	if line_info.type ~= 'sentence' then
		return
	end

	local list = {}
	for line, item in pairs(block) do
		if tb.hasIntersection(item.matchKeys, line_info.matchKeys) then
			table.insert(list, line)
		end
	end

	table.sort(list, function(a, b)
		return a < b
	end)

	return list
end

M.get_link = function(block, line)
	if line == nil then
		line = vim.fn.line(".")
	end
	if (block[line] ~= nil and block[line].link ~= nil) then
		return block[line].link
	end

	local start_key, end_key = get_block_range(block)
	for key = end_key, start_key, -1 do
		local item = block[key]
		if key > line or item == nil then
			goto continue
		end

		if item.type == 'link' then
			return item.content
		end

		::continue::
	end

	return nil
	-- for _, item in pairs(block) do
	-- 	if item.type == "link" then
	-- 		return item.content
	-- 	end
	-- end
end

return M
