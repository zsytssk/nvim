-- 在english.md中控制youtube视频播放
-- nvim/lua -> curl -> trans -> tampermonkey -> youtube
local block = require("custom.youtube.block")
local yutils = require("custom.youtube.yutils")
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
    mode:update_status()
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

local emit_event_youdao = function(str)
    if info == nil then
        info = {}
    end

    local allInfo = vim.tbl_extend("force", {
        type = "youdao",
        str = str,
    }, info)

    local json = vim.fn.json_encode(allInfo)
    vim.system(
        {
            "curl", "-s", "-X", "POST",
            "-d", json,
            "http://127.0.0.1:60829/send"
        }
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
    local link = block.get_link(info, current_line)
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
    local link = block.get_link(info, current_line)
    local time_list = {}
    local cur_index = 0
    for _, item in ipairs(list) do
        local itemInfo = item.item
        local line = item.line
        local time = itemInfo.time
        if itemInfo.type == 'link' then
            goto continue
        end
        if type == 'current' and line < current_line then
            cur_index = cur_index + 1
        end
        table.insert(time_list, time)
        ::continue::
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

local toggle_pause_all = function()
    showStatus("⏸")
    emit_event("toggle_pause", '')
end

local copy_sentence = function()
    showStatus("️📋")
    local info = block.get_block()
    local line_num = vim.fn.line(".")
    local line_info = info[line_num]
    if line_info ~= nil and line_info.content then
        local result = line_info.content:gsub("%[.-%]", "")
        result = result:gsub("`([^`]-)`", function(inner)
            -- 如果内部有 |，只取第一个 | 之前的部分
            local chosen = inner:match("^([^|]+)") or inner
            -- 去掉开头的非字母/数字符号（如 !、@、# 等）
            chosen = chosen:gsub("^[^%w]+", "")
            return chosen
        end)
        vim.fn.setreg("+", "先翻译，再详细解释: " .. result)
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

local switch_history = function(direction)
    if direction == 'prev' then
        showStatus("️⏪")
    else
        showStatus("️⏪")
    end
    emit_event("history", direction)
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
    ---@cast line_info SentenceItem
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
local toggle_hide_words_all = function()
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
        local start = 0
        -- if not item.content:match("^[A-Za-z%[]") then
        --     start = 2
        -- end
        local line = string.rep("*", vim.fn.strdisplaywidth(item.content))
        set_multiline_virt_text(0, ns_id, tonumber(key) - 1, line, "Normal", start)
        ::continue::
    end
    flag = true
end

local toggle_hide_words = function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    flag = not flag
    local info = block.get_block()
    for key, item in pairs(info) do
        if item.type ~= 'sentence' then goto continue end

        local content = item.content
        local row = tonumber(key) - 1
        local ranges = {}
        local start = 1
        -- local start = content:match("^[A-Za-z%[]") and 1 or 3

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
            local text = string.sub(content, r[1], r[2])
            local width = vim.fn.strdisplaywidth(text)
            set_multiline_virt_text2(0, ns_id, row, string.rep("*", width), "Normal", r[1] - 1)
        end

        ::continue::
    end
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
    -- local info = block.get_block()
    -- print(vim.inspect(info))
    -- local pattern = "https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+"
    -- local url = "htp://test.org"

    -- local match = string.match(url, pattern)
    -- print(match)
    toggle_pause()
end
local jump_imp = function(dir)
    local info = block.get_block()
    local current_line = vim.fn.line(".")
    local next_imp_line = block.find_imp(info, current_line, dir)
    if next_imp_line == nil then
        return
    end
    vim.api.nvim_win_set_cursor(0, { next_imp_line, 0 })
end

local change_page_url = function()
    local link = block.get_link(block.get_block())
    emit_event("change_page_url", link, nil)
end

local youdao_pronounce = function()
    local word = vim.fn.expand('<cword>')
    emit_event_youdao(word)
end

local M = {}

local mappings = {
    ["<M-n>"] = { function()
        vim.cmd('/`[^`]*`')
    end, "video loop" },
    ["<M-S-N>"] = { function()
        -- vim.cmd('/\\[[^\\]]*\\]')
        vim.cmd('/`\\![^`]*`')
    end, "video loop" },
    ["n"] = { utils.bind(yutils.jump_to_match, 'next'), "video loop" },
    ["N"] = { utils.bind(yutils.jump_to_match, 'prev'), "video loop" },
    ["<M-j>"] = { video_loop, "video loop" },
    ["<M-r>"] = { youdao_pronounce, "youdao pronounce" },
    ["<M-s>"] = { yutils.word_to_qs, "grep word to quickfix" },
    ["<C-M-y>"] = { change_page_url, "change page url" },
    -- ["<C-M-j>"] = { video_jump, "video jump" },
    ["<M-t>"] = { toggle_hide_words, "toggle hide words" },
    ["<C-M-t>"] = { toggle_hide_words_all, "toggle hide words" },
    -- ["<C-M-y>"] = { test, "youtube test" },
    ["<M-k>"] = { sentence_jump, "sentence jump" },
    ["<C-S-M-j>"] = { utils.bind(video_list_loop, 'start'), "video list loop" },
    ["<C-S-M-k>"] = { utils.bind(video_list_loop, 'current'), "video list loop from", },
    ["<C-M-j>"] = { jump_imp, "video loop" },
    ["<C-M-k>"] = { utils.bind(jump_imp, 'prev'), "video loop" },
    ["<M-Space>"] = { toggle_pause, "(un)pause" },
    ["<C-M-Space>"] = { toggle_pause_all, "(un)pause" },
    -- ['K'] = { toggle_pause, { buffer = true, desc = '(un)pause' } },
    ["C"] = { toggle_subtitle, "(un)subtitle" },
    ["<"] = { reduce_speed, "reduce speed" },
    [">"] = { plus_speed, "plus speed" },
    ["J"] = { play_back, "play back" },
    ["L"] = { play_forward, "play forward" },
    -- ["<C-C>"] = { copy_time, "copy time" },
    ["<C-S-M-c>"] = { copy_imp_words, "copy imp words" },
    ["<C-S-M-v>"] = { copy_url, "copy imp words" },
    ["<C-M-C>"] = { copy_sentence, "copy time" },
    ["<C-V>"] = { paste_time, "paste time" },
    ["<C-M-V>"] = { paste_end_time, "paste end time" },
    ["<M-Up>"] = { utils.bind(switch_time, 'start', 1), "add start time", },
    ["<M-Down>"] = { utils.bind(switch_time, 'start', -1), "reduce start time", },
    ["<C-M-Up>"] = { utils.bind(switch_time, 'end', 1), "add end time", },
    ["<C-M-Down>"] = { utils.bind(switch_time, 'end', -1), "add end time", },
    ["<M-Left>"] = { utils.bind(switch_history, 'prev'), "add start time", },
    ["<M-right>"] = { utils.bind(switch_history, 'next'), "reduce start time", },
}

mode = Mode:new(function()
    return modeName
end, mappings)

M.toggle = function()
    if mode.is_run then
        vim.o.timeoutlen = 300
        mode:exit()
    else
        vim.o.timeoutlen = 100
        mode:enter()
    end
end

return M
