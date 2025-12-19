-- 在english.md中控制youtube视频播放
-- nvim/lua -> curl -> trans -> tampermonkey -> youtube
local block = require("custom.youtube.block")
local utils = require("custom.utils")
local Mode = require("libs.mode")
local tb = require("libs.table")
local set_multiline_virt_text = require("libs.vim").set_multiline_virt_text
local set_multiline_virt_text2 = require("libs.vim").set_multiline_virt_text2
local OriModeName = "YT"
local modeName = "YT"
-- @type Mode
local mode
local timeout
local showStatus = function(status)
	if timeout ~= nil then
		timeout()
	end
	timeout = utils.setTimeout(function()
		modeName = OriModeName
	end, 1000)
	modeName = OriModeName .. ":" .. status .. ' '
	mode.update_status()
end

local emit_event = function(action, link, info, callback)
	if info == nil then
		info = {}
	end

	local allInfo = vim.tbl_extend("force", {
		type = "youtube",
		link = link,
		action = action,
	}, info)

	local json = vim.fn.json_encode(allInfo)
	vim.system(
		{
			"curl", "-s", "-X", "POST",
			"-d", json,
			"http://127.0.0.1:60829/send"
		},
		{},
		function(obj)
			if callback ~= nil then
				vim.schedule(function()
					callback(pcall(vim.fn.json_decode, obj.stdout))
				end)
			end
		end
	)
end

local get_current_state = function(callback)
	local link = block.get_link(block.get_block())
	emit_event("get_current_state", link, nil, function(ok, decoded)
		if not ok then
			return
		end
		callback(string.format("%.2f", decoded.currentTime))
	end)
end

local video_loop = function()
	showStatus("️▶️")
	local current_line = vim.fn.line(".")
	local info = block.get_block()
	local link = block.get_link(info)
	local time_scope = info[current_line].time
	if time_scope == nil or #time_scope < 1 then
		return
	end

	if #time_scope == 1 then
		emit_event("jump", link, { time = time_scope })
		return
	end
	emit_event("loop", link, { time = time_scope })
end

local video_list_loop = function(type)
	showStatus("️▶️")
	local count = vim.v.count
	if count == 0 then
		count = 3
	end
	local current_line = vim.fn.line(".")
	local info = block.get_block()
	local list = block.get_group(current_line)
	if list == nil then
		return
	end
	local link = block.get_link(info)
	local time_list = {}
	local cur_index = 0
	for index, item in ipairs(list) do
		local itemInfo = item.item
		local line = item.line
		local time = itemInfo.time
		if type == 'current' and line == current_line then
			cur_index = index - 1
		end
		table.insert(time_list, time)
	end

	emit_event("list_loop", link, { count = count, cur_index = cur_index, time_list = time_list })
end

local toggle_subtitle = function()
	showStatus("💬")
	local link = block.get_link(block.get_block())
	emit_event("toggle_subtitle", link)
end

local reduce_speed = function()
	local link = block.get_link(block.get_block())
	emit_event("reduce_speed", link, nil, function(ok, decoded)
		if ok then
			showStatus("⏪  " .. decoded.playbackRate)
		else
			showStatus("⏪  --")
		end
	end)
end

local plus_speed = function()
	showStatus("⏩")
	local link = block.get_link(block.get_block())
	emit_event("plus_speed", link, nil, function(ok, decoded)
		if ok then
			showStatus("⏩  " .. decoded.playbackRate)
		else
			showStatus("⏩  --")
		end
	end)
end

local play_back = function()
	showStatus("⏮")
	local link = block.get_link(block.get_block())
	emit_event("play_back", link)
end

local play_forward = function()
	showStatus("⏭ ")
	local link = block.get_link(block.get_block())
	emit_event("play_forward", link)
end

local toggle_pause = function()
	showStatus("⏸")
	local link = block.get_link(block.get_block())
	emit_event("toggle_pause", link)
end

local copy_sentence = function()
	showStatus("️📋")
	local info = block.get_block()
	local line_num = vim.fn.line(".")
	local line_info = info[line_num]
	if line_info ~= nil and line_info.content then
		vim.fn.setreg("+", "如何理解: " .. line_info.content)
	end
end

local copy_url = function()
	showStatus("️📋")
	emit_event("copy_url", '', nil, function(ok, decoded)
		if ok then
			vim.api.nvim_put({ decoded.url }, 'c', true, true)
		end
	end)
end

local update_line_time = function(line_num, line_info)
	local pre_line = line_num - 1 -- Lua 索引从 0 开始
	local line_content = vim.api.nvim_buf_get_lines(0, pre_line, pre_line + 1, false)[1]
	local time_text = line_info.content or ""
	if #line_info.time == 1 then
		time_text = "(" .. string.format("%.2f", line_info.time[1]) .. ")"
	elseif #line_info.time == 2 then
		time_text = "(" ..
			string.format("%.2f", line_info.time[1]) .. "-" .. string.format("%.2f", line_info.time[2]) .. ")"
	end
	-- 在行尾插入文本
	vim.api.nvim_buf_set_text(0, pre_line, #line_info.content, pre_line, #line_content, { time_text })
end

local paste_time = function()
	showStatus("️📋")
	get_current_state(function(cur_time)
		if cur_time == nil then
			return
		end
		local info = block.get_block()
		local line_num = vim.fn.line(".")
		local line_info = info[line_num] or { type = "sentence", content = "", time = {} }
		line_info.time[1] = cur_time
		update_line_time(line_num, line_info)
	end)
end

local paste_end_time = function()
	showStatus("️📋")
	get_current_state(function(cur_time)
		if cur_time == nil then
			return
		end
		local info = block.get_block()
		local line_num = vim.fn.line(".")
		local line_info = info[line_num]
		if line_info == nil then
			return
		end
		line_info.time[2] = cur_time
		update_line_time(line_num, line_info)
	end)
end

local sentence_jump = function()
	showStatus("️🔄")
	local info = block.get_block()
	local line_num = vim.fn.line(".")
	local line_info = info[line_num]
	if line_info.matchKeys == nil then
		return
	end
	local match_items = block.get_match_items(line_info, info)
	if match_items == nil then
		return
	end
	local cur_index = tb.findIndex(match_items, line_num)
	local target_index = cur_index + 1
	if target_index > #match_items then
		target_index = 1
	end
	local target = match_items[target_index]
	vim.api.nvim_win_set_cursor(0, { target, 0 })
end

local switch_time = function(pos, action)
	showStatus("️🕒")
	local info = block.get_block()
	local line_num = vim.fn.line(".")
	local line_info = info[line_num]
	-- print(vim.inspect(line_info))
	if pos == "start" then
		if action == 1 then
			line_info.time[1] = line_info.time[1] + 0.1
		else
			line_info.time[1] = line_info.time[1] - 0.1
		end
	else
		if action == 1 then
			line_info.time[2] = line_info.time[2] + 0.1
		else
			line_info.time[2] = line_info.time[2] - 0.1
		end
	end

	update_line_time(line_num, line_info)
end

local ns_id = vim.api.nvim_create_namespace("english_hide_words")
local flag = false
local toggle_hide_words = function()
	if flag then
		vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
		flag = false
		return
	end
	local info = block.get_block()
	for key, item in pairs(info) do
		if item.type ~= 'sentence' then
			goto continue
		end

		-- local line = string.rep("*", #item.content)
		-- set_multiline_virt_text(0, ns_id, tonumber(key) - 1, line, "Normal")

		local arr = {}
		local start = 0;
		for start_pos, _, end_pos in item.content:gmatch("()%[(.-)%]()") do
			table.insert(arr, { start_pos = start, end_pos = start_pos - 1, replace = true })
			table.insert(arr, { start_pos = start_pos - 1, end_pos = end_pos - 1, replace = false })
			start = end_pos - 1
		end
		table.insert(arr, { start_pos = start, end_pos = #item.content, replace = true })

		for i, item in ipairs(arr) do
			if item.replace == false then
				goto continue
			end
			local line = string.rep("*", item.end_pos - item.start_pos)
			set_multiline_virt_text2(0, ns_id, tonumber(key) - 1, line, "Normal", item.start_pos)
			::continue::
		end
		::continue::
	end
	flag = true
end

local copy_imp_words = function()
	showStatus("️📋")
	local current_line = vim.fn.line(".")
	local list = block.get_group(current_line)
	if list == nil then
		return
	end
	local arr = {}
	for _, line in ipairs(list) do
		local item = line.item
		if item.type ~= 'sentence' then
			goto continue
		end

		local line_words = {}
		for _1, content, _2 in item.content:gmatch("()%[(.-)%]()") do
			table.insert(line_words, content)
		end
		if #line_words == 0 then
			goto continue
		end
		table.insert(arr, table.concat(line_words, ' '))
		::continue::
	end
	local str = table.concat(arr, '\n')
	vim.fn.setreg("+", str)
end


local test = function()
	print("hello")
end

local M = {}

local mappings = {
	["<M-j>"] = { video_loop, "video loop" },
	-- ["<C-M-j>"] = { video_jump, "video jump" },
	["<M-t>"] = { toggle_hide_words, "toggle hide words" },
	-- ["<C-M-t>"] = { test, "youtube test" },
	["<C-M-j>"] = { function()
		video_list_loop('start')
	end, "video list loop" },
	["<C-S-M-k>"] = {
		function()
			video_list_loop('current')
		end,
		"video list loop from",
	},
	["<M-k>"] = { sentence_jump, "sentence jump" },
	["<M-Space>"] = { toggle_pause, { buffer = true, desc = "(un)pause" } },
	-- ['K'] = { toggle_pause, { buffer = true, desc = '(un)pause' } },
	["C"] = { toggle_subtitle, "(un)subtitle" },
	["<"] = { reduce_speed, "reduce speed" },
	[">"] = { plus_speed, "plus speed" },
	["J"] = { play_back, "play back" },
	["L"] = { play_forward, "play forward" },
	-- ["<C-C>"] = { copy_time, "copy time" },
	["<C-S-M-c>"] = { copy_imp_words, "copy imp words" },
	["<C-M-C>"] = { copy_sentence, "copy time" },
	["<C-V>"] = { paste_time, "paste time" },
	["<C-M-V>"] = { paste_end_time, "paste end time" },
	["<M-Up>"] = {
		function()
			switch_time("start", 1)
		end,
		"add start time",
	},
	["<M-Down>"] = {
		function()
			switch_time("start", -1)
		end,
		"reduce start time",
	},
	["<C-M-Up>"] = {
		function()
			switch_time("end", 1)
		end,
		"add end time",
	},
	["<C-M-Down>"] = {
		function()
			switch_time("end", -1)
		end,
		"reduce end time",
	},
}

mode = Mode(function()
	return modeName
end, mappings)

M.toggle = function()
	if mode.is_run() then
		vim.o.timeoutlen = 300
		mode.exit()
	else
		vim.o.timeoutlen = 100
		mode.enter()
	end
end

return M
