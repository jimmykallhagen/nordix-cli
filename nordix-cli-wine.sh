#!/bin/bash
##=========================================================##
 # SPDX-License-Identifier: GPL-3.0-or-later               #
 # Copyright (c) 2025 Jimmy Källhagen                      #
 # Part of Yggdrasil - Nordix desktop environment          #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen  #
##=========================================================##
# ============================================
# Nordix CLI Wine - Version 1.0
# Wine management tool for Hyprland
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
# GLOBAL VARIABLES
# ============================================
SELECTED_PREFIX=""
SELECTED_WINE=""
SELECTED_WINE_NAME=""
DEFAULT_PREFIX_DIR="$HOME/wine-prefixes"

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

check_pkg() {
    pacman -Qi "$1" &>/dev/null 2>&1
}

install_pkg() {
    local pkg="$1"
    echo -e "${WHITE}Installing ${NARTIC}${pkg}${WHITE}...${NC}"
    
    if pacman -Si "$pkg" &>/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm "$pkg"
    elif have_cmd paru; then
        paru -S --needed --noconfirm "$pkg"
    elif have_cmd yay; then
        yay -S --needed --noconfirm "$pkg"
    else
        echo -e "${RED}[X]${NC} ${WHITE}Package ${NARTIC}$pkg${WHITE} not found.${NC}"
        echo -e "${WHITE}You may need an AUR helper (paru/yay) for this package.${NC}"
        return 1
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
    draw_box "         Nordix CLI - Wine           "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DESCRIPTION:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Version 1.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Run Windows applications with Wine${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Manage Wine prefixes${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Configure Wine with winecfg${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Install Windows components with winetricks${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Support for wine-staging, wine-cachyos, wine-ge${NC}"
    echo ""
    draw_border
    echo ""
    exit 0
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# ============================================
# WINE VERSION SELECTION
# ============================================
select_wine_version() {
    clear
    echo ""
    draw_box "       Select Wine Version          "
    echo ""
    draw_border
    echo -e "${WHITE}Choose which Wine to use:${NC}"
    draw_border
    echo ""
    
    local option_num=1
    local has_system=false
    local has_cachyos=false
    local has_wine_ge=false
    local wine_ge_path=""
    
    # System wine
    if have_cmd wine; then
        has_system=true
        local sys_version
        sys_version=$(wine --version 2>/dev/null | head -1)
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}System Wine ${NHYPRBLUE}($sys_version)${NC}"
    else
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}System Wine ${RED}(not installed)${NC}"
    fi
    option_num=$((option_num + 1))
    
    # Wine CachyOS
    if [[ -x "/opt/wine-cachyos/bin/wine" ]]; then
        has_cachyos=true
        local cachyos_version
        cachyos_version=$(/opt/wine-cachyos/bin/wine --version 2>/dev/null | head -1)
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}Wine CachyOS ${NHYPRBLUE}($cachyos_version)${NC}"
    else
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}Wine CachyOS ${RED}(not installed)${NC}"
    fi
    option_num=$((option_num + 1))
    
    # Wine-GE from Lutris
    wine_ge_path=$(find "$HOME/.local/share/lutris/runners/wine/" -maxdepth 2 -name "wine64" -path "*wine-ge*" 2>/dev/null | head -1)
    if [[ -x "$wine_ge_path" ]]; then
        has_wine_ge=true
        local wine_ge_dir
        wine_ge_dir=$(dirname "$wine_ge_path")
        wine_ge_dir=$(dirname "$wine_ge_dir")
        local wine_ge_name
        wine_ge_name=$(basename "$wine_ge_dir")
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}Wine-GE ${NHYPRBLUE}($wine_ge_name) ${NARTIC}via Lutris${NC}"
    else
        echo -e "${BLUE} ${option_num}${NC} ${NVFROST}-${NC} ${NARTIC}Wine-GE ${RED}(not installed - requires Lutris)${NC}"
    fi
    
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose Wine version ${NHYPRBLUE}(0-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r wine_choice
    
    case "$wine_choice" in
        1)
            if [[ "$has_system" == true ]]; then
                SELECTED_WINE="wine"
                SELECTED_WINE_NAME="System Wine"
                return 0
            else
                echo ""
                echo -e "${YELLOW}!${NC} ${WHITE}System Wine is not installed.${NC}"
                echo -ne "${WHITE}Install wine-staging? ${NHYPRBLUE}[Y/n]: ${NC}"
                read -r install_choice
                case "$install_choice" in
                    [yY]|[yY][eE][sS]|"")
                        install_pkg "wine-staging"
                        if have_cmd wine; then
                            SELECTED_WINE="wine"
                            SELECTED_WINE_NAME="System Wine"
                            return 0
                        fi
                        ;;
                esac
                return 1
            fi
            ;;
        2)
            if [[ "$has_cachyos" == true ]]; then
                SELECTED_WINE="/opt/wine-cachyos/bin/wine"
                SELECTED_WINE_NAME="Wine CachyOS"
                return 0
            else
                echo ""
                echo -e "${YELLOW}!${NC} ${WHITE}Wine CachyOS is not installed.${NC}"
                echo -ne "${WHITE}Install wine-cachyos-opt? ${NHYPRBLUE}[Y/n]: ${NC}"
                read -r install_choice
                case "$install_choice" in
                    [yY]|[yY][eE][sS]|"")
                        install_pkg "wine-cachyos-opt"
                        if [[ -x "/opt/wine-cachyos/bin/wine" ]]; then
                            SELECTED_WINE="/opt/wine-cachyos/bin/wine"
                            SELECTED_WINE_NAME="Wine CachyOS"
                            return 0
                        fi
                        ;;
                esac
                return 1
            fi
            ;;
        3)
            if [[ "$has_wine_ge" == true ]]; then
                SELECTED_WINE="$wine_ge_path"
                SELECTED_WINE_NAME="Wine-GE (Lutris)"
                return 0
            else
                echo ""
                echo -e "${YELLOW}!${NC} ${WHITE}Wine-GE is not installed.${NC}"
                echo -e "${WHITE}Wine-GE comes with Lutris. Install Lutris first,${NC}"
                echo -e "${WHITE}then download Wine-GE from Lutris runner management.${NC}"
                press_enter
                return 1
            fi
            ;;
        0)
            return 1
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            sleep 1
            return 1
            ;;
    esac
}

# ============================================
# PREFIX SELECTION
# ============================================
select_prefix() {
    clear
    echo ""
    draw_box "        Select Wine Prefix          "
    echo ""
    draw_border
    echo -e "${WHITE}Choose Wine prefix:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Default prefix ${NHYPRBLUE}(~/.wine)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Create new prefix ${GREEN}(recommended)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Select existing prefix${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Enter custom path${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${YELLOW}!${NC} ${WHITE}Tip: Use separate prefixes for each application.${NC}"
    echo -e "${WHITE}   This prevents conflicts between programs.${NC}"
    echo -e "${WHITE}   Nordix recommends: ${NARTIC}~/wine-prefixes/app-name${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r prefix_choice
    
    case "$prefix_choice" in
        1)
            SELECTED_PREFIX="$HOME/.wine"
            return 0
            ;;
        2)
            # Check if prefix directory exists
            if [[ ! -d "$DEFAULT_PREFIX_DIR" ]]; then
                echo ""
                echo -e "${YELLOW}!${NC} ${WHITE}Directory ${NARTIC}$DEFAULT_PREFIX_DIR${WHITE} does not exist.${NC}"
                echo -ne "${WHITE}Create it now? ${NHYPRBLUE}[Y/n]: ${NC}"
                read -r create_dir
                case "$create_dir" in
                    [yY]|[yY][eE][sS]|"")
                        mkdir -p "$DEFAULT_PREFIX_DIR"
                        echo -e "${GREEN}[OK]${NC} ${WHITE}Created ${NARTIC}$DEFAULT_PREFIX_DIR${NC}"
                        ;;
                    *)
                        echo -e "${RED}[X]${NC} ${WHITE}Cannot create prefix without directory.${NC}"
                        press_enter
                        return 1
                        ;;
                esac
            fi
            
            echo ""
            draw_border
            echo -e "${WHITE}Enter name for new prefix:${NC}"
            echo -e "${NARTIC}Will be created in: ${NHYPRBLUE}$DEFAULT_PREFIX_DIR/${NC}"
            draw_border
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r prefix_name
            
            if [[ -z "$prefix_name" ]]; then
                echo -e "${RED}[X]${NC} ${WHITE}No name entered!${NC}"
                press_enter
                return 1
            fi
            
            # Remove spaces and special characters
            prefix_name=$(echo "$prefix_name" | tr ' ' '-' | tr -cd '[:alnum:]-_')
            SELECTED_PREFIX="$DEFAULT_PREFIX_DIR/$prefix_name"
            
            if [[ -d "$SELECTED_PREFIX" ]]; then
                echo -e "${YELLOW}!${NC} ${WHITE}Prefix already exists: ${NARTIC}$SELECTED_PREFIX${NC}"
                echo -ne "${WHITE}Use this existing prefix? ${NHYPRBLUE}[Y/n]: ${NC}"
                read -r use_existing
                case "$use_existing" in
                    [yY]|[yY][eE][sS]|"")
                        return 0
                        ;;
                    *)
                        return 1
                        ;;
                esac
            fi
            
            echo -e "${GREEN}[OK]${NC} ${WHITE}New prefix will be created: ${NARTIC}$SELECTED_PREFIX${NC}"
            return 0
            ;;
        3)
            # List existing prefixes
            echo ""
            draw_border
            echo -e "${WHITE}Existing prefixes:${NC}"
            draw_border
            echo ""
            
            local prefix_count=0
            declare -a prefix_list
            
            # Check default .wine
            if [[ -d "$HOME/.wine" ]]; then
                prefix_count=$((prefix_count + 1))
                prefix_list[$prefix_count]="$HOME/.wine"
                echo -e "${BLUE} ${prefix_count}${NC} ${NVFROST}-${NC} ${NARTIC}~/.wine ${NHYPRBLUE}(default)${NC}"
            fi
            
            # List prefixes in wine-prefixes directory
            if [[ -d "$DEFAULT_PREFIX_DIR" ]]; then
                for dir in "$DEFAULT_PREFIX_DIR"/*/; do
                    if [[ -d "$dir" ]]; then
                        prefix_count=$((prefix_count + 1))
                        prefix_list[$prefix_count]="${dir%/}"
                        local dirname
                        dirname=$(basename "$dir")
                        echo -e "${BLUE} ${prefix_count}${NC} ${NVFROST}-${NC} ${NARTIC}$dirname${NC}"
                    fi
                done
            fi
            
            if [[ $prefix_count -eq 0 ]]; then
                echo -e "${YELLOW}!${NC} ${WHITE}No existing prefixes found.${NC}"
                press_enter
                return 1
            fi
            
            echo ""
            echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
            echo ""
            draw_border
            echo ""
            echo -e "${NGLACIER}Choose prefix ${NHYPRBLUE}(0-$prefix_count):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r prefix_num
            
            if [[ "$prefix_num" == "0" ]]; then
                return 1
            fi
            
            if [[ -n "${prefix_list[$prefix_num]}" ]]; then
                SELECTED_PREFIX="${prefix_list[$prefix_num]}"
                return 0
            else
                echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
                press_enter
                return 1
            fi
            ;;
        4)
            echo ""
            draw_border
            echo -e "${WHITE}Enter full path to prefix:${NC}"
            draw_border
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r custom_path
            
            if [[ -z "$custom_path" ]]; then
                echo -e "${RED}[X]${NC} ${WHITE}No path entered!${NC}"
                press_enter
                return 1
            fi
            
            # Expand ~ to $HOME
            custom_path="${custom_path/#\~/$HOME}"
            SELECTED_PREFIX="$custom_path"
            return 0
            ;;
        0)
            return 1
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            sleep 1
            return 1
            ;;
    esac
}

# ============================================
# SHOW CURRENT SELECTION
# ============================================
show_current_selection() {
    if [[ -n "$SELECTED_WINE" || -n "$SELECTED_PREFIX" ]]; then
        echo ""
        draw_border
        echo -e "${WHITE}Current selection:${NC}"
        draw_border
        echo ""
        if [[ -n "$SELECTED_WINE_NAME" ]]; then
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Wine: ${NARTIC}$SELECTED_WINE_NAME${NC}"
        fi
        if [[ -n "$SELECTED_PREFIX" ]]; then
            echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Prefix: ${NARTIC}$SELECTED_PREFIX${NC}"
        fi
        echo ""
    fi
}

# ============================================
# RUN WINE APPLICATION
# ============================================
run_wine_application() {
    clear
    echo ""
    draw_box "      Run Windows Application       "
    echo ""
    
    # Select wine version if not selected
    if [[ -z "$SELECTED_WINE" ]]; then
        if ! select_wine_version; then
            return
        fi
        clear
        echo ""
        draw_box "      Run Windows Application       "
        echo ""
    fi
    
    # Select prefix if not selected
    if [[ -z "$SELECTED_PREFIX" ]]; then
        if ! select_prefix; then
            return
        fi
        clear
        echo ""
        draw_box "      Run Windows Application       "
        echo ""
    fi
    
    show_current_selection
    
    draw_border
    echo -e "${WHITE}Enter path to .exe file:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r exe_path
    
    if [[ -z "$exe_path" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No file specified!${NC}"
        press_enter
        return
    fi
    
    # Expand ~ to $HOME
    exe_path="${exe_path/#\~/$HOME}"
    
    if [[ ! -f "$exe_path" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}File not found: ${NARTIC}$exe_path${NC}"
        press_enter
        return
    fi
    
    echo ""
    draw_border
    echo -e "${YELLOW}!${NC} ${WHITE}Tip: When installing applications, choose a folder in your${NC}"
    echo -e "${WHITE}   home directory, not inside the Wine prefix.${NC}"
    echo -e "${WHITE}   Example: ${NARTIC}~/Games/MyGame${WHITE} or ${NARTIC}~/Programs/MyApp${NC}"
    draw_border
    echo ""
    
    echo -e "${WHITE}Running: ${NARTIC}$exe_path${NC}"
    echo -e "${WHITE}With: ${NARTIC}$SELECTED_WINE_NAME${NC}"
    echo -e "${WHITE}Prefix: ${NARTIC}$SELECTED_PREFIX${NC}"
    echo ""
    
    # Create prefix directory if it doesn't exist
    if [[ ! -d "$SELECTED_PREFIX" ]]; then
        mkdir -p "$SELECTED_PREFIX"
    fi
    
    # Run wine
    WINEPREFIX="$SELECTED_PREFIX" "$SELECTED_WINE" "$exe_path"
    
    press_enter
}

# ============================================
# RUN WINECFG
# ============================================
run_winecfg() {
    clear
    echo ""
    draw_box "         Wine Configuration         "
    echo ""
    
    # Select wine version if not selected
    if [[ -z "$SELECTED_WINE" ]]; then
        if ! select_wine_version; then
            return
        fi
        clear
        echo ""
        draw_box "         Wine Configuration         "
        echo ""
    fi
    
    # Select prefix if not selected
    if [[ -z "$SELECTED_PREFIX" ]]; then
        if ! select_prefix; then
            return
        fi
        clear
        echo ""
        draw_box "         Wine Configuration         "
        echo ""
    fi
    
    show_current_selection
    
    draw_border
    echo -e "${WHITE}IMPORTANT TIPS:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}Check the ${NARTIC}Windows Version${WHITE} setting in the Applications tab.${NC}"
    echo -e "${WHITE}   Most modern programs need ${NARTIC}Windows 10${WHITE}.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}If text is too small, go to ${NARTIC}Graphics${WHITE} tab and${NC}"
    echo -e "${WHITE}   increase the ${NARTIC}Screen resolution (DPI)${WHITE} value.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${WHITE}The ${NARTIC}Drives${WHITE} tab shows how Wine maps your filesystem.${NC}"
    echo ""
    draw_border
    echo ""
    
    if confirm_action "Open winecfg?"; then
        # Create prefix directory if it doesn't exist
        if [[ ! -d "$SELECTED_PREFIX" ]]; then
            mkdir -p "$SELECTED_PREFIX"
        fi
        
        # Get winecfg path based on wine version
        local winecfg_path
        if [[ "$SELECTED_WINE" == "wine" ]]; then
            winecfg_path="winecfg"
        else
            winecfg_path="$(dirname "$SELECTED_WINE")/winecfg"
        fi
        
        echo ""
        echo -e "${WHITE}Opening winecfg...${NC}"
        WINEPREFIX="$SELECTED_PREFIX" "$winecfg_path" 2>/dev/null || WINEPREFIX="$SELECTED_PREFIX" winecfg
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}winecfg closed.${NC}"
    fi
    
    press_enter
}

# ============================================
# WINETRICKS
# ============================================
run_winetricks() {
    clear
    echo ""
    draw_box "            Winetricks              "
    echo ""
    
    # Check if winetricks is installed
    if ! have_cmd winetricks; then
        echo -e "${YELLOW}!${NC} ${WHITE}Winetricks is not installed.${NC}"
        echo -ne "${WHITE}Install winetricks? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_choice
        case "$install_choice" in
            [yY]|[yY][eE][sS]|"")
                install_pkg "winetricks"
                if ! have_cmd winetricks; then
                    echo -e "${RED}[X]${NC} ${WHITE}Installation failed!${NC}"
                    press_enter
                    return
                fi
                ;;
            *)
                return
                ;;
        esac
    fi
    
    # Select wine version if not selected
    if [[ -z "$SELECTED_WINE" ]]; then
        if ! select_wine_version; then
            return
        fi
        clear
        echo ""
        draw_box "            Winetricks              "
        echo ""
    fi
    
    # Select prefix if not selected
    if [[ -z "$SELECTED_PREFIX" ]]; then
        if ! select_prefix; then
            return
        fi
        clear
        echo ""
        draw_box "            Winetricks              "
        echo ""
    fi
    
    show_current_selection
    
    draw_border
    echo -e "${WHITE}Winetricks options:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Gaming Meta ${NHYPRBLUE}(full gaming setup)${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Gaming Meta Minimal ${NHYPRBLUE}(basic gaming)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Gaming Legacy ${NHYPRBLUE}(older games, Win7)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Program Meta Minimal ${NHYPRBLUE}(basic apps)${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Program Meta Max ${NHYPRBLUE}(full app support)${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Program Legacy ${NHYPRBLUE}(older apps, Win7)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Custom installation ${NHYPRBLUE}(choose packages)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Open winetricks GUI${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${RED}!${NC} ${WHITE}Warning: Do not install multiple .NET versions in the same prefix.${NC}"
    echo -e "${WHITE}   This can cause conflicts. Choose one version that your app needs.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-8):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r tricks_choice
    
    # Create prefix directory if it doesn't exist
    if [[ ! -d "$SELECTED_PREFIX" ]]; then
        mkdir -p "$SELECTED_PREFIX"
    fi
    
    case "$tricks_choice" in
        1) winetricks_gaming_meta ;;
        2) winetricks_gaming_minimal ;;
        3) winetricks_gaming_legacy ;;
        4) winetricks_program_minimal ;;
        5) winetricks_program_max ;;
        6) winetricks_program_legacy ;;
        7) winetricks_custom ;;
        8)
            echo ""
            echo -e "${WHITE}Opening winetricks GUI...${NC}"
            WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks --gui
            ;;
        0) return ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            press_enter
            return
            ;;
    esac
    
    press_enter
}

# ============================================
# WINETRICKS META PACKAGES
# ============================================

winetricks_gaming_meta() {
    clear
    echo ""
    draw_box "      Gaming Meta Installation       "
    echo ""
    draw_border
    echo -e "${WHITE}This will install:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 10 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 4.0, 4.8${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ 2013, 2015, 2022${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DXVK, VKD3D${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DirectX components (d3dx9, d3dx11, d3dcompiler)${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}FAudio, XInput, XACT, PhysX, OpenAL${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Core fonts and other essentials${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${YELLOW}!${NC} ${WHITE}This may take a while...${NC}"
    echo ""
    
    if confirm_action "Install Gaming Meta package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win10 dotnet40 dotnet48 \
            vcrun2013 vcrun2015 vcrun2022 \
            dxvk vkd3d \
            d3dcompiler_43 d3dcompiler_47 d3dx9 d3dx9_43 d3dx11_43 \
            faudio xinput xact msxml6 physx openal crypt32 \
            corefonts tahoma
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Gaming Meta installed!${NC}"
    fi
}

winetricks_gaming_minimal() {
    clear
    echo ""
    draw_box "   Gaming Meta Minimal Installation  "
    echo ""
    draw_border
    echo -e "${WHITE}This will install:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 10 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ 2022${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 4.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DXVK${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}FAudio, XInput${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Core fonts${NC}"
    echo ""
    draw_border
    echo ""
    
    if confirm_action "Install Gaming Meta Minimal package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win10 vcrun2022 dotnet40 dxvk faudio xinput corefonts tahoma
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Gaming Meta Minimal installed!${NC}"
    fi
}

winetricks_gaming_legacy() {
    clear
    echo ""
    draw_box "    Gaming Legacy Installation      "
    echo ""
    draw_border
    echo -e "${WHITE}This will install ${NHYPRBLUE}(Windows 7 mode):${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 7 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ 2005-2012${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 3.5${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DirectX 9 components${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DirectPlay, DirectInput${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Core fonts${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${YELLOW}!${NC} ${WHITE}Use this for older games (pre-2015).${NC}"
    echo ""
    
    if confirm_action "Install Gaming Legacy package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win7 vcrun2005 vcrun2008 vcrun2010 vcrun2012 dotnet35 \
            d3dx9 d3dx9_43 d3dcompiler_43 xinput xact \
            directplay quartz openal dinput8 \
            corefonts tahoma
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Gaming Legacy installed!${NC}"
    fi
}

winetricks_program_minimal() {
    clear
    echo ""
    draw_box "  Program Meta Minimal Installation  "
    echo ""
    draw_border
    echo -e "${WHITE}This will install:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 10 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ 2022${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 4.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}MSXML6, GDI+, RichEdit${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Core fonts${NC}"
    echo ""
    draw_border
    echo ""
    
    if confirm_action "Install Program Meta Minimal package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win10 vcrun2022 dotnet40 corefonts gdiplus riched30 msxml6
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Program Meta Minimal installed!${NC}"
    fi
}

winetricks_program_max() {
    clear
    echo ""
    draw_box "    Program Meta Max Installation    "
    echo ""
    draw_border
    echo -e "${WHITE}This will install everything for full compatibility:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 10 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 4.0, 4.8${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ runtimes${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}MSXML, GDI+, RichEdit${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Media codecs, Windows Media Player${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}VB/VC runtimes${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Database components (MDAC, Jet)${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}All fonts${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${YELLOW}!${NC} ${WHITE}This is a large installation and will take a long time...${NC}"
    echo ""
    
    if confirm_action "Install Program Meta Max package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win10 dotnet40 dotnet48 \
            vcrun2013 vcrun2022 \
            msxml3 msxml4 msxml6 gdiplus riched20 riched30 \
            corefonts tahoma \
            quartz wmp10 allcodecs \
            vb6run vcrun6 mfc42 mdac28 jet40
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Program Meta Max installed!${NC}"
    fi
}

winetricks_program_legacy() {
    clear
    echo ""
    draw_box "   Program Legacy Installation      "
    echo ""
    draw_border
    echo -e "${WHITE}This will install ${NHYPRBLUE}(Windows 7 mode):${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Windows 7 environment${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}.NET Framework 2.0, 3.5, 4.0${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Visual C++ 2005-2012${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}MSXML, GDI+, RichEdit${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Media codecs${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}VB/VC runtimes${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}DirectX 9, DirectSound, DirectPlay${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${YELLOW}!${NC} ${WHITE}Use this for older applications.${NC}"
    echo -e "${YELLOW}!${NC} ${WHITE}This is a large installation and will take a long time...${NC}"
    echo ""
    
    if confirm_action "Install Program Legacy package?"; then
        echo ""
        WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q \
            win7 dotnet20 dotnet35 dotnet40 \
            vcrun2005 vcrun2008 vcrun2010 vcrun2012 \
            msxml3 msxml4 msxml6 gdiplus riched20 \
            corefonts tahoma \
            quartz wmp9 \
            vb5run vb6run vcrun6 mfc40 mfc42 mdac28 jet40 \
            directx9 dinput8 dsound
        
        echo ""
        echo -e "${GREEN}[OK]${NC} ${WHITE}Program Legacy installed!${NC}"
    fi
}

winetricks_custom() {
    clear
    echo ""
    draw_box "     Custom Winetricks Install      "
    echo ""
    
    show_current_selection
    
    draw_border
    echo -e "${WHITE}Enter winetricks packages to install:${NC}"
    echo -e "${NARTIC}Separate multiple packages with spaces.${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Common packages:${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}vcrun2022 vcrun2019 vcrun2015 vcrun2013${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}dotnet48 dotnet40 dotnet35 dotnet20${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}dxvk vkd3d d3dx9 d3dx11${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}corefonts tahoma${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}win10 win7 winxp${NC}"
    echo ""
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_packages
    
    if [[ -z "$custom_packages" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No packages specified!${NC}"
        return
    fi
    
    echo ""
    echo -e "${WHITE}Installing: ${NARTIC}$custom_packages${NC}"
    echo ""
    
    WINEPREFIX="$SELECTED_PREFIX" WINE="$SELECTED_WINE" winetricks -q $custom_packages
    
    echo ""
    echo -e "${GREEN}[OK]${NC} ${WHITE}Installation completed!${NC}"
}

# ============================================
# WINE CHECK - SYSTEM REQUIREMENTS
# ============================================
wine_check() {
    clear
    echo ""
    draw_box "       Nordix Wine Check            "
    echo ""
    draw_border
    echo -e "${WHITE}Checking Wine components and dependencies...${NC}"
    draw_border
    echo ""
    
    local missing_packages=()
    local all_ok=true
    
    echo -e "${WHITE}CORE WINE COMPONENTS:${NC}"
    echo ""
    
    # Check wine-staging
    if check_pkg "wine-staging"; then
        local ver=$(wine --version 2>/dev/null | head -1)
        echo -e "${GREEN}[OK]${NC} ${WHITE}wine-staging ${NARTIC}($ver)${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}wine-staging ${RED}(not installed)${NC}"
        missing_packages+=("wine-staging")
        all_ok=false
    fi
    
    # Check winetricks
    if have_cmd winetricks; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}winetricks${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}winetricks ${RED}(not installed)${NC}"
        missing_packages+=("winetricks")
        all_ok=false
    fi
    
    # Check wine-cachyos-opt
    if [[ -x "/opt/wine-cachyos/bin/wine" ]]; then
        local ver=$(/opt/wine-cachyos/bin/wine --version 2>/dev/null | head -1)
        echo -e "${GREEN}[OK]${NC} ${WHITE}wine-cachyos-opt ${NARTIC}($ver)${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}wine-cachyos-opt ${NARTIC}(optional)${NC}"
        missing_packages+=("wine-cachyos-opt")
    fi
    
    echo ""
    echo -e "${WHITE}VULKAN/DIRECTX TRANSLATION:${NC}"
    echo ""
    
    # Check vkd3d
    if check_pkg "vkd3d"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}vkd3d${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}vkd3d ${RED}(not installed)${NC}"
        missing_packages+=("vkd3d")
        all_ok=false
    fi
    
    # Check lib32-vkd3d
    if check_pkg "lib32-vkd3d"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}lib32-vkd3d${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}lib32-vkd3d ${RED}(not installed)${NC}"
        missing_packages+=("lib32-vkd3d")
        all_ok=false
    fi
    
    # Check vkd3d-proton
    if check_pkg "vkd3d-proton-mingw-git"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}vkd3d-proton-mingw-git${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}vkd3d-proton-mingw-git ${NARTIC}(optional)${NC}"
        missing_packages+=("vkd3d-proton-mingw-git")
    fi
    
    # Check dxvk
    if check_pkg "dxvk-mingw-git"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}dxvk-mingw-git${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}dxvk-mingw-git ${RED}(not installed)${NC}"
        missing_packages+=("dxvk-mingw-git")
        all_ok=false
    fi
    
    echo ""
    echo -e "${WHITE}PROTON COMPONENTS:${NC}"
    echo ""
    
    # Check umu-launcher
    if have_cmd umu-run; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}umu-launcher${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}umu-launcher ${NARTIC}(optional)${NC}"
        missing_packages+=("umu-launcher")
    fi
    
    # Check protonup-qt
    if have_cmd protonup-qt; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}protonup-qt${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}protonup-qt ${NARTIC}(optional)${NC}"
        missing_packages+=("protonup-qt")
    fi
    
    # Check protontricks
    if have_cmd protontricks; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}protontricks${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}protontricks ${NARTIC}(optional)${NC}"
        missing_packages+=("protontricks")
    fi
    
    # Check protonplus
    if have_cmd protonplus; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}protonplus${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}protonplus ${NARTIC}(optional)${NC}"
        missing_packages+=("protonplus")
    fi
    
    # Check proton-cachyos
    if check_pkg "proton-cachyos"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}proton-cachyos${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}proton-cachyos ${NARTIC}(optional)${NC}"
        missing_packages+=("proton-cachyos")
    fi
    
    # Check proton-cachyos-slr
    if check_pkg "proton-cachyos-slr"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}proton-cachyos-slr${NC}"
    else
        echo -e "${YELLOW}[!]${NC} ${WHITE}proton-cachyos-slr ${NARTIC}(optional)${NC}"
        missing_packages+=("proton-cachyos-slr")
    fi
    
    echo ""
    echo -e "${WHITE}KERNEL MODULES:${NC}"
    echo ""
    
    # Check ntsync
    local ntsync_ok=false
    if [[ -f "/etc/modules-load.d/ntsync.conf" ]]; then
        if grep -q "ntsync" "/etc/modules-load.d/ntsync.conf" 2>/dev/null; then
            ntsync_ok=true
            echo -e "${GREEN}[OK]${NC} ${WHITE}ntsync module configured${NC}"
        fi
    fi
    
    if [[ "$ntsync_ok" == false ]]; then
        echo -e "${YELLOW}[!]${NC} ${WHITE}ntsync module not configured${NC}"
        echo ""
        echo -e "${WHITE}ntsync improves Wine/Proton performance.${NC}"
        echo -ne "${WHITE}Configure ntsync now? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r configure_ntsync
        case "$configure_ntsync" in
            [yY]|[yY][eE][sS]|"")
                echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf > /dev/null
                echo -e "${GREEN}[OK]${NC} ${WHITE}ntsync configured. Reboot to activate.${NC}"
                ;;
        esac
    fi
    
    echo ""
    draw_border
    echo ""
    
    # Summary
    if [[ "$all_ok" == true ]]; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}All essential Wine components are installed!${NC}"
    else
        echo -e "${YELLOW}!${NC} ${WHITE}Some components are missing.${NC}"
    fi
    
    echo ""
    
    # Offer to install missing packages
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        draw_border
        echo -e "${WHITE}Missing packages:${NC}"
        draw_border
        echo ""
        for pkg in "${missing_packages[@]}"; do
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$pkg${NC}"
        done
        echo ""
        
        echo -ne "${WHITE}Install all missing packages? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r install_all
        case "$install_all" in
            [yY]|[yY][eE][sS]|"")
                echo ""
                for pkg in "${missing_packages[@]}"; do
                    install_pkg "$pkg"
                done
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Installation completed!${NC}"
                ;;
        esac
    fi
    
    press_enter
}

# ============================================
# MANAGE PREFIXES
# ============================================
manage_prefixes() {
    clear
    echo ""
    draw_box "        Manage Wine Prefixes        "
    echo ""
    draw_border
    echo -e "${WHITE}Options:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}List all prefixes${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Create new prefix${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Delete prefix${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Open prefix folder${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r manage_choice
    
    case "$manage_choice" in
        1) list_prefixes ;;
        2) create_new_prefix ;;
        3) delete_prefix ;;
        4) open_prefix_folder ;;
        0) return ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
            sleep 1
            ;;
    esac
    
    press_enter
}

list_prefixes() {
    clear
    echo ""
    draw_box "         All Wine Prefixes          "
    echo ""
    draw_border
    echo -e "${WHITE}Found prefixes:${NC}"
    draw_border
    echo ""
    
    local found=false
    
    # Check default .wine
    if [[ -d "$HOME/.wine" ]]; then
        found=true
        local size
        size=$(du -sh "$HOME/.wine" 2>/dev/null | cut -f1)
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}~/.wine ${WHITE}(default) ${NHYPRBLUE}[$size]${NC}"
    fi
    
    # List prefixes in wine-prefixes directory
    if [[ -d "$DEFAULT_PREFIX_DIR" ]]; then
        for dir in "$DEFAULT_PREFIX_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                found=true
                local dirname size
                dirname=$(basename "$dir")
                size=$(du -sh "$dir" 2>/dev/null | cut -f1)
                echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$dirname ${NHYPRBLUE}[$size]${NC}"
            fi
        done
    fi
    
    if [[ "$found" == false ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}No prefixes found.${NC}"
    fi
    
    echo ""
    draw_border
}

create_new_prefix() {
    clear
    echo ""
    draw_box "       Create New Prefix            "
    echo ""
    
    # Ensure prefix directory exists
    if [[ ! -d "$DEFAULT_PREFIX_DIR" ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}Directory ${NARTIC}$DEFAULT_PREFIX_DIR${WHITE} does not exist.${NC}"
        echo -ne "${WHITE}Create it now? ${NHYPRBLUE}[Y/n]: ${NC}"
        read -r create_dir
        case "$create_dir" in
            [yY]|[yY][eE][sS]|"")
                mkdir -p "$DEFAULT_PREFIX_DIR"
                echo -e "${GREEN}[OK]${NC} ${WHITE}Created ${NARTIC}$DEFAULT_PREFIX_DIR${NC}"
                ;;
            *)
                return
                ;;
        esac
    fi
    
    draw_border
    echo -e "${WHITE}Enter name for new prefix:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r prefix_name
    
    if [[ -z "$prefix_name" ]]; then
        echo -e "${RED}[X]${NC} ${WHITE}No name entered!${NC}"
        return
    fi
    
    # Clean the name
    prefix_name=$(echo "$prefix_name" | tr ' ' '-' | tr -cd '[:alnum:]-_')
    local new_prefix="$DEFAULT_PREFIX_DIR/$prefix_name"
    
    if [[ -d "$new_prefix" ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}Prefix already exists: ${NARTIC}$new_prefix${NC}"
        return
    fi
    
    mkdir -p "$new_prefix"
    echo -e "${GREEN}[OK]${NC} ${WHITE}Created prefix: ${NARTIC}$new_prefix${NC}"
    echo ""
    echo -e "${WHITE}Run winecfg to initialize the prefix.${NC}"
}

delete_prefix() {
    clear
    echo ""
    draw_box "         Delete Prefix              "
    echo ""
    draw_border
    echo -e "${WHITE}Select prefix to delete:${NC}"
    draw_border
    echo ""
    
    local prefix_count=0
    declare -a prefix_list
    
    # List prefixes in wine-prefixes directory only (not default .wine)
    if [[ -d "$DEFAULT_PREFIX_DIR" ]]; then
        for dir in "$DEFAULT_PREFIX_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                prefix_count=$((prefix_count + 1))
                prefix_list[$prefix_count]="${dir%/}"
                local dirname size
                dirname=$(basename "$dir")
                size=$(du -sh "$dir" 2>/dev/null | cut -f1)
                echo -e "${BLUE} ${prefix_count}${NC} ${NVFROST}-${NC} ${NARTIC}$dirname ${NHYPRBLUE}[$size]${NC}"
            fi
        done
    fi
    
    if [[ $prefix_count -eq 0 ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}No deletable prefixes found.${NC}"
        echo -e "${WHITE}Note: Default ~/.wine is not listed for safety.${NC}"
        return
    fi
    
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Cancel${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose prefix to delete ${NHYPRBLUE}(0-$prefix_count):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r del_choice
    
    if [[ "$del_choice" == "0" ]]; then
        return
    fi
    
    if [[ -n "${prefix_list[$del_choice]}" ]]; then
        local target="${prefix_list[$del_choice]}"
        local target_name
        target_name=$(basename "$target")
        
        echo ""
        echo -e "${RED}!${NC} ${WHITE}This will permanently delete: ${NARTIC}$target${NC}"
        echo -ne "${WHITE}Are you sure? Type '${RED}yes${WHITE}' to confirm: ${NC}"
        read -r confirm_delete
        
        if [[ "$confirm_delete" == "yes" ]]; then
            rm -rf "$target"
            echo -e "${GREEN}[OK]${NC} ${WHITE}Deleted: ${NARTIC}$target_name${NC}"
        else
            echo -e "${YELLOW}!${NC} ${WHITE}Deletion cancelled.${NC}"
        fi
    else
        echo -e "${RED}[X]${NC} ${WHITE}Invalid selection!${NC}"
    fi
}

open_prefix_folder() {
    clear
    echo ""
    draw_box "       Open Prefix Folder           "
    echo ""
    
    if ! select_prefix; then
        return
    fi
    
    if [[ -d "$SELECTED_PREFIX" ]]; then
        echo -e "${WHITE}Opening: ${NARTIC}$SELECTED_PREFIX${NC}"
        
        # Try various file managers
        if have_cmd nautilus; then
            nautilus "$SELECTED_PREFIX" &
        elif have_cmd dolphin; then
            dolphin "$SELECTED_PREFIX" &
        elif have_cmd thunar; then
            thunar "$SELECTED_PREFIX" &
        elif have_cmd pcmanfm; then
            pcmanfm "$SELECTED_PREFIX" &
        elif have_cmd nemo; then
            nemo "$SELECTED_PREFIX" &
        elif have_cmd xdg-open; then
            xdg-open "$SELECTED_PREFIX" &
        else
            echo -e "${YELLOW}!${NC} ${WHITE}No file manager found.${NC}"
            echo -e "${WHITE}Path: ${NARTIC}$SELECTED_PREFIX${NC}"
        fi
    else
        echo -e "${RED}[X]${NC} ${WHITE}Prefix does not exist: ${NARTIC}$SELECTED_PREFIX${NC}"
    fi
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
    draw_box "         Nordix CLI - Wine           "
    echo ""
    echo ""
    
    show_current_selection
    
    draw_border
    echo -e "${WHITE}OPTIONS:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Run Windows application${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Wine configuration ${NHYPRBLUE}(winecfg)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Winetricks ${NHYPRBLUE}(install components)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Manage prefixes${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Select Wine version${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Select prefix${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Wine Check ${NHYPRBLUE}(verify installation)${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-7):${NC}"
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
        1) run_wine_application ;;
        2) run_winecfg ;;
        3) run_winetricks ;;
        4) manage_prefixes ;;
        5) select_wine_version ;;
        6) select_prefix ;;
        7) wine_check ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix CLI Wine!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[X]${NC} ${WHITE}Invalid choice! Please enter a number between 0 and 7.${NC}"
            sleep 2
            ;;
    esac
done
