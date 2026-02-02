# Rime 雾凇拼音与双拼方案冲突问题排查与解决

## 问题描述

**症状**：选择"雾凇拼音"（全拼方案）后，输入 `nihao` 得到的是"你哈 O"，而不是期望的"你好"。

**表现**：
- 输入 `nihao` → 输出"你哈 O"（双拼行为）
- 输入 `ni hao`（空格分隔）→ 输出"你哈 O"
- 输入 `ni'hao`（单引号分隔）→ 输出"你哈 O"

**预期**：全拼方案应该将 `nihao` 或 `ni hao` 识别为"你好"。

---

## 问题根源

### 核心原因

当 `rime_ice.schema.yaml`（雾凇拼音全拼方案）和 `double_pinyin_flypy_ice.schema.yaml`（小鹤双拼·雾凇方案）**同时使用相同的词典名称** `rime_ice` 时，Rime 在编译时会产生 **prism 文件冲突**。

### Rime 编译机制

Rime 的编译机制如下：

```
词典文件 (.dict.yaml)  →  table.bin (词条数据)
方案文件 (.schema.yaml) →  prism.bin (拼写索引)
```

- **table.bin**：存储词库数据，按词典名称生成（如 `rime_ice.table.bin`）
- **prism.bin**：存储拼写索引，按方案 schema_id 生成（如 `rime_ice.prism.bin`）

### 冲突机制

当两个方案配置如下时：

**rime_ice.schema.yaml（全拼）**：
```yaml
translator:
  dictionary: rime_ice  # 使用 rime_ice 词典
speller:
  algebra:
    - abbrev/^([a-z]).+$/$1/   # 全拼规则
    - derive/...
```

**double_pinyin_flypy_ice.schema.yaml（双拼）**：
```yaml
translator:
  dictionary: rime_ice  # 同样使用 rime_ice 词典
speller:
  algebra:
    - xform/iu$/Q/  # 双拼转换规则
    - xform/(.)ei$/$1W/
    - ...
```

**问题发生过程**：

1. Rime 编译 `rime_ice` 方案时，生成 `rime_ice.prism.bin`（全拼索引）
2. Rime 编译 `double_pinyin_flypy_ice` 方案时，因为两者都使用 `dictionary: rime_ice`
3. 在某些情况下，Rime 可能会：
   - 覆盖 `rime_ice.prism.bin` 为双拼索引
   - 或者在选择方案时使用了错误的 prism 文件
4. 导致选择"雾凇拼音"时，实际使用的是双拼的 prism 索引

---

## 排查过程

### 1. 验证配置文件

首先确认 `rime_ice.schema.yaml` 的 speller 配置是否正确：

```bash
# 检查是否包含双拼转换规则（xform）
grep "xform" ~/Library/Rime/rime_ice.schema.yaml | grep -v "^#"
```

**结果**：配置文件本身是正确的全拼方案（只有 `derive`、`abbrev`，没有 `xform` 转换）。

### 2. 检查编译文件

```bash
# 查看编译后的方案文件
cat ~/Library/Rime/build/rime_ice.schema.yaml | grep -A30 "^speller:"
```

**结果**：编译后的方案文件也是全拼配置。

### 3. 隔离测试

```bash
# 移除所有双拼方案
cd ~/Library/Rime
mkdir -p .backup
mv double_pinyin*.schema.yaml .backup/

# 重新部署
# 点击输入法图标 → "重新部署"
```

**测试结果**：移除双拼方案后，输入 `nihao` 正常得到"你好"。

### 4. 逐个恢复测试

```bash
# 恢复 double_pinyin_flypy_ice.schema.yaml
cp .backup/double_pinyin_flypy_ice.schema.yaml ./

# 重新部署并测试
```

**测试结果**：问题复现！输入 `nihao` 又得到"你哈 O"。

**结论**：`double_pinyin_flypy_ice.schema.yaml` 与 `rime_ice.schema.yaml` 存在冲突。

---

## 解决方案

### 方案一：使用 `prism` 参数（推荐）✅

通过在 `double_pinyin_flypy_ice.schema.yaml` 中显式指定 `prism` 参数，让两个方案：
- **共享词库数据**（`dictionary: rime_ice`）
- **使用独立的拼写索引**（`prism: double_pinyin_flypy_ice`）

**修改 `double_pinyin_flypy_ice.schema.yaml`**：

```yaml
# 主翻译器 - 使用雾凇词库
# 注意：虽然 dictionary 使用 rime_ice，但 Rime 会根据 prism 参数生成独立的 prism 文件
translator:
  dictionary: rime_ice                    # 使用雾凇词典数据
  prism: double_pinyin_flypy_ice          # 使用独立的拼写索引
  enable_word_completion: true
  spelling_hints: 8
  always_show_comments: true
  initial_quality: 1.2
  # ... 其他配置 ...

# 部件拆字反查也需要使用相同的词典
radical_reverse_lookup:
  tags: [ radical_lookup ]
  dictionary: rime_ice  # 使用雾凇词典
```

**原理**：
- `dictionary: rime_ice` → 使用 `rime_ice.table.bin`（词库数据，约 58M）
- `prism: double_pinyin_flypy_ice` → 生成独立的 `double_pinyin_flypy_ice.prism.bin`（双拼索引）
- 雾凇全拼方案不受影响，继续使用 `rime_ice.prism.bin`（全拼索引）

### 方案二：使用独立词典名称（不推荐）

创建一个包装词典，导入雾凇词库：

**创建 `double_pinyin_flypy_ice.dict.yaml`**：
```yaml
---
name: double_pinyin_flypy_ice
version: "2026.02.02"
import_tables:
  - rime_ice  # 导入雾凇拼音的所有词库数据
...
```

**修改方案配置**：
```yaml
translator:
  dictionary: double_pinyin_flypy_ice  # 使用独立的词典名称
```

**缺点**：
- 会生成独立的 `double_pinyin_flypy_ice.table.bin`（约 58M），占用额外空间
- 编译时间更长
- 词库数据实际上是重复的

---

## 验证修复

### 1. 删除旧的编译文件

```bash
cd ~/Library/Rime/build
rm -f rime_ice.prism.bin rime_ice.reverse.bin
rm -f double_pinyin_flypy_ice.*
```

### 2. 重新部署

点击输入法图标 → "重新部署"

### 3. 测试全拼方案

选择"雾凇拼音"，输入 `nihao`：
- ✅ 期望输出："你好"

### 4. 测试双拼方案

切换到"小鹤双拼·雾凇"，输入 `nihc`（ni=你，hc=好）：
- ✅ 期望输出："你好"

---

## 关键知识点

### 1. Rime 文件结构

```
用户配置目录 (~/.config/ibus/rime 或 ~/Library/Rime)
├── *.schema.yaml       # 方案配置文件
├── *.dict.yaml         # 词典配置文件
└── build/              # 编译输出目录
    ├── *.prism.bin     # 拼写索引（按 schema_id 或 prism 参数命名）
    ├── *.table.bin     # 词库数据（按 dictionary 名称命名）
    ├── *.reverse.bin   # 反查索引
    └── *.schema.yaml   # 编译后的方案配置
```

### 2. dictionary 与 prism 的关系

| 配置项 | 作用 | 生成的文件 |
|--------|------|-----------|
| `dictionary: rime_ice` | 指定使用的词库数据 | `rime_ice.table.bin` |
| `prism: xxx`（可选） | 指定拼写索引的名称 | `xxx.prism.bin` |
| 默认（无 prism） | 使用 schema_id 作为 prism 名称 | `{schema_id}.prism.bin` |

### 3. 为什么需要 prism 参数

当多个方案使用同一个词典但编码方式不同时（如全拼 vs 双拼），必须使用不同的 prism 文件：

```
rime_ice (全拼)         → dictionary: rime_ice → rime_ice.table.bin
                        → (默认 prism)        → rime_ice.prism.bin (全拼索引)

double_pinyin_flypy_ice → dictionary: rime_ice → rime_ice.table.bin (共享)
                        → prism: double_pinyin_flypy_ice
                                              → double_pinyin_flypy_ice.prism.bin (双拼索引)
```

### 4. 常见错误配置

❌ **错误**：两个方案都用 `dictionary: rime_ice`，没有指定 prism
```yaml
# rime_ice.schema.yaml
translator:
  dictionary: rime_ice  # 会生成 rime_ice.prism.bin

# double_pinyin_flypy_ice.schema.yaml
translator:
  dictionary: rime_ice  # 可能会覆盖 rime_ice.prism.bin！
```

✅ **正确**：使用 prism 参数区分
```yaml
# rime_ice.schema.yaml
translator:
  dictionary: rime_ice  # 默认 prism: rime_ice

# double_pinyin_flypy_ice.schema.yaml
translator:
  dictionary: rime_ice
  prism: double_pinyin_flypy_ice  # 使用独立的 prism
```

---

## 预防措施

### 1. 创建双拼方案时的检查清单

- [ ] 确认 `translator.dictionary` 使用的词典名称
- [ ] 如果复用其他方案的词典，**必须**添加 `translator.prism` 参数
- [ ] prism 参数应该与 schema_id 一致或使用有意义的名称
- [ ] 在 `radical_reverse_lookup.dictionary` 等其他引用词典的地方保持一致

### 2. 方案配置模板

```yaml
schema:
  schema_id: my_double_pinyin
  name: 我的双拼方案

translator:
  dictionary: rime_ice              # 使用雾凇词典
  prism: my_double_pinyin           # ⚠️ 重要：使用独立 prism
  enable_word_completion: true
  spelling_hints: 8

speller:
  algebra:
    - xform/...  # 双拼转换规则
```

### 3. 编译后验证

```bash
# 检查生成的 prism 文件大小
ls -lh ~/Library/Rime/build/*.prism.bin

# 全拼的 prism 应该比双拼的大（因为全拼有更多拼写组合）
# 如果两个文件大小相同或接近，可能有问题
```

---

## 参考资料

- [Rime 官方文档 - Schema.yaml 详解](https://github.com/rime/home/wiki/RimeWithSchemata)
- [Rime 词典管理](https://github.com/rime/home/wiki/DictionaryPack)
- [雾凇拼音项目](https://github.com/iDvel/rime-ice)

---

## 总结

这个问题的本质是 **Rime 的 prism 文件冲突**，当多个方案使用相同的词典名称但采用不同的拼音编码方式时，必须通过 `prism` 参数来区分各自的拼写索引文件。

**关键教训**：
1. ✅ 使用 `prism` 参数来避免索引文件冲突
2. ✅ 理解 `dictionary`（词库数据）和 `prism`（拼写索引）的区别
3. ✅ 在隔离环境中测试新方案，避免影响现有配置
4. ✅ 遇到输入异常时，优先检查是否有方案冲突

---

*文档生成时间：2026-02-02*
*问题解决时间：约 2 小时*
*涉及文件：rime_ice.schema.yaml, double_pinyin_flypy_ice.schema.yaml*
