---@diagnostic disable: missing-fields
---@class LinkItem
---@field content string
---@field link string
---@field type "link"
---@field group integer

---@class SentenceItem
---@field content string
---@field type "sentence"
---@field time integer[]          -- 时间范围，可能只有一个元素
---@field group integer
---@field isImp boolean
---@field link string
---@field matchKeys integer[]|nil

---@alias BlockItem LinkItem|SentenceItem
---@alias Block table<integer, BlockItem>

---@type { hasIntersection: fun(t: table, other: table): boolean }
local tb = require("libs.table")

local M = {}

---@param url string
---@return boolean
local function is_match_url(url)
	local pattern = "https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+"
	local match = string.match(url, pattern)
	return match ~= nil
end

---@param sentence string
---@return boolean
local function is_match_imp(sentence)
	if string.match(sentence, "^%* ") then
		return true
	end
	return false
end

---@param block table<any, any>
---@return integer ?first
---@return integer ?last
local function get_block_range(block)
	local keys = {}
	for k, _ in pairs(block) do
		table.insert(keys, k)
	end
	table.sort(keys)

	if #keys == 0 then
		return 0, 0
	end

	local first = keys[1]
	local last  = keys[#keys]

	return tonumber(first), tonumber(last)
end

---@param time1 integer[]
---@param time2 integer[]
---@return boolean
local function is_time_overlap(time1, time2)
	if #time1 < 2 or #time2 < 2 then
		return false
	end
	local dist1 = math.max(time2[2], time1[2]) - math.min(time2[1], time1[1])
	local dist2 = time1[2] - time1[1] + time2[2] - time2[1]
	return dist1 < dist2
end

---@param line_str string
---@return integer[]
local function get_content_seconds(line_str)
	local time_str = string.match(line_str, "%((.-)%)")
	if time_str == nil then
		return {}
	end
	local start_time, end_time = string.match(time_str, "([^-)]+)-([^-)]+)")
	start_time = start_time or tonumber(time_str)
	return { tonumber(start_time), tonumber(end_time) }
end

---@param line_num integer
---@param line_info SentenceItem
---@param block Block
---@return integer[]|nil
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

---@return table<integer, string>
function M.get_raw_block()
	local strMap = {}
	local total_lines = vim.api.nvim_buf_line_count(0)
	local current_line = vim.fn.line(".")

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

	for line = current_line, total_lines + 1 do
		local content = vim.fn.getline(line)
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

---@return Block
function M.get_block()
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
		if is_match_url(value) then
			group = group + 1
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
			isImp = is_match_imp(value)
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

---@param line_num integer
---@return {line: integer, item: BlockItem}[]|nil
function M.get_group(line_num)
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

---@param line_info SentenceItem
---@param block Block
---@return integer[]|nil
function M.get_match_items(line_info, block)
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

---@param block Block
---@param line integer|nil
---@return string|nil
function M.get_link(block, line)
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
end

function M.find_imp(tbl, startKey, direction)
	direction = direction or "next" -- 补上默认值

	-- 收集所有 imp 键
	local imp_keys = {}
	for k, v in pairs(tbl) do
		if v and v.isImp then
			table.insert(imp_keys, k)
		end
	end
	if #imp_keys == 0 then return nil end

	table.sort(imp_keys)

	if direction == "next" then
		for _, k in ipairs(imp_keys) do
			if k > startKey then
				return k, tbl[k]
			end
		end
		-- 没找到更大的，返回最小的（循环回来）
		local k = imp_keys[1]
		return k, tbl[k]
	elseif direction == "prev" then
		for i = #imp_keys, 1, -1 do
			local k = imp_keys[i]
			if k < startKey then
				return k, tbl[k]
			end
		end
		-- 没找到更小的，返回最大的（循环回来）
		local k = imp_keys[#imp_keys]
		return k, tbl[k]
	end

	return nil
end

return M
