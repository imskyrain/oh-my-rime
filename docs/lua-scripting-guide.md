# Rime Lua 脚本完全教程

## 📚 目录

- [1. Lua 脚本简介](#1-lua-脚本简介)
- [2. 已有的 Lua 功能](#2-已有的-lua-功能)
- [3. 如何使用 Lua 脚本](#3-如何使用-lua-脚本)
- [4. Lua 脚本类型](#4-lua-脚本类型)
- [5. 编写自定义 Lua 脚本](#5-编写自定义-lua-脚本)
- [6. 实战案例](#6-实战案例)
- [7. 调试技巧](#7-调试技巧)

---

## 1. Lua 脚本简介

### 什么是 Lua 脚本？

Rime 从 librime 1.8.0 开始支持 **Lua 脚本扩展**，允许用户通过编写 Lua 代码来：

- ✅ 自定义输入逻辑（processor）
- ✅ 处理候选项（filter）
- ✅ 生成动态内容（translator）
- ✅ 实现复杂功能（计算器、日期时间、大小写转换等）

### 为什么使用 Lua？

| 优势 | 说明 |
|------|------|
| **无限扩展** | 不受 Rime 内置功能限制 |
| **动态生成** | 可以根据输入实时生成候选项 |
| **跨平台** | Lua 脚本在所有平台上通用 |
| **易于调试** | 修改后重新部署即可生效 |
| **丰富的API** | Rime 提供了完整的 Lua API |

---

## 2. 已有的 Lua 功能

当前配置中已包含的 Lua 脚本功能：

### 📅 日期时间类

| 功能 | 触发词 | 示例 |
|------|--------|------|
| 日期 | `rq` | 2026-02-02、2026/02/02、2026年02月02日 |
| 时间 | `sj` | 10:30、10:30:45 |
| 星期 | `xq` | 星期日、周日、礼拜日 |
| 日期时间 | `dt` | 2026-02-02T10:30:45+08:00 |
| 时间戳 | `ts` | 1738468245 |
| 农历 | `nl` | 二〇二六年正月初五 |

**使用方法**：
```
输入 rq → 候选项显示：2026-02-02、2026/02/02 等
输入 sj → 候选项显示：10:30、10:30:45
```

### 🔢 数字转换类

| 功能 | 触发词 | 示例 |
|------|--------|------|
| 数字大写 | `R` + 数字 | R123 → 壹佰贰拾叁元整 |
| 金额大写 | `R` + 金额 | R123.45 → 壹佰贰拾叁元肆角伍分 |

**使用方法**：
```
输入 R123 → 壹佰贰拾叁元整、一百二十三
输入 R88.88 → 捌拾捌元捌角捌分
```

### 🧮 计算器

| 功能 | 触发词 | 示例 |
|------|--------|------|
| 计算器 | `=` 或 `cC` | =1+2*3 → 7 |

**使用方法**：
```
输入 =1+2*3 → 7
输入 =sqrt(16) → 4
输入 =sin(30) → 0.5
```

支持的函数：
- 基本运算：`+`、`-`、`*`、`/`、`%`、`^`
- 数学函数：`sqrt()`、`sin()`、`cos()`、`tan()`、`log()`、`exp()`、`abs()`

### 🔤 文本处理类

| 功能 | 说明 |
|------|------|
| 英文自动大写 | 句首英文单词自动大写 |
| 中英混输空格 | 中英文之间自动添加空格 |
| 错音错字提示 | 显示拼音注音提示 |

### 🎯 辅助功能

| 功能 | 说明 |
|------|------|
| 长词优先 | 提升长词在候选项中的位置 |
| 用户词典标记 | 标记输入过的词条 |
| 生僻词降频 | 降低生僻词的显示频率 |
| 以词定字 | 快速输入词组的某个字 |

---

## 3. 如何使用 Lua 脚本

### 在方案中启用 Lua 脚本

**步骤 1：在方案配置中引用 Lua 脚本**

编辑方案文件（如 `rime_ice.schema.yaml`）：

```yaml
engine:
  # 在对应的组件中添加 Lua 脚本
  processors:
    - lua_processor@*select_character  # Lua processor

  translators:
    - lua_translator@*date_translator  # Lua translator
    - lua_translator@*number_translator

  filters:
    - lua_filter@*long_word_filter     # Lua filter
    - lua_filter@*is_in_user_dict
```

**步骤 2：配置 Lua 脚本参数**

在方案配置中添加脚本的配置项：

```yaml
# Lua 配置：日期时间触发关键字
date_translator:
  date: rq       # 日期
  time: sj       # 时间
  week: xq       # 星期
  datetime: dt   # ISO 8601
  timestamp: ts  # 时间戳

# Lua 配置：长词优先
long_word_filter:
  count: 2       # 提升 2 个词语
  idx: 4         # 插入到第 4 个位置
```

### Lua 脚本命名规则

Rime 使用 `@` 符号来引用 Lua 脚本：

```yaml
lua_translator@*date_translator
      ↑          ↑
      |          └─ 脚本名称（对应 lua/date_translator.lua）
      └─ 组件类型
```

**前缀 `*` 的作用**：
- 带 `*`：`lua_translator@*date_translator` → 使用方案中的配置项 `date_translator`
- 不带 `*`：`lua_translator@date_translator` → 直接使用脚本默认配置

---

## 4. Lua 脚本类型

Rime 支持三种类型的 Lua 脚本组件：

### 4.1 Processor（处理器）

**作用**：处理按键事件，修改输入行为

**应用场景**：
- 限制输入长度
- 自定义快捷键
- 以词定字功能

**示例**：`lua/select_character.lua`（以词定字）

```lua
-- 简化示例
local function processor(key, env)
    local engine = env.engine
    local context = engine.context

    -- 判断按键
    if key:repr() == 'bracketleft' then  -- [ 键
        -- 选择词组的第一个字
        return select_first_character(context)
    end

    return 2  -- 不处理，传递给下一个 processor
end

return processor
```

**返回值**：
- `0` (kRejected) - 拒绝处理
- `1` (kAccepted) - 接受并处理
- `2` (kNoop) - 不处理，传递给下一个组件

### 4.2 Translator（翻译器）

**作用**：根据输入生成候选项

**应用场景**：
- 日期时间生成
- 计算器
- 动态内容生成
- Unicode 转换

**示例**：`lua/date_translator.lua`

```lua
local M = {}

-- 初始化函数（可选）
function M.init(env)
    local config = env.engine.schema.config
    env.name_space = env.name_space:gsub('^*', '')
    M.date = config:get_string(env.name_space .. '/date') or 'rq'
end

-- 主要函数
function M.func(input, seg, env)
    if input == M.date then
        local current_time = os.time()

        -- 生成候选项
        local cand = Candidate('', seg.start, seg._end,
                              os.date('%Y-%m-%d', current_time), '')
        cand.quality = 100  -- 设置优先级
        yield(cand)  -- 输出候选项

        -- 可以生成多个候选项
        yield(Candidate('', seg.start, seg._end,
                       os.date('%Y/%m/%d', current_time), ''))
    end
end

return M
```

**关键API**：
- `Candidate(type, start, end, text, comment)` - 创建候选项
- `yield(cand)` - 输出候选项
- `seg.start` / `seg._end` - 输入的起始/结束位置

### 4.3 Filter（过滤器）

**作用**：处理和修改候选项列表

**应用场景**：
- 长词优先
- 降低英文单词权重
- 标记用户词典
- 过滤生僻词

**示例**：`lua/long_word_filter.lua`

```lua
local function filter(input, env)
    local config = env.engine.schema.config
    local count = config:get_int('long_word_filter/count') or 2
    local idx = config:get_int('long_word_filter/idx') or 4

    local long_words = {}
    local other_cands = {}

    -- 遍历所有候选项
    for cand in input:iter() do
        local text = cand.text

        -- 收集长词（≥2个字）
        if utf8.len(text) > 1 and #long_words < count then
            table.insert(long_words, cand)
        else
            table.insert(other_cands, cand)
        end
    end

    -- 重新排序输出
    for i, cand in ipairs(other_cands) do
        if i == idx then
            -- 在第 idx 位置插入长词
            for _, long_word in ipairs(long_words) do
                yield(long_word)
            end
        end
        yield(cand)
    end
end

return filter
```

**关键API**：
- `input:iter()` - 遍历输入的候选项
- `cand.text` - 候选项文本
- `cand.comment` - 候选项注释
- `cand.quality` - 候选项权重

---

## 5. 编写自定义 Lua 脚本

### 5.1 创建简单的 Translator

**需求**：输入 `version` 显示 Rime 版本信息

**步骤 1：创建 Lua 脚本**

创建文件 `lua/version_translator.lua`：

```lua
-- 版本信息翻译器
local function translator(input, seg, env)
    -- 只处理输入为 "version" 的情况
    if input == "version" then
        -- 获取 Rime 版本
        local rime_version = env.engine.schema.schema_id

        -- 创建候选项
        local cand = Candidate("version", seg.start, seg._end,
                              "Rime librime 1.16.0",
                              "〔版本信息〕")
        cand.quality = 100
        yield(cand)

        -- 再添加一个候选项
        local cand2 = Candidate("version", seg.start, seg._end,
                               "当前方案：" .. rime_version,
                               "")
        cand2.quality = 99
        yield(cand2)
    end
end

return translator
```

**步骤 2：在方案中启用**

编辑 `rime_ice.schema.yaml`：

```yaml
engine:
  translators:
    - punct_translator
    - script_translator
    - lua_translator@version_translator  # 添加这一行
    # ... 其他 translator
```

**步骤 3：重新部署并测试**

```
输入: version
候选项:
  1. Rime librime 1.16.0 〔版本信息〕
  2. 当前方案：rime_ice
```

### 5.2 创建带配置的 Translator

**需求**：自定义快捷文本输入（类似文本替换）

**步骤 1：创建 Lua 脚本**

创建文件 `lua/quick_text_translator.lua`：

```lua
local M = {}

-- 初始化函数，读取配置
function M.init(env)
    local config = env.engine.schema.config
    env.name_space = env.name_space:gsub('^*', '')

    -- 读取快捷文本映射
    M.shortcuts = {}
    local list = config:get_list(env.name_space)
    if list then
        for i = 0, list.size - 1 do
            local item = list:get_value_at(i).value
            local parts = {}
            for part in string.gmatch(item, "[^\t]+") do
                table.insert(parts, part)
            end
            if #parts >= 2 then
                M.shortcuts[parts[1]] = parts[2]
            end
        end
    end
end

-- 翻译函数
function M.func(input, seg, env)
    local text = M.shortcuts[input]
    if text then
        local cand = Candidate("quick", seg.start, seg._end, text, "〔快捷文本〕")
        cand.quality = 100
        yield(cand)
    end
end

return M
```

**步骤 2：在方案中配置**

编辑 `rime_ice.schema.yaml`：

```yaml
engine:
  translators:
    - lua_translator@*quick_text_translator  # 注意有 * 前缀

# Lua 配置：快捷文本
quick_text_translator:
  - "yx\t我的邮箱：example@email.com"
  - "dh\t我的电话：138-1234-5678"
  - "dz\t我的地址：北京市海淀区"
  - "qm\t此致\n敬礼！"
```

**步骤 3：使用**

```
输入: yx
候选项: 我的邮箱：example@email.com 〔快捷文本〕

输入: qm
候选项: 此致
      敬礼！ 〔快捷文本〕
```

### 5.3 创建 Filter

**需求**：过滤掉包含特定字符的候选项

**创建文件 `lua/word_blocker_filter.lua`**：

```lua
-- 词语屏蔽过滤器
local function filter(input, env)
    local config = env.engine.schema.config

    -- 读取屏蔽词列表
    local blocked_words = {}
    local list = config:get_list('word_blocker')
    if list then
        for i = 0, list.size - 1 do
            local word = list:get_value_at(i).value
            blocked_words[word] = true
        end
    end

    -- 过滤候选项
    for cand in input:iter() do
        local should_block = false

        -- 检查是否包含屏蔽词
        for word, _ in pairs(blocked_words) do
            if string.find(cand.text, word) then
                should_block = true
                break
            end
        end

        -- 只输出未被屏蔽的候选项
        if not should_block then
            yield(cand)
        end
    end
end

return filter
```

**在方案中启用**：

```yaml
engine:
  filters:
    - lua_filter@word_blocker_filter
    - uniquifier

# 屏蔽词列表
word_blocker:
  - "敏感词1"
  - "敏感词2"
```

---

## 6. 实战案例

### 案例 1：英文单词首字母大写

**需求**：输入英文时，自动将首字母大写

**实现**：`lua/autocap_filter.lua`

```lua
-- 英文自动大写过滤器（简化版）
local function filter(input, env)
    local context = env.engine.context
    local is_sentence_start = true  -- 是否句首

    for cand in input:iter() do
        local text = cand.text

        -- 检查是否为英文单词
        if text:match("^[a-z]+$") and is_sentence_start then
            -- 首字母大写
            local capped = text:gsub("^%l", string.upper)

            -- 创建新候选项
            local new_cand = Candidate(cand.type, cand.start, cand._end,
                                      capped, cand.comment)
            new_cand.quality = cand.quality + 1  -- 提高优先级
            yield(new_cand)
        end

        -- 原候选项
        yield(cand)
    end
end

return filter
```

### 案例 2：UUID 生成器

**需求**：输入 `uuid` 生成随机 UUID

**实现**：创建 `lua/uuid_translator.lua`

```lua
-- UUID 生成器
local function uuid()
    local random = math.random
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function translator(input, seg, env)
    if input == "uuid" then
        math.randomseed(os.time())
        local cand = Candidate("uuid", seg.start, seg._end,
                              uuid(), "〔UUID〕")
        cand.quality = 100
        yield(cand)
    end
end

return translator
```

### 案例 3：网址自动补全

**需求**：输入 `gh/用户名/项目` 自动补全 GitHub 地址

**实现**：创建 `lua/url_expander_translator.lua`

```lua
local function translator(input, seg, env)
    -- 匹配 gh/user/repo 格式
    local user, repo = input:match("^gh/([^/]+)/([^/]+)$")

    if user and repo then
        local url = string.format("https://github.com/%s/%s", user, repo)
        local cand = Candidate("url", seg.start, seg._end, url, "〔GitHub〕")
        cand.quality = 100
        yield(cand)

        -- 也生成 clone 命令
        local clone_cmd = string.format("git clone %s", url)
        local cand2 = Candidate("url", seg.start, seg._end, clone_cmd, "〔Git Clone〕")
        cand2.quality = 99
        yield(cand2)
    end
end

return translator
```

**使用**：

```
输入: gh/iDvel/rime-ice
候选项:
  1. https://github.com/iDvel/rime-ice 〔GitHub〕
  2. git clone https://github.com/iDvel/rime-ice 〔Git Clone〕
```

---

## 7. 调试技巧

### 7.1 日志输出

在 Lua 脚本中添加日志：

```lua
local function translator(input, seg, env)
    -- 输出调试日志
    log.info("输入内容: " .. input)

    if input == "test" then
        log.info("匹配成功，生成候选项")
        -- ...
    end
end
```

**查看日志**：

- **macOS**: `tail -f ~/Library/Logs/Squirrel.INFO`
- **Windows**: `%TEMP%\rime.weasel.*`
- **Linux**: `/tmp/rime.*`

### 7.2 打印变量

使用 `log` 模块打印变量内容：

```lua
local log = require('log')

-- 打印字符串
log.info("当前输入: " .. input)

-- 打印表（table）
function print_table(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            log.info(indent .. k .. ":")
            print_table(v, indent .. "  ")
        else
            log.info(indent .. k .. ": " .. tostring(v))
        end
    end
end

print_table(env.engine.schema)
```

### 7.3 常见错误排查

**错误 1：脚本不生效**

检查项：
- [ ] 文件名是否正确（`lua/xxx.lua`）
- [ ] 方案配置中是否正确引用（`lua_translator@xxx`）
- [ ] 是否重新部署 Rime
- [ ] 查看日志是否有错误信息

**错误 2：候选项不显示**

检查项：
- [ ] `yield(cand)` 是否被调用
- [ ] 候选项的 `quality` 是否足够高
- [ ] 输入条件是否匹配

**错误 3：Lua 语法错误**

常见问题：
- Lua 数组索引从 1 开始（不是 0）
- 字符串连接使用 `..` 而不是 `+`
- `end` 关键字不要忘记
- 局部变量使用 `local` 声明

### 7.4 性能优化

**避免在循环中创建对象**：

```lua
-- ❌ 不好的做法
for cand in input:iter() do
    local config = env.engine.schema.config  -- 重复创建
    -- ...
end

-- ✅ 好的做法
local config = env.engine.schema.config  -- 只创建一次
for cand in input:iter() do
    -- ...
end
```

**缓存配置项**：

```lua
-- 在 init 函数中缓存配置
function M.init(env)
    M.cached_config = env.engine.schema.config:get_string('xxx')
end

function M.func(input, seg, env)
    -- 直接使用缓存的配置
    local value = M.cached_config
end
```

---

## 8. 常用 Rime Lua API

### 8.1 Candidate 对象

```lua
-- 创建候选项
local cand = Candidate(type, start, _end, text, comment)

-- 属性
cand.text       -- 候选文本
cand.comment    -- 注释/提示
cand.quality    -- 权重（数字越大优先级越高）
cand.type       -- 类型标识
```

### 8.2 Context 对象

```lua
local context = env.engine.context

-- 属性
context.input              -- 当前输入
context.caret_pos          -- 光标位置
context.composition        -- 当前编码
context:get_selected_candidate()  -- 获取选中的候选项
```

### 8.3 Config 对象

```lua
local config = env.engine.schema.config

-- 读取配置
config:get_string('key')        -- 读取字符串
config:get_int('key')           -- 读取整数
config:get_bool('key')          -- 读取布尔值
config:get_list('key')          -- 读取列表
```

### 8.4 UTF-8 字符串处理

```lua
-- 获取字符串长度（字符数，不是字节数）
local len = utf8.len(text)

-- 遍历字符
for pos, code in utf8.codes(text) do
    local char = utf8.char(code)
    -- ...
end
```

---

## 9. 学习资源

### 官方文档

- [Rime Lua 脚本](https://github.com/hchunhui/librime-lua/blob/master/doc/sample.md)
- [Rime Wiki](https://github.com/rime/home/wiki)

### 优秀的 Lua 脚本示例

- [雾凇拼音 Lua 脚本](https://github.com/iDvel/rime-ice/tree/main/lua)
- [98五笔 Lua 脚本](https://github.com/yanhuacuo/98wubi-tables/tree/master/lua)

### 本项目的 Lua 脚本

查看 `lua/` 目录中的脚本，每个都是很好的学习案例：

```bash
lua/
├── date_translator.lua        # 日期时间
├── number_translator.lua      # 数字大写
├── calc_translator.lua        # 计算器
├── long_word_filter.lua       # 长词优先
├── autocap_filter.lua         # 英文大写
└── ...
```

---

## 10. 快速参考

### 创建 Translator 模板

```lua
local M = {}

function M.init(env)
    -- 初始化（可选）
    local config = env.engine.schema.config
    M.my_config = config:get_string('my_setting')
end

function M.func(input, seg, env)
    if input == "trigger" then
        local cand = Candidate("type", seg.start, seg._end,
                              "结果文本", "提示")
        cand.quality = 100
        yield(cand)
    end
end

return M
```

### 创建 Filter 模板

```lua
local function filter(input, env)
    local config = env.engine.schema.config

    for cand in input:iter() do
        -- 处理候选项
        -- 可以修改、过滤或重新排序
        yield(cand)
    end
end

return filter
```

### 创建 Processor 模板

```lua
local function processor(key, env)
    local engine = env.engine
    local context = engine.context

    -- 检查按键
    if key:repr() == "某个按键" then
        -- 处理逻辑
        return 1  -- kAccepted
    end

    return 2  -- kNoop
end

return processor
```

---

**🎉 恭喜！你现在已经掌握了 Rime Lua 脚本的基础知识。开始创建你自己的 Lua 扩展吧！**

---

*最后更新：2026-02-02*
*文档版本：1.0*
