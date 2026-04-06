#!/bin/bash
##============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                      #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0  #
 # Copyright (c) 2025 Jimmy Källhagen                                         #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                     #
##============================================================================##

# ============================================
# Nordix CLI Media - Version 1.0
# Media conversion and metadata cleaning tool
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
# SPINNER FUNCTIONS
# ============================================
SPINNER_CHARS='|/-\'
SPINNER_PID=""

# Start spinner line
start_spinner_line() {
    (
        tput civis
        while true; do
            for ((i=0; i<${#SPINNER_CHARS}; i++)); do
                printf "\r"
                for j in {1..30}; do
                    printf "${NHYPRBLUE}%c ${NC}" "${SPINNER_CHARS:i:1}"
                done
                sleep 0.1
            done
        done
    ) &
    SPINNER_PID=$!
}

# Stop spinner line
stop_spinner_line() {
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        SPINNER_PID=""
        printf "\r\033[K"
        tput cnorm
    fi
}

# ============================================
# CLEANUP FUNCTION
# ============================================
cleanup() {
    stop_spinner_line
    tput cnorm 2>/dev/null
    echo -ne "${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# ============================================
# STARTUP CHECK
# ============================================
startup_check() {
    if ! command -v ffmpeg &>/dev/null; then
        clear
        echo ""
        draw_border
        echo -e "${RED}          FFMPEG NOT INSTALLED           ${NC}"
        draw_border
        echo ""
        echo -e "${WHITE}Nordix CLI Media requires ${NARTIC}ffmpeg${WHITE} to function.${NC}"
        echo -e "${WHITE}ffmpeg is a universal media converter.${NC}"
        echo ""
        echo -ne "${WHITE}Would you like to install ffmpeg now? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_ffmpeg
        
        case "$install_ffmpeg" in
            [yY]|[yY][eE][sS]|"")
                echo ""
                echo -e "${WHITE}Installing ffmpeg...${NC}"
                sudo pacman -S --needed --noconfirm ffmpeg
                
                if command -v ffmpeg &>/dev/null; then
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}ffmpeg installed successfully!${NC}"
                    echo ""
                    echo -ne "${WHITE}Press Enter to continue to Nordix CLI Media...${NC}"
                    read -r
                else
                    echo ""
                    echo -e "${RED}[X]${NC} ${WHITE}ffmpeg installation failed!${NC}"
                    echo -e "${WHITE}Please install ffmpeg manually and try again.${NC}"
                    echo ""
                    exit 1
                fi
                ;;
            *)
                echo ""
                echo -e "${RED}ffmpeg is required for Nordix CLI Media.${NC}"
                echo -e "${WHITE}Exiting...${NC}"
                echo ""
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
    draw_box "         Nordix CLI - Media           "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DESCRIPTION:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Version 1.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Convert single media files${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Batch-convert multiple files${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Inspect media file metadata${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Clean metadata from media files${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}USAGE:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}nx-cli-media${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}nx-cli-media --help${NC}"
    echo ""
    draw_border
    echo ""
    exit 0
}

# Check for --help or -h
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# Run startup check
startup_check

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
    draw_box "         Nordix CLI - Media           "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}OPTIONS:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Convert media file${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Batch-convert media files${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Inspect media file${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Clean metadata${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-4):${NC}"
    echo ""
}

# ============================================
# FORMAT SELECTION MENU
# ============================================
# Global variable to store format choice
FORMAT_CHOICE=""

select_output_format() {
    local title="$1"
    clear
    echo ""
    draw_box "          $title          "
    echo ""
    draw_border
    echo -e "${WHITE}Select output format:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}MP3 ${NHYPRBLUE}(audio)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}FLAC ${NHYPRBLUE}(lossless audio)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}M4A ${NHYPRBLUE}(AAC audio)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}OGG ${NHYPRBLUE}(Vorbis audio)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}OPUS ${NHYPRBLUE}(Opus audio)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}WAV ${NHYPRBLUE}(uncompressed)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}MP4 ${NHYPRBLUE}(video)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}MKV ${NHYPRBLUE}(video)${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}WEBM ${NHYPRBLUE}(web video)${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back to main menu${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-9):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r FORMAT_CHOICE
}

# Get file extension from format choice
get_extension() {
    case "$1" in
        1) echo "mp3" ;;
        2) echo "flac" ;;
        3) echo "m4a" ;;
        4) echo "ogg" ;;
        5) echo "opus" ;;
        6) echo "wav" ;;
        7) echo "mp4" ;;
        8) echo "mkv" ;;
        9) echo "webm" ;;
        *) echo "" ;;
    esac
}

# Get ffmpeg codec options for format
get_codec_options() {
    case "$1" in
        mp3)  echo "-c:a libmp3lame -q:a 2" ;;
        flac) echo "-c:a flac" ;;
        m4a)  echo "-c:a aac -b:a 256k" ;;
        ogg)  echo "-c:a libvorbis -q:a 6" ;;
        opus) echo "-c:a libopus -b:a 128k" ;;
        wav)  echo "-c:a pcm_s16le" ;;
        mp4)  echo "-c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k" ;;
        mkv)  echo "-c:v libx264 -preset medium -crf 23 -c:a copy" ;;
        webm) echo "-c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -b:a 128k" ;;
        *)    echo "" ;;
    esac
}

# ============================================
# CONVERT SINGLE FILE
# ============================================
convert_media() {
    select_output_format "Convert Media File"
    
    if [[ "$FORMAT_CHOICE" == "0" || -z "$FORMAT_CHOICE" ]]; then
        return
    fi
    
    local ext
    ext=$(get_extension "$FORMAT_CHOICE")
    
    if [[ -z "$ext" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Invalid format selection!${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter the path to the input file:${NC}"
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
    
    # Generate output filename
    local basename
    basename=$(basename "$input_file")
    local name_noext="${basename%.*}"
    local output_file="${name_noext}.${ext}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter output filename ${NHYPRBLUE}(default: $output_file):${NC}"
    echo -e "${NARTIC}Extension .${ext} will be added automatically${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_output
    
    if [[ -n "$custom_output" ]]; then
        # Remove any existing extension and add the correct one
        custom_output="${custom_output%.*}"
        output_file="${custom_output}.${ext}"
    fi
    
    local codec_opts
    codec_opts=$(get_codec_options "$ext")
    
    echo ""
    echo -e "${WHITE}Converting: ${NARTIC}$input_file${NC}"
    echo -e "${WHITE}Output: ${NARTIC}$output_file${NC}"
    echo ""
    
    if ffmpeg -y -i "$input_file" $codec_opts "$output_file" 2>/dev/null; then
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Conversion completed: ${NARTIC}$output_file${NC}"
    else
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}Conversion failed!${NC}"
    fi
    
    press_enter
}

# ============================================
# BATCH CONVERT FILES
# ============================================
batch_convert_media() {
    select_output_format "Batch Convert Media"
    
    if [[ "$FORMAT_CHOICE" == "0" || -z "$FORMAT_CHOICE" ]]; then
        return
    fi
    
    local ext
    ext=$(get_extension "$FORMAT_CHOICE")
    
    if [[ -z "$ext" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Invalid format selection!${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}Select source format to convert from:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}WAV files ${NHYPRBLUE}(*.wav)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}MP3 files ${NHYPRBLUE}(*.mp3)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}FLAC files ${NHYPRBLUE}(*.flac)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}M4A files ${NHYPRBLUE}(*.m4a)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}MP4 files ${NHYPRBLUE}(*.mp4)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}MKV files ${NHYPRBLUE}(*.mkv)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}All media files ${NHYPRBLUE}(custom pattern)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose source format ${NHYPRBLUE}(1-7):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r source_choice
    
    local pattern
    case "$source_choice" in
        1) pattern="*.wav" ;;
        2) pattern="*.mp3" ;;
        3) pattern="*.flac" ;;
        4) pattern="*.m4a" ;;
        5) pattern="*.mp4" ;;
        6) pattern="*.mkv" ;;
        7)
            echo ""
            echo -e "${WHITE}Enter file pattern ${NHYPRBLUE}(e.g., *.avi):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r pattern
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter directory path ${NHYPRBLUE}(default: current directory):${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r dir_path
    
    if [[ -z "$dir_path" ]]; then
        dir_path="."
    fi
    
    if [[ ! -d "$dir_path" ]]; then
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}Directory not found: ${NARTIC}$dir_path${NC}"
        press_enter
        return
    fi
    
    local codec_opts
    codec_opts=$(get_codec_options "$ext")
    
    local count=0
    local failed=0
    
    echo ""
    echo -e "${WHITE}Converting ${NARTIC}$pattern${WHITE} files to ${NARTIC}$ext${WHITE}...${NC}"
    echo ""
    
    shopt -s nullglob
    for f in "$dir_path"/$pattern; do
        local basename
        basename=$(basename "$f")
        local name_noext="${basename%.*}"
        local output_file="$dir_path/${name_noext}.${ext}"
        
        echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Converting: ${NARTIC}$basename${NC}"
        
        if ffmpeg -y -i "$f" $codec_opts "$output_file" 2>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC} ${NARTIC}${name_noext}.${ext}${NC}"
            ((count++))
        else
            echo -e "  ${RED}[X]${NC} ${WHITE}Failed${NC}"
            ((failed++))
        fi
    done
    shopt -u nullglob
    
    echo ""
    draw_border
    echo -e "${WHITE}Batch conversion complete!${NC}"
    echo -e "${GREEN}[OK]${NC} ${WHITE}Converted: ${NARTIC}$count${WHITE} files${NC}"
    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}Failed: ${NARTIC}$failed${WHITE} files${NC}"
    fi
    draw_border
    
    press_enter
}

# ============================================
# INSPECT MEDIA FILE
# ============================================
inspect_media() {
    clear
    echo ""
    draw_box "         Inspect Media File          "
    echo ""
    draw_border
    echo -e "${WHITE}Enter the path to the media file:${NC}"
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
    
    echo ""
    draw_border
    echo -e "${WHITE}MEDIA INFORMATION:${NC}"
    draw_border
    echo ""
    
    ffprobe -hide_banner "$input_file" 2>&1
    
    echo ""
    draw_border
    
    press_enter
}

# ============================================
# CLEAN METADATA
# ============================================
clean_metadata() {
    clear
    echo ""
    draw_box "          Clean Metadata             "
    echo ""
    draw_border
    echo -e "${WHITE}Enter the path to the input file:${NC}"
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
    
    # Get file extension from input file
    local basename
    basename=$(basename "$input_file")
    local name_noext="${basename%.*}"
    local ext="${basename##*.}"
    local output_file="clean_${name_noext}.${ext}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Detected format: ${NARTIC}.${ext}${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Enter output filename ${NHYPRBLUE}(default: $output_file):${NC}"
    echo -e "${NARTIC}Extension .${ext} will be added automatically${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_output
    
    if [[ -n "$custom_output" ]]; then
        # Remove any existing extension and add the correct one
        custom_output="${custom_output%.*}"
        output_file="${custom_output}.${ext}"
    fi
    
    echo ""
    echo -e "${WHITE}Cleaning metadata...${NC}"
    echo -e "${WHITE}Input: ${NARTIC}$input_file${NC}"
    echo -e "${WHITE}Output: ${NARTIC}$output_file${NC}"
    echo ""
    
    # Clean metadata with -map_metadata -1, copy streams without re-encoding
    if ffmpeg -y -i "$input_file" \
        -map 0 \
        -map_metadata -1 \
        -c copy \
        "$output_file" 2>/dev/null; then
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Metadata cleaned: ${NARTIC}$output_file${NC}"
    else
        echo ""
        echo -e "${RED}[X]${NC} ${WHITE}Cleaning failed!${NC}"
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
            convert_media
            ;;
        2)
            batch_convert_media
            ;;
        3)
            inspect_media
            ;;
        4)
            clean_metadata
            ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix CLI Media!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid choice! Please enter a number between 0 and 4.${NC}"
            sleep 2
            ;;
    esac
done
