#!/bin/bash
##============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                      #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0  #
 # Copyright (c) 2025 Jimmy Källhagen                                         #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                     #
##============================================================================##
# ============================================
# Nordix CLI PDF - Version 1.0
# PDF manipulation tool
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

check_dependencies() {
    local missing=()
    
    # Check poppler-utils (pdfunite, pdfseparate, pdfinfo, pdftotext, pdftoppm)
    if ! have_cmd pdfinfo; then
        missing+=("poppler")
    fi
    
    # Check qpdf for encryption/rotation
    if ! have_cmd qpdf; then
        missing+=("qpdf")
    fi
    
    # Check ghostscript for compression
    if ! have_cmd gs; then
        missing+=("ghostscript")
    fi
    
    # Check ImageMagick for image conversion
    if ! have_cmd magick; then
        missing+=("imagemagick")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}!${NC} ${WHITE}Missing required packages: ${NARTIC}${missing[*]}${NC}"
        echo ""
        echo -ne "${WHITE}Install missing packages? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_choice
        case "$install_choice" in
            [yY]|[yY][eE][sS]|"")
                sudo pacman -S --needed --noconfirm "${missing[@]}"
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Packages installed!${NC}"
                ;;
            *)
                echo -e "${YELLOW}!${NC} ${WHITE}Some features may not work without these packages.${NC}"
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
    draw_box "          Nordix CLI - PDF           "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DESCRIPTION:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Version 1.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}PDF manipulation and conversion${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Merge, split, compress PDFs${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Convert between PDF and images${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Password protection${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Text extraction${NC}"
    echo ""
    draw_border
    echo ""
    exit 0
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# Check dependencies
check_dependencies

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

get_pdf_pages() {
    local file="$1"
    pdfinfo "$file" 2>/dev/null | grep "Pages:" | awk '{print $2}'
}

get_pdf_info() {
    local file="$1"
    local pages=$(get_pdf_pages "$file")
    local size=$(get_file_size "$file")
    echo "${pages} pages, ${size}"
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

# ============================================
# 1. MERGE PDFs
# ============================================
merge_pdfs() {
    clear
    echo ""
    draw_box "           Merge PDF Files           "
    echo ""
    draw_border
    echo -e "${WHITE}MERGE PDF FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Enter PDF files to merge, space separated${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Files will be merged in the order entered${NC}"
    echo ""
    echo -e "${WHITE}Example: ${NARTIC}file1.pdf file2.pdf file3.pdf${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}Enter PDF files:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r pdf_list
    
    if [[ -z "$pdf_list" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No files specified!${NC}"
        press_enter
        return
    fi
    
    # Validate files
    local valid_files=""
    local count=0
    
    for pdf in $pdf_list; do
        pdf="${pdf/#\~/$HOME}"
        if [[ -f "$pdf" ]]; then
            valid_files="$valid_files $pdf"
            count=$((count + 1))
            local info=$(get_pdf_info "$pdf")
            echo -e "${GREEN}[OK]${NC} ${NARTIC}$(basename "$pdf")${NC} ${NHYPRBLUE}($info)${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Not found: ${NARTIC}$pdf${NC}"
        fi
    done
    
    if [[ $count -lt 2 ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}Need at least 2 PDF files to merge!${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter output filename:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r output_file
    
    if [[ -z "$output_file" ]]; then
        output_file="merged_$(date +%Y%m%d_%H%M%S).pdf"
    fi
    
    # Add .pdf extension if missing
    [[ "$output_file" != *.pdf ]] && output_file="${output_file}.pdf"
    
    echo ""
    
    if confirm_action "Merge $count PDF files?"; then
        echo ""
        echo -e "${WHITE}Merging...${NC}"
        
        if pdfunite $valid_files "$output_file" 2>/dev/null; then
            local info=$(get_pdf_info "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDFs merged successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Result: ${NARTIC}$info${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Merge failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 2. SPLIT PDF
# ============================================
split_pdf() {
    clear
    echo ""
    draw_box "            Split PDF File           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local pages=$(get_pdf_pages "$input_file")
    local size=$(get_file_size "$input_file")
    
    echo ""
    echo -e "${WHITE}PDF info: ${NARTIC}$pages pages, $size${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Split method:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Split into individual pages${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Extract page range${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Extract specific pages${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose method ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r split_method
    
    local dir=$(dirname "$input_file")
    local base=$(basename "$input_file" .pdf)
    
    case "$split_method" in
        1)
            local output_dir="${dir}/${base}_pages"
            
            if confirm_action "Split into $pages individual pages?"; then
                mkdir -p "$output_dir"
                echo ""
                echo -e "${WHITE}Splitting...${NC}"
                
                if pdfseparate "$input_file" "${output_dir}/page_%d.pdf" 2>/dev/null; then
                    local count=$(find "$output_dir" -name "*.pdf" | wc -l)
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}PDF split successfully!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Pages: ${NARTIC}$count${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_dir${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Split failed!${NC}"
                fi
            fi
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter start page ${NHYPRBLUE}(1-$pages):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r start_page
            
            echo ""
            echo -e "${WHITE}Enter end page ${NHYPRBLUE}(1-$pages):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r end_page
            
            local output_file="${dir}/${base}_pages${start_page}-${end_page}.pdf"
            
            if confirm_action "Extract pages $start_page to $end_page?"; then
                echo ""
                echo -e "${WHITE}Extracting...${NC}"
                
                if qpdf "$input_file" --pages . "$start_page-$end_page" -- "$output_file" 2>/dev/null; then
                    local info=$(get_pdf_info "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Pages extracted!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Result: ${NARTIC}$info${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Extraction failed!${NC}"
                fi
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Enter page numbers ${NHYPRBLUE}(comma separated, e.g., 1,3,5,7):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r page_list
            
            local output_file="${dir}/${base}_selected.pdf"
            
            if confirm_action "Extract pages: $page_list?"; then
                echo ""
                echo -e "${WHITE}Extracting...${NC}"
                
                if qpdf "$input_file" --pages . "$page_list" -- "$output_file" 2>/dev/null; then
                    local info=$(get_pdf_info "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Pages extracted!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Result: ${NARTIC}$info${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Extraction failed!${NC}"
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
# 3. COMPRESS PDF
# ============================================
compress_pdf() {
    clear
    echo ""
    draw_box "          Compress PDF File          "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local orig_size=$(get_file_size "$input_file")
    local pages=$(get_pdf_pages "$input_file")
    
    echo ""
    echo -e "${WHITE}Current: ${NARTIC}$pages pages, $orig_size${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Compression level:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Screen ${NHYPRBLUE}(72 dpi - smallest, low quality)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Ebook ${NHYPRBLUE}(150 dpi - good balance)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Printer ${NHYPRBLUE}(300 dpi - high quality)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Prepress ${NHYPRBLUE}(300 dpi - highest quality)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose level ${NHYPRBLUE}(1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r compress_level
    
    local setting=""
    
    case "$compress_level" in
        1) setting="/screen" ;;
        2) setting="/ebook" ;;
        3) setting="/printer" ;;
        4) setting="/prepress" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "_compressed" "pdf")
    
    echo ""
    
    if confirm_action "Compress PDF?"; then
        echo ""
        echo -e "${WHITE}Compressing...${NC}"
        echo -e "${YELLOW}!${NC} ${WHITE}This may take a while for large files...${NC}"
        
        if gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="$setting" \
            -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output_file" "$input_file" 2>/dev/null; then
            
            local new_size=$(get_file_size "$output_file")
            local orig_bytes=$(stat -c%s "$input_file" 2>/dev/null)
            local new_bytes=$(stat -c%s "$output_file" 2>/dev/null)
            
            if [[ -n "$orig_bytes" && -n "$new_bytes" && "$orig_bytes" -gt 0 ]]; then
                local saved=$((orig_bytes - new_bytes))
                local percent=$((saved * 100 / orig_bytes))
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}PDF compressed!${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Original: ${NARTIC}$orig_size${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Compressed: ${NARTIC}$new_size${NC}"
                if [[ $saved -gt 0 ]]; then
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Saved: ${GREEN}${percent}%${NC}"
                else
                    echo -e "${NHYPRBLUE}❯${NC} ${YELLOW}!${NC} ${WHITE}File grew ${NARTIC}$((-percent))%${NC} ${WHITE}(already optimized?)${NC}"
                fi
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
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
# 4. ROTATE PAGES
# ============================================
rotate_pdf() {
    clear
    echo ""
    draw_box "          Rotate PDF Pages           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local pages=$(get_pdf_pages "$input_file")
    echo ""
    echo -e "${WHITE}PDF has ${NARTIC}$pages${WHITE} pages.${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Select rotation:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}90° clockwise${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}90° counter-clockwise${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}180°${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose rotation ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r rotation_choice
    
    local rotation=""
    local suffix=""
    
    case "$rotation_choice" in
        1) rotation="+90"; suffix="_rotated90" ;;
        2) rotation="-90"; suffix="_rotated270" ;;
        3) rotation="+180"; suffix="_rotated180" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    draw_border
    echo -e "${WHITE}Which pages to rotate?${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}All pages${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Specific pages${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose ${NHYPRBLUE}(1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r page_choice
    
    local output_file=$(generate_output_name "$input_file" "$suffix" "pdf")
    local page_spec=""
    
    case "$page_choice" in
        1)
            page_spec="1-z"
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter pages ${NHYPRBLUE}(e.g., 1,3,5 or 1-5):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r page_spec
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    
    if confirm_action "Rotate pages?"; then
        echo ""
        echo -e "${WHITE}Rotating...${NC}"
        
        if qpdf "$input_file" --rotate="$rotation:$page_spec" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF rotated!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Rotation failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 5. PDF TO IMAGES
# ============================================
pdf_to_images() {
    clear
    echo ""
    draw_box "        Convert PDF to Images        "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local pages=$(get_pdf_pages "$input_file")
    echo ""
    echo -e "${WHITE}PDF has ${NARTIC}$pages${WHITE} pages.${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Select output format:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}PNG ${NHYPRBLUE}(lossless, larger files)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}JPG ${NHYPRBLUE}(smaller files)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose format ${NHYPRBLUE}(1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r format_choice
    
    local format=""
    local ext=""
    
    case "$format_choice" in
        1) format="png"; ext="png" ;;
        2) format="jpeg"; ext="jpg" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    draw_border
    echo -e "${WHITE}Select resolution:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Screen ${NHYPRBLUE}(72 dpi)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Medium ${NHYPRBLUE}(150 dpi)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}High ${NHYPRBLUE}(300 dpi)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose resolution ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r res_choice
    
    local dpi=""
    
    case "$res_choice" in
        1) dpi="72" ;;
        2) dpi="150" ;;
        3) dpi="300" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local dir=$(dirname "$input_file")
    local base=$(basename "$input_file" .pdf)
    local output_dir="${dir}/${base}_images"
    
    echo ""
    
    if confirm_action "Convert $pages pages to $format at ${dpi}dpi?"; then
        mkdir -p "$output_dir"
        echo ""
        echo -e "${WHITE}Converting...${NC}"
        echo -e "${YELLOW}!${NC} ${WHITE}This may take a while...${NC}"
        
        if pdftoppm -$format -r "$dpi" "$input_file" "${output_dir}/page" 2>/dev/null; then
            # Rename files to have correct extension
            if [[ "$ext" == "jpg" ]]; then
                            for f in "${output_dir}"/*.ppm; do
                    [[ -f "$f" ]] && mv "$f" "${f%.ppm}.jpg"
                done
            fi
            
            local count=$(find "$output_dir" -name "*.$ext" -o -name "*.ppm" 2>/dev/null | wc -l)
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF converted to images!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Images: ${NARTIC}$count${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_dir${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Conversion failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 6. IMAGES TO PDF
# ============================================
images_to_pdf() {
    clear
    echo ""
    draw_box "        Convert Images to PDF        "
    echo ""
    draw_border
    echo -e "${WHITE}Select input method:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Directory of images${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}List of image files${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose method ${NHYPRBLUE}(1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r method_choice
    
    local images=""
    local output_file=""
    
    case "$method_choice" in
        1)
            echo ""
            echo -e "${WHITE}Enter directory containing images:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r input_dir
            
            input_dir="${input_dir/#\~/$HOME}"
            
            if [[ ! -d "$input_dir" ]]; then
                echo -e "${RED}[X]${NC} ${WHITE}Directory not found!${NC}"
                press_enter
                return
            fi
            
            images=$(find "$input_dir" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | sort)
            output_file="${input_dir}/images.pdf"
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter image files ${NHYPRBLUE}(space separated):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r image_list
            
            for img in $image_list; do
                img="${img/#\~/$HOME}"
                if [[ -f "$img" ]]; then
                    images="$images $img"
                fi
            done
            output_file="images_$(date +%Y%m%d_%H%M%S).pdf"
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local count=$(echo "$images" | wc -w)
    
    if [[ $count -eq 0 ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No images found!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Found ${NARTIC}$count${WHITE} images.${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter output PDF filename:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Default: ${NARTIC}$output_file${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_output
    
    [[ -n "$custom_output" ]] && output_file="$custom_output"
    [[ "$output_file" != *.pdf ]] && output_file="${output_file}.pdf"
    
    echo ""
    
    if confirm_action "Create PDF from $count images?"; then
        echo ""
        echo -e "${WHITE}Creating PDF...${NC}"
        
        if magick $images "$output_file" 2>/dev/null; then
            local size=$(get_file_size "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF created!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Pages: ${NARTIC}$count${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}PDF creation failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 7. ADD PASSWORD
# ============================================
add_password() {
    clear
    echo ""
    draw_box "       Add Password to PDF           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    echo -e "${WHITE}PASSWORD TYPES:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}User password: Required to open the PDF${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Owner password: Required to modify/print${NC}"
    echo ""
    
    echo ""
    echo -e "${WHITE}Enter user password ${NHYPRBLUE}(required to open):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -rs user_pass
    echo ""
    
    if [[ -z "$user_pass" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Password cannot be empty!${NC}"
        press_enter
        return
    fi
    
    echo -e "${WHITE}Confirm user password:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -rs user_pass_confirm
    echo ""
    
    if [[ "$user_pass" != "$user_pass_confirm" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Passwords do not match!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Enter owner password ${NHYPRBLUE}(leave empty to use same):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -rs owner_pass
    echo ""
    
    [[ -z "$owner_pass" ]] && owner_pass="$user_pass"
    
    local output_file=$(generate_output_name "$input_file" "_protected" "pdf")
    
    echo ""
    
    if confirm_action "Add password protection?"; then
        echo ""
        echo -e "${WHITE}Encrypting...${NC}"
        
        if qpdf --encrypt "$user_pass" "$owner_pass" 256 -- "$input_file" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF encrypted!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
            echo ""
            echo -e "${YELLOW}!${NC} ${WHITE}Remember your password - it cannot be recovered!${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Encryption failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 8. REMOVE PASSWORD
# ============================================
remove_password() {
    clear
    echo ""
    draw_box "      Remove Password from PDF       "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to encrypted PDF:${NC}"
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
    echo -e "${WHITE}Enter current password:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -rs password
    echo ""
    
    local output_file=$(generate_output_name "$input_file" "_decrypted" "pdf")
    
    echo ""
    
    if confirm_action "Remove password protection?"; then
        echo ""
        echo -e "${WHITE}Decrypting...${NC}"
        
        if qpdf --password="$password" --decrypt "$input_file" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Password removed!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Decryption failed! Wrong password?${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 9. EXTRACT TEXT
# ============================================
extract_text() {
    clear
    echo ""
    draw_box "        Extract Text from PDF        "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local pages=$(get_pdf_pages "$input_file")
    echo ""
    echo -e "${WHITE}PDF has ${NARTIC}$pages${WHITE} pages.${NC}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Extract option:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}All pages${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Specific page range${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Preview only ${NHYPRBLUE}(show in terminal)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r extract_choice
    
    local dir=$(dirname "$input_file")
    local base=$(basename "$input_file" .pdf)
    local output_file="${dir}/${base}.txt"
    
    case "$extract_choice" in
        1)
            if confirm_action "Extract all text?"; then
                echo ""
                echo -e "${WHITE}Extracting...${NC}"
                
                if pdftotext "$input_file" "$output_file" 2>/dev/null; then
                    local size=$(get_file_size "$output_file")
                    local lines=$(wc -l < "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Text extracted!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Lines: ${NARTIC}$lines${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$size${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Extraction failed!${NC}"
                fi
            fi
            ;;
        2)
            echo ""
            echo -e "${WHITE}Enter start page:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r start_page
            
            echo ""
            echo -e "${WHITE}Enter end page:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r end_page
            
            output_file="${dir}/${base}_pages${start_page}-${end_page}.txt"
            
            if confirm_action "Extract text from pages $start_page to $end_page?"; then
                echo ""
                echo -e "${WHITE}Extracting...${NC}"
                
                if pdftotext -f "$start_page" -l "$end_page" "$input_file" "$output_file" 2>/dev/null; then
                    local lines=$(wc -l < "$output_file")
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Text extracted!${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Lines: ${NARTIC}$lines${NC}"
                    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Extraction failed!${NC}"
                fi
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Preview (first 50 lines):${NC}"
            draw_border
            echo ""
            pdftotext "$input_file" - 2>/dev/null | head -50
            echo ""
            draw_border
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            ;;
    esac
    
    press_enter
}

# ============================================
# 10. VIEW PDF INFO
# ============================================
view_pdf_info() {
    clear
    echo ""
    draw_box "          View PDF Info              "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    echo -e "${WHITE}PDF INFORMATION:${NC}"
    draw_border
    echo ""
    
    local filename=$(basename "$input_file")
    local filesize=$(get_file_size "$input_file")
    
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Filename: ${NARTIC}$filename${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}File size: ${NARTIC}$filesize${NC}"
    echo ""
    
    # Get detailed info
    pdfinfo "$input_file" 2>/dev/null | while read -r line; do
        local key=$(echo "$line" | cut -d: -f1)
        local value=$(echo "$line" | cut -d: -f2- | xargs)
        echo -e "${NHYPRBLUE}❯${NC} ${WHITE}$key: ${NARTIC}$value${NC}"
    done
    
    # Check if encrypted
    if qpdf --is-encrypted "$input_file" 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}!${NC} ${WHITE}This PDF is ${RED}password protected${NC}"
    fi
    
    echo ""
    
    press_enter
}

# ============================================
# 11. ADD WATERMARK
# ============================================
add_watermark() {
    clear
    echo ""
    draw_box "        Add Watermark to PDF         "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
        echo -e "${RED}[X]${NC} ${WHITE}No watermark text entered!${NC}"
        press_enter
        return
    fi
    
    local pages=$(get_pdf_pages "$input_file")
    local output_file=$(generate_output_name "$input_file" "_watermarked" "pdf")
    
    echo ""
    
    if confirm_action "Add watermark to all $pages pages?"; then
        echo ""
        echo -e "${WHITE}Adding watermark...${NC}"
        echo -e "${YELLOW}!${NC} ${WHITE}This may take a while...${NC}"
        
        # Create temporary watermark PDF
        local temp_watermark="/tmp/watermark_$$.pdf"
        
        # Create watermark using ImageMagick and convert to PDF
        magick -size 800x600 xc:transparent \
            -font Helvetica -pointsize 60 \
            -fill "rgba(128,128,128,0.3)" \
            -gravity center -annotate 45x45+0+0 "$watermark_text" \
            "$temp_watermark" 2>/dev/null
        
        if [[ -f "$temp_watermark" ]]; then
            # Apply watermark using qpdf
            if qpdf "$input_file" --overlay "$temp_watermark" -- "$output_file" 2>/dev/null; then
                rm -f "$temp_watermark"
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Watermark added!${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
            else
                rm -f "$temp_watermark"
                echo -e "${RED}[X]${NC} ${WHITE}Failed to add watermark!${NC}"
            fi
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to create watermark!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 12. RESIZE/SCALE PAGES
# ============================================
resize_pdf() {
    clear
    echo ""
    draw_box "         Resize PDF Pages            "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    echo -e "${WHITE}Select target page size:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}A4 ${NHYPRBLUE}(210x297mm - Standard)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Letter ${NHYPRBLUE}(8.5x11in - US)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}A3 ${NHYPRBLUE}(297x420mm)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}A5 ${NHYPRBLUE}(148x210mm)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Legal ${NHYPRBLUE}(8.5x14in)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose size ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r size_choice
    
    local paper_size=""
    local suffix=""
    
    case "$size_choice" in
        1) paper_size="a4"; suffix="_A4" ;;
        2) paper_size="letter"; suffix="_Letter" ;;
        3) paper_size="a3"; suffix="_A3" ;;
        4) paper_size="a5"; suffix="_A5" ;;
        5) paper_size="legal"; suffix="_Legal" ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    local output_file=$(generate_output_name "$input_file" "$suffix" "pdf")
    
    echo ""
    
    if confirm_action "Resize to $paper_size?"; then
        echo ""
        echo -e "${WHITE}Resizing...${NC}"
        
        if gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
            -dPDFFitPage -sPAPERSIZE="$paper_size" \
            -dNOPAUSE -dQUIET -dBATCH \
            -sOutputFile="$output_file" "$input_file" 2>/dev/null; then
            local size=$(get_file_size "$output_file")
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF resized!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Size: ${NARTIC}$size${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Resize failed!${NC}"
        fi
    fi
    
    press_enter
}

# ============================================
# 13. REPAIR PDF
# ============================================
repair_pdf() {
    clear
    echo ""
    draw_box "           Repair PDF File           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter path to PDF file:${NC}"
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
    
    local output_file=$(generate_output_name "$input_file" "_repaired" "pdf")
    
    echo ""
    echo -e "${WHITE}This will attempt to fix common PDF issues:${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Corrupted structure${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Invalid objects${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Broken cross-references${NC}"
    echo ""
    
    if confirm_action "Attempt to repair PDF?"; then
        echo ""
        echo -e "${WHITE}Repairing...${NC}"
        
        # First try qpdf
        if qpdf --linearize "$input_file" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}PDF repaired successfully!${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
        else
            echo -e "${YELLOW}!${NC} ${WHITE}qpdf repair failed, trying Ghostscript...${NC}"
            
            # Try Ghostscript as fallback
            if gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH \
                -sOutputFile="$output_file" "$input_file" 2>/dev/null; then
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}PDF repaired with Ghostscript!${NC}"
                echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Output: ${NARTIC}$output_file${NC}"
            else
                echo -e "${RED}[X]${NC} ${WHITE}Repair failed - PDF may be too damaged.${NC}"
            fi
        fi
    fi
    
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
    draw_box "          Nordix CLI - PDF           "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}PDF OPERATIONS:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Merge PDFs${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Split PDF${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Compress PDF${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Rotate pages${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}PDF to images${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Images to PDF${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Add password${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Remove password${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Extract text${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}View PDF info${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Add watermark${NC}"
    echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Resize pages ${NHYPRBLUE}(A4, Letter, etc.)${NC}"
    echo -e "${BLUE}13${NC} ${NVFROST}-${NC} ${NARTIC}Repair PDF${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-13):${NC}"
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
        1) merge_pdfs ;;
        2) split_pdf ;;
        3) compress_pdf ;;
        4) rotate_pdf ;;
        5) pdf_to_images ;;
        6) images_to_pdf ;;
        7) add_password ;;
        8) remove_password ;;
        9) extract_text ;;
        10) view_pdf_info ;;
        11) add_watermark ;;
        12) resize_pdf ;;
        13) repair_pdf ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix CLI PDF!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid choice! Please enter a number between 0 and 13.${NC}"
            sleep 2
            ;;
    esac
done
