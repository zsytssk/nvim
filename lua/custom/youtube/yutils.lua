local function word_to_qs()
    -- 获取光标下的单词
    local word = vim.fn.expand('<cword>')
    if word == '' then
        vim.notify('No word under cursor', 'warn')
        return
    end
    word = "\\<" .. word .. "\\>"

    -- 指定搜索的文件夹（可根据需要修改）
    local search_dir = vim.fn.expand('%:p:h')

    -- 可选：显示正在搜索的目录（用于提示）
    vim.notify('Searching in: ' .. search_dir .. ">" .. word, 'info')
    if search_dir == '' then
        return
    end

    local cmd = string.format("rg --vimgrep --no-heading --color=never %s %s", vim.fn.shellescape(word),
        vim.fn.shellescape(search_dir))
    local output = vim.fn.systemlist(cmd)
    vim.fn.setqflist({}, ' ', { title = "Grep Result: " .. word, lines = output })
    vim.cmd('copen')
end


-- 在 init.lua 中
local function jump_to_match(direction, force)
    local pattern = vim.fn.getreg('/')
    if pattern == '' then return vim.notify('no match', vim.log.levels.WARN) end
    local next_start = vim.fn.searchpos(pattern, 'n')
    local prev_end = vim.fn.searchpos(pattern, 'bne')
    local prev_start = vim.fn.searchpos(pattern, 'bn')
    if direction ~= 'next' and force == nil then
        -- vim.api.nvim_win_set_cursor(0, { prev_end[1], prev_end[2] - 1 })
        vim.api.nvim_win_set_cursor(0, { prev_end[1], prev_end[2] })
        jump_to_match('prev', true)
        return
    end

    local pos = next_start
    if direction ~= 'next' then
        pos = prev_start
    end


    if pos[1] == 0 then return end
    -- 找到匹配后，跳到中心
    local sx, sy = pos[1], pos[2]
    vim.api.nvim_win_set_cursor(0, { sx, sy })
end



return { word_to_qs = word_to_qs, jump_to_match = jump_to_match }
