#!/bin/bash

# Image Optimization Script for Jekyll Site
# This script converts images to WebP format and generates responsive versions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🖼️  Starting image optimization...${NC}"

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo -e "${RED}❌ cwebp is not installed. Please install webp tools:${NC}"
    echo "macOS: brew install webp"
    echo "Ubuntu: sudo apt install webp"
    exit 1
fi

# Create WebP versions of images
IMAGE_DIR="images"
OPTIMIZED_COUNT=0

if [ -d "$IMAGE_DIR" ]; then
    echo -e "${YELLOW}📁 Processing images in $IMAGE_DIR...${NC}"
    
    # Process JPG and PNG files
    for file in "$IMAGE_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            name="${filename%.*}"
            webp_file="$IMAGE_DIR/${name}.webp"
            
            # Skip if WebP already exists and is newer
            if [ -f "$webp_file" ] && [ "$webp_file" -nt "$file" ]; then
                echo "⏭️  Skipping $filename (WebP up to date)"
                continue
            fi
            
            echo "🔄 Converting $filename to WebP..."
            
            # Convert to WebP with high quality
            if cwebp -q 85 -m 6 "$file" -o "$webp_file"; then
                original_size=$(wc -c < "$file")
                webp_size=$(wc -c < "$webp_file")
                savings=$((100 - (webp_size * 100 / original_size)))
                
                echo -e "${GREEN}✅ Converted $filename (${savings}% smaller)${NC}"
                ((OPTIMIZED_COUNT++))
            else
                echo -e "${RED}❌ Failed to convert $filename${NC}"
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠️  Images directory not found: $IMAGE_DIR${NC}"
fi

# Generate responsive image sizes for key images
PROFILE_IMAGE="$IMAGE_DIR/liang_chen.jpg"
if [ -f "$PROFILE_IMAGE" ]; then
    echo -e "${YELLOW}📐 Generating responsive sizes for profile image...${NC}"
    
    # Check if ImageMagick is available
    if command -v convert &> /dev/null; then
        for size in 150 300 600; do
            output_file="$IMAGE_DIR/liang_chen_${size}w.jpg"
            webp_output="$IMAGE_DIR/liang_chen_${size}w.webp"
            
            if [ ! -f "$output_file" ]; then
                convert "$PROFILE_IMAGE" -resize "${size}x${size}>" -quality 85 "$output_file"
                echo "✅ Generated ${size}px version"
            fi
            
            if [ ! -f "$webp_output" ]; then
                cwebp -q 85 "$output_file" -o "$webp_output"
                echo "✅ Generated ${size}px WebP version"
            fi
        done
    else
        echo -e "${YELLOW}⚠️  ImageMagick not installed. Skipping responsive image generation.${NC}"
        echo "macOS: brew install imagemagick"
        echo "Ubuntu: sudo apt install imagemagick"
    fi
fi

echo -e "${GREEN}🎉 Image optimization complete!${NC}"
echo -e "${GREEN}📊 Optimized $OPTIMIZED_COUNT images${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "• Use <picture> elements with WebP fallbacks in your templates"
echo "• Consider using 'loading=\"lazy\"' for images below the fold"
echo "• Test your images on different devices and connections"
