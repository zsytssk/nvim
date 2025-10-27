-- 获取文本区域的可用宽度
local function get_text_area_width()
    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
    return win_info.width - win_info.textoff
end

local function set_multiline_virt_text(bufnr, ns_id, line_num, text, highlight)
    local win_width = get_text_area_width()
    local line_width = vim.fn.strdisplaywidth(text)

    -- 计算需要多少行来显示
    local display_lines = math.ceil(line_width / win_width)
    local start_col = 0
    for i = 0, display_lines - 1 do
        local display_text = text:sub(start_col + 1, start_col + win_width + 1)
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, start_col, {
            virt_text = { { display_text, highlight } },
            virt_text_pos = "overlay",
            virt_text_win_col = nil,
        })
        start_col = start_col + win_width
    end
end



return {
    set_multiline_virt_text = set_multiline_virt_text,
    get_text_area_width = get_text_area_width
}
