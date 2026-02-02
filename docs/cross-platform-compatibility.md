# oh-my-rime 跨平台兼容性说明

## 📋 概述

本配置方案**完全兼容** Windows、macOS 和 Linux 平台，可以直接 clone 后使用。

## ✅ 跨平台兼容性

### 核心配置文件（完全兼容）

以下配置文件在所有平台上**完全通用**：

```
📁 核心方案文件
├── default.yaml                    # 方案列表、快捷键等通用配置
├── *.schema.yaml                   # 所有输入方案配置
├── *.dict.yaml                     # 所有词典文件
├── symbols.yaml                    # 符号映射
├── dicts/                          # 词库目录
└── lua/                            # Lua 脚本（跨平台）
```

**兼容性说明**：
- ✅ 方案配置（.schema.yaml）完全通用
- ✅ 词典文件（.dict.yaml）完全通用
- ✅ Lua 脚本跨平台兼容
- ✅ 没有硬编码的平台路径
- ✅ 不依赖平台特定的功能

### 平台特定配置文件（可选）

以下文件为**平台外观配置**，不影响输入功能：

| 文件 | 平台 | 说明 |
|------|------|------|
| `squirrel.yaml` | macOS（鼠须管） | 候选窗口样式、皮肤配置 |
| `weasel.yaml` | Windows（小狼毫） | 候选窗口样式、皮肤配置 |
| `ibus_rime.yaml` | Linux（iBus） | 候选窗口样式配置 |

**重要**：
- 这些文件只影响外观，不影响输入逻辑
- 如果平台不匹配，Rime 会自动忽略
- 可以安全地将所有文件一起复制

## 🚀 跨平台使用步骤

### 方法一：直接 Clone（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/YOUR_USERNAME/oh-my-rime.git

# 2. 复制到 Rime 配置目录
# Windows (小狼毫)
xcopy oh-my-rime\*.* %APPDATA%\Rime\ /E /Y

# macOS (鼠须管)
cp -r oh-my-rime/* ~/Library/Rime/

# Linux (iBus)
cp -r oh-my-rime/* ~/.config/ibus/rime/

# Linux (Fcitx5)
cp -r oh-my-rime/* ~/.local/share/fcitx5/rime/

# 3. 重新部署 Rime
# 在输入法菜单中选择"重新部署"
```

### 方法二：符号链接（开发者推荐）

**macOS/Linux**:
```bash
# 备份原配置
mv ~/Library/Rime ~/Library/Rime.backup  # macOS
# 或
mv ~/.config/ibus/rime ~/.config/ibus/rime.backup  # Linux iBus

# 创建符号链接
ln -s /path/to/oh-my-rime ~/Library/Rime  # macOS
# 或
ln -s /path/to/oh-my-rime ~/.config/ibus/rime  # Linux iBus
```

**Windows**（需要管理员权限）:
```cmd
# 备份原配置
move %APPDATA%\Rime %APPDATA%\Rime.backup

# 创建符号链接（需要管理员权限）
mklink /D %APPDATA%\Rime C:\path\to\oh-my-rime
```

## 📍 各平台配置目录

| 平台 | 前端 | 配置目录 |
|------|------|----------|
| **Windows** | 小狼毫 (Weasel) | `%APPDATA%\Rime` |
| **macOS** | 鼠须管 (Squirrel) | `~/Library/Rime` |
| **macOS** | Fcitx5 | `~/.local/share/fcitx5/rime` |
| **Linux** | iBus | `~/.config/ibus/rime` |
| **Linux** | Fcitx5 | `~/.local/share/fcitx5/rime` |
| **Android** | Fcitx5 (小企鹅) | `/storage/emulated/0/Android/data/org.fcitx.fcitx5.android/files/data/rime/` |

## ⚠️ 已知的平台差异

### 1. 外观配置不通用

**现象**：
- macOS 的 `squirrel.yaml` 在 Windows 上无效
- Windows 的 `weasel.yaml` 在 macOS 上无效

**影响**：仅影响候选窗口外观，不影响输入功能

**解决**：Rime 会自动使用对应平台的配置文件

### 2. 字体配置

**Windows (`weasel.yaml`)**:
```yaml
style:
  font_face: "Microsoft YaHei, Segoe UI Emoji"  # Windows 系统字体
```

**macOS (`squirrel.yaml`)**:
```yaml
style:
  font_face: "PingFang SC, Apple Color Emoji"   # macOS 系统字体
```

**建议**：使用跨平台字体或为每个平台准备 `.custom.yaml` 覆盖配置

### 3. 路径分隔符

**兼容性处理**：
- Rime 配置文件中的路径使用 `/`（Unix 风格）
- Windows 会自动处理路径分隔符转换
- 词典导入路径使用相对路径，天然跨平台

### 4. 用户词典 (.userdb)

**兼容性**：
- ✅ 词典数据格式完全通用
- ✅ 可以在不同平台间同步用户词典
- ⚠️ 需要注意文件权限（Windows 可能需要解锁）

**同步方法**：
```bash
# 备份用户词典
cp -r ~/Library/Rime/*.userdb /path/to/backup/

# 恢复到另一台设备
cp -r /path/to/backup/*.userdb ~/Library/Rime/
```

## 🔍 兼容性验证清单

### 安装后检查项目

- [ ] 运行 Rime 并重新部署成功
- [ ] 所有输入方案出现在方案选择菜单中
- [ ] 能够正常输入中文（测试全拼和双拼）
- [ ] Lua 脚本功能正常（日期、计算器等）
- [ ] 符号输入正常（测试 `v` 模式）
- [ ] 简繁转换正常
- [ ] Emoji 输入正常

### 检查编译文件

编译成功后，`build/` 目录应包含：

```bash
build/
├── *.prism.bin      # 拼写索引（每个方案一个）
├── *.table.bin      # 词库数据
├── *.reverse.bin    # 反查索引
└── *.schema.yaml    # 编译后的方案配置
```

**验证命令**：
```bash
# macOS/Linux
ls -lh ~/Library/Rime/build/*.prism.bin

# Windows (PowerShell)
dir "$env:APPDATA\Rime\build\*.prism.bin"
```

## 🐛 常见问题

### Q1: 复制后无法部署/方案列表为空

**原因**：可能存在符号链接或文件权限问题

**解决**：
```bash
# 1. 检查符号链接是否正确
ls -la ~/Library/Rime/  # macOS/Linux
dir %APPDATA%\Rime      # Windows

# 2. 确保文件有读取权限
chmod -R u+r ~/Library/Rime/  # macOS/Linux

# 3. 删除 build 目录并重新部署
rm -rf ~/Library/Rime/build/  # macOS/Linux
```

### Q2: Lua 脚本不工作

**原因**：Lua 版本或 librime 版本过旧

**解决**：
- 更新 Rime 到最新版本（需要 librime >= 1.8.0）
- 检查 `lua/` 目录是否正确复制

### Q3: 词库编译失败

**原因**：词典文件格式或路径问题

**解决**：
```bash
# 检查词典文件完整性
grep "^name:" *.dict.yaml

# 检查词典导入路径
grep "import_tables:" *.dict.yaml
```

### Q4: Windows 上中文显示乱码

**原因**：文件编码问题

**解决**：
- 确保所有 `.yaml` 文件使用 UTF-8 编码
- Windows 用户建议使用 Git Bash 或 WSL 操作文件

## 📚 平台特定优化建议

### macOS 优化

**配置 `squirrel.custom.yaml`**:
```yaml
patch:
  style:
    color_scheme: purity_of_form_custom  # 使用适合 macOS 的主题
    font_face: "PingFang SC"             # macOS 原生字体
```

### Windows 优化

**配置 `weasel.custom.yaml`**:
```yaml
patch:
  style:
    color_scheme: purity_of_form_custom
    font_face: "Microsoft YaHei"         # Windows 原生字体
```

### Linux 优化

**配置 `ibus_rime.custom.yaml` 或 `fcitx5_rime.custom.yaml`**:
```yaml
patch:
  style:
    horizontal: true                     # 横向候选
    font_face: "Noto Sans CJK SC"       # Linux 推荐字体
```

## 🎯 最佳实践

### 1. 使用 Git 管理配置

**推荐的 .gitignore 配置**:
```gitignore
# 忽略编译文件
build/
*.userdb/
*.bin

# 忽略平台特定的安装信息
installation.yaml

# 忽略个人配置覆盖（可选）
*.custom.yaml

# 保留示例文件
!example.custom.yaml
```

### 2. 跨平台同步方案

**方案 A：Git 仓库同步**
```bash
# 在设备 A 上提交
git add *.schema.yaml *.dict.yaml lua/
git commit -m "update: ..."
git push

# 在设备 B 上拉取
git pull
# 重新部署 Rime
```

**方案 B：云盘同步**
- 将配置目录放在 iCloud / OneDrive / Dropbox
- 在不同设备上创建符号链接指向云盘目录
- ⚠️ 注意：`build/` 和 `.userdb/` 可能不同步

### 3. 多设备共享用户词典

使用 Git LFS 或云盘同步用户词典：

```bash
# 定期备份用户词典
tar -czf userdb-backup-$(date +%Y%m%d).tar.gz *.userdb

# 在新设备恢复
tar -xzf userdb-backup-20260202.tar.gz
```

## ✅ 总结

**本配置方案的跨平台兼容性**：

| 功能 | Windows | macOS | Linux |
|------|---------|-------|-------|
| 输入方案 | ✅ | ✅ | ✅ |
| 词库 | ✅ | ✅ | ✅ |
| Lua 脚本 | ✅ | ✅ | ✅ |
| 用户词典同步 | ✅ | ✅ | ✅ |
| 外观配置 | 平台专用 | 平台专用 | 平台专用 |

**可以放心地**：
- ✅ 在任何平台上 clone 并使用
- ✅ 在不同平台间同步配置
- ✅ 使用 Git 管理和版本控制
- ✅ 与团队共享配置

**注意事项**：
- ⚠️ 首次使用需要重新部署
- ⚠️ 外观配置需要根据平台调整
- ⚠️ 注意文件编码为 UTF-8
- ⚠️ 符号链接在 Windows 上需要管理员权限

---

*最后更新：2026-02-02*
