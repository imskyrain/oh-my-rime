# 输入方案专属配色方案

## 📋 概述

本配置为不同的输入方案配置了独立的配色主题，方便在切换输入方案时获得不同的视觉体验。

## 🎨 配色分配

| 输入方案 | Schema ID | 配色主题 | 说明 |
|---------|-----------|---------|------|
| **雾凇拼音** | `rime_ice` | 碧月青（mint_dark_green） | 深色绿色主题，沉稳优雅 |
| **雾凇双拼** | `double_pinyin_flypy_ice` | 黑水鸭（mint_dark_blue） | 深色蓝色主题，专业高效 |
| **薄荷拼音** | `rime_mint` | 蓝水鸭（mint_light_blue） | 浅色蓝色主题，清新明亮 |

## ⚙️ 实现原理

在每个 schema 配置文件末尾添加 `style` 节点，指定该方案的专属配色：

```yaml
# 方案专属配色
style:
  color_scheme: mint_dark_green        # 亮色模式使用的配色
  color_scheme_dark: mint_dark_green   # 暗色模式使用的配色
```

### 配置说明

- **`color_scheme`**: 系统处于亮色模式（Light Mode）时使用的配色方案
- **`color_scheme_dark`**: 系统处于暗色模式（Dark Mode）时使用的配色方案

## 📝 配置文件位置

- **雾凇拼音**: `rime_ice.schema.yaml:454-458`
- **雾凇双拼**: `double_pinyin_flypy_ice.schema.yaml:302-306`
- **薄荷拼音**: `rime_mint.schema.yaml:424-428`

## 🎨 可用配色主题

所有配色主题定义在 `squirrel.yaml` 的 `preset_color_schemes` 节点中：

### Mintimate 薄荷系列

| 主题名称 | Schema Key | 风格 | 特点 |
|---------|-----------|------|------|
| 蓝水鸭 | `mint_light_blue` | 浅色 | 清新蓝色，适合日常使用 |
| 黑水鸭 | `mint_dark_blue` | 深色 | 深蓝背景，护眼舒适 |
| 碧皓青 | `mint_light_green` | 浅色 | 清新绿色，柔和护眼 |
| 碧月青 | `mint_dark_green` | 深色 | 深绿背景，优雅沉稳 |

### Rime 官方内置主题

| 主题名称 | Schema Key | 风格 |
|---------|-----------|------|
| 系统配色 | `native` | 跟随系统 |
| 碧水 | `aqua` | 浅色 |
| 青天 | `azure` | 深色 |
| 明月 | `luna` | 深色 |
| 墨池 | `ink` | 浅色 |
| 孤寺 | `lost_temple` | 深色 |
| 暗堂 | `dark_temple` | 深色 |
| 幽能 | `psionics` | 深色 |
| 纯粹的形式 | `purity_of_form` | 深色 |
| 纯粹的本质 | `purity_of_essence` | 浅色 |
| 星际争霸 | `starcraft` | 深色 |
| 谷歌 | `google` | 浅色 |
| 曬經石 | `solarized_rock` | 深色 |
| 简约白 | `clean_white` | 浅色 |
| 冷漠 | `apathy` | 浅色 |
| 浮尘 | `dust` | 浅色 |
| 沙漠夜 | `mojave_dark` | 深色 |
| 曬經·日 | `solarized_light` | 浅色 |
| 曬經·月 | `solarized_dark` | 深色 |

## 🔧 自定义配色

### 为其他输入方案配置专属配色

在对应的 `.schema.yaml` 文件末尾添加：

```yaml
# 方案专属配色
style:
  color_scheme: your_light_theme_key
  color_scheme_dark: your_dark_theme_key
```

### 配色优先级

Rime 的配色加载优先级：

1. **Schema 专属配色** (最高优先级)
   - 在 `*.schema.yaml` 中的 `style/color_scheme`

2. **全局配置**
   - 在 `squirrel.yaml` 中的 `style/color_scheme`

3. **系统默认**
   - 如果以上都未配置，使用 Rime 内置默认主题

## 🔄 如何切换配色

### 方法一：修改 Schema 配置（推荐）

直接修改对应方案的 `*.schema.yaml` 文件：

```yaml
style:
  color_scheme: mint_light_green  # 改成你想要的配色
```

### 方法二：使用 `.custom.yaml` 覆盖

创建 `rime_ice.custom.yaml`（以雾凇拼音为例）：

```yaml
patch:
  style:
    color_scheme: mint_light_green
    color_scheme_dark: mint_dark_green
```

**优点**：不修改原始文件，升级时不会丢失配置

### 方法三：临时更改全局配色

修改 `squirrel.yaml` 中的全局配色：

```yaml
style:
  color_scheme: mint_light_blue
  color_scheme_dark: mint_dark_blue
```

**注意**：会影响所有没有专属配色的方案

## ✅ 使配置生效

修改配置后，需要重新部署 Rime：

1. **macOS（鼠须管）**:
   - 在输入法菜单中选择「重新部署」
   - 或按快捷键 `Control+Option+`

2. **Windows（小狼毫）**:
   - 在系统托盘图标上右键，选择「重新部署」

3. **Linux（iBus/Fcitx5）**:
   - 在输入法菜单中选择「Deploy」
   - 或重启输入法服务

## 🎯 配色效果预览

### 碧月青（mint_dark_green）- 雾凇拼音

- **背景色**: 深灰绿 `#323232`
- **选中背景**: 青绿色 `#83C81C`
- **文字颜色**: 浅灰白 `#E8E8E8`
- **选中文字**: 白色 `#EFEFEF`
- **拼音颜色**: 青绿色 `#83C81C`

### 黑水鸭（mint_dark_blue）- 雾凇双拼

- **背景色**: 深灰色 `#424242`
- **选中背景**: 金黄色 `#c6c01a`
- **文字颜色**: 浅灰白 `#efefef`
- **选中文字**: 白色 `#efefef`
- **拼音颜色**: 蓝色 `#6495ed`

### 蓝水鸭（mint_light_blue）- 薄荷拼音

- **背景色**: 浅灰色 `#efefef`
- **选中背景**: 橙色 `#ed9564`
- **文字颜色**: 深灰色 `#424242`
- **选中文字**: 白色 `#efefef`
- **拼音颜色**: 蓝色 `#6495ed`

## 📚 相关资源

- [鼠须管皮肤展示](https://github.com/NavisLab/rime-pifu)
- [鼠须管界面配置指南](https://github.com/LEOYoon-Tsaw/Rime_collections/blob/master/鼠鬚管介面配置指南.md)
- [鼠须管皮肤设计器](https://github.com/LEOYoon-Tsaw/Squirrel-Designer)
- [小狼毫皮肤配置](https://github.com/rime/weasel/wiki/CustomizationGuide)

## 🐛 常见问题

### Q1: 修改配置后没有生效？

**解决方案**:
1. 确保 YAML 缩进正确（使用 2 个空格）
2. 执行「重新部署」操作
3. 检查是否有 `.custom.yaml` 文件覆盖了配置

### Q2: 想要所有方案使用同一个配色？

**解决方案**:
1. 删除各个 schema 中的 `style` 配置
2. 在 `squirrel.yaml` 中配置全局 `style/color_scheme`
3. 重新部署

### Q3: 切换方案后配色没有立即改变？

**解决方案**:
这是正常现象。Rime 在切换方案时会加载对应的配色，但可能需要：
- 输入新内容触发候选框刷新
- 或者切换到其他应用再切回来

### Q4: 能否为每个方案配置不同的字体？

**解决方案**:
可以！在 `style` 节点下添加字体配置：

```yaml
style:
  color_scheme: mint_dark_green
  font_face: "PingFang SC"        # 候选词字体
  font_point: 18                  # 字体大小
  label_font_face: "Monaco"       # 序号字体
```

## 🎨 创建自定义配色

在 `squirrel.custom.yaml` 中添加自己的配色方案：

```yaml
patch:
  preset_color_schemes:
    my_custom_theme:
      name: 我的自定义主题
      author: Your Name
      back_color: 0xFFFFFF                    # 背景色（BGR 格式）
      candidate_text_color: 0x000000          # 候选词颜色
      hilited_candidate_back_color: 0x3399FF  # 选中背景色
      hilited_candidate_text_color: 0xFFFFFF  # 选中文字颜色
      # ... 更多配置项
```

然后在 schema 中引用：

```yaml
style:
  color_scheme: my_custom_theme
```

---

*配置文件更新日期：2026-02-02*
