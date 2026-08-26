local tb = require 'libs.table'
local win_switch = require 'custom.jump_list.win_switch'

local M = {}

-- 历史记录存储：每个条目包含文件名、行号、列号和时间戳
local history = {}
local max_history = 100
local jump_space = 10
local curIndex
M._skip_next = false

local function isCurFile(item)
    if item == nil then
        return false
    end
    local winid = vim.api.nvim_get_current_win()

    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    return item.file == filename and winid == item.winid
end

M.on_window_close = function(args)
    local closed_win_id = tonumber(args.match)
    local old_len = #history
    history = tb.filter(history, function(item)
        return item.winid ~= closed_win_id
    end)
    if old_len > #history then
        curIndex = nil
    end
end

M.track_cursor = function()
    if M._skip_next then
        return
    end
    local winid = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(0)
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == '' then
        return
    end

    local curLine = pos[1]
    local lastItem = history[#history]
    if (isCurFile(lastItem) and math.abs(lastItem.line - curLine) <= jump_space) then
        -- lastItem.line = curLine
        return
    end

    if curIndex then
        history = tb.clear_after(history, curIndex)
        curIndex = nil
    end

    -- 添加到历史记录
    table.insert(history, {
        winid = winid,
        bufnr = bufnr,
        file = filename,
        line = curLine,
        col = pos[2],
    })

    if #history > max_history then
        table.remove(history, 1)
    end
end

M.jump = function(idx, callback)
    local item = history[idx]
    if not item then
        callback()
        return
    end

    if vim.api.nvim_buf_is_valid(item.bufnr) then
        local win_is_valid = false
        if vim.api.nvim_win_is_valid(item.winid) then
            vim.api.nvim_set_current_win(item.winid)
            win_is_valid = true
        end
        vim.schedule(function()
            if not isCurFile(item) then
                vim.cmd.edit(vim.fn.fnameescape(item.file))
            end
            if win_is_valid then
                vim.api.nvim_win_set_cursor(item.winid, { item.line, item.col })
            end
            callback()
            curIndex = idx
        end)
        return
    end
    table.remove(history, idx)
    callback()
end

M.prev = function()
    if M._skip_next then
        return
    end

    local prevIdx = math.max((curIndex or #history) - 1, 1)
    if prevIdx < 1 then
        return
    end

    M._skip_next = true
    M.jump(prevIdx, function()
        vim.defer_fn(function()
            M._skip_next = false
        end, 50)
    end)
end

M.next = function()
    if M._skip_next then
        return
    end

    local nextIdx = (curIndex or #history) + 1
    if nextIdx > #history then
        return
    end

    M._skip_next = true
    M.jump(nextIdx, function()
        vim.defer_fn(function()
            M._skip_next = false
        end, 50)
    end)
end

M.switch_panel_prev = function()
    win_switch.prev()
end
M.switch_panel_next = function()
    win_switch.next()
end

-- 创建自动命令
M.init = function()
    local autoGroup = vim.api.nvim_create_augroup("CursorTracker", { clear = true })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = autoGroup,
        callback = M.track_cursor,
        desc = "Track cursor position changes"
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = autoGroup,
        callback = M.on_window_close,
        desc = "Clean up history on window close"
    })

    M.track_cursor()
end

M.debug = function()
    print(vim.inspect({ curIndex = curIndex, history = history }))
end

return M
