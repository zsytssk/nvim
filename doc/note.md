https://gitlab.com/thomas3081/nvim

## 2026-09-01 16:03:59

telescope 切换搜索模式

## 2026-08-25 17:29:26

- 自己写一个nvim跳转的功能 -> switch_panel
  - 我要用一个按键 按照从下到上左 从右到左的顺序切换

## 2026-07-24 14:09:07

- nvim youtube 中文对位置的干扰
  - 计算这一行的换行的位置
  - 看换行位置在不在区间内
  - 计算区间分割按idx，
  - 计算每个分区要覆盖的字符

我某一行有中文而且是wrap 因为这一行的最后一个空位无法放下中文，在neovim中显示一个`>`, 然后在下一行显示那个中文，但是我使用nvim_buf_set_extmark想覆盖那个中文时，如果start_p正好是那个中文的idx就显示在上一行，如果start_p+1就会在下一行的这个中文的下一个位置显示覆盖字符
vim.api.nvim_buf_set_extmark(0, ns_id, line_num, start_p, {
virt_text = { { display_text, "Normal" } },
virt_text_pos = "overlay",
virt_text_win_col = nil,
})

## 2025-10-27 09:14:23

lualine_a -> 改变状态 没有其他方法了吗

## 2025-03-31 08:36:58

gitsign
lsp + autoformat + autocomplete

## 2025-04-19 12:16:36

- @ques 如何定义类型

```ts
type Item = {
  content: '',
  type "link" | 'sentence',
  time: number[],
  step: number
  matchKeys: `1,2,3`
}
type Block = Record<number, Item>
```

## 2024-09-23 09:52:57

diffview

oil 收藏文件或者文件夹。。。
eslint
disable C-space

### end

- @ques 检查 mode 的绑定逻辑，要不要做成日记绑定的
- @ques neovim 笔记应用
- @ques lualine 更新时间
- @ques neovim 保存自动格式化
  - https://github.com/stevearc/conform.nvim
- lsp markdown ->

## 2024-09-22 12:31:25

- @ques 怎么知道文件的最后一行的行号

- @ques 可以将对应关系直接放到 table 中
  - {int: [type content ref]}

```lua
vim.api.nvim_buf_line_count(0)

vim.startswith(content, "##")

local content = vim.fn.getline(line)

local current_line = vim.fn.line('.')

function find_target_lines()
    local targets = {}
    local total_lines = vim.api.nvim_buf_line_count(0) -- 获取当前 buffer 的总行数
    local current_line = vim.fn.line('.')              -- 获取当前光标所在行
    local start_line, end_line

    -- 向上查找目标行（以 "##" 开头或者文件开头）
    for line = current_line, 1, -1 do
        if vim.startswith(content, "##") or line == 0 then
            break
        else
            local content = vim.fn.getline(line)           -- 获取该行内容
            table.insert(targets, line, content)
        end
    end

    -- 向下查找目标行（以 "##" 开头或者文件结尾）
    for line = current_line, total_lines +1 do
        local content = vim.fn.getline(line) -- 获取该行内容
        if vim.startswith(content, "##") or line == total_lines+1 then
            end_line = line
            break
        else
            local content = vim.fn.getline(line) -- 获取该行内容
            table.insert(targets, line, content)
        end
    end

    return targets
end

```

## 2024-09-19 19:33:28

```ts
function triggerKeyEvent(
  keyCode,
  opts = {
    altKey: false,
    ctrlKey: false,
    metaKey: false,
    shiftKey: false,
    repeat: false,
  },
) {
  var event = new KeyboardEvent("keydown", {
    keyCode: keyCode,
    which: keyCode,
    bubbles: true,
    cancelable: true,
    ...opts,
  });
  document.dispatchEvent(event);
}

triggerKeyEvent(32); // 空格
triggerKeyEvent("C".charCodeAt(0)); // 字幕
triggerKeyEvent(188, { shiftKey: true }); // 减速
triggerKeyEvent(190, { shiftKey: true }); // 增速
triggerKeyEvent(37); // before
triggerKeyEvent(39); // after
```

## 2024-09-17 08:43:04

- @ques 如何能显示当前的速度就更好了
  - 如果能调用 youtube 内置功能就很好了
  - 或者 js 模拟默认的按键行为
    - 要找到监听按键的 dom 节点 -> 直接 video 发送事件会怎么样

neovim 控制 youtube 先看看那个插件的问题

- @ques neovim 快捷键做了转换 保存和和设置的 key 不一样
  - `<A-t>` -> `<M-t>`
  - `<C-t>` -> `<C-T>`
  - 默认的快捷键找不到 `gg`这种的

- @ques 原来的 map 中的 options 怎么处理？

- @ques
  - neovim 能不能自己搞一个 mode 来控制视频的播放？
    - https://github.com/Iron-E/nvim-libmodal/blob/master/lua/libmodal/Layer.lua
    - https://github.com/Iron-E/nvim-libmodal/tree/master/examples/lua
    - youtube 视频能减速 加速吗
  - statusLine -> 怎么显示当前的状态
  - 或者怎么能切换到 chrome 上去？awesome？
  - youtube 快捷键直接复制 时间
  - 两边的快捷键应该能同步

- libmodal 经常不起作用。。。
  - 也许可以自己写一个
  - 只需要事件绑定就可以了
  - 绑定之前把之前的 key 记下来，后面删除自己的时候还原

- @ques 如何给一个 buffer 绑定事件，然后再去掉
  - 监听当前 buffer 的修改

- @ques js 能不能在网页上发布一个 快捷键

```js
element = document.getElementById("idTxtBx_SAOTCS_ProofConfirmation");

element.value = "8885"; // this alone was not working as keypress.

var evt = document.createEvent("HTMLEvents");
evt.initEvent("change", false, true); // adding this created a magic and passes it as if keypressed
element.dispatchEvent(evt);

// 显示字幕
$(".ytp-subtitles-button").click();
// 速度
document.querySelector("video").playbackRate *= 0.75;

// 向前 向后
document.querySelector("video").currentTime -= 5;
```

```lua
{
  abbr = 0,
  buffer = 0,
  desc = "move down",
  expr = 0,
  lhs = "<M-t>",
  lhsraw = "<80><fc>\bt",
  lnum = 0,
  mode = "n",
  mode_bits = 1,
  noremap = 1,
  nowait = 0,
  rhs = "<Cmd> ToggleTermFloat <CR>",
  script = 0,
  scriptversion = 1,
  sid = -8,
  silent = 0
}
```

```lua
local function remove_component()
  local config = require('lualine').get_config()  -- 获取当前配置
  for i, comp in ipairs(config.sections.lualine_a) do
    if comp == 'diagnostics' then  -- 检查是否有 diagnostics 组件
      table.remove(config.sections.lualine_c, i)  -- 移除 diagnostics 组件
      break
    end
  end
  require('lualine').setup(config)  -- 重新加载配置
end


if buffer then
  vim.api.nvim_buf_del_keymap(buffer, mode, lhs)
else
  vim.api.nvim_del_keymap(mode, lhs)
end

vim.keymap.del()
vim.keymap.set(mode, lhs, rhs, options)

-- 获取普通模式下的所有键映射
local mappings = vim.api.nvim_get_keymap('n')

-- 打印所有映射
for _, map in ipairs(mappings) do
  print(vim.inspect(map))
end

```
