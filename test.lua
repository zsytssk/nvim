-- direction:
-- "forward"  => 先往后找；如果后面没有，则从最小 key 开始重新找第一个
-- "backward" => 只往前找（更小的 key）

local function findImp(tbl, startKey, direction)
    direction = direction or "forward"

    local keys = {}

    -- 收集所有数字 key
    for k in pairs(tbl) do
        table.insert(keys, k)
    end

    -- 全部升序排序
    table.sort(keys)

    if direction == "backward" then
        -- 从 startKey 前面开始，倒序找
        for i = #keys, 1, -1 do
            local k = keys[i]

            if k < startKey then
                local item = tbl[k]
                if item and item.isImp then
                    return k, item
                end
            end
        end
    elseif direction == "forward" then
        -- 第一轮：先往后找
        for _, k in ipairs(keys) do
            if k > startKey then
                local item = tbl[k]
                if item and item.isImp then
                    return k, item
                end
            end
        end

        -- 第二轮：后面没找到，从头开始找
        for _, k in ipairs(keys) do
            local item = tbl[k]
            if item and item.isImp then
                return k, item
            end
        end
    end

    return nil
end


-- 示例
local data = {
    [1] = { isImp = false },
    [3] = { isImp = true },
    [5] = { isImp = false },
    [8] = { isImp = false },
    [10] = { isImp = false }
}

-- 正常向后
local k1 = findImp(data, 3, "forward")
print(k1) -- 8

-- 向后找不到，回头从头找
local k2 = findImp(data, 10, "forward")
print(k2) -- 3

-- 向前找
local k3 = findImp(data, 8, "backward")
print(k3) -- 3
