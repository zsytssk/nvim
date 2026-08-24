local tb = require 'libs.table'

-- lua/cursor-tracker/init.lua
local M = {}

-- 历史记录存储：每个条目包含文件名、行号、列号和时间戳
local history = {}
local max_history = 100 -- 最大记录条数
local jump_space = 5
local curIndex
M._skip_next = false

M.track_cursor = function()
    if M._skip_next then
        return
    end
    local pos = vim.api.nvim_win_get_cursor(0) -- 获取当前窗口光标位置
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local curLine = pos[1]
    local lastItem = table[#table]
    if (lastItem and math.abs(lastItem.line - curLine) <= jump_space) then
        return
    end

    if curIndex then
        history = tb.clear_after(history, curIndex)
    end
    curIndex = nil

    -- 添加到历史记录
    table.insert(history, {
        bufnr = bufnr,
        file = filename,
        line = curLine,
        col = pos[2],
    })

    -- print(vim.inspect(history))

    -- 保持历史记录不超过最大长度
    if #history > max_history then
        table.remove(history, 1)
    end
end

M.prev = function()
    local prevIdx = math.max((curIndex or #history) - 1, 1)
    local prevItem = history[prevIdx]
    if not prevItem then
        return
    end

    M._skip_next = true
    vim.defer_fn(function()
        M._skip_next = false
    end, 10)

    if vim.api.nvim_buf_is_valid(prevItem.bufnr) then
        -- vim.api.nvim_set_current_buf(prevItem.bufnr)
        vim.cmd("edit " .. prevItem.file)

        vim.api.nvim_win_set_cursor(0, { prevItem.line, prevItem.col })
    else
        table.remove(history, prevIdx)
    end
    curIndex = prevIdx
end

M.next = function()
    local nextIdx = (curIndex or #history) + 1
    local nextItem = history[nextIdx]
    if not nextItem then
        return
    end

    M._skip_next = true
    vim.defer_fn(function()
        M._skip_next = false
    end, 10)

    if vim.api.nvim_buf_is_valid(nextItem.bufnr) then
        -- vim.api.nvim_set_current_buf(nextItem.bufnr)
        vim.cmd("edit " .. nextItem.file)
        vim.api.nvim_win_set_cursor(0, { nextItem.line, nextItem.col })
        curIndex = nextIdx
        return
    end
    table.remove(history, nextIdx)
end

-- 创建自动命令
M.init = function()
    local augroup = vim.api.nvim_create_augroup("CursorTracker", { clear = true })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        callback = M.track_cursor,
        desc = "Track cursor position changes"
    })
    M.track_cursor()
end

M.debug = function()
    print(vim.inspect({ curIndex = curIndex, history = history }))
end

return M
