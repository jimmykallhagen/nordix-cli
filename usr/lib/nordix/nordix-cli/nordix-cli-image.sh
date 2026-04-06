#!/bin/bash
##============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                      #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0  #
 # Copyright (c) 2025 Jimmy Källhagen                                         #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                     #
##============================================================================##
# ============================================
# Nordix CLI Image - Version 1.0
# Image manipulation tool using ImageMagick
# ============================================

# ============================================
# NORDIX COLORS
# ============================================
RED='\033[38;2;255;0;0m'
GREEN='\033[38;2;0;255;0m'
YELLOW='\033[38;2;255;255;0m'
WHITE='\033[38;2;255;255;255m'
BLUE='\033[38;2;1;204;255m'
NBLUE='\033[38;2;19;171;198m'
NVBLUE='\033[38;2;175;251;253m'
NICE='\033[38;2;0;132;175m'
NARTIC='\033[38;2;156;230;255m'
NGLACIER='\033[38;2;80;200;255m'
NVFROST='\033[38;2;210;255;255m'
NHYPRBLUE='\033[38;2;0;210;255m'
NC='\033[0m'

# ============================================
# UI HELPER FUNCTIONS
# ============================================

draw_box() {
    local text="$1"
    local length=${#text}
    local border=$(printf '%*s' $((length+4)) | tr ' ' '=')
    echo -e "${BLUE}${border}${NC}"
    echo -e "${BLUE}|${NC} ${NARTIC}$text${NC} ${BLUE}|${NC}"
    echo -e "${BLUE}${border}${NC}"
}

draw_border() {
    echo -e "${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NC}"
}

confirm_action() {
    local message="$1"
    echo ""
    echo -e "${NARTIC}$message${NC}"
    echo -ne "${WHITE}Continue? ${NHYPRBLUE}[Y/n]: ${NC}"
    read -r confirm
    case "$confirm" in
        [yY]|[yY][eE][sS]|"")
            return 0
            ;;
        *)
            echo -e "${RED}Cancelled.${NC}"
            return 1
            ;;
    esac
}

press_enter() {
    echo ""
    echo -ne "${WHITE}Press Enter to continue...${NC}"
    read -r
}

# ============================================
# TOOL CHECK FUNCTIONS
# ============================================

have_cmd() {
    command -v "$1" &>/dev/null
}

check_imagemagick() {
    if ! have_cmd magick; then
        echo -e "${YELLOW}!${NC} ${WHITE}ImageMagick is not installed.${NC}"
        echo -ne "${WHITE}Install imagemagick? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_choice
        case "$install_choice" in
            [yY]|[yY][eE][sS]|"")
                sudo pacman -S --needed --noconfirm imagemagick
                if ! have_cmd magick; then
                    echo -e "${RED}[X]${NC} ${WHITE}Installation failed!${NC}"
                    exit 1
                fi
                echo -e "${GREEN}[OK]${NC} ${WHITE}ImageMagick installed!${NC}"
                ;;
            *)
                echo -e "${RED}[X]${NC} ${WHITE}ImageMagick is required.${NC}"
                exit 1
                ;;
        esac
    fi
}

# ============================================
# HELP DISPLAY
# ============================================
show_help() {
    clear
    echo ""
    echo -e "${NGLACIER}    ____  ___ ______ _______ _______ ____________    ____   ${NC}"
    echo -e "${NGLACIER}    |  \ |  |/  __  \|  __  \|   __ \ \_    _/\  \  /  /    ${NC}"
    echo -e "${NGLACIER}    |   \|  |  |  |  | |__)  |  |  | |  |  |   \  \/  /     ${NC}"
    echo -e "${NGLACIER}    |  |\   |  |__|  |  __  <|  |__| | _|  |_  /  /\  \     ${NC}"
    echo -e "${NGLACIER}  --|__| \__|\______/|__| \__|______/ /______\/__/  \__\-- ${NC}"
    echo -e "${NVBLUE}.__________________________________________________________.${NC}"
    echo -e "${NARTIC}...........................     ............................${NC}"
    echo -e "${NARTIC}.................                     ...................${NC}"
    echo -e "${NARTIC}..........                                ............${NC}"
    echo -e "${NARTIC}......                                     ......${NC}"
    echo -e "${NARTIC}...                                       ...${NC}"
    echo -e "${NARTIC}.                                       .${NC}"
    echo ""
    echo ""
    draw_box "         Nordix CLI - Image          "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DESCRIPTION:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Version 1.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Image manipulation using ImageMagick${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Convert, resize, compress, rotate images${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Strip metadata for privacy${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Create GIFs and thumbnails${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Batch processing support${NC}"
    echo ""
    draw_border
    echo ""
    exit 0
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# Check for ImageMagick
check_imagemagick

# ============================================
# HELPER FUNCTIONS
# ============================================

get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        du -h "$file" | cut -f1
    else
        echo "N/A"
    fi
}

get_image_info() {
    local file="$1"
    magick identify -format "%wx%h %m %z-bit" "$file" 2>/dev/null
}

generate_output_name() {
    local input="$1"
    local suffix="$2"
    local new_ext="$3"
    
    local dir=$(dirname "$input")
    local base=$(basename "$input")
    local name="${base%.*}"
    local ext="${base##*.}"
    
    if [[ -n "$new_ext" ]]; then
        ext="$new_ext"
    fi
    
    echo "${dir}/${name}${suffix}.${ext}"
}

select_format() {
    echo ""
    draw_border
    echo -e "${WHITE}Select output format:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}PNG ${NHYPRBLUE}(lossless, transparency)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}JPG ${NHYPRBLUE}(smaller size, photos)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}WEBP ${NHYPRBLUE}(modern, small size)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}GIF ${NHYPRBLUE}(animation, limited colors)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}BMP ${NHYPRBLUE}(uncompressed)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}TIFF ${NHYPRBLUE}(high quality, large)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}ICO ${NHYPRBLUE}(icon format)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}PDF ${NHYPRBLUE}(document)${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}AVIF ${NHYPRBLUE}(modern, excellent compression)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose format ${NHYPRBLUE}(1-9):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r format_choice
    
    case "$format_choice" in
        1) echo "png" ;;
        2) echo "jpg" ;;
        3) echo "webp" ;;
        4) echo "gif" ;;
        5) echo "bmp" ;;
        6) echo "tiff" ;;
        7) echo "ico" ;;
        8) echo "pdf" ;;
        9) echo "avif" ;;
        *) echo "" ;;
    esac
}

# ============================================
# 1. CONVERT FORMAT
# ============================================
convert_format() {
    clear
    echo ""
    draw_box "         Convert Image Format        "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    # Show current file info
    local info=$(get_image_info "$input_file")
    local size=$(get_file_size "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info ${NHYPRBLUE}($size)${NC}"
    
    local new_format=$(select_format)
    
    if [[ -z "$new_format" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Invalid format selection!${NC}"
        press_enter
        return
    fi
    
    local output_file=$(generate_output_name "$input_file" "_converted" "$new_format")
    
    echo ""
    echo -e "${WHITE}Output will be: ${NARTIC}$output_file${NC}"
    echo ""
    
    if confirm_action "Convert to $new_format?"; then
        echo ""
        echo -e "${WHITE}Converting...${NC}"
        
        if magick "$input_file" "$output_file"; then
            local new_size=$(get_file_size "$output_file")
            local new_info=$(get_image_info "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Converted successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$new_size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Info: ${NARTIC}$new_info${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Conversion failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 2. RESIZE IMAGE
# ============================================
resize_image() {
    clear
    echo ""
    draw_box "           Resize Image              "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local info=$(get_image_info "$input_file")
    local size=$(get_file_size "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info ${NHYPRBLUE}($size)${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Resize method:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}By percentage ${NHYPRBLUE}(e.g., 50%)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}By width ${NHYPRBLUE}(keep aspect ratio)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}By height ${NHYPRBLUE}(keep aspect ratio)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Exact dimensions ${NHYPRBLUE}(may distort)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Fit within box ${NHYPRBLUE}(keep aspect ratio)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose method ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r resize_method
    
    local resize_arg=""
    
    case "$resize_method" in
        1)
            echo ""
            echo -e "${WHITE}Enter percentage ${NHYPRBLUE}(e.g., 50 for 50%):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r percent
            resize_arg="${percent}%"
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter width in pixels:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r width
            resize_arg="${width}x"
            ;;
        3)
            echo ""
            echo -e "${WHITE}Enter height in pixels:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r height
            resize_arg="x${height}"
            ;;
        4)
            echo ""
            echo -e "${WHITE}Enter dimensions ${NHYPRBLUE}(e.g., 800x600):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r dimensions
            resize_arg="${dimensions}!"
            ;;
        5)
            echo ""
            echo -e "${WHITE}Enter max dimensions ${NHYPRBLUE}(e.g., 800x600):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r dimensions
            resize_arg="${dimensions}"
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_resized" "")
    
    echo ""
    echo -e "${WHITE}Resizing to: ${NARTIC}$resize_arg${NC}"
    echo -e "${WHITE}Output: ${NARTIC}$output_file${NC}"
    echo ""
    
    if confirm_action "Resize image?"; then
        echo ""
        echo -e "${WHITE}Resizing...${NC}"
        
        if magick "$input_file" -resize "$resize_arg" "$output_file"; then
            local new_size=$(get_file_size "$output_file")
            local new_info=$(get_image_info "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Resized successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}New dimensions: ${NARTIC}$new_info${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}File size: ${NARTIC}$new_size${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Resize failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 3. COMPRESS/OPTIMIZE
# ============================================
compress_image() {
    clear
    echo ""
    draw_box "       Compress/Optimize Image       "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local info=$(get_image_info "$input_file")
    local orig_size=$(get_file_size "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info ${NHYPRBLUE}($orig_size)${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Select quality level:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}High quality ${NHYPRBLUE}(90% - minimal loss)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Good quality ${NHYPRBLUE}(80% - recommended)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Medium quality ${NHYPRBLUE}(70% - balanced)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Low quality ${NHYPRBLUE}(50% - smaller file)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Custom quality ${NHYPRBLUE}(1-100)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose quality ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r quality_choice
    
    local quality=""
    
    case "$quality_choice" in
        1) quality="90" ;;
        2) quality="80" ;;
        3) quality="70" ;;
        4) quality="50" ;;
        5)
            echo ""
            echo -e "${WHITE}Enter quality ${NHYPRBLUE}(1-100):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r quality
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_compressed" "")
    
    echo ""
    echo -e "${WHITE}Compressing with quality: ${NARTIC}${quality}%${NC}"
    echo ""
    
    if confirm_action "Compress image?"; then
        echo ""
        echo -e "${WHITE}Compressing...${NC}"
        
        if magick "$input_file" -quality "$quality" -strip "$output_file"; then
            local new_size=$(get_file_size "$output_file")
            local orig_bytes=$(stat -c%s "$input_file" 2>/dev/null)
            local new_bytes=$(stat -c%s "$output_file" 2>/dev/null)
            
            if [[ -n "$orig_bytes" && -n "$new_bytes" && "$orig_bytes" -gt 0 ]]; then
                local saved=$((orig_bytes - new_bytes))
                local percent=$((saved * 100 / orig_bytes))
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Compressed successfully!${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Original: ${NARTIC}$orig_size${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Compressed: ${NARTIC}$new_size${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Saved: ${GREEN}${percent}%${NC}"
            else
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Compressed: ${NARTIC}$new_size${NC}"
            fi
        else
            echo -e "${RED}[X]${NC} ${WHITE}Compression failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 4. ROTATE IMAGE
# ============================================
rotate_image() {
    clear
    echo ""
    draw_box "           Rotate Image              "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local info=$(get_image_info "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Select rotation:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}90° clockwise${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}90° counter-clockwise${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}180°${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Custom angle${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose rotation ${NHYPRBLUE}(1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r rotate_choice
    
    local angle=""
    
    case "$rotate_choice" in
        1) angle="90" ;;
        2) angle="-90" ;;
        3) angle="180" ;;
        4)
            echo ""
            echo -e "${WHITE}Enter angle in degrees:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r angle
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_rotated" "")
    
    echo ""
    echo -e "${WHITE}Rotating by: ${NARTIC}${angle}°${NC}"
    echo ""
    
    if confirm_action "Rotate image?"; then
        echo ""
        echo -e "${WHITE}Rotating...${NC}"
        
        if magick "$input_file" -rotate "$angle" "$output_file"; then
            local new_info=$(get_image_info "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Rotated successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}New dimensions: ${NARTIC}$new_info${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Rotation failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 5. FLIP IMAGE
# ============================================
flip_image() {
    clear
    echo ""
    draw_box "            Flip Image               "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Select flip direction:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Horizontal ${NHYPRBLUE}(mirror left-right)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Vertical ${NHYPRBLUE}(mirror top-bottom)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Both${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose direction ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r flip_choice
    
    local flip_cmd=""
    local suffix=""
    
    case "$flip_choice" in
        1) 
            flip_cmd="-flop"
            suffix="_flipped_h"
            ;;
        2) 
            flip_cmd="-flip"
            suffix="_flipped_v"
            ;;
        3) 
            flip_cmd="-flip -flop"
            suffix="_flipped_both"
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "$suffix" "")
    
    echo ""
    
    if confirm_action "Flip image?"; then
        echo ""
        echo -e "${WHITE}Flipping...${NC}"
        
        if magick "$input_file" $flip_cmd "$output_file"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Flipped successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Flip failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 6. CROP IMAGE
# ============================================
crop_image() {
    clear
    echo ""
    draw_box "            Crop Image               "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local info=$(get_image_info "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Crop method:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}From center ${NHYPRBLUE}(specify size)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}From position ${NHYPRBLUE}(specify size and offset)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Trim edges ${NHYPRBLUE}(remove borders)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose method ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r crop_method
    
    local output_file=$(generate_output_name "$input_file" "_cropped" "")
    local success=false
    
    case "$crop_method" in
        1)
            echo ""
            echo -e "${WHITE}Enter crop size ${NHYPRBLUE}(e.g., 800x600):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r crop_size
            
            echo ""
            echo -e "${WHITE}Cropping ${NARTIC}$crop_size${WHITE} from center...${NC}"
            
            if magick "$input_file" -gravity center -crop "${crop_size}+0+0" +repage "$output_file"; then
                success=true
            fi
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter crop size ${NHYPRBLUE}(e.g., 800x600):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r crop_size
            
            echo ""
            echo -e "${WHITE}Enter X offset from left:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r offset_x
            
            echo ""
            echo -e "${WHITE}Enter Y offset from top:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r offset_y
            
            echo ""
            echo -e "${WHITE}Cropping ${NARTIC}$crop_size${WHITE} at position ${NARTIC}+${offset_x}+${offset_y}${WHITE}...${NC}"
            
            if magick "$input_file" -crop "${crop_size}+${offset_x}+${offset_y}" +repage "$output_file"; then
                success=true
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Trimming edges...${NC}"
            
            if magick "$input_file" -trim +repage "$output_file"; then
                success=true
            fi
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    if [[ "$success" == true ]]; then
        local new_info=$(get_image_info "$output_file")
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Cropped successfully!${NC}"
        echo -e "${NHYPRBLUE}❯${NC} ${WHITE}New dimensions: ${NARTIC}$new_info${NC}"
        echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}Crop failed!${NC}"
    fi
    
    press_enter
}

# ============================================
# 7. GRAYSCALE
# ============================================
make_grayscale() {
    clear
    echo ""
    draw_box "         Make Grayscale              "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local output_file=$(generate_output_name "$input_file" "_grayscale" "")
    
    if confirm_action "Convert to grayscale?"; then
        echo ""
        echo -e "${WHITE}Converting...${NC}"
        
        if magick "$input_file" -colorspace Gray "$output_file"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Converted to grayscale!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Conversion failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 8. STRIP METADATA
# ============================================
strip_metadata() {
    clear
    echo ""
    draw_box "     Strip Metadata (Privacy)       "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    # Show current metadata
    echo ""
    draw_border
    echo -e "${WHITE}Current metadata:${NC}"
    draw_border
    echo ""
    magick identify -verbose "$input_file" 2>/dev/null | grep -E "^[[:space:]]*(exif:|date:|GPS|Camera|Make|Model|Software)" | head -15
    echo ""
    
    echo ""
    draw_border
    echo -e "${YELLOW}!${NC} ${WHITE}This removes EXIF data including:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}GPS location${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Camera model${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Date/time taken${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Software used${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Other personal information${NC}"
    echo ""
    
    local output_file=$(generate_output_name "$input_file" "_clean" "")
    
    if confirm_action "Strip all metadata?"; then
        echo ""
        echo -e "${WHITE}Stripping metadata...${NC}"
        
        if magick "$input_file" -strip "$output_file"; then
            local orig_size=$(get_file_size "$input_file")
            local new_size=$(get_file_size "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Metadata removed!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Original: ${NARTIC}$orig_size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Clean: ${NARTIC}$new_size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to strip metadata!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 9. ADD WATERMARK/TEXT
# ============================================
add_watermark() {
    clear
    echo ""
    draw_box "        Add Watermark/Text          "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter watermark text:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r watermark_text
    
    if [[ -z "$watermark_text" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No text entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Select position:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Bottom right${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Bottom left${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Top right${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Top left${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Center${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose position ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r position_choice
    
    local gravity=""
    
    case "$position_choice" in
        1) gravity="SouthEast" ;;
        2) gravity="SouthWest" ;;
        3) gravity="NorthEast" ;;
        4) gravity="NorthWest" ;;
        5) gravity="Center" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_watermarked" "")
    
    echo ""
    
    if confirm_action "Add watermark?"; then
        echo ""
        echo -e "${WHITE}Adding watermark...${NC}"
        
        if magick "$input_file" \
            -gravity "$gravity" \
            -pointsize 24 \
            -fill "rgba(255,255,255,0.7)" \
            -stroke "rgba(0,0,0,0.5)" \
            -strokewidth 1 \
            -annotate +10+10 "$watermark_text" \
            "$output_file"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Watermark added!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to add watermark!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 10. ADD BORDER
# ============================================
add_border() {
    clear
    echo ""
    draw_box "          Add Border/Frame          "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Enter border size in pixels ${NHYPRBLUE}(e.g., 10):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r border_size
    
    echo ""
    draw_border
    echo -e "${WHITE}Select border color:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}White${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Black${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Gray${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Custom ${NHYPRBLUE}(hex color)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose color ${NHYPRBLUE}(1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r color_choice
    
    local color=""
    
    case "$color_choice" in
        1) color="white" ;;
        2) color="black" ;;
        3) color="gray" ;;
        4)
            echo ""
            echo -e "${WHITE}Enter hex color ${NHYPRBLUE}(e.g., #ff0000):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r color
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_border" "")
    
    echo ""
    
    if confirm_action "Add border?"; then
        echo ""
        echo -e "${WHITE}Adding border...${NC}"
        
        if magick "$input_file" -bordercolor "$color" -border "$border_size" "$output_file"; then
            local new_info=$(get_image_info "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Border added!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}New dimensions: ${NARTIC}$new_info${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to add border!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 11. CREATE THUMBNAIL
# ============================================
create_thumbnail() {
    clear
    echo ""
    draw_box "        Create Thumbnail            "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local info=$(get_image_info "$input_file")
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$info${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Select thumbnail size:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Small ${NHYPRBLUE}(100x100)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Medium ${NHYPRBLUE}(200x200)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Large ${NHYPRBLUE}(300x300)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Custom size${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose size ${NHYPRBLUE}(1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r size_choice
    
    local size=""
    
    case "$size_choice" in
        1) size="100x100" ;;
        2) size="200x200" ;;
        3) size="300x300" ;;
        4)
            echo ""
            echo -e "${WHITE}Enter size ${NHYPRBLUE}(e.g., 150x150):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r size
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_thumb" "")
    
    echo ""
    
    if confirm_action "Create thumbnail?"; then
        echo ""
        echo -e "${WHITE}Creating thumbnail...${NC}"
        
        if magick "$input_file" -thumbnail "$size" "$output_file"; then
            local new_info=$(get_image_info "$output_file")
            local new_size=$(get_file_size "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Thumbnail created!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Dimensions: ${NARTIC}$new_info${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$new_size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to create thumbnail!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 12. VIEW IMAGE INFO
# ============================================
view_image_info() {
    clear
    echo ""
    draw_box "         View Image Info            "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to image file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}IMAGE INFORMATION:${NC}"
    draw_border
    echo ""
    
    local filename=$(basename "$input_file")
    local filesize=$(get_file_size "$input_file")
    local dimensions=$(magick identify -format "%wx%h" "$input_file" 2>/dev/null)
    local format=$(magick identify -format "%m" "$input_file" 2>/dev/null)
    local colorspace=$(magick identify -format "%[colorspace]" "$input_file" 2>/dev/null)
    local depth=$(magick identify -format "%z" "$input_file" 2>/dev/null)
    local compression=$(magick identify -format "%C" "$input_file" 2>/dev/null)
    
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Filename: ${NARTIC}$filename${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}File size: ${NARTIC}$filesize${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Dimensions: ${NARTIC}$dimensions${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Format: ${NARTIC}$format${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Color space: ${NARTIC}$colorspace${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Bit depth: ${NARTIC}${depth}-bit${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Compression: ${NARTIC}$compression${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}METADATA (if available):${NC}"
    draw_border
    echo ""
    
    magick identify -verbose "$input_file" 2>/dev/null | grep -E "^[[:space:]]*(exif:|date:|GPS|Camera|Make|Model|Software)" | head -10 | while read -r line; do
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$line${NC}"
    done
    
    echo ""
    
    press_enter
}

# ============================================
# 13. BATCH CONVERT
# ============================================
batch_convert() {
    clear
    echo ""
    draw_box "       Batch Convert Images         "
    echo ""
    draw_border
    echo -e "${WHITE}Enter directory containing images:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_dir
    
    input_dir="${input_dir/#\~/$HOME}"
    
    if [[ ! -d "$input_dir" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Directory not found: ${NARTIC}$input_dir${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Select input format to convert:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}PNG files${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}JPG files${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}WEBP files${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}BMP files${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}All image files${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose input format ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_format
    
    local pattern=""
    
    case "$input_format" in
        1) pattern="*.png" ;;
        2) pattern="*.jpg *.jpeg" ;;
        3) pattern="*.webp" ;;
        4) pattern="*.bmp" ;;
        5) pattern="*.png *.jpg *.jpeg *.webp *.bmp *.gif *.tiff" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local new_format=$(select_format)
    
    if [[ -z "$new_format" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Invalid format selection!${NC}"
        press_enter
        return
    fi
    
    # Count files
    local file_count=0
    for ext in $pattern; do
        local count=$(find "$input_dir" -maxdepth 1 -name "$ext" 2>/dev/null | wc -l)
        file_count=$((file_count + count))
    done
    
    echo ""
    echo -e "${WHITE}Found ${NARTIC}$file_count${WHITE} files to convert.${NC}"
    echo ""
    
    if [[ $file_count -eq 0 ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}No matching files found.${NC}"
        press_enter
        return
    fi
    
    # Create output directory
    local output_dir="${input_dir}/converted_${new_format}"
    
    if confirm_action "Convert $file_count files to $new_format?"; then
        mkdir -p "$output_dir"
        echo ""
        echo -e "${WHITE}Converting...${NC}"
        echo ""
        
        local success=0
        local failed=0
        
        for ext in $pattern; do
            for file in "$input_dir"/$ext; do
                if [[ -f "$file" ]]; then
                    local basename=$(basename "$file")
                    local name="${basename%.*}"
                    local output="${output_dir}/${name}.${new_format}"
                    
                    if magick "$file" "$output" 2>/dev/null; then
                        echo -e "${GREEN}[OK]${NC} ${NARTIC}$basename${NC}"
                        success=$((success + 1))
                    else
                        echo -e "${RED}[X]${NC} ${NARTIC}$basename${NC}"
                        failed=$((failed + 1))
                    fi
                fi
            done
        done
        
        echo ""
        draw_border
        echo -e "${WHITE}Batch conversion complete!${NC}"
        draw_border
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Successful: ${NARTIC}$success${NC}"
        if [[ $failed -gt 0 ]]; then
            echo -e "${RED}[X]${NC} ${WHITE}Failed: ${NARTIC}$failed${NC}"
        fi
        echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_dir${NC}"
    fi
    
    press_enter
}

# ============================================
# 14. CREATE GIF
# ============================================
create_gif() {
    clear
    echo ""
    draw_box "       Create GIF from Images       "
    echo ""
    draw_border
    echo -e "${WHITE}Enter directory containing images:${NC}"
    echo -e "${NARTIC}Images will be sorted alphabetically.${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_dir
    
    input_dir="${input_dir/#\~/$HOME}"
    
    if [[ ! -d "$input_dir" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Directory not found: ${NARTIC}$input_dir${NC}"
        press_enter
        return
    fi
    
    # Count images
    local file_count=$(find "$input_dir" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | wc -l)
    
    echo ""
    echo -e "${WHITE}Found ${NARTIC}$file_count${WHITE} images.${NC}"
    
    if [[ $file_count -lt 2 ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Need at least 2 images to create GIF.${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Select animation speed:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Slow ${NHYPRBLUE}(1 fps)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Normal ${NHYPRBLUE}(5 fps)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Fast ${NHYPRBLUE}(10 fps)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Very fast ${NHYPRBLUE}(20 fps)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Custom delay${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose speed ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r speed_choice
    
    local delay=""
    
    case "$speed_choice" in
        1) delay="100" ;;
        2) delay="20" ;;
        3) delay="10" ;;
        4) delay="5" ;;
        5)
            echo ""
            echo -e "${WHITE}Enter delay in centiseconds ${NHYPRBLUE}(e.g., 10 = 0.1s):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r delay
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file="${input_dir}/animation.gif"
    
    echo ""
    
    if confirm_action "Create animated GIF?"; then
        echo ""
        echo -e "${WHITE}Creating GIF...${NC}"
        echo -e "${YELLOW}!${NC} ${WHITE}This may take a while for many images...${NC}"
        echo ""
        
        if magick -delay "$delay" -loop 0 "$input_dir"/*.{png,jpg,jpeg} "$output_file" 2>/dev/null; then
            local file_size=$(get_file_size "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}GIF created!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Frames: ${NARTIC}$file_count${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$file_size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to create GIF!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 15. EXTRACT GIF FRAMES
# ============================================
extract_gif_frames() {
    clear
    echo ""
    draw_box "      Extract Frames from GIF       "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to GIF file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    input_file="${input_file/#\~/$HOME}"
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    # Count frames
    local frame_count=$(magick identify "$input_file" 2>/dev/null | wc -l)
    
    echo ""
    echo -e "${WHITE}GIF has ${NARTIC}$frame_count${WHITE} frames.${NC}"
    
    local output_dir=$(dirname "$input_file")
    local basename=$(basename "$input_file" .gif)
    local frames_dir="${output_dir}/${basename}_frames"
    
    echo ""
    
    if confirm_action "Extract all frames to ${frames_dir}?"; then
        mkdir -p "$frames_dir"
        echo ""
        echo -e "${WHITE}Extracting frames...${NC}"
        
        if magick "$input_file" -coalesce "${frames_dir}/frame_%04d.png"; then
            local extracted=$(find "$frames_dir" -name "*.png" | wc -l)
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Frames extracted!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Frames: ${NARTIC}$extracted${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$frames_dir${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to extract frames!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 16. COMBINE IMAGES
# ============================================
combine_images() {
    clear
    echo ""
    draw_box "         Combine Images             "
    echo ""
    draw_border
    echo -e "${WHITE}Combine method:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Side by side ${NHYPRBLUE}(horizontal)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Stacked ${NHYPRBLUE}(vertical)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Grid ${NHYPRBLUE}(tile)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose method ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r combine_method
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter paths to images (space separated):${NC}"
    echo -e "${NARTIC}Example: image1.png image2.png image3.png${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r image_list
    
    if [[ -z "$image_list" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No images specified!${NC}"
        press_enter
        return
    fi
    
    # Expand paths
    local images=""
    for img in $image_list; do
        img="${img/#\~/$HOME}"
        if [[ -f "$img" ]]; then
            images="$images $img"
        else
            echo -e "${YELLOW}!${NC} ${WHITE}File not found: ${NARTIC}$img${NC}"
        fi
    done
    
    if [[ -z "$images" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No valid images found!${NC}"
        press_enter
        return
    fi
    
    local output_file="combined_$(date +%Y%m%d_%H%M%S).png"
    
    echo ""
    
    case "$combine_method" in
        1)
            if confirm_action "Combine images side by side?"; then
                echo ""
                echo -e "${WHITE}Combining...${NC}"
                if magick $images +append "$output_file"; then
                    local info=$(get_image_info "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Images combined!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Dimensions: ${NARTIC}$info${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to combine!${NC}"
                fi
            fi
            ;;
        2)
            if confirm_action "Stack images vertically?"; then
                echo ""
                echo -e "${WHITE}Combining...${NC}"
                if magick $images -append "$output_file"; then
                    local info=$(get_image_info "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Images combined!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Dimensions: ${NARTIC}$info${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to combine!${NC}"
                fi
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Enter grid columns ${NHYPRBLUE}(e.g., 2 for 2xN):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r cols
            
            if confirm_action "Create ${cols}xN grid?"; then
                echo ""
                echo -e "${WHITE}Creating grid...${NC}"
                if magick montage $images -tile "${cols}x" -geometry +5+5 "$output_file"; then
                    local info=$(get_image_info "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Grid created!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Dimensions: ${NARTIC}$info${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to create grid!${NC}"
                fi
            fi
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            ;;
    esac
    
    press_enter
}

# ============================================
# MAIN MENU
# ============================================
show_menu() {
    clear
    echo ""
    echo -e "${NGLACIER}    ____  ___ ______ _______ _______ ____________    ____   ${NC}"
    echo -e "${NGLACIER}    |  \ |  |/  __  \|  __  \|   __ \ \_    _/\  \  /  /    ${NC}"
    echo -e "${NGLACIER}    |   \|  |  |  |  | |__)  |  |  | |  |  |   \  \/  /     ${NC}"
    echo -e "${NGLACIER}    |  |\   |  |__|  |  __  <|  |__| | _|  |_  /  /\  \     ${NC}"
    echo -e "${NGLACIER}  --|__| \__|\______/|__| \__|______/ /______\/__/  \__\-- ${NC}"
    echo -e "${NVBLUE}.__________________________________________________________.${NC}"
    echo -e "${NARTIC}...........................     ............................${NC}"
    echo -e "${NARTIC}.................                     ...................${NC}"
    echo -e "${NARTIC}..........                                ............${NC}"
    echo -e "${NARTIC}......                                     ......${NC}"
    echo -e "${NARTIC}...                                       ...${NC}"
    echo -e "${NARTIC}.                                       .${NC}"
    echo ""
    echo ""
    draw_box "         Nordix CLI - Image          "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}IMAGE OPERATIONS:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Convert format${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Resize image${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Compress/optimize${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Rotate image${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Flip image${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Crop image${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Make grayscale${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Strip metadata ${NHYPRBLUE}(privacy)${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Add watermark/text${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Add border/frame${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Create thumbnail${NC}"
    echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}View image info${NC}"
    echo -e "${BLUE}13${NC} ${NVFROST}-${NC} ${NARTIC}Batch convert${NC}"
    echo -e "${BLUE}14${NC} ${NVFROST}-${NC} ${NARTIC}Create GIF from images${NC}"
    echo -e "${BLUE}15${NC} ${NVFROST}-${NC} ${NARTIC}Extract GIF frames${NC}"
    echo -e "${BLUE}16${NC} ${NVFROST}-${NC} ${NARTIC}Combine images${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-16):${NC}"
    echo ""
}

# ============================================
# MAIN LOOP
# ============================================
while true; do
    show_menu
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1) convert_format ;;
        2) resize_image ;;
        3) compress_image ;;
        4) rotate_image ;;
        5) flip_image ;;
        6) crop_image ;;
        7) make_grayscale ;;
        8) strip_metadata ;;
        9) add_watermark ;;
        10) add_border ;;
        11) create_thumbnail ;;
        12) view_image_info ;;
        13) batch_convert ;;
        14) create_gif ;;
        15) extract_gif_frames ;;
        16) combine_images ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix CLI Image!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid choice! Please enter a number between 0 and 16.${NC}"
            sleep 2
            ;;
    esac
done
