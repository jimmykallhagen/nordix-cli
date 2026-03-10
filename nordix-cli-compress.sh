#!/bin/bash
##=========================================================##
 # SPDX-License-Identifier: GPL-3.0-or-later               #
 # Copyright (c) 2025 Jimmy Källhagen                      #
 # Part of Yggdrasil - Nordix desktop environment          #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen  #
##=========================================================##

# ============================================
# Nordix CLI Compress - Version 1.0
# Archive and compression tool
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

# Draw a decorative box around text
draw_box() {
    local text="$1"
    local length=${#text}
    local border=$(printf '%*s' $((length+4)) | tr ' ' '=')
    echo -e "${BLUE}${border}${NC}"
    echo -e "${BLUE}|${NC} ${NARTIC}$text${NC} ${BLUE}|${NC}"
    echo -e "${BLUE}${border}${NC}"
}

# Draw Nordix border line
draw_border() {
    echo -e "${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NGLACIER}=${NVBLUE}=${NC}"
}

# Y/N confirmation function
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

# Wait for user input
press_enter() {
    echo ""
    echo -ne "${WHITE}Press Enter to continue...${NC}"
    read -r
}

# ============================================
# TOOL CHECK FUNCTIONS
# ============================================

# Check if a command exists
have_cmd() {
    command -v "$1" &>/dev/null
}

# Install a package if missing
install_if_missing() {
    local cmd="$1"
    local pkg="$2"
    
    if ! have_cmd "$cmd"; then
        echo ""
        echo -e "${YELLOW}!${NC} ${WHITE}${cmd} is not installed.${NC}"
        echo -ne "${WHITE}Would you like to install ${NARTIC}${pkg}${WHITE}? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_choice
        
        case "$install_choice" in
            [yY]|[yY][eE][sS]|"")
                echo -e "${WHITE}Installing ${NARTIC}${pkg}${WHITE}...${NC}"
                sudo pacman -S --needed --noconfirm "$pkg"
                if have_cmd "$cmd"; then
                    echo -e "${GREEN}[OK]${NC} ${WHITE}${pkg} installed successfully!${NC}"
                    return 0
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Installation failed!${NC}"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}[X]${NC} ${WHITE}${cmd} is required for this operation.${NC}"
                return 1
                ;;
        esac
    fi
    return 0
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
    draw_box "        Nordix CLI - Compress         "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DESCRIPTION:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Version 1.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Create archives ${NHYPRBLUE}(7z, tar, zip, rar)${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Compress files ${NHYPRBLUE}(gzip, bzip2, xz, zstd, lz4)${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Extract any archive format${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Auto-detect compression type${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}USAGE:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}nx-cli-compress${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}nx-cli-compress --help${NC}"
    echo ""
    draw_border
    echo ""
    exit 0
}

# Check for --help or -h
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

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
    draw_box "        Nordix CLI - Compress         "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}OPTIONS:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Create archive ${NHYPRBLUE}(7z, tar, zip, rar)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Extract archive ${NHYPRBLUE}(auto-detect)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}List archive contents${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Compress file ${NHYPRBLUE}(gzip, bzip2, xz, zstd, lz4)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Decompress file ${NHYPRBLUE}(auto-detect)${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-5):${NC}"
    echo ""
}

# ============================================
# CREATE ARCHIVE
# ============================================
create_archive() {
    clear
    echo ""
    draw_box "          Create Archive             "
    echo ""
    draw_border
    echo -e "${WHITE}Select archive format:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}7z ${NHYPRBLUE}(best compression ratio)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}tar.gz ${NHYPRBLUE}(Linux standard, good compression)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}tar.xz ${NHYPRBLUE}(Linux standard, excellent compression)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}tar.zst ${NHYPRBLUE}(fast compression and decompression)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}tar ${NHYPRBLUE}(no compression, just archive)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}zip ${NHYPRBLUE}(widely compatible, Windows friendly)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}rar ${NHYPRBLUE}(good compression, proprietary)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}lha ${NHYPRBLUE}(legacy format, Japan standard)${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back to main menu${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose format ${NHYPRBLUE}(0-8):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r format_choice
    
    if [[ "$format_choice" == "0" ]]; then
        return
    fi
    
    # Check for required tools
    case "$format_choice" in
        1) install_if_missing "7z" "p7zip" || return ;;
        2|3|4|5) install_if_missing "tar" "tar" || return ;;
        6) install_if_missing "zip" "zip" || return ;;
        7) install_if_missing "rar" "rar" || return ;;
        8) install_if_missing "lha" "lha" || return ;;
    esac
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to file or folder to archive:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_path
    
    if [[ ! -e "$input_path" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}Path not found: ${NARTIC}$input_path${NC}"
        press_enter
        return
    fi
    
    # Generate output name
    local basename
    basename=$(basename "$input_path")
    local name_noext="${basename%.*}"
    
    local ext output_file
    case "$format_choice" in
        1) ext="7z" ;;
        2) ext="tar.gz" ;;
        3) ext="tar.xz" ;;
        4) ext="tar.zst" ;;
        5) ext="tar" ;;
        6) ext="zip" ;;
        7) ext="rar" ;;
        8) ext="lzh" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    output_file="${name_noext}.${ext}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter output filename ${NHYPRBLUE}(default: $output_file):${NC}"
    echo -e "${NARTIC}Extension .${ext} will be added automatically${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_output
    
    if [[ -n "$custom_output" ]]; then
        custom_output="${custom_output%.*}"
        output_file="${custom_output}.${ext}"
    fi
    
    echo ""
    echo -e "${WHITE}Creating archive: ${NARTIC}$output_file${NC}"
    echo ""
    
    # Show time warning for slow formats
    case "$format_choice" in
        1)
            echo -e "${YELLOW}!${NC} ${WHITE}7z uses high compression - this may take a while...${NC}"
            echo ""
            ;;
        3)
            echo -e "${YELLOW}!${NC} ${WHITE}tar.xz uses high compression - this may take a while...${NC}"
            echo ""
            ;;
    esac
    
    local success=false
    case "$format_choice" in
        1)
            7z a "$output_file" "$input_path" && success=true
            ;;
        2)
            tar -czvf "$output_file" "$input_path" && success=true
            ;;
        3)
            tar -cJvf "$output_file" "$input_path" && success=true
            ;;
        4)
            tar --zstd -cvf "$output_file" "$input_path" && success=true
            ;;
        5)
            tar -cvf "$output_file" "$input_path" && success=true
            ;;
        6)
            zip -r "$output_file" "$input_path" && success=true
            ;;
        7)
            rar a "$output_file" "$input_path" && success=true
            ;;
        8)
            lha a "$output_file" "$input_path" && success=true
            ;;
    esac
    
    echo ""
    if [[ "$success" == true ]]; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}Archive created: ${NARTIC}$output_file${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}Failed to create archive!${NC}"
    fi
    
    press_enter
}

# ============================================
# EXTRACT ARCHIVE (AUTO-DETECT)
# ============================================
extract_archive() {
    clear
    echo ""
    draw_box "      Extract Archive (Auto-Detect)   "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to archive file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r archive_file
    
    if [[ ! -f "$archive_file" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$archive_file${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter destination folder ${NHYPRBLUE}(default: current directory):${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r dest_dir
    
    if [[ -z "$dest_dir" ]]; then
        dest_dir="."
    fi
    
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
    fi
    
    # Detect file type and extract
    local filename
    filename=$(basename "$archive_file")
    local ext_lower
    ext_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    
    echo ""
    echo -e "${WHITE}Extracting: ${NARTIC}$archive_file${NC}"
    echo -e "${WHITE}Destination: ${NARTIC}$dest_dir${NC}"
    echo ""
    
    local success=false
    
    case "$ext_lower" in
        *.tar.gz|*.tgz)
            install_if_missing "tar" "tar" || return
            tar -xzvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.tar.bz2|*.tbz2)
            install_if_missing "tar" "tar" || return
            tar -xjvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.tar.xz|*.txz)
            install_if_missing "tar" "tar" || return
            tar -xJvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.tar.zst|*.tzst)
            install_if_missing "tar" "tar" || return
            install_if_missing "zstd" "zstd" || return
            tar --zstd -xvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.tar.lz4)
            install_if_missing "tar" "tar" || return
            install_if_missing "lz4" "lz4" || return
            tar --use-compress-program=lz4 -xvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.tar.lrz)
            install_if_missing "tar" "tar" || return
            install_if_missing "lrztar" "lrzip" || return
            lrztar -d "$archive_file" -O "$dest_dir" && success=true
            ;;
        *.tar)
            install_if_missing "tar" "tar" || return
            tar -xvf "$archive_file" -C "$dest_dir" && success=true
            ;;
        *.7z)
            install_if_missing "7z" "p7zip" || return
            7z x "$archive_file" -o"$dest_dir" && success=true
            ;;
        *.zip)
            install_if_missing "unzip" "unzip" || return
            unzip "$archive_file" -d "$dest_dir" && success=true
            ;;
        *.rar)
            install_if_missing "unrar" "unrar" || return
            unrar x "$archive_file" "$dest_dir/" && success=true
            ;;
        *.lzh|*.lha)
            install_if_missing "lha" "lha" || return
            cd "$dest_dir" && lha x "$archive_file" && success=true
            ;;
        *.gz)
            install_if_missing "gzip" "gzip" || return
            gunzip -k "$archive_file" && success=true
            ;;
        *.bz2)
            install_if_missing "bzip2" "bzip2" || return
            bunzip2 -k "$archive_file" && success=true
            ;;
        *.xz)
            install_if_missing "xz" "xz" || return
            unxz -k "$archive_file" && success=true
            ;;
        *.zst)
            install_if_missing "zstd" "zstd" || return
            zstd -d "$archive_file" -o "$dest_dir/$(basename "${archive_file%.zst}")" && success=true
            ;;
        *.lz4)
            install_if_missing "lz4" "lz4" || return
            lz4 -d "$archive_file" "$dest_dir/$(basename "${archive_file%.lz4}")" && success=true
            ;;
        *.lrz)
            install_if_missing "lrzip" "lrzip" || return
            lrzip -d "$archive_file" -o "$dest_dir/$(basename "${archive_file%.lrz}")" && success=true
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Unknown archive format: ${NARTIC}$filename${NC}"
            echo ""
            echo -e "${WHITE}Supported formats:${NC}"
            echo -e "${NARTIC}  Archives: .7z, .zip, .rar, .tar, .lzh${NC}"
            echo -e "${NARTIC}  Tar+compression: .tar.gz, .tar.bz2, .tar.xz, .tar.zst, .tar.lz4${NC}"
            echo -e "${NARTIC}  Compressed: .gz, .bz2, .xz, .zst, .lz4, .lrz${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    if [[ "$success" == true ]]; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}Extraction completed!${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}Extraction failed!${NC}"
    fi
    
    press_enter
}

# ============================================
# LIST ARCHIVE CONTENTS
# ============================================
list_archive() {
    clear
    echo ""
    draw_box "        List Archive Contents         "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to archive file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r archive_file
    
    if [[ ! -f "$archive_file" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$archive_file${NC}"
        press_enter
        return
    fi
    
    local filename
    filename=$(basename "$archive_file")
    local ext_lower
    ext_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    
    echo ""
    draw_border
    echo -e "${WHITE}CONTENTS OF: ${NARTIC}$filename${NC}"
    draw_border
    echo ""
    
    case "$ext_lower" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.zst|*.tzst|*.tar)
            install_if_missing "tar" "tar" || return
            tar -tvf "$archive_file"
            ;;
        *.7z)
            install_if_missing "7z" "p7zip" || return
            7z l "$archive_file"
            ;;
        *.zip)
            install_if_missing "unzip" "unzip" || return
            unzip -l "$archive_file"
            ;;
        *.rar)
            install_if_missing "unrar" "unrar" || return
            unrar l "$archive_file"
            ;;
        *.lzh|*.lha)
            install_if_missing "lha" "lha" || return
            lha l "$archive_file"
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Cannot list contents of: ${NARTIC}$filename${NC}"
            echo -e "${WHITE}This format is a single compressed file, not an archive.${NC}"
            ;;
    esac
    
    echo ""
    draw_border
    
    press_enter
}

# ============================================
# COMPRESS FILE
# ============================================
compress_file() {
    clear
    echo ""
    draw_box "          Compress File              "
    echo ""
    draw_border
    echo -e "${WHITE}Select compression tool:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}zstd ${NHYPRBLUE}(fast, excellent ratio - recommended)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}lz4 ${NHYPRBLUE}(extremely fast, lower ratio)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}gzip ${NHYPRBLUE}(widely compatible, good ratio)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}xz ${NHYPRBLUE}(slow, best ratio)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}bzip2 ${NHYPRBLUE}(good ratio, slower than gzip)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}bzip3 ${NHYPRBLUE}(better than bzip2, newer)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}lrzip ${NHYPRBLUE}(best for large files with redundancy)${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back to main menu${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose compression ${NHYPRBLUE}(0-7):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r comp_choice
    
    if [[ "$comp_choice" == "0" ]]; then
        return
    fi
    
    # Check for required tools
    case "$comp_choice" in
        1) install_if_missing "zstd" "zstd" || return ;;
        2) install_if_missing "lz4" "lz4" || return ;;
        3) install_if_missing "gzip" "gzip" || return ;;
        4) install_if_missing "xz" "xz" || return ;;
        5) install_if_missing "bzip2" "bzip2" || return ;;
        6) install_if_missing "bzip3" "bzip3" || return ;;
        7) install_if_missing "lrzip" "lrzip" || return ;;
    esac
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to file to compress:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r input_file
    
    if [[ ! -f "$input_file" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$input_file${NC}"
        press_enter
        return
    fi
    
    local ext output_file
    case "$comp_choice" in
        1) ext="zst" ;;
        2) ext="lz4" ;;
        3) ext="gz" ;;
        4) ext="xz" ;;
        5) ext="bz2" ;;
        6) ext="bz3" ;;
        7) ext="lrz" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    output_file="${input_file}.${ext}"
    
    echo ""
    echo -e "${WHITE}Compressing: ${NARTIC}$input_file${NC}"
    echo -e "${WHITE}Output: ${NARTIC}$output_file${NC}"
    echo ""
    
    # Show time warning for slow compressors
    case "$comp_choice" in
        4)
            echo -e "${YELLOW}!${NC} ${WHITE}xz uses high compression - this may take a while...${NC}"
            echo ""
            ;;
        5|6)
            echo -e "${YELLOW}!${NC} ${WHITE}bzip compression is slower than alternatives...${NC}"
            echo ""
            ;;
        7)
            echo -e "${YELLOW}!${NC} ${WHITE}lrzip analyzes the entire file - this may take a while for large files...${NC}"
            echo ""
            ;;
    esac
    
    local success=false
    case "$comp_choice" in
        1)
            zstd -k "$input_file" -o "$output_file" && success=true
            ;;
        2)
            lz4 -k "$input_file" "$output_file" && success=true
            ;;
        3)
            gzip -k "$input_file" && success=true
            ;;
        4)
            xz -k "$input_file" && success=true
            ;;
        5)
            bzip2 -k "$input_file" && success=true
            ;;
        6)
            bzip3 -k "$input_file" && success=true
            ;;
        7)
            lrzip "$input_file" -o "$output_file" && success=true
            ;;
    esac
    
    echo ""
    if [[ "$success" == true ]]; then
        # Show compression stats
        local orig_size comp_size ratio
        orig_size=$(stat --printf="%s" "$input_file" 2>/dev/null)
        comp_size=$(stat --printf="%s" "$output_file" 2>/dev/null)
        
        if [[ -n "$orig_size" && -n "$comp_size" && "$orig_size" -gt 0 ]]; then
            ratio=$(echo "scale=1; 100 - ($comp_size * 100 / $orig_size)" | bc 2>/dev/null)
            echo -e "${GREEN}[OK]${NC} ${WHITE}Compression completed!${NC}"
            echo -e "${WHITE}Original: ${NARTIC}$(numfmt --to=iec $orig_size 2>/dev/null || echo $orig_size)${NC}"
            echo -e "${WHITE}Compressed: ${NARTIC}$(numfmt --to=iec $comp_size 2>/dev/null || echo $comp_size)${NC}"
            if [[ -n "$ratio" ]]; then
                echo -e "${WHITE}Saved: ${NARTIC}${ratio}%${NC}"
            fi
        else
            echo -e "${GREEN}[OK]${NC} ${WHITE}Compression completed: ${NARTIC}$output_file${NC}"
        fi
    else
        echo -e "${RED}[X]${NC} ${WHITE}Compression failed!${NC}"
    fi
    
    press_enter
}

# ============================================
# DECOMPRESS FILE (AUTO-DETECT)
# ============================================
decompress_file() {
    clear
    echo ""
    draw_box "     Decompress File (Auto-Detect)    "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to compressed file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r comp_file
    
    if [[ ! -f "$comp_file" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$comp_file${NC}"
        press_enter
        return
    fi
    
    local filename
    filename=$(basename "$comp_file")
    local ext_lower
    ext_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    
    echo ""
    echo -e "${WHITE}Decompressing: ${NARTIC}$comp_file${NC}"
    echo ""
    
    local success=false
    
    case "$ext_lower" in
        *.gz)
            install_if_missing "gzip" "gzip" || return
            gunzip -k "$comp_file" && success=true
            ;;
        *.bz2)
            install_if_missing "bzip2" "bzip2" || return
            bunzip2 -k "$comp_file" && success=true
            ;;
        *.bz3)
            install_if_missing "bzip3" "bzip3" || return
            bzip3 -dk "$comp_file" && success=true
            ;;
        *.xz)
            install_if_missing "xz" "xz" || return
            unxz -k "$comp_file" && success=true
            ;;
        *.zst)
            install_if_missing "zstd" "zstd" || return
            zstd -dk "$comp_file" && success=true
            ;;
        *.lz4)
            install_if_missing "lz4" "lz4" || return
            lz4 -dk "$comp_file" && success=true
            ;;
        *.lrz)
            install_if_missing "lrzip" "lrzip" || return
            lrzip -dk "$comp_file" && success=true
            ;;
        *.z)
            install_if_missing "gzip" "gzip" || return
            uncompress -k "$comp_file" && success=true
            ;;
        *)
            echo -e "${YELLOW}!${NC} ${WHITE}This might be an archive, not a compressed file.${NC}"
            echo -e "${WHITE}Try using ${NARTIC}Extract archive${WHITE} instead.${NC}"
            echo ""
            echo -e "${WHITE}Supported compression formats:${NC}"
            echo -e "${NARTIC}  .gz, .bz2, .bz3, .xz, .zst, .lz4, .lrz${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    if [[ "$success" == true ]]; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}Decompression completed!${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}Decompression failed!${NC}"
    fi
    
    press_enter
}

# ============================================
# MAIN LOOP
# ============================================
while true; do
    show_menu
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1)
            create_archive
            ;;
        2)
            extract_archive
            ;;
        3)
            list_archive
            ;;
        4)
            compress_file
            ;;
        5)
            decompress_file
            ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix CLI Compress!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid choice! Please enter a number between 0 and 5.${NC}"
            sleep 2
            ;;
    esac
done
