#!/bin/bash
# custom_phrase.txt 快速添加工具
# 使用方法: ./add_custom_phrase.sh "内容" "编码" "权重(可选)"

PHRASE_FILE="custom_phrase.txt"

if [ $# -lt 2 ]; then
    echo "❌ 用法: $0 \"内容\" \"编码\" [权重]"
    echo ""
    echo "示例:"
    echo "  $0 \"im.skyrain@gmail.com\" \"yx\" 99"
    echo "  $0 \"收到，马上处理\" \"sdcl\""
    echo ""
    exit 1
fi

CONTENT="$1"
CODE="$2"
WEIGHT="${3:-99}"  # 默认权重 99

# 检查文件是否存在
if [ ! -f "$PHRASE_FILE" ]; then
    echo "❌ 错误: 找不到 $PHRASE_FILE 文件"
    exit 1
fi

# 使用 printf 确保使用 Tab 分隔符
NEW_ENTRY=$(printf "%s\t%s\t%s\n" "$CONTENT" "$CODE" "$WEIGHT")

# 添加到文件末尾
echo "$NEW_ENTRY" >> "$PHRASE_FILE"

echo "✅ 成功添加到 $PHRASE_FILE:"
echo "   内容: $CONTENT"
echo "   编码: $CODE"
echo "   权重: $WEIGHT"
echo ""
echo "📝 验证格式（应该看到 \\t 表示 Tab）:"
grep -F "$CONTENT" "$PHRASE_FILE" | tail -1 | od -c | head -3
echo ""
echo "🔄 下一步: 重新部署 Rime 输入法"
echo "   macOS: 点击菜单栏输入法图标 → Deploy / 重新部署"
