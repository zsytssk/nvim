-- lua/custom/window_nav.lua
local M = {}

-- 获取所有窗口按"从下到上、从右到左"排序的列表
local function get_sorted_windows()
    local wins = vim.api.nvim_list_wins()
    local infos = {}

    for _, winid in ipairs(wins) do
        local pos = vim.api.nvim_win_get_position(winid)
        table.insert(infos, {
            winid = winid,
            row = pos[1],
            col = pos[2],
        })
    end

    -- 排序：行从上到下 | 列从小到大
    table.sort(infos, function(a, b)
        if a.col == b.col then
            return a.row < b.row
        end
        return a.col < b.col
    end)

    -- 提取 winid 列表
    local result = {}
    for _, info in ipairs(infos) do
        table.insert(result, info.winid)
    end
    return result
end

-- 获取下一个窗口 ID
function M.get_next_window_id()
    local order = get_sorted_windows()
    if #order <= 1 then
        return nil
    end

    local current = vim.api.nvim_get_current_win()
    for i, winid in ipairs(order) do
        if winid == current then
            local next_idx = i % #order + 1
            return order[next_idx]
        end
    end
    return order[1]
end

-- 获取上一个窗口 ID
function M.get_prev_window_id()
    local order = get_sorted_windows()
    if #order <= 1 then
        return nil
    end

    local current = vim.api.nvim_get_current_win()
    for i, winid in ipairs(order) do
        if winid == current then
            local prev_idx = (i - 2) % #order + 1
            return order[prev_idx]
        end
    end
    return order[#order] -- 如果当前窗口不在列表中，返回最后一个
end

-- 跳转到下一个窗口
function M.next()
    local winid = M.get_next_window_id()
    if winid then
        vim.api.nvim_set_current_win(winid)
    end
end

-- 跳转到上一个窗口
function M.prev()
    local winid = M.get_prev_window_id()
    if winid then
        vim.api.nvim_set_current_win(winid)
    end
end

return M
