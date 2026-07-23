local function grep_word_to_quickfix()
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


return { grep_word_to_quickfix = grep_word_to_quickfix }
