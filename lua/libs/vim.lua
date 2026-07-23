-- 获取文本区域的可用宽度
local function get_text_area_width()
    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
    return win_info.width - win_info.textoff
end

local function set_multiline_virt_text(bufnr, ns_id, line_num, text, highlight, start_pos)
    local win_width = get_text_area_width()
    local line_width = vim.fn.strdisplaywidth(text)

    -- 计算需要多少行来显示
    local display_lines = math.ceil(line_width / win_width)
    local start_col = start_pos or 0
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

local function set_multiline_virt_text2(bufnr, ns_id, line_num, text, highlight, start_pos)
    local win_width = get_text_area_width()
    local line_width = start_pos + vim.fn.strdisplaywidth(text)

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
        local display_text = text:sub(0, end_index - start_index)

        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, start_index, {
            virt_text = { { display_text, highlight } },
            virt_text_pos = "overlay",
            virt_text_win_col = nil,
        })
        start_col = next_start

        ::continue::
    end
end



return {
    set_multiline_virt_text = set_multiline_virt_text,
    set_multiline_virt_text2 = set_multiline_virt_text2,
    get_text_area_width = get_text_area_width
}
