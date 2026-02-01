#!/bin/bash

echo "=== Rime 配置检查工具 ==="
echo ""

# 1. 检查配置目录
echo "1️⃣  配置目录位置："
echo "   ~/Library/Rime"
echo ""

# 2. 检查方案文件
echo "2️⃣  已安装方案："
if [ -f ~/Library/Rime/rime_ice.schema.yaml ]; then
    echo "   ✅ rime_ice.schema.yaml (雾凇拼音) - 存在"
else
    echo "   ❌ rime_ice.schema.yaml (雾凇拼音) - 缺失"
fi

if [ -f ~/Library/Rime/double_pinyin_flypy_ice.schema.yaml ]; then
    echo "   ✅ double_pinyin_flypy_ice.schema.yaml (小鹤双拼·雾凇) - 存在"
else
    echo "   ❌ double_pinyin_flypy_ice.schema.yaml (小鹤双拼·雾凇) - 缺失"
fi
echo ""

# 3. 检查词库文件
echo "3️⃣  词库文件："
if [ -L ~/Library/Rime/rime_ice.dict.yaml ]; then
    target=$(readlink ~/Library/Rime/rime_ice.dict.yaml)
    echo "   ✅ rime_ice.dict.yaml → $target"
    if [ -f ~/Library/Rime/"$target" ]; then
        echo "      ✅ 目标文件存在"
    else
        echo "      ❌ 目标文件不存在"
    fi
else
    echo "   ❌ rime_ice.dict.yaml 不是软链接"
fi
echo ""

# 4. 检查 cn_dicts
echo "4️⃣  中文词库目录："
if [ -L ~/Library/Rime/cn_dicts ]; then
    target=$(readlink ~/Library/Rime/cn_dicts)
    echo "   ✅ cn_dicts → $target"
    if [ -d ~/Library/Rime/"$target" ]; then
        echo "      ✅ 目录存在，包含以下文件:"
        ls -1 ~/Library/Rime/"$target"/*.dict.yaml | xargs -n1 basename | sed 's/^/         - /'
    else
        echo "      ❌ 目标目录不存在"
    fi
else
    echo "   ❌ cn_dicts 不是软链接"
fi
echo ""

# 5. 检查编译文件
echo "5️⃣  编译状态："
if [ -f ~/Library/Rime/build/rime_ice.table.bin ]; then
    size=$(ls -lh ~/Library/Rime/build/rime_ice.table.bin | awk '{print $5}')
    mtime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" ~/Library/Rime/build/rime_ice.table.bin)
    echo "   ✅ rime_ice.table.bin 已编译"
    echo "      大小: $size"
    echo "      时间: $mtime"
else
    echo "   ❌ rime_ice.table.bin 未编译"
fi

if [ -f ~/Library/Rime/build/double_pinyin_flypy_ice.prism.bin ]; then
    mtime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" ~/Library/Rime/build/double_pinyin_flypy_ice.prism.bin)
    echo "   ✅ double_pinyin_flypy_ice.prism.bin 已编译"
    echo "      时间: $mtime"
else
    echo "   ❌ double_pinyin_flypy_ice.prism.bin 未编译"
fi
echo ""

# 6. 检查 Lua 脚本
echo "6️⃣  Lua 脚本："
lua_dir=~/Library/Rime/lua
if [ -d "$lua_dir" ]; then
    echo "   ✅ lua 目录存在"
    required_scripts=(
        "date_translator.lua"
        "lunar.lua"
        "cn_en_spacer.lua"
        "is_in_user_dict.lua"
        "cold_word_drop"
    )
    for script in "${required_scripts[@]}"; do
        if [ -e "$lua_dir/$script" ]; then
            echo "      ✅ $script"
        else
            echo "      ❌ $script (缺失)"
        fi
    done
else
    echo "   ❌ lua 目录不存在"
fi
echo ""

# 7. 建议操作
echo "=========================================="
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 重新部署 Rime："
echo "   点击输入法图标 → 「重新部署」"
echo ""
echo "2. 切换输入方案："
echo "   按 Ctrl+\` 或 F4 → 选择「雾凇拼音」"
echo ""
echo "3. 如果还是不行，查看日志："
echo "   tail -50 ~/Library/Logs/Squirrel.INFO"
echo ""
echo "=========================================="
