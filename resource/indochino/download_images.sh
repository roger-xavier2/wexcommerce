#!/bin/bash

# 创建图片目录
mkdir -p images

# 产品列表（从页面快照中提取的产品ID）
declare -A products=(
    ["15015811"]="Hartley Cotton Stretch Light Blue Suit"
    ["15010154"]="Hemsworth Black Suit"
    ["15022844"]="Hexham Black Suit"
    ["15022856"]="Hexham Charcoal Suit"
    ["15010685"]="Hayle Sharkskin Slate Blue Suit"
    ["15022868"]="Hexham Gray Suit"
    ["15010148"]="Hemsworth Charcoal Suit"
    ["15010749"]="Hampton Black Tuxedo"
    ["15010130"]="Hemsworth Navy Suit"
    ["15015273"]="Hartley Cotton Stretch Blue Suit"
)

# 下载函数
download_image() {
    local id=$1
    local name=$2
    local filename=$(echo "$name" | sed 's/[^a-zA-Z0-9 -]//g' | sed 's/ /_/g')
    
    # 尝试不同的图片URL格式
    local urls=(
        "https://i8.amplience.net/i/indochino/${id}_0_0.jpg?w=800&h=1000&qlt=75"
        "https://i8.amplience.net/i/indochino/${id}_0_0.jpg?w=400&h=500&qlt=75"
        "https://i8.amplience.net/i/indochino/${id}_0_0.jpg"
    )
    
    for url in "${urls[@]}"; do
        echo "尝试下载: $name - $url"
        if curl -s -f -L -o "images/${filename}.jpg" "$url" --max-time 10; then
            # 检查文件大小（至少1KB）
            if [ -s "images/${filename}.jpg" ] && [ $(stat -f%z "images/${filename}.jpg" 2>/dev/null || stat -c%s "images/${filename}.jpg" 2>/dev/null) -gt 1000 ]; then
                echo "✓ 成功下载: ${filename}.jpg"
                return 0
            else
                rm -f "images/${filename}.jpg"
            fi
        fi
    done
    
    echo "✗ 下载失败: $name"
    return 1
}

# 下载所有产品图片
echo "开始下载 Indochino 产品图片..."
echo ""

for id in "${!products[@]}"; do
    download_image "$id" "${products[$id]}"
    echo ""
done

echo "完成！图片保存在: images/"

