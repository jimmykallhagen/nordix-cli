#!/bin/bash
##=============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                       #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0   #
 # Copyright (c) 2025 Jimmy Källhagen                                          #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                   #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                      #
##=============================================================================##

# User-friendly Arch Linux helper

# ============================================
# CONFIGURATION - User can modify these
# ============================================
# Colors for better UX
RED='\033[38;2;255;0;0m'
GREEN='\033[38;2;0;255;0m'
WHITE='\033[38;2;255;255;255m'
BLUE='\033[38;2;1;204;255m'
NBLUE='\033[38;2;19;171;198m'
NVBLUE='\033[38;2;175;251;253m'
NICE='\033[38;2;0;132;175m'
NARTIC='\033[38;2;156;230;255m'
NGLACIER='\033[38;2;80;200;255m'
NVFROST='\033[38;2;210;255;255m'
NHYPRBLUE='\033[38;2;0;210;255m'
NC='\033[0m' # No Color
# ============================================
# STARTUP CHECK - Verify paru is installed
# ============================================
startup_check() {
    if ! command -v paru &>/dev/null; then
        clear
        echo ""
        draw_border
        echo -e "${RED}          PARU NOT INSTALLED            ${NC}"
        draw_border
        echo ""
        echo -e "${WHITE}Nordix Arch Helper requires ${NARTIC}paru${WHITE} to function.${NC}"
        echo -e "${WHITE}Paru is an AUR helper that allows installation of${NC}"
        echo -e "${WHITE}packages from the Arch User Repository.${NC}"
        echo ""
        echo -e "${WHITE}Would you like to install paru now? [Y/n]: ${NC}"
        read -r install_paru
        
        case "$install_paru" in
            [yY]|[yY][eE][sS]|"")
                echo ""
                echo -e "${WHITE}Installing paru...${NC}"
                echo ""
                
                # Check if base-devel and git are installed
                echo -e "${WHITE}Checking dependencies...${NC}"
                sudo pacman -S --needed --noconfirm base-devel git
                
                # Clone and build paru
                echo ""
                echo -e "${WHITE}Cloning paru from AUR...${NC}"
                cd /tmp
                rm -rf paru-bin 2>/dev/null
                git clone https://aur.archlinux.org/paru-bin.git
                cd paru-bin
                
                echo ""
                echo -e "${WHITE}Building and installing paru...${NC}"
                makepkg -si --noconfirm
                
                cd ~
                rm -rf /tmp/paru-bin
                
                # Verify installation
                if command -v paru &>/dev/null; then
                    echo ""
                    echo -e "${GREEN}Paru installed successfully!${NC}"
                    echo ""
                    echo -e "${WHITE}Press Enter to continue to Nordix Arch Helper...${NC}"
                    read
                else
                    echo ""
                    echo -e "${RED}Paru installation failed!${NC}"
                    echo -e "${WHITE}Please install paru manually and try again.${NC}"
                    echo ""
                    echo -e "${WHITE}Manual installation:${NC}"
                    echo -e "${NARTIC}  git clone https://aur.archlinux.org/paru-bin.git${NC}"
                    echo -e "${NARTIC}  cd paru-bin${NC}"
                    echo -e "${NARTIC}  makepkg -si${NC}"
                    echo ""
                    exit 1
                fi
                ;;
            *)
                echo ""
                echo -e "${RED}Paru is required for Nordix Arch Helper.${NC}"
                echo -e "${WHITE}Exiting...${NC}"
                echo ""
                exit 1
                ;;
        esac
    fi
}

# Run startup check before anything else
startup_check

# ============================================
# HELPER FUNCTIONS
# ============================================

# Check if paru is installed
check_paru() {
    if command -v paru &>/dev/null; then
        return 0
    else
        return 1
    fi
}

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
back_action() {
    local message="$1"
    echo ""
    echo -e "${NARTIC}$message${NC}"
    echo -ne "${WHITE}Press enter to go back to the menu${NC}"
    read -r confirm
    case "$confirm" in

        *)
            echo -e "${RED}Cancelled.${NC}"
            return 1
            ;;
    esac
}
# Open URL in default browser
open_url() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" 2>/dev/null &
    elif command -v firefox &>/dev/null; then
        firefox "$url" 2>/dev/null &
    else
        echo -e "${WHITE}Please open this URL manually: ${NARTIC}$url${NC}"
    fi
}

# Main menu display
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
    draw_box "         Nordix Arch Helper         "
    echo ""
    echo ""

    draw_border
    echo -e "${WHITE}What would you like to do?${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Update system${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}System maintenance${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}System repair${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}system service${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Install a packages${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Search for package${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Remove/uninstall a package${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}List files in a package${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Show detailed package info${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Show installed packages${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Search installed packages${NC}"
    echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Show pacman history${NC}"
    echo -e "${BLUE}13${NC} ${NVFROST}-${NC} ${NARTIC}Learn Commands ${NGLACIER}- ${NHYPRBLUE}(Educational)${NC}"
    echo -e "${BLUE}14${NC} ${NVFROST}-${NC} ${NARTIC}System Information ${NGLACIER}- ${NHYPRBLUE}(Analyzer)${NC}"
    echo -e "${BLUE}15${NC} ${NVFROST}-${NC} ${NARTIC}Boot Optimization ${NGLACIER}- ${NHYPRBLUE}(Performance)${NC}"
    echo -e "${BLUE}16${NC} ${NVFROST}-${NC} ${NARTIC}AUR Security Check ${NGLACIER}- ${NHYPRBLUE}(Security)${NC}"
    echo -e "${BLUE}17${NC} ${NVFROST}-${NC} ${NARTIC}Network Diagnostics${NC}"
    echo -e "${BLUE}18${NC} ${NVFROST}-${NC} ${NARTIC}About Nordix${NC}"
    echo ""
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-18):${NC}"
    echo ""
}

# Wait for user input
press_enter() {
    echo ""
    echo -ne "${NHYPRBLUE}Press Enter to continue...${NC}"
    read
}

# Install package - with Arch/AUR selection
install_package() {
    clear
    echo ""
    draw_box "          INSTALL PACKAGE           "
    echo ""
    draw_border
    echo -e "${WHITE}Select package source:${NC}"
    echo ""
echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}CachyOS – Arch Linux Official Repositories ${NHYPRBLUE}(CPU-Optimized Build Flags & Kernels)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}AUR (Arch User Repository)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Security check AUR package${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read source_option

    case $source_option in
        1)
            # Arch official repos
            clear
            echo ""
            draw_box "     INSTALL - ARCH REPOSITORY      "
            echo ""
    draw_border
            echo -e "${WHITE}Enter package name(s) to install${NC}"
            echo -e "${WHITE}(space-separated for multiple):${NC}"
    draw_border
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read package_names
            
            if [ -z "$package_names" ]; then
                echo -e "${RED}No package name entered!${NC}"
                press_enter
                return
            fi
            
            echo ""
            echo -e "${BLUE}Installing from Arch repos: ${NARTIC}$package_names${NC}"
            sudo pacman -S --needed $package_names
            ;;
        2)
            # AUR packages
            if ! check_paru; then
                echo -e "${RED}Paru is not installed! Cannot install AUR packages.${NC}"
                press_enter
                return
            fi
        
            clear
            echo ""
            draw_box "          INSTALL - AUR             "
            echo ""
    draw_border
            echo -e "${WHITE}Enter AUR package name(s) to install${NC}"
            echo -e "${WHITE}(space-separated for multiple):${NC}"
    draw_border
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read package_names
            
            if [ -z "$package_names" ]; then
                echo -e "${RED}No package name entered!${NC}"
                press_enter
                return
            fi
            
            echo ""
            echo -e "${BLUE}Installing from AUR: ${NARTIC}$package_names${NC}"
            paru -S $package_names
            ;;
        3)  
            aur_security_check
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Search packages - with Arch/AUR and Terminal/Web selection
search_packages() {
    clear
    echo ""
    draw_box "          SEARCH PACKAGES           "
    echo ""
    draw_border
    echo -e "${WHITE}Select package source to search:${NC}"
    echo ""
echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}CachyOS – Arch Linux Official Repositories ${NHYPRBLUE}(CPU-Optimized Build Flags & Kernels)${NC}"

    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}AUR ${NHYPRBLUE}(Arch User Repository)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read source_option

    case $source_option in
        1)
            # Arch search submenu
            search_arch_packages
            ;;
        2)
            # AUR search submenu
            search_aur_packages
            ;;
        3)  
            aur_security_check
           ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            press_enter
            ;;
    esac
}

# Search Arch packages submenu
search_arch_packages() {
    clear
    echo ""
    draw_box "      SEARCH - ARCH REPOSITORY      "
    echo ""
    draw_border
    echo -e "${WHITE}Select search method:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Search in terminal ${NHYPRBLUE}(pacman -Ss)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Search on archlinux.org${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read method_option

    echo ""
    draw_border
    echo -e "${WHITE}Enter search term:${NC}"
    draw_border
    echo ""
    echo -ne "${NGLACIER}❯ ${NC}"
    read search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}No search term entered!${NC}"
        press_enter
        return
    fi

    case $method_option in
        1)
            echo ""
            echo -e "${BLUE}Searching Arch repos for: ${NARTIC}$search_term${NC}"
            echo ""
            pacman -Ss "$search_term"
            press_enter
            ;;
        2)
            echo ""
            echo -e "${BLUE}Opening archlinux.org packages search...${NC}"
            local url="https://archlinux.org/packages/?q=${search_term}"
            open_url "$url"
            echo -e "${BLUE}URL: ${NARTIC}$url${NC}"
            press_enter
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            press_enter
            ;;
    esac
}

# Search AUR packages submenu
search_aur_packages() {
    clear
    echo ""
    draw_box "          SEARCH - AUR              "
    echo ""
    draw_border
    echo -e "${WHITE}Select search method:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Search in terminal ${NHYPRBLUE}(paru -Ss)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Search on aur.archlinux.org${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-2):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read method_option

    echo ""
    draw_border
    echo -e "${WHITE}Enter search term:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}No search term entered!${NC}"
        press_enter
        return
    fi

    case $method_option in
        1)
            if ! check_paru; then
                echo -e "${RED}Paru is not installed! Cannot search AUR.${NC}"
                press_enter
                return
            fi
            echo ""
            echo -e "${WHITE}Searching AUR for: ${NARTIC}$search_term${NC}"
            echo ""
            paru -Ss "$search_term" --aur
            press_enter
            ;;
        2)
            echo ""
            echo -e "${WHITE}Opening AUR search...${NC}"
            local url="https://aur.archlinux.org/packages?O=0&K=${search_term}"
            open_url "$url"
            echo -e "${WHITE}URL: ${NARTIC}$url${NC}"
            press_enter         
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            press_enter
            ;;
    esac
}

# Show package info
package_info() {
    clear
    echo ""
    draw_box "        PACKAGE INFORMATION         "
    echo ""
    draw_border
    echo -e "${WHITE}Enter package name:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read package_name
    
    if [ -z "$package_name" ]; then
        echo -e "${RED}No package name entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Information for: ${NARTIC}$package_name${NC}"
    echo ""
    pacman -Si "$package_name" 2>/dev/null || echo -e "${RED}Package not found in repositories${NC}"
    press_enter
}

# Remove package
remove_package() {
    clear
    echo ""
    draw_box "           REMOVE PACKAGE           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter package name(s) to remove${NC}"
    echo -e "${WHITE}(space-separated for multiple):${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read package_names
    
    if [ -z "$package_names" ]; then
        echo -e "${RED}No package name entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${RED}Warning: This will remove: $package_names${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}Remove options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Remove only${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Remove with dependencies${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Remove with dependencies AND config files${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read remove_option
    
    case $remove_option in
        1)
            sudo pacman -R $package_names
            ;;
        2)
            sudo pacman -Rs $package_names
            ;;
        3)
            sudo pacman -Rns $package_names
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Update system - with flatpak support
update_system() {
    clear
    echo ""
    draw_box "           UPDATE SYSTEM            "
    echo ""
    draw_border
    echo -e "${WHITE}Update options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Synchronize and refresh package database ${NHYPRBLUE}(no update)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}System update ${NHYPRBLUE}(pacman + AUR + flatpak)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Full system update with force sync ${GREEN}(recommended)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read update_option
    
    case $update_option in
        1)
            echo ""
            echo -e "${WHITE}Synchronizing package databases...${NC}"
            sudo pacman -Syy
            ;;
        2)
            echo ""
            echo -e "${WHITE}Updating system (pacman + AUR)...${NC}"
            if check_paru; then
                paru -Syu
            else
                echo -e "${NARTIC}Paru not found, using pacman only${NC}"
                sudo pacman -Syu
            fi
            # Update flatpak if installed
            if check_flatpak; then
                echo ""
                echo -e "${WHITE}Updating Flatpak packages...${NC}"
                flatpak update -y
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Full system update with force sync...${NC}"
            if check_paru; then
                paru -Syyu
            else
                echo -e "${NARTIC}Paru not found, using pacman only${NC}"
                sudo pacman -Syyu
            fi
            # Update flatpak if installed
            if check_flatpak; then
                echo ""
                echo -e "${WHITE}Updating Flatpak packages...${NC}"
                flatpak update -y
            fi
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            press_enter
            return
            ;;
    esac
    press_enter
}

# System services management
system_service() {
    clear
    echo ""
    draw_box "    SYSTEM SERVICES (systemctl)     "
    echo ""
    draw_border
    echo -e "${WHITE}Systemctl options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}List all services${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}List running services${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Start a service${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Stop a service${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Enable a service${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Disable a service${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Check service status${NC}"
    echo -e "${BLUE}8${NC} ${NVFROST}-${NC} ${NARTIC}Restart a service${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (0-18):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read service_option
    
    case $service_option in
        1)
            systemctl list-unit-files --type=service
            ;;
        2)
            systemctl list-units --type=service --state=running
            ;;
        3)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            sudo systemctl start "$service_name"
            echo -e "${GREEN}Service $service_name started${NC}"
            ;;
        4)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            sudo systemctl stop "$service_name"
            echo -e "${NARTIC}Service $service_name stopped${NC}"
            ;;
        5)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            sudo systemctl enable "$service_name"
            echo -e "${GREEN}Service $service_name enabled${NC}"
            ;;
        6)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            sudo systemctl disable "$service_name"
            echo -e "${NARTIC}Service $service_name disabled${NC}"
            ;;
        7)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            systemctl status "$service_name"
            ;;
        8)
            echo -ne "${WHITE}Enter service name: ${NC}"
            read service_name
            sudo systemctl restart "$service_name"
            echo -e "${GREEN}Service $service_name restarted${NC}"
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Show installed packages
show_installed() {
    clear
    echo ""
    draw_box "        INSTALLED PACKAGES          "
    echo ""
    draw_border
    echo -e "${WHITE}Display options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Show all installed packages${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Show explicitly installed packages${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Show orphan packages ${NHYPRBLUE}(no longer needed)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Show AUR/foreign packages${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read installed_option
    
    case $installed_option in
        1)
            pacman -Q
            ;;
        2)
            pacman -Qe
            ;;
        3)
            pacman -Qtdq || echo -e "${GREEN}No orphan packages found!${NC}"
            ;;
        4)
            pacman -Qm
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Search installed packages
search_installed() {
    clear
    echo ""
    draw_box "      SEARCH INSTALLED PACKAGES     "
    echo ""
    draw_border
    echo -e "${WHITE}Enter search term:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}No search term entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Searching installed packages for: ${NARTIC}$search_term${NC}"
    echo ""
    pacman -Qs "$search_term"
    press_enter
}

# List package files
list_package_files() {
    clear
    echo ""
    draw_box "         PACKAGE FILE LIST          "
    echo ""
    draw_border
    echo -e "${WHITE}Enter package name:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read package_name
    
    if [ -z "$package_name" ]; then
        echo -e "${RED}No package name entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Files in package: ${NARTIC}$package_name${NC}"
    echo ""
    pacman -Ql "$package_name" 2>/dev/null || echo -e "${RED}Package not found or not installed${NC}"
    press_enter
}

# Show pacman history
show_history() {
    clear
    echo ""
    draw_box "          PACMAN HISTORY            "
    echo ""
    draw_border
    echo -e "${WHITE}History options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Last 10 transactions${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}All transactions${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Search in history${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read history_option
    
    case $history_option in
        1)
            echo ""
            echo -e "${WHITE}Last 10 transactions:${NC}"
            echo ""
            grep -A2 -B2 "\[PACMAN\]" /var/log/pacman.log | tail -30
            ;;
        2)
            grep -A2 -B2 "\[PACMAN\]" /var/log/pacman.log
            ;;
        3)
            echo -ne "${WHITE}Enter search term: ${NC}"
            read history_search
            echo ""
            echo -e "${WHITE}Results for: ${NARTIC}$history_search${NC}"
            echo ""
            grep -i "$history_search" /var/log/pacman.log | tail -20
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# System maintenance
system_maintenance() {
    clear
    echo ""
    draw_box "        SYSTEM MAINTENANCE          "
    echo ""
    draw_border
    echo -e "${WHITE}Maintenance options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Rate mirrors for faster package installs${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Clear the package cache and synchronize databases${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Remove unused packages (orphans)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Check for broken symlinks${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Check for .pacnew/.pacsave files${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read maintenance_option
    
    case $maintenance_option in
        1)
            echo ""
            echo -e "${WHITE}Rating mirrors for faster package installs...${NC}"
            if confirm_action "Rate mirrors using cachyos-rate-mirrors?"; then
                sudo cachyos-rate-mirrors
            fi
            ;;
        2)
            echo -e "${WHITE}Clear the package cache and synchronize databases${NC}"
            if confirm_action "Clear package cache?"; then
                sudo pacman -Scc
                sudo pacman -Sy
            fi
            ;;
        3)
            echo -e "${WHITE}Checking for unused packages (orphans)...${NC}"
            ignore="smile,spotify-launcher,qalculate-gtk,upscayl-appimage,wlogout,zfsbootmenu,swengine,qbittorrent,pavucontrol,paru,plymouth,pacman-contrib,noto-color-emoji-fontconfig,man-pages,linuxconsole,lact,gnome-themes-extra,hyprpolkitagent,gpu-screen-recorder-gtk,grimblast-git,cpupower,cachyos-kernel-manager,adwaita-color-schemes,adwaita-qt-git,adwaita-qt6,alacritty,ashell,blueman,bluez-hid2hci,bluez-tools,bluez-utils"
            orphans=$(pacman -Qdtq 2>/dev/null)
            if [ -z "$orphans" ]; then
                echo -e "${GREEN}No orphan packages found!${NC}"
            else
                echo -e "${NARTIC}Found orphan packages:${NC}"
                echo "$orphans"
                if confirm_action "${NHYPRNBLUE}Remove these orphan packages?${NC}"; then
                    sudo pacman -Rns --ignore "$ignore" $orphans
                fi
            fi
            ;;
        4)
            manage_broken_symlinks
            ;;
        5)
            manage_pacnew_files
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Comprehensive broken symlinks manager
manage_broken_symlinks() {
    clear
    echo ""
    draw_box "     BROKEN SYMLINKS MANAGER        "
    echo ""
    
    echo -e "${WHITE}Scanning for broken symlinks...${NC}"
    echo -e "${WHITE}(This may take a moment)${NC}"
    echo ""
    
    # Scan common system directories
    broken_links=$(find /usr /etc /opt 2>/dev/null -xtype l 2>/dev/null)
    
    if [ -z "$broken_links" ]; then
        echo -e "${GREEN}OK No broken symlinks found!${NC}"
        echo -e "${WHITE}Your system is clean.${NC}"
        return
    fi
    
    # Count and categorize
    total_count=$(echo "$broken_links" | grep -c "." 2>/dev/null || echo "0")
    
    # Categorize the broken links
    lib_links=$(echo "$broken_links" | grep -E "\.so|/lib/|/lib32/|/lib64/" 2>/dev/null || true)
    icon_links=$(echo "$broken_links" | grep -E "/icons/|\.png$|\.svg$|\.xpm$" 2>/dev/null || true)
    license_links=$(echo "$broken_links" | grep -E "/licenses/" 2>/dev/null || true)
    doc_links=$(echo "$broken_links" | grep -E "/doc/|/man/|/share/doc/" 2>/dev/null || true)
    other_links=$(echo "$broken_links" | grep -vE "\.so|/lib/|/lib32/|/lib64/|/icons/|\.png$|\.svg$|\.xpm$|/licenses/|/doc/|/man/|/share/doc/" 2>/dev/null || true)
    
    lib_count=$(echo "$lib_links" | grep -c "." 2>/dev/null || echo "0")
    icon_count=$(echo "$icon_links" | grep -c "." 2>/dev/null || echo "0")
    license_count=$(echo "$license_links" | grep -c "." 2>/dev/null || echo "0")
    doc_count=$(echo "$doc_links" | grep -c "." 2>/dev/null || echo "0")
    other_count=$(echo "$other_links" | grep -c "." 2>/dev/null || echo "0")
    
    # Handle empty counts
    [ -z "$lib_links" ] && lib_count=0
    [ -z "$icon_links" ] && icon_count=0
    [ -z "$license_links" ] && license_count=0
    [ -z "$doc_links" ] && doc_count=0
    [ -z "$other_links" ] && other_count=0
    
    # Display summary
    draw_border
    echo ""
    echo -e "${WHITE}SCAN RESULTS: ${NARTIC}$total_count broken symlinks found${NC}"
    draw_border
    echo ""
    
    # Show by category with risk level
    if [ "$lib_count" -gt 0 ]; then
        echo -e "${RED}! Libraries (.so files): $lib_count ${NC}${RED}[HIGH RISK]${NC}"
    fi
    if [ "$icon_count" -gt 0 ]; then
        echo -e "${NARTIC}* Icons/Images: $icon_count ${NC}${GREEN}[LOW RISK]${NC}"
    fi
    if [ "$license_count" -gt 0 ]; then
        echo -e "${NARTIC}* Licenses: $license_count ${NC}${GREEN}[LOW RISK]${NC}"
    fi
    if [ "$doc_count" -gt 0 ]; then
        echo -e "${NARTIC}* Documentation: $doc_count ${NC}${GREEN}[LOW RISK]${NC}"
    fi
    if [ "$other_count" -gt 0 ]; then
        echo -e "${NARTIC}* Other: $other_count ${NC}${NARTIC}[MEDIUM RISK]${NC}"
    fi
    
    echo ""
    draw_border
    echo ""

    # Explain risk levels
    echo -e "${WHITE}Risk levels explained:${NC}"
    echo -e "${RED}HIGH${NC}   ${WHITE}= May cause programs to crash or not start${NC}"
    echo -e "${NARTIC}MEDIUM${NC} ${WHITE}= May cause minor issues${NC}"
    echo -e "${GREEN}LOW${NC}    ${WHITE}= Cosmetic only, safe to ignore${NC}"
    echo ""
    
    draw_border
    echo -e "${WHITE}What would you like to do?${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}View all broken symlinks${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}View only HIGH RISK ${NHYPRBLUE}(libraries)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Find which packages own broken links${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Try to repair ${NHYPRBLUE}(reinstall affected packages)${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Delete LOW RISK broken symlinks${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Learn more about broken symlinks${NC}"
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Go back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (0-6):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read symlink_option
    
    case $symlink_option in
        1)
            view_all_broken_symlinks "$broken_links"
            ;;
        2)
            view_high_risk_symlinks "$lib_links"
            ;;
        3)
            find_symlink_owners "$broken_links"
            ;;
        4)
            repair_broken_symlinks "$broken_links"
            ;;
        5)
            delete_low_risk_symlinks "$icon_links" "$license_links" "$doc_links"
            ;;
        6)
            learn_about_symlinks
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# View all broken symlinks
view_all_broken_symlinks() {
    local links="$1"
    clear
    echo ""
    draw_box "      ALL BROKEN SYMLINKS           "
    echo ""
    
    echo -e "${WHITE}Broken symlinks found:${NC}"
    echo ""
    
    echo "$links" | while read -r link; do
        if [ -n "$link" ]; then
            # Get what the symlink points to
            target=$(readlink "$link" 2>/dev/null)
            
            # Categorize with color
            if echo "$link" | grep -qE "\.so|/lib/|/lib32/|/lib64/"; then
                echo -e "${RED}[LIB]${NC} ${WHITE}$link${NC}"
                echo -e "      ${NARTIC}- points to: $target ${NHYPRBLUE}(missing)${NC}"
            elif echo "$link" | grep -qE "/icons/|\.png$|\.svg$|\.xpm$"; then
                echo -e "${GREEN}[ICON]${NC} ${WHITE}$link${NC}"
            elif echo "$link" | grep -qE "/licenses/"; then
                echo -e "${GREEN}[LIC]${NC} ${WHITE}$link${NC}"
            elif echo "$link" | grep -qE "/doc/|/man/"; then
                echo -e "${GREEN}[DOC]${NC} ${WHITE}$link${NC}"
            else
                echo -e "${NARTIC}[OTHER]${NC} ${WHITE}$link${NC}"
            fi
        fi
    done | head -100
    
    total=$(echo "$links" | wc -l)
    if [ "$total" -gt 100 ]; then
        echo ""
        echo -e "${NARTIC}(Showing first 100 of $total results)${NC}"
    fi
}

# View only high risk symlinks (libraries)
view_high_risk_symlinks() {
    local lib_links="$1"
    clear
    echo ""
    draw_box "    HIGH RISK - BROKEN LIBRARIES    "
    echo ""
    
    if [ -z "$lib_links" ]; then
        echo -e "${GREEN} No broken library symlinks found!${NC}"
        return
    fi
    
    echo -e "${RED} These broken links may cause programs to fail:${NC}"
    echo ""
    
    echo "$lib_links" | while read -r link; do
        if [ -n "$link" ]; then
            target=$(readlink "$link" 2>/dev/null)
            owner=$(pacman -Qo "$link" 2>/dev/null | awk '{print $5}' || echo "unknown")
            
            echo -e "${RED}x${NC} ${WHITE}$link${NC}"
            echo -e "  ${NARTIC}- Target: $target${NC}"
            echo -e "  ${BLUE}- Package: $owner${NC}"
            echo ""
        fi
    done
    
    echo -e "${WHITE}To fix these, try reinstalling the owning packages.${NC}"
}

# Find which packages own the broken symlinks
find_symlink_owners() {
    local links="$1"
    clear
    echo ""
    draw_box "    PACKAGES WITH BROKEN LINKS      "
    echo ""
    
    echo -e "${WHITE}Finding package owners...${NC}"
    echo -e "${WHITE}(This may take a moment)${NC}"
    echo ""
    
    # Create associative array to track packages
    declare -A package_links
    
    echo "$links" | while read -r link; do
        if [ -n "$link" ]; then
            owner=$(pacman -Qo "$link" 2>/dev/null | awk '{print $5}')
            if [ -n "$owner" ]; then
                echo -e "${NHYPRBLUE}$owner${NC} ${WHITE}-${NC} $link"
            else
                echo -e "${NARTIC}(no owner)${NC} ${WHITE}-${NC} $link"
            fi
        fi
    done | sort | head -50
    
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}Packages with broken links can be reinstalled with:${NC}"
    echo -e "${NARTIC}sudo pacman -S --needed package_name${NC}"
    echo ""
    echo -e "${WHITE}Or use option 4 to attempt automatic repair.${NC}"
}

# Attempt to repair broken symlinks by reinstalling packages
repair_broken_symlinks() {
    local links="$1"
    clear
    echo ""
    draw_box "     REPAIR BROKEN SYMLINKS         "
    echo ""
    
    echo -e "${WHITE}Analyzing broken symlinks to find affected packages...${NC}"
    echo ""
    
    # Find unique packages that own broken symlinks
    packages=""
    while read -r link; do
        if [ -n "$link" ]; then
            owner=$(pacman -Qo "$link" 2>/dev/null | awk '{print $5}')
            if [ -n "$owner" ] && [ "$owner" != "No" ]; then
                packages="$packages $owner"
            fi
        fi
    done <<< "$links"
    
    # Remove duplicates
    unique_packages=$(echo "$packages" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    if [ -z "$unique_packages" ]; then
        echo -e "${WHITE}No packages found that own these broken symlinks.${NC}"
        echo -e "${WHITE}These may be leftover from manually removed software.${NC}"
        echo ""
        echo -e "${WHITE}You can safely delete them with option 5,${NC}"
        echo -e "${WHITE}or manually with: ${NHYPRBLUE}sudo rm /path/to/broken/link${NC}"
        return
    fi
    
    package_count=$(echo "$unique_packages" | wc -w)
    
    echo -e "${WHITE}Found ${NHYPRBLUE}$package_count${NC}${WHITE} package(s) with broken symlinks:${NC}"
    echo ""
    
    for pkg in $unique_packages; do
        echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$pkg${NC}"
    done
    
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}Reinstalling these packages may fix the broken links.${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}Repair options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Reinstall ALL affected packages${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Reinstall only HIGH RISK ${NHYPRBLUE}(library)${NARTIC} packages${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Choose specific packages to reinstall${NC}"
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Go back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (0-3):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read repair_option
    
    case $repair_option in
        1)
            echo ""
            if confirm_action "Reinstall all $package_count packages?"; then
                echo ""
                echo -e "${WHITE}Reinstalling packages (including AUR)...${NC}"
                paru -S --noconfirm $unique_packages
                echo ""
                echo -e "${GREEN}Reinstallation complete!${NC}"
                echo -e "${WHITE}Run this check again to verify repairs.${NC}"
            fi
            ;;
        2)
            # Find packages that own library symlinks
            lib_packages=""
            while read -r link; do
                if [ -n "$link" ] && echo "$link" | grep -qE "\.so|/lib/|/lib32/|/lib64/"; then
                    owner=$(pacman -Qo "$link" 2>/dev/null | awk '{print $5}')
                    if [ -n "$owner" ] && [ "$owner" != "No" ]; then
                        lib_packages="$lib_packages $owner"
                    fi
                fi
            done <<< "$links"
            
            lib_packages=$(echo "$lib_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ')
            
            if [ -z "$lib_packages" ]; then
                echo -e "${GREEN}No library packages need repair!${NC}"
            else
                lib_count=$(echo "$lib_packages" | wc -w)
                echo ""
                echo -e "${WHITE}Library packages to reinstall:${NC}"
                for pkg in $lib_packages; do
                    echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$pkg${NC}"
                done
                echo ""
                if confirm_action "Reinstall these $lib_count library packages?"; then
                    paru -S --noconfirm $lib_packages
                    echo ""
                    echo -e "${GREEN} Library packages reinstalled!${NC}"
                fi
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Enter package names to reinstall (space-separated):${NC}"
            echo -e "${WHITE}Available: ${NARTIC}$unique_packages${NC}"
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read selected_packages
            
            if [ -n "$selected_packages" ]; then
                if confirm_action "Reinstall: $selected_packages?"; then
                    paru -S --noconfirm $selected_packages
                    echo ""
                    echo -e "${GREEN}OK Selected packages reinstalled!${NC}"
                fi
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Delete low risk broken symlinks (icons, licenses, docs)
delete_low_risk_symlinks() {
    local icon_links="$1"
    local license_links="$2"
    local doc_links="$3"
    
    clear
    echo ""
    draw_box "    DELETE LOW RISK SYMLINKS        "
    echo ""
    
    # Combine all low risk links
    low_risk_links=$(echo -e "$icon_links\n$license_links\n$doc_links" | grep -v "^$")
    
    if [ -z "$low_risk_links" ]; then
        echo -e "${GREEN} No low risk broken symlinks found!${NC}"
        return
    fi
    
    low_risk_count=$(echo "$low_risk_links" | grep -c "." 2>/dev/null || echo "0")
    
    echo -e "${WHITE}Found ${NARTIC}$low_risk_count${NC}${WHITE} low risk broken symlinks:${NC}"
    echo ""
    echo -e "${WHITE}Categories:${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Icons and images${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}License files${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Documentation${NC}"
    echo ""
    
    echo -e "${WHITE}These are safe to delete - they only affect:${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Missing icons in menus${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}license references${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}documentation links${NC}"
    echo ""
    
    draw_border
    echo -e "${WHITE}Delete options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}View all low risk symlinks first${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Delete ALL low risk symlinks${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Delete only icon symlinks${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Delete only license symlinks${NC}"
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Go back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (0-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read delete_option
    
    case $delete_option in
        1)
            echo ""
            echo -e "${WHITE}Low risk broken symlinks:${NC}"
            echo ""
            echo "$low_risk_links" | while read -r link; do
                if [ -n "$link" ]; then
                    echo -e "  ${GREEN}*${NC} ${WHITE}$link${NC}"
                fi
            done | head -50
            ;;
        2)
            echo ""
            if confirm_action "Delete all $low_risk_count low risk broken symlinks?"; then
                deleted=0
                echo "$low_risk_links" | while read -r link; do
                    if [ -n "$link" ] && [ -L "$link" ]; then
                        sudo rm "$link" 2>/dev/null && echo -e "${GREEN}OK${NC} ${WHITE}Deleted: $link${NC}"
                    fi
                done
                echo ""
                echo -e "${GREEN}OK Low risk symlinks deleted!${NC}"
            fi
            ;;
        3)
            if [ -z "$icon_links" ]; then
                echo -e "${GREEN}No broken icon symlinks found.${NC}"
            else
                icon_count=$(echo "$icon_links" | grep -c "." 2>/dev/null || echo "0")
                if confirm_action "Delete $icon_count broken icon symlinks?"; then
                    echo "$icon_links" | while read -r link; do
                        if [ -n "$link" ] && [ -L "$link" ]; then
                            sudo rm "$link" 2>/dev/null && echo -e "${GREEN}OK${NC} ${WHITE}Deleted: $link${NC}"
                        fi
                    done
                    echo ""
                    echo -e "${GREEN} Icon symlinks deleted!${NC}"
                fi
            fi
            ;;
        4)
            if [ -z "$license_links" ]; then
                echo -e "${GREEN}No broken license symlinks found.${NC}"
            else
                lic_count=$(echo "$license_links" | grep -c "." 2>/dev/null || echo "0")
                if confirm_action "Delete $lic_count broken license symlinks?"; then
                    echo "$license_links" | while read -r link; do
                        if [ -n "$link" ] && [ -L "$link" ]; then
                            sudo rm "$link" 2>/dev/null && echo -e "${GREEN}OK${NC} ${WHITE}Deleted: $link${NC}"
                        fi
                    done
                    echo ""
                    echo -e "${GREEN} License symlinks deleted!${NC}"
                fi
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Learn about broken symlinks
learn_about_symlinks() {
    clear
    echo ""
    draw_box "    UNDERSTANDING BROKEN SYMLINKS   "
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS A SYMLINK?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}A symbolic link (symlink) is like a shortcut that${NC}"
    echo -e "${WHITE}points to another file or directory.${NC}"
    echo ""
    echo -e "${NARTIC}Example:${NC}"
    echo -e "${WHITE}  /usr/lib/libfoo.so --> /usr/lib/libfoo.so.1.2.3${NC}"
    echo -e "${WHITE}  (shortcut)            (actual file)${NC}"
    echo ""
    echo ""  
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS A BROKEN SYMLINK?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}A broken symlink points to a file that no longer exists.${NC}"
    echo ""
    echo -e "${NARTIC}Example:${NC}"
    echo -e "${WHITE}  /usr/lib/libfoo.so --> /usr/lib/libfoo.so.1.2.3${NC}"
    echo -e "${WHITE}  (shortcut)            ${RED}(FILE MISSING!)${NC}"
    echo ""
    echo ""  
    echo ""
    draw_border
    echo -e "${WHITE}WHY DO BROKEN SYMLINKS HAPPEN?${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Package was partially removed${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Failed or interrupted update${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Manual deletion of files${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Package conflicts during updates${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}AUR packages with bugs${NC}"
    echo ""
    echo ""  
    echo ""
    draw_border
    echo -e "${WHITE}RISK LEVELS EXPLAINED:${NC}"
    draw_border
    echo ""
    echo -e "${RED}HIGH RISK - Libraries (.so files)${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Programs may crash or refuse to start${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Example: Firefox won't open, games crash${NC}"
    echo ""
    echo -e "${NARTIC}MEDIUM RISK - Config files, binaries${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Features may not work correctly${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Example: Missing themes, broken scripts${NC}"
    echo ""
    echo -e "${GREEN}LOW RISK - Icons, licenses, docs${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Cosmetic issues only${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Example: Missing menu icon${NC}"
    echo ""
    echo ""  
    echo ""
    draw_border
    echo -e "${WHITE}HOW TO FIX BROKEN SYMLINKS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}1. Find the owner package:${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}pacman -Qo /path/to/broken/link${NC}"
    echo ""
    echo -e "${NARTIC}2. Reinstall the package:${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}sudo pacman -S package_name${NC}"
    echo ""
    echo -e "${NARTIC}3. Or delete if unneeded:${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}sudo rm /path/to/broken/link${NC}"
    echo ""
    echo -e "${BLUE}TIP: Use option 4 in this tool for automatic repair!${NC}"
}

# Comprehensive .pacnew and .pacsave file manager
manage_pacnew_files() {
    clear
    echo ""
    draw_box "    PACNEW / PACSAVE FILE MANAGER   "
    echo ""
    
    # Find all .pacnew and .pacsave files
    echo -e "${WHITE}Scanning for .pacnew and .pacsave files...${NC}"
    echo ""
    
    pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null)
    pacsave_files=$(find /etc -name "*.pacsave" 2>/dev/null)
    
    pacnew_count=$(echo "$pacnew_files" | grep -c "." 2>/dev/null || echo "0")
    pacsave_count=$(echo "$pacsave_files" | grep -c "." 2>/dev/null || echo "0")
    
    # Handle empty results
    if [ -z "$pacnew_files" ]; then
        pacnew_count=0
    fi
    if [ -z "$pacsave_files" ]; then
        pacsave_count=0
    fi
    
    # Display summary
    draw_border
    echo ""
    echo -e "${WHITE}SCAN RESULTS:${NC}"
    draw_border
    echo ""
    
    if [ "$pacnew_count" -eq 0 ] && [ "$pacsave_count" -eq 0 ]; then
        echo -e "${GREEN}No .pacnew or .pacsave files found!${NC}"
        echo -e "${WHITE}Your configuration files are all up to date.${NC}"
        return
    fi
    
    # Show .pacnew files
    if [ "$pacnew_count" -gt 0 ]; then
        echo -e "${NARTIC}Found $pacnew_count .pacnew file(s):${NC}"
        echo -e "${WHITE}(New config versions from package updates)${NC}"
        echo ""
        echo "$pacnew_files" | while read -r file; do
            if [ -n "$file" ]; then
                original="${file%.pacnew}"
                echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$file${NC}"
            fi
        done
        echo ""
    fi
    
    # Show .pacsave files
    if [ "$pacsave_count" -gt 0 ]; then
        echo -e "${NARTIC}Found $pacsave_count .pacsave file(s):${NC}"
        echo -e "${WHITE}(Saved configs from removed packages)${NC}"
        echo ""
        echo "$pacsave_files" | while read -r file; do
            if [ -n "$file" ]; then
                echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$file${NC}"
            fi
        done
        echo ""
    fi
    draw_border
    echo ""    
    
    # Show explanation
    echo -e "${BLUE}What are these files?${NC}"
    echo -e "${WHITE}.pacnew  = New config from update (your version was kept)${NC}"
    echo -e "${WHITE}.pacsave = Your config backup (package was removed)${NC}"
    echo ""
    
    draw_border
    echo -e "${WHITE}What would you like to do?${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}View differences for a specific file${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Use pacdiff (interactive merge tool)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Keep original, delete .pacnew${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Use new version, replace original${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Delete all .pacsave files${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Learn more about handling these files${NC}"
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Go back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (0-6):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read pacnew_option
    
    case $pacnew_option in
        1)
            # View diff for specific file
            view_pacnew_diff
            ;;
        2)
            # Use pacdiff
            use_pacdiff
            ;;
        3)
            # Keep original, delete .pacnew
            keep_original_config
            ;;
        4)
            # Use new version
            use_new_config
            ;;
        5)
            # Delete all .pacsave
            delete_pacsave_files
            ;;
        6)
            # Learn more
            learn_pacnew_handling
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# View diff between original and .pacnew
view_pacnew_diff() {
    echo ""
    echo -e "${WHITE}Available .pacnew files:${NC}"
    echo ""
    
    pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null)
    
    if [ -z "$pacnew_files" ]; then
        echo -e "${NARTIC}No .pacnew files found.${NC}"
        return
    fi
    
    # Number the files
    i=1
    echo "$pacnew_files" | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "  ${NHYPRBLUE}$i${NC} ${NVFROST}-${NC} ${WHITE}$file${NC}"
            i=$((i+1))
        fi
    done
    
    echo ""
    echo -e "${WHITE}Enter the full path of the .pacnew file to compare:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read selected_file
    
    if [ -z "$selected_file" ]; then
        echo -e "${RED}No file selected!${NC}"
        return
    fi
    
    if [ ! -f "$selected_file" ]; then
        echo -e "${RED}File not found: $selected_file${NC}"
        return
    fi
    
    original="${selected_file%.pacnew}"
    
    if [ ! -f "$original" ]; then
        echo -e "${RED}Original file not found: $original${NC}"
        return
    fi
    
    echo ""
draw_border
    echo -e "${WHITE}Comparing:${NC}"
    echo -e "${NARTIC}  Original: $original${NC}"
    echo -e "${NARTIC}  New:      $selected_file${NC}"
draw_border
    echo ""
    echo -e "${WHITE}Legend: ${RED}- removed${NC} | ${GREEN}+ added${NC}${NC}"
    echo ""
    
    # Check if diff or colordiff is available
    if command -v colordiff &>/dev/null; then
        colordiff "$original" "$selected_file"
    elif command -v diff &>/dev/null; then
        diff --color=auto "$original" "$selected_file"
    else
        echo -e "${RED}diff command not found!${NC}"
        return
    fi
    
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}What would you like to do with this file?${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Keep original ${NHYPRBLUE}(delete .pacnew)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Use new version ${NHYPRBLUE}(replace original)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Edit original manually with nano${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Edit .pacnew manually with nano${NC}"
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Do nothing, go back${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option (0-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read diff_action
    
    case $diff_action in
        1)
            if confirm_action "Delete $selected_file and keep original?"; then
                sudo rm "$selected_file"
                echo -e "${GREEN}OK Deleted $selected_file${NC}"
            fi
            ;;
        2)
            if confirm_action "Replace $original with new version?"; then
                sudo cp "$original" "${original}.backup.$(date +%Y%m%d)"
                sudo mv "$selected_file" "$original"
                echo -e "${GREEN}OK Updated $original (backup created)${NC}"
            fi
            ;;
        3)
            sudo nano "$original"
            echo ""
            if confirm_action "Delete .pacnew file now that you've edited the original?"; then
                sudo rm "$selected_file"
                echo -e "${GREEN}OK Deleted $selected_file${NC}"
            fi
            ;;
        4)
            sudo nano "$selected_file"
            echo ""
            echo -e "${WHITE}Remember to decide what to do with these files when done.${NC}"
            ;;
        0)
            return
            ;;
    esac
}

# Use pacdiff tool
use_pacdiff() {
    echo ""
    
    if ! command -v pacdiff &>/dev/null; then
        echo -e "${NARTIC}pacdiff is not installed.${NC}"
        echo -e "${WHITE}It's part of the pacman-contrib package.${NC}"
        echo ""
        if confirm_action "Install pacman-contrib now?"; then
            sudo pacman -S --needed pacman-contrib
            echo ""
            echo -e "${GREEN} pacman-contrib installed${NC}"
        else
            return
        fi
    fi
    
    echo -e "${WHITE}Starting pacdiff...${NC}"
    echo -e "${BLUE}This will show each .pacnew file and let you choose what to do.${NC}"
    echo ""
    echo -e "${WHITE}Options in pacdiff:${NC}"
    echo -e "${WHITE}  V = View diff${NC}"
    echo -e "${WHITE}  E = Edit merged file${NC}"
    echo -e "${WHITE}  R = Remove .pacnew (keep original)${NC}"
    echo -e "${WHITE}  O = Overwrite with .pacnew${NC}"
    echo -e "${WHITE}  S = Skip${NC}"
    echo ""
    
    if confirm_action "Start pacdiff?"; then
        sudo pacdiff
    fi
}

# Keep original config, delete .pacnew
keep_original_config() {
    echo ""
    echo -e "${WHITE}Available .pacnew files:${NC}"
    echo ""
    
    pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null)
    
    if [ -z "$pacnew_files" ]; then
        echo -e "${NARTIC}No .pacnew files found.${NC}"
        return
    fi
    
    echo "$pacnew_files" | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$file${NC}"
        fi
    done
    
    echo ""
    echo -e "${WHITE}Enter the full path of the .pacnew file to delete:${NC}"
    echo -e "${WHITE}(or type 'all' to delete ALL .pacnew files)${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read selected_file
    
    if [ "$selected_file" = "all" ]; then
        echo ""
        echo -e "${RED}WARNING: This will delete ALL .pacnew files!${NC}"
        echo -e "${WHITE}Your current configs will remain unchanged.${NC}"
        if confirm_action "Delete ALL .pacnew files?"; then
            echo "$pacnew_files" | while read -r file; do
                if [ -n "$file" ]; then
                    sudo rm "$file"
                    echo -e "${GREEN} Deleted $file${NC}"
                fi
            done
        fi
    elif [ -f "$selected_file" ]; then
        if confirm_action "Delete $selected_file?"; then
            sudo rm "$selected_file"
            echo -e "${GREEN} Deleted $selected_file${NC}"
        fi
    else
        echo -e "${RED}File not found: $selected_file${NC}"
    fi
}

# Use new config version
use_new_config() {
    echo ""
    echo -e "${WHITE}Available .pacnew files:${NC}"
    echo ""
    
    pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null)
    
    if [ -z "$pacnew_files" ]; then
        echo -e "${NARTIC}No .pacnew files found.${NC}"
        return
    fi
    
    echo "$pacnew_files" | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$file${NC}"
        fi
    done
    
    echo ""
    echo -e "${WHITE}Enter the full path of the .pacnew file to use:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read selected_file
    
    if [ ! -f "$selected_file" ]; then
        echo -e "${RED}File not found: $selected_file${NC}"
        return
    fi
    
    original="${selected_file%.pacnew}"
    
    echo ""
    echo -e "${NARTIC}WARNING: This will replace your current config!${NC}"
    echo -e "${WHITE}Original: $original${NC}"
    echo -e "${WHITE}New:      $selected_file${NC}"
    
    if confirm_action "Replace original with new version? (backup will be created)"; then
        # Create backup with timestamp
        backup_name="${original}.backup.$(date +%Y%m%d_%H%M%S)"
        sudo cp "$original" "$backup_name"
        echo -e "${GREEN}Backup created: $backup_name${NC}"
        
        # Replace original with .pacnew
        sudo mv "$selected_file" "$original"
        echo -e "${GREEN}Updated $original${NC}"
    fi
}

# Delete all .pacsave files
delete_pacsave_files() {
    echo ""
    
    pacsave_files=$(find /etc -name "*.pacsave" 2>/dev/null)
    
    if [ -z "$pacsave_files" ]; then
        echo -e "${GREEN}No .pacsave files found.${NC}"
        return
    fi
    
    echo -e "${WHITE}Found .pacsave files:${NC}"
    echo ""
    echo "$pacsave_files" | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "  ${NHYPRBLUE}*${NC} ${WHITE}$file${NC}"
        fi
    done
    
    echo ""
    echo -e "${WHITE}.pacsave files are backups of YOUR configs from removed packages.${NC}"
    echo -e "${WHITE}They are safe to delete if you don't need to restore them.${NC}"
    
    if confirm_action "Delete ALL .pacsave files?"; then
        echo "$pacsave_files" | while read -r file; do
            if [ -n "$file" ]; then
                sudo rm "$file"
                echo -e "${GREEN}Deleted $file${NC}"
            fi
        done
    fi
}

# Learn about pacnew handling
learn_pacnew_handling() {
    clear
    echo ""
    draw_box "   UNDERSTANDING PACNEW/PACSAVE     "
    echo ""
draw_border
    echo -e "${WHITE}WHAT IS A .pacnew FILE?${NC}"
draw_border
    echo ""
    echo -e "${WHITE}When you update a package that contains a config file${NC}"
    echo -e "${WHITE}that YOU have modified, pacman doesn't overwrite your${NC}"
    echo -e "${WHITE}changes. Instead, it saves the new version as .pacnew${NC}"
    echo ""
    echo -e "${NARTIC}Example:${NC}"
    echo -e "${WHITE}  Your file:     /etc/pacman.conf (modified by you)${NC}"
    echo -e "${WHITE}  Package update brings new version${NC}"
    echo -e "${WHITE}  New file:      /etc/pacman.conf.pacnew${NC}"
    echo ""
draw_border
    echo -e "${WHITE}WHAT IS A .pacsave FILE?${NC}"
draw_border
    echo ""
    echo -e "${WHITE}When you REMOVE a package and its config file was${NC}"
    echo -e "${WHITE}modified, pacman saves your version as .pacsave${NC}"
    echo -e "${WHITE}in case you want to restore it later.${NC}"
    echo ""
draw_border
    echo -e "${WHITE}WHY SHOULD YOU CARE?${NC}"
draw_border
    echo ""
    echo -e "${WHITE}Ignoring .pacnew files can cause problems:${NC}"
    echo ""
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Missing new features or options${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Security settings not updated${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Syntax changes breaking services${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Deprecated options causing errors${NC}"
    echo ""
draw_border
    echo -e "${WHITE}BEST PRACTICES:${NC}"
draw_border
    echo ""
    echo -e "${NARTIC}1.${NC} ${WHITE}Check for .pacnew files after updates${NC}"
    echo -e "${NARTIC}2.${NC} ${WHITE}Compare differences with diff or pacdiff${NC}"
    echo -e "${NARTIC}3.${NC} ${WHITE}Merge important changes into your config${NC}"
    echo -e "${NARTIC}4.${NC} ${WHITE}Delete .pacnew files when handled${NC}"
    echo -e "${NARTIC}5.${NC} ${WHITE}Delete .pacsave files if not needed${NC}"
    echo ""
draw_border
    echo -e "${WHITE}CRITICAL FILES TO WATCH:${NC}"
draw_border
    echo ""
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}/etc/mkinitcpio.conf   - Boot failures${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}/etc/pacman.conf       - Package management${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}/etc/fstab             - Mount failures${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}/etc/ssh/sshd_config   - SSH access${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}/etc/sudoers           - Sudo access${NC}"
    echo ""
    echo -e "${BLUE}TIP: Run 'sudo pacdiff' for interactive handling!${NC}"
}

# NVIDIA fix function - mkinitcpio only, no GRUB
fix_nvidia_mkinitcpio() {
    echo ""
    echo -e "${WHITE}Checking NVIDIA setup...${NC}"
    echo ""
    
    # Check if nvidia package is installed
    if ! pacman -Qi nvidia &>/dev/null && ! pacman -Qi nvidia-dkms &>/dev/null; then
        echo -e "${NARTIC}NVIDIA driver not installed.${NC}"
        if confirm_action "Install nvidia-dkms package?"; then
            sudo pacman -S --needed nvidia-dkms nvidia-utils
        else
            return
        fi
    else
        echo -e "${GREEN} NVIDIA driver is installed${NC}"
    fi
    
    # Check if nvidia modules are in MODULES in mkinitcpio.conf
    if grep -q "^MODULES=" /etc/mkinitcpio.conf; then
        current_modules=$(grep "^MODULES=" /etc/mkinitcpio.conf | sed 's/MODULES=(\(.*\))/\1/')
        
        # Check which nvidia modules are missing
        missing_modules=""
        for mod in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
            if ! echo "$current_modules" | grep -qw "$mod"; then
                missing_modules="$missing_modules $mod"
            fi
        done
        
        if [ -z "$missing_modules" ]; then
            echo -e "${GREEN} All NVIDIA modules already in mkinitcpio.conf${NC}"
        else
            echo -e "${NARTIC}Missing NVIDIA modules:${NC}$missing_modules"
            echo ""
            
            if confirm_action "Add NVIDIA modules to mkinitcpio.conf?"; then
                # Add the modules
                new_modules="$current_modules nvidia nvidia_modeset nvidia_uvm nvidia_drm"
                # Remove duplicates and extra spaces
                new_modules=$(echo "$new_modules" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/^ *//;s/ *$//')
                
                sudo sed -i "s/^MODULES=.*/MODULES=($new_modules)/" /etc/mkinitcpio.conf
                echo -e "${GREEN} NVIDIA modules added to mkinitcpio.conf${NC}"
                
                # Regenerate initramfs
                echo ""
                echo -e "${WHITE}Regenerating initramfs...${NC}"
                sudo mkinitcpio -P
                echo -e "${GREEN} Initramfs regenerated${NC}"
            fi
        fi
    else
        echo -e "${RED}Could not find MODULES line in mkinitcpio.conf${NC}"
    fi
    
    echo ""
    echo -e "${WHITE}NVIDIA mkinitcpio check complete.${NC}"
    echo -e "${WHITE}Note: If using ZFSBootMenu, ensure your kernel cmdline includes:${NC}"
    echo -e "${NARTIC}nvidia-drm.modeset=1${NC}"
}

# System repair
system_repair() {
    clear
    echo ""
    draw_box "           SYSTEM REPAIR            "
    echo ""
    draw_border
    echo -e "${WHITE}Repair options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'wrong password 3 times'${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Fix - '404 Not Found'${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'error: could not remove' ${NHYPRBLUE}(clear cache)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'error: File is corrupted ${NHYPRBLUE}(PGP signature)'${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'error: unable to lock database'${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'error: Connection timed out'${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'warning: local is newer than...'${NC}"
    echo -e "${BLUE}8${NC} ${NVFROST}-${NC} ${NARTIC}Fix - 'ERROR: module not found: nvidia'${NC}"
    echo -e "${BLUE}9${NC} ${NVFROST}-${NC} ${NARTIC}Several Fix and reinstall all packages (Last try)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-9):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read repair_option
    
    case $repair_option in
        1)
            echo ""
            echo -e "${WHITE}Fix - 'wrong password 3 times'${NC}"
            echo -e "${WHITE}This will reset the faillock for your user${NC}"
            if confirm_action "Reset faillock?"; then
                faillock --reset
                echo -e "${GREEN} Faillock reset successfully${NC}"
            fi
            ;;
        2)
            echo ""
            echo -e "${WHITE}Fix - '404 Not Found'${NC}"
            echo -e "${WHITE}This will refresh package databases and update${NC}"
            if confirm_action "Refresh and update?"; then
                sudo pacman -Syu
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Fix - 'error: could not remove' (clear cache)${NC}"
            echo -e "${WHITE}This will delete all cached packages${NC}"
            if confirm_action "Clear package cache?"; then
                sudo rm -rf /var/cache/pacman/pkg/*
                echo -e "${GREEN}OK Package cache cleared${NC}"
            fi
            ;;
        4)
            echo ""
            echo -e "${WHITE}Fix - 'error: File is corrupted (PGP signature)'${NC}"
            echo -e "${WHITE}This will reinitialize pacman keys${NC}"
            if confirm_action "Reinitialize pacman keys?"; then
                sudo rm -rf /etc/pacman.d/gnupg/
                sudo pacman-key --init
                sudo pacman-key --populate
                sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
                sudo pacman-key --lsign-key F3B607488DB35A47
                sudo rm -rf /var/lib/pacman/sync
                sudo pacman -Sy
                echo -e "${GREEN} Pacman keys reinitialized${NC}"
            fi
            ;;
        5)
            echo ""
            echo -e "${WHITE}Fix - 'error: unable to lock database'${NC}"
            echo -e "${WHITE}This will remove the pacman database lock${NC}"
            if confirm_action "Remove database lock?"; then
                sudo rm -f /var/lib/pacman/db.lck
                echo -e "${GREEN}Database lock removed${NC}"
            fi
            ;;
        6)
            echo ""
            echo -e "${WHITE}Fix - 'error: Connection timed out'${NC}"
            echo -e "${WHITE}This will re-rate mirrors and update${NC}"
            if confirm_action "Re-rate mirrors and update?"; then
                sudo cachyos-rate-mirrors
                sudo pacman -Syu
            fi
            ;;
        7)
            echo ""
            echo -e "${WHITE}Fix - 'warning: local is newer than...'${NC}"
            echo -e "${WHITE}This will force downgrade to repo version${NC}"
            if confirm_action "Force sync and allow downgrades?"; then
                sudo pacman -Syuu
            fi
            ;;
        8)
            echo ""
            echo -e "${WHITE}Fix - 'ERROR: module not found: nvidia'${NC}"
            echo -e "${WHITE}This will check and fix NVIDIA mkinitcpio configuration${NC}"
            if confirm_action "Check and fix NVIDIA setup?"; then
                fix_nvidia_mkinitcpio
            fi
            ;;
        9)
            echo ""
            echo -e "${WHITE}Complete Fix - reinstall all packages${NC}"
            echo -e "${RED}WARNING: This is a nuclear option - only use if nothing else works!${NC}"
            echo ""
            echo -e "${WHITE}This will:${NC}"
            echo -e "${WHITE}  - Remove database lock${NC}"
            echo -e "${WHITE}  - Re-rate mirrors${NC}"
            echo -e "${WHITE}  - Reinitialize pacman keys${NC}"
            echo -e "${WHITE}  - Clear package cache${NC}"
            echo -e "${WHITE}  - Reinstall ALL native packages${NC}"
            echo ""
            if confirm_action "Are you SURE you want to proceed?"; then
                echo -e "${WHITE}Starting complete system repair...${NC}"
                sudo rm -f /var/lib/pacman/db.lck
                sudo cachyos-rate-mirrors
                sudo rm -rf /etc/pacman.d/gnupg/
                sudo pacman-key --init
                sudo pacman-key --populate
                sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
                sudo pacman-key --lsign-key F3B607488DB35A47
                sudo rm -rf /var/lib/pacman/sync
                sudo pacman -Scc --noconfirm
                sudo pacman -Syyu
                if check_paru; then
                    paru -Syyu
                fi
                if check_flatpak; then
                    flatpak update -y
                fi
                pacman -Qqn | sudo pacman -S --noconfirm -
                echo -e "${GREEN}[x]Complete system repair finished${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Educational function - Learn Commands
learn_commands() {
    clear
    echo ""
    draw_box "         LEARN ARCH COMMANDS        "
    echo ""
    draw_border
    echo -e "${WHITE}Select a topic to learn about:${NC}"
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Update System Commands${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Install Package Commands${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Search Package Commands${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Remove Package Commands${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Package Information Commands${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}System Service Commands${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}System Maintenance Commands${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}System Repair Commands${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}AUR Helper ${NHYPRBLUE}(paru)${NARTIC} Commands${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Flatpak Commands${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Useful Tips & Tricks${NC}"
    echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${GREEN}Linux Terminal Basics${NC} ${NHYPRBLUE}(Essential!)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-12):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read learn_option

    case $learn_option in
        1)
            learn_update_commands
            ;;
        2)
            learn_install_commands
            ;;
        3)
            learn_search_commands
            ;;
        4)
            learn_remove_commands
            ;;
        5)
            learn_info_commands
            ;;
        6)
            learn_service_commands
            ;;
        7)
            learn_maintenance_commands
            ;;
        8)
            learn_repair_commands
            ;;
        9)
            learn_aur_commands
            ;;
        10)
            learn_flatpak_commands
            ;;
        11)
            learn_tips_tricks
            ;;
        12)
            learn_linux_basics
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# Learn: Update System Commands
learn_update_commands() {
    clear
    echo ""
    draw_box "      UPDATE SYSTEM - COMMANDS      "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}PACMAN UPDATE COMMANDS:${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Sy${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Synchronize package database only${NC}"
    echo -e "${WHITE}Downloads the latest package lists from mirrors${NC}" 
    echo ""
    echo -e "${NARTIC}sudo pacman -Syy${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Force refresh package database${NC}"
     echo -e "${NARTIC}Re-downloads package lists even if up to date${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Syu${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Sync database AND upgrade all packages${NC}"
    echo -e "${WHITE}This is the standard update command${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Syyu${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Force sync AND upgrade all packages${NC}"
    echo -e "${WHITE}Use when mirrors have been changed${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT THE FLAGS MEAN:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}-S${NC}  ${WHITE}= Sync (install/update packages)${NC}"
    echo -e "${NHYPRBLUE}-y${NC}  ${WHITE}= Refresh package database${NC}"
    echo -e "${NHYPRBLUE}-yy${NC} ${WHITE}= force sync${NC}"
    echo -e "${NHYPRBLUE}-u${NC}  ${WHITE}= Upgrade installed packages${NC}"
    echo ""
    echo -e "${BLUE}TIP: Always use -Syu, never just -Sy followed by -S package${NC}"
    echo -e "${BLUE}This prevents partial upgrades which can break your system!${NC}"
}

# Learn: Install Package Commands
learn_install_commands() {
    clear
    echo ""
    draw_box "     INSTALL PACKAGES - COMMANDS    "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}BASIC INSTALL COMMANDS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -S package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install a package from official repos${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -S package1 package2 package3${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install multiple packages at once${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -S --needed package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install only if not already installed${NC}"
    echo -e "${WHITE}Skips reinstallation of up-to-date packages${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -S group_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install a package group (e.g., base-devel)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}INSTALL FROM FILE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -U /path/to/package.pkg.tar.zst${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install a local package file${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -U https://url/package.pkg.tar.zst${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install a package from URL${NC}"
    echo ""
    echo -e "${BLUE}TIP: Use -S --needed when scripting to avoid unnecessary reinstalls${NC}"
}

# Learn: Search Package Commands
learn_search_commands() {
    clear
    echo ""
    draw_box "      SEARCH PACKAGES - COMMANDS    "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}SEARCH IN REPOSITORIES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pacman -Ss search_term${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search for packages in repos by name/description${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Ss '^vim'${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search with regex (packages starting with vim)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}SEARCH INSTALLED PACKAGES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pacman -Qs search_term${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search among installed packages${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Q${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List ALL installed packages${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qe${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List explicitly installed packages${NC}"
    echo -e "${WHITE}(packages you installed, not dependencies)${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qm${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List foreign packages ${NHYPRBLUE}(AUR, manual installs)${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qdt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List orphan packages ${NHYPRBLUE}(unneeded dependencies)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT THE FLAGS MEAN:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}-S${NC}  ${WHITE}= Sync (search repos)${NC}"
    echo -e "${NHYPRBLUE}-Q${NC}  ${WHITE}= Query (search installed)${NC}"
    echo -e "${NHYPRBLUE}-s${NC}  ${WHITE}= Search${NC}"
    echo -e "${NHYPRBLUE}-e${NC}  ${WHITE}= Explicitly installed${NC}"
    echo -e "${NHYPRBLUE}-m${NC}  ${WHITE}= Foreign (not from repos)${NC}"
    echo -e "${NHYPRBLUE}-d${NC}  ${WHITE}= Dependencies${NC}"
    echo -e "${NHYPRBLUE}-t${NC}  ${WHITE}= Unrequired (orphans)${NC}"
}

# Learn: Remove Package Commands
learn_remove_commands() {
    clear
    echo ""
    draw_box "      REMOVE PACKAGES - COMMANDS    "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}REMOVE COMMANDS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -R package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove a package only${NC}"
    echo -e "${WHITE}Keeps dependencies and config files${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Rs package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove package AND unused dependencies${NC}"
    echo -e "${WHITE}Recommended for clean removal${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Rns package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove package, dependencies, AND config files${NC}"
    echo -e "${WHITE}Complete removal - nothing left behind${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Rdd package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Force remove, ignore dependencies${NC}"
    echo -e "${RED}DANGEROUS - can break your system!${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CLEAN UP ORPHANS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -Rns \$(pacman -Qdtq)${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove all orphan packages at once${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT THE FLAGS MEAN:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}-R${NC}  ${WHITE}= Remove${NC}"
    echo -e "${NHYPRBLUE}-s${NC}  ${WHITE}= Recursive (remove dependencies)${NC}"
    echo -e "${NHYPRBLUE}-n${NC}  ${WHITE}= Nosave (remove config files)${NC}"
    echo -e "${NHYPRBLUE}-d${NC}  ${WHITE}= Skip dependency check${NC}"
    echo ""
    echo -e "${BLUE}TIP: Always use -Rs or -Rns for clean removal${NC}"
}

# Learn: Package Info Commands
learn_info_commands() {
    clear
    echo ""
    draw_box "     PACKAGE INFO - COMMANDS        "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}INFO FROM REPOSITORIES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pacman -Si package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show detailed info from repos${NC}"
    echo -e "${WHITE}     Version, dependencies, size, etc.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}INFO FROM INSTALLED PACKAGES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pacman -Qi package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show info for installed package${NC}"
    echo -e "${WHITE}     Install date, size on disk, etc.${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Ql package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List all files owned by package${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qo /path/to/file${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Find which package owns a file${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qii package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show info including backup files${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT THE FLAGS MEAN:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}-S${NC}  ${WHITE}= Sync (repos)${NC}"
    echo -e "${NHYPRBLUE}-Q${NC}  ${WHITE}= Query (installed)${NC}"
    echo -e "${NHYPRBLUE}-i${NC}  ${WHITE}= Info${NC}"
    echo -e "${NHYPRBLUE}-l${NC}  ${WHITE}= List files${NC}"
    echo -e "${NHYPRBLUE}-o${NC}  ${WHITE}= Owner of file${NC}"
}
# Learn: System Service Commands
learn_service_commands() {
    clear
    echo ""
    draw_box "    SYSTEMCTL SERVICE - COMMANDS    "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}BASIC SERVICE CONTROL:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo systemctl start service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Start a service now${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl stop service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Stop a running service${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl restart service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Restart a service${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl reload service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reload config without full restart${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}ENABLE/DISABLE ON BOOT:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo systemctl enable service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Enable service to start on boot${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl disable service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Disable service from starting on boot${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl enable --now service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Enable AND start immediately${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CHECK STATUS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}systemctl status service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show service status and recent logs${NC}"
    echo ""
    echo -e "${NARTIC}systemctl is-active service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Check if service is running${NC}"
    echo ""
    echo -e "${NARTIC}systemctl is-enabled service_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Check if service starts on boot${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}LIST SERVICES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}systemctl list-units --type=service${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List all loaded services${NC}"
    echo ""
    echo -e "${NARTIC}systemctl list-units --type=service --state=running${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List only running services${NC}"
    echo ""
    echo -e "${NARTIC}systemctl list-unit-files --type=service${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List all installed services${NC}"
}

# Learn: System Maintenance Commands
learn_maintenance_commands() {
    clear
    echo ""
    draw_box "   SYSTEM MAINTENANCE - COMMANDS    "
    echo ""
    draw_border
    echo -e "${WHITE}CACHE MANAGEMENT:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -Sc${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove old packages from cache${NC}"
    echo -e "${WHITE}Keeps currently installed versions${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Scc${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove ALL packages from cache${NC}"
    echo -e "${WHITE}Frees maximum disk space${NC}"
    echo ""
    echo -e "${NARTIC}paccache -r${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Keep only last 3 versions in cache${NC}"
    echo -e "${WHITE}(requires pacman-contrib package)${NC}"
    echo ""
    echo -e "${NARTIC}paccache -rk1${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Keep only last 1 version in cache${NC}"
    echo ""
draw_border
    echo -e "${WHITE}ORPHAN CLEANUP:${NC}"
draw_border
    echo ""
    echo -e "${NARTIC}pacman -Qdt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List orphan packages${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -Rns \$(pacman -Qdtq)${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove all orphans at once${NC}"
    echo ""
draw_border
    echo -e "${WHITE}CONFIG FILE MANAGEMENT:${NC}"
draw_border
    echo ""
    echo -e "${NARTIC}find /etc -name '*.pacnew'${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Find new config files from updates${NC}"
    echo ""
    echo -e "${NARTIC}find /etc -name '*.pacsave'${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Find saved config files from removals${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}MIRROR MANAGEMENT:${NC}"
    draw_border
    echo ""   
    echo -e "${NARTIC}sudo cachyos-rate-mirrors${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Rate and select fastest mirrors ${NHYPRBLUE}(CachyOS)${NC}"
    echo ""
    echo -e "${NARTIC}sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Rate mirrors with reflector ${NHYPRBLUE}(Arch)${NC}"
}

# Learn: System Repair Commands
learn_repair_commands() {
    clear
    echo ""
    draw_box "     SYSTEM REPAIR - COMMANDS       "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}DATABASE ISSUES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo rm /var/lib/pacman/db.lck${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove database lock${NC}"
    echo -e "${WHITE} Use when pacman says 'database is locked'${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}PGP/SIGNATURE ISSUES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman-key --init${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Initialize the pacman keyring${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman-key --populate${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reload the default keys${NC}"
    echo ""
    echo -e "${NARTIC}sudo rm -rf /etc/pacman.d/gnupg${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove keyring ${NHYPRBLUE}(then run --init and --populate)${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}FAILED LOGIN ATTEMPTS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}faillock --reset${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reset failed password counter${NC}"
    echo ""   
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}INITRAMFS/MKINITCPIO:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo mkinitcpio -P${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Regenerate all initramfs images${NC}"
    echo ""
    echo -e "${NARTIC}sudo mkinitcpio -p linux${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Regenerate initramfs for specific kernel${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}REINSTALL PACKAGES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo pacman -S \$(pacman -Qnq)${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reinstall all native packages${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qqn | sudo pacman -S -${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Alternative: reinstall all native packages${NC}"
}

# Learn: AUR Commands
learn_aur_commands() {
    clear
    echo ""
    draw_box "      AUR HELPER (PARU) - COMMANDS  "
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS AUR?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}AUR = Arch User Repository${NC}"
    echo -e "${WHITE}Community-maintained packages not in official repos${NC}"
    echo -e "${WHITE}Paru is an AUR helper that simplifies installation${NC}"
    echo ""
    echo ""
    echo ""
    draw_border

    echo -e "${WHITE}PARU COMMANDS (similar to pacman):${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}paru -S package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install from repos OR AUR${NC}"
    echo ""
    echo -e "${NARTIC}paru -Ss search_term${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search repos AND AUR${NC}"
    echo ""
    echo -e "${NARTIC}paru -Ss --aur search_term${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search AUR only${NC}"
    echo ""
    echo -e "${NARTIC}paru -Syu${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Update system (repos + AUR)${NC}"
    echo ""
    echo -e "${NARTIC}paru -Sua${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Update AUR packages only${NC}"
    echo ""
    echo -e "${NARTIC}paru${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Shortcut for paru -Syu${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}USEFUL PARU OPTIONS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}paru -G package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Download PKGBUILD without installing${NC}"
    echo ""
    echo -e "${NARTIC}paru -Gc package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show AUR comments for package${NC}"
    echo ""
    echo -e "${NARTIC}paru -Ui${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install from local PKGBUILD${NC}"
    echo ""
    echo -e "${BLUE}TIP: Paru wraps pacman - all pacman commands work with paru!${NC}"
}

# Learn: Flatpak Commands
learn_flatpak_commands() {
    clear
    echo ""
    draw_box "        FLATPAK - COMMANDS          "
    echo ""
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS FLATPAK?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Flatpak = Universal Linux package format${NC}"
    echo -e "${WHITE}Apps run in sandboxed environments${NC}"
    echo -e "${WHITE}Works across different Linux distributions${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}BASIC COMMANDS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}flatpak install flathub app_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install an app from Flathub${NC}"
    echo ""
    echo -e "${NARTIC}flatpak install flathub com.spotify.Client${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install using full app ID${NC}"
    echo ""
    echo -e "${NARTIC}flatpak uninstall app_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove a flatpak app${NC}"
    echo ""
    echo -e "${NARTIC}flatpak update${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Update all flatpak apps${NC}"
    echo ""
    echo -e "${NARTIC}flatpak update -y${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Update all without confirmation${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}SEARCH AND INFO:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}flatpak search app_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Search for apps${NC}"
    echo ""
    echo -e "${NARTIC}flatpak list${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List installed apps${NC}"
    echo ""
    echo -e "${NARTIC}flatpak info app_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show app information${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}MAINTENANCE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}flatpak uninstall --unused${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Remove unused runtimes${NC}"
    echo ""
    echo -e "${NARTIC}flatpak repair${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Repair flatpak installation${NC}"
}

# Learn: Tips and Tricks
learn_tips_tricks() {
    clear
    echo ""
    draw_box "       TIPS & TRICKS FOR ARCH       "
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}GOLDEN RULES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}1.${NC} ${WHITE}Always update with -Syu, never just -Sy${NC}"
    echo -e "${WHITE}   Partial upgrades break your system!${NC}"
    echo ""
    echo -e "${NARTIC}2.${NC} ${WHITE}Read before you update${NC}"
    echo -e "${WHITE}   Check archlinux.org for important news${NC}"
    echo ""
    echo -e "${NARTIC}3.${NC} ${WHITE}Keep your system updated regularly${NC}"
    echo -e "${WHITE}   Weekly updates are easier than monthly${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}USEFUL SHORTCUTS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pacman -Qs | wc -l${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Count installed packages${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qi | grep 'Installed Size' | sort -h${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Find largest packages${NC}"
    echo ""
    echo -e "${NARTIC}pacman -Qo \$(which command)${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Find which package provides a command${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}USEFUL RESOURCES:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}Arch Wiki:${NC}        ${WHITE}wiki.archlinux.org${NC}"
    echo -e "${BLUE}Arch Packages:${NC}    ${WHITE}archlinux.org/packages${NC}"
    echo -e "${BLUE}AUR Packages:${NC}     ${WHITE}aur.archlinux.org${NC}"
    echo -e "${BLUE}Arch Forums:${NC}      ${WHITE}bbs.archlinux.org${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}PACMAN CHEAT SHEET:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}-S${NC}  ${WHITE}= Sync ${NHYPRBLUE}(work with repos)${NC}"
    echo -e "${NHYPRBLUE}-Q${NC}  ${WHITE}= Query ${NHYPRBLUE}(work with installed)${NC}"
    echo -e "${NHYPRBLUE}-R${NC}  ${WHITE}= Remove${NC}"
    echo -e "${NHYPRBLUE}-U${NC}  ${WHITE}= Upgrade ${NHYPRBLUE}(local file)${NC}"
    echo -e "${NHYPRBLUE}-F${NC}  ${WHITE}= Files ${NHYPRBLUE}(search file database)${NC}"
    echo ""
    echo -e "${BLUE}Combine with lowercase for actions:${NC}"
    echo -e "${NHYPRBLUE}-s${NC}  ${WHITE}= search${NC}"
    echo -e "${NHYPRBLUE}-i${NC}  ${WHITE}= info${NC}"
    echo -e "${NHYPRBLUE}-l${NC}  ${WHITE}= list${NC}"
    echo -e "${NHYPRBLUE}-u${NC}  ${WHITE}= upgrade${NC}"
    echo -e "${NHYPRBLUE}-y${NC}  ${WHITE}= refresh${NC}"
}

# Learn: Linux Terminal Basics - Main Menu
learn_linux_basics() {
    clear
    echo ""
    draw_box "      LINUX TERMINAL BASICS         "
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}Essential knowledge for navigating Linux${NC}"
    draw_border
    echo ""
    draw_border
    echo -e "${WHITE}Select a topic:${NC}"
    echo ""
    echo -e "${NHYPRBLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Navigation & Paths ${NHYPRBLUE}(cd, ls, pwd)${NC}"
    echo -e "${NHYPRBLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}File Operations ${NHYPRBLUE}(cp, mv, rm, mkdir)${NC}"
    echo -e "${NHYPRBLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}File Viewing & Editing ${NHYPRBLUE}(cat, nano, less)${NC}"
    echo -e "${NHYPRBLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Permissions & Ownership ${NHYPRBLUE}(chmod, chown)${NC}"
    echo -e "${NHYPRBLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Archives & Compression ${NHYPRBLUE}(tar, unzip, 7z)${NC}"
    echo -e "${NHYPRBLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Downloading Files ${NHYPRBLUE}(wget, aria2c, git)${NC}"
    echo -e "${NHYPRBLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}System Information ${NHYPRBLUE}(lsblk, lsusb, mount)${NC}"
    echo -e "${NHYPRBLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Building Packages ${NHYPRBLUE}(makepkg, cmake)${NC}"
    echo -e "${NHYPRBLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Understanding sudo & Root${NC}"
    echo -e "${NHYPRBLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Shells: Bash vs Fish${NC}"
    echo -e "${NHYPRBLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Environment Variables & Export${NC}"
    echo -e "${NHYPRBLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Debugging & Troubleshooting Programs${NC}"
    echo -e "${NHYPRBLUE}13${NC} ${NVFROST}-${NC} ${NARTIC}Wine & Windows Programs${NC}"
    echo -e "${NHYPRBLUE}14${NC} ${NVFROST}-${NC} ${NARTIC}Getting Help ${NHYPRBLUE}(man, --help)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-14):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read basics_option

    case $basics_option in
        1) learn_basics_navigation ;;
        2) learn_basics_files ;;
        3) learn_basics_viewing ;;
        4) learn_basics_permissions ;;
        5) learn_basics_archives ;;
        6) learn_basics_downloading ;;
        7) learn_basics_sysinfo ;;
        8) learn_basics_building ;;
        9) learn_basics_sudo ;;
        10) learn_basics_shells ;;
        11) learn_basics_environment ;;
        12) learn_basics_debugging ;;
        13) learn_basics_wine ;;
        14) learn_basics_help ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
}

# Basics: Navigation & Paths
learn_basics_navigation() {
    clear
    echo ""
    draw_box "     NAVIGATION & PATHS             "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}UNDERSTANDING PATHS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}~/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Your home directory (same as \$HOME)${NC}"
    echo -e "${WHITE}     Example: ~/Documents = /home/username/Documents${NC}"
    echo ""
    echo -e "${NARTIC}\$HOME${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Environment variable pointing to your home${NC}"
    echo -e "${WHITE}     Example: \$HOME/Downloads = /home/username/Downloads${NC}"
    echo ""
    echo -e "${NARTIC}/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Root of the filesystem ${NHYPRBLUE}(top level)${NC}"
    echo ""
    echo -e "${NARTIC}./${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Current directory${NC}"
    echo -e "${WHITE}     Example: ./script.sh = run script in current folder${NC}"
    echo ""
    echo -e "${NARTIC}../${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Parent directory ${NHYPRBLUE}(one level up)${NC}"
    echo ""
    echo -e "${NARTIC}/*${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Wildcard - matches everything${NC}"
    echo -e "${RED}     ! DANGER: rm -rf /* deletes EVERYTHING!${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}NAVIGATION COMMANDS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}pwd${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Print working directory ${NHYPRBLUE}(where am I?)${NC}"
    echo ""
    echo -e "${NARTIC}cd /path/to/folder${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Change directory${NC}"
    echo ""
    echo -e "${NARTIC}cd${NC}  ${WHITE}or${NC}  ${NARTIC}cd ~${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Go to home directory${NC}"
    echo ""
    echo -e "${NARTIC}cd ..${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Go up one directory${NC}"
    echo ""
    echo -e "${NARTIC}cd -${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Go to previous directory${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}LISTING FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}ls${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List files in current directory${NC}"
    echo ""
    echo -e "${NARTIC}ls -l${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List with details (permissions, size, date)${NC}"
    echo ""
    echo -e "${NARTIC}ls -la${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List ALL files including hidden ${NHYPRBLUE}(starting with .)${NC}"
    echo ""
    echo -e "${NARTIC}ls -lh${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List with human-readable sizes ${NHYPRBLUE}(KB, MB, GB)${NC}"
}

# Basics: File Operations
learn_basics_files() {
    clear
    echo ""
    draw_box "       FILE OPERATIONS              "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}COPY FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}cp file.txt /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Copy a file to destination${NC}"
    echo ""
    echo -e "${NARTIC}cp -r folder/ /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Copy folder recursively ${NHYPRBLUE}(including contents)${NC}"
    echo -e "${WHITE}     -r = recursive (required for directories!)${NC}"
    echo ""
    echo -e "${NARTIC}cp -v file.txt /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Copy with verbose output ${NHYPRBLUE}(shows what's copied)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}MOVE / RENAME:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}mv file.txt /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Move file to destination${NC}"
    echo ""
    echo -e "${NARTIC}mv oldname.txt newname.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Rename a file${NC}"
    echo ""
    echo -e "${NARTIC}mv folder/ /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Move folder ${NHYPRBLUE}(no -r needed unlike cp)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}DELETE FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}rm file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Delete a file${NC}"
    echo ""
    echo -e "${NARTIC}rm -r folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Delete folder and contents recursively${NC}"
    echo ""
    echo -e "${NARTIC}rm -f file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Force delete ${NHYPRBLUE}(no confirmation)${NC}"
    echo ""
    echo -e "${NARTIC}rm -rf folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Force delete folder recursively${NC}"
    echo -e "${RED}     ! BE VERY CAREFUL! No undo! No trash!${NC}"
    echo ""
    echo -e "${RED}NEVER RUN: sudo rm -rf /* ${NC}"
    echo -e "${RED}This deletes your ENTIRE system!${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CREATE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}mkdir foldername${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Create a directory${NC}"
    echo ""
    echo -e "${NARTIC}mkdir -p path/to/nested/folders${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Create nested directories ${NHYPRBLUE}(creates parents)${NC}"
    echo ""
    echo -e "${NARTIC}touch filename.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Create empty file ${NHYPRBLUE}(or update timestamp)${NC}"
}

# Basics: File Viewing & Editing
learn_basics_viewing() {
    clear
    echo ""
    draw_box "     FILE VIEWING & EDITING         "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}VIEWING FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}cat file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Display entire file contents${NC}"
    echo -e "${WHITE}     Best for small files${NC}"
    echo ""
    echo -e "${NARTIC}less file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}View file with scrolling${NC}"
    echo -e "${WHITE}     Press q to quit, / to search${NC}"
    echo ""
    echo -e "${NARTIC}head file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show first 10 lines${NC}"
    echo ""
    echo -e "${NARTIC}head -n 20 file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show first 20 lines${NC}"
    echo ""
    echo -e "${NARTIC}tail file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show last 10 lines${NC}"
    echo ""
    echo -e "${NARTIC}tail -f logfile.log${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Follow file ${NHYPRBLUE}(live updates)${NARTIC} - great for logs${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}EDITING FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}nano file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Simple terminal text editor${NC}"
    echo -e "${WHITE}     Ctrl+O = Save, Ctrl+X = Exit${NC}"
    echo ""
    echo -e "${NARTIC}sudo nano /etc/somefile.conf${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Edit system files ${NHYPRBLUE}(requires sudo)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}OUTPUT REDIRECTION:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}echo \"hello\" > file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Write to file ${NHYPRBLUE}(overwrites!)${NC}"
    echo ""
    echo -e "${NARTIC}echo \"hello\" >> file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Append to file${NC}"
    echo ""
    echo -e "${NARTIC}echo \"text\" | tee file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Write to file AND show on screen${NC}"
    echo ""
    echo -e "${NARTIC}echo \"text\" | sudo tee /etc/file.conf${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Write to system file as root${NC}"
}

 # Basics: Permissions & Ownership
learn_basics_permissions() {
    clear
    echo ""
    draw_box "     PERMISSIONS & OWNERSHIP        "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}UNDERSTANDING PERMISSIONS:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}When you run ${NARTIC}ls -l${WHITE}, you see:${NC}"
    echo -e "${NARTIC}-rwxr-xr-x 1 user group 1234 date file.txt${NC}"
    echo ""
    echo -e "${WHITE}The first part ${NARTIC}-rwxr-xr-x${WHITE} means:${NC}"
    echo -e "${WHITE}  Position 1:    ${NHYPRBLUE}-${NC} = file, ${NHYPRBLUE}d${NC} = directory"
    echo -e "${WHITE}  Positions 2-4: ${NHYPRBLUE}rwx${NC} = owner permissions"
    echo -e "${WHITE}  Positions 5-7: ${NHYPRBLUE}r-x${NC} = group permissions"
    echo -e "${WHITE}  Positions 8-10: ${NHYPRBLUE}r-x${NC} = others permissions"
    echo ""
    echo -e "${WHITE}Permission letters:${NC}"
    echo -e "${NHYPRBLUE}r${NC} = read    (value: 4)"
    echo -e "${NHYPRBLUE}w${NC} = write   (value: 2)"
    echo -e "${NHYPRBLUE}x${NC} = execute (value: 1)"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CHMOD - CHANGE PERMISSIONS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}chmod +x script.sh${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Make file executable${NC}"
    echo -e "${WHITE}     Required before running scripts!${NC}"
    echo ""
    echo -e "${NARTIC}chmod 755 script.sh${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}rwx for owner, rx for group and others${NC}"
    echo -e "${WHITE}     Common for executable scripts${NC}"
    echo ""
    echo -e "${NARTIC}chmod 644 file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}rw for owner, r for group and others${NC}"
    echo -e "${WHITE}     Common for regular files${NC}"
    echo ""
    echo -e "${NARTIC}chmod -R 755 folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Apply recursively to folder${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CHOWN - CHANGE OWNERSHIP:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo chown user:group file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Change owner and group${NC}"
    echo ""
    echo -e "${NARTIC}sudo chown -R user:user folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Change ownership recursively${NC}"
    echo ""
    echo -e "${NARTIC}sudo chown \$USER:$USER file.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Change to current user${NC}"
}

# Basics: Archives & Compression
learn_basics_archives() {
    clear
    echo ""
    draw_box "     ARCHIVES & COMPRESSION         "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}TAR ARCHIVES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}tar -xvf archive.tar${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract .tar archive${NC}"
    echo ""
    echo -e "${NARTIC}tar -xzvf archive.tar.gz${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract .tar.gz ${NHYPRBLUE}(gzip compressed)${NC}"
    echo ""
    echo -e "${NARTIC}tar -xjvf archive.tar.bz2${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract .tar.bz2 ${NHYPRBLUE}(bzip2 compressed)${NC}"
    echo ""
    echo -e "${NARTIC}tar -xf archive.tar.xz${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract .tar.xz ${NHYPRBLUE}(xz compressed)${NC}"
    echo ""
    echo -e "${NARTIC}tar -xf archive.tar.zst${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract .tar.zst ${NHYPRBLUE}(zstd compressed)${NC}"
    echo ""
    echo -e "${WHITE}Flags: ${NHYPRBLUE}x${NC}=extract ${NHYPRBLUE}v${NC}=verbose ${NHYPRBLUE}f${NC}=file ${NHYPRBLUE}z${NC}=gzip ${NHYPRBLUE}j${NC}=bzip2${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CREATE TAR ARCHIVES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}tar -czvf archive.tar.gz folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Create compressed archive${NC}"
    echo -e "${WHITE}     ${NHYPRBLUE}c${NC}=create${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}ZIP FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}unzip archive.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract zip file${NC}"
    echo ""
    echo -e "${NARTIC}unzip archive.zip -d /destination/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract to specific directory${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}RAR FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}unrar x archive.rar${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract rar with full paths${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}7ZIP FILES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}7z x archive.7z${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Extract 7z archive${NC}"
    echo ""
    echo -e "${BLUE}TIP: 7z can extract almost any format!${NC}"
}

# Basics: Downloading Files
learn_basics_downloading() {
    clear
    echo ""
    draw_box "       DOWNLOADING FILES            "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WGET - SIMPLE DOWNLOADS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}wget https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Download a file${NC}"
    echo ""
    echo -e "${NARTIC}wget -O newname.zip https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Download with different filename${NC}"
    echo ""
    echo -e "${NARTIC}wget -c https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Continue interrupted download${NC}"
    echo ""
    echo -e "${RED} DO NOT use sudo with wget!${NC}"
    echo -e "${RED} If you have downloaded with sudo, you need to run 'sudo chmod ${NHYPRBLUE}(your)${RED} username:username -R /path/to/your/package'${NC}"

    echo -e "${WHITE}  Downloaded files would be owned by root${NC}"
    echo -e "${WHITE}  and could be a security risk.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}ARIA2C - FASTER DOWNLOADS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}aria2 https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Download with multiple connections (faster!)${NC}"
    echo ""
    echo -e "${NARTIC}aria2 -x 16 https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Use 16 connections (even faster)${NC}"
    echo ""
    echo -e "${NARTIC}aria2 -c https://example.com/file.zip${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Continue interrupted download${NC}"
    echo ""
    echo -e "${WHITE}Why aria2 over wget?${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Multiple simultaneous connections${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Often 3-10x faster than wget${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Supports torrents and metalinks${NC}"
    echo -e "${RED} DO NOT use sudo with aria2 root will own the downloded content!${NC}"
    echo -e "${RED} If you have downloaded with sudo, you need to run 'sudo chmod (your) username:username -R /path/to/your/package'${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}GIT CLONE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}git clone https://github.com/user/repo.git${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Download a git repository${NC}"
    echo ""
    echo -e "${NARTIC}git clone --depth 1 https://github.com/user/repo.git${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Shallow clone (faster, less disk space)${NC}"
    echo ""
    echo -e "${RED} DO NOT use sudo with git clone!${NC}"
    echo -e "${RED} If you have downloaded with sudo, you need to run 'sudo chmod (your) username:username -R /path/to/your/package'${NC}"
    echo -e "${WHITE}  Clone to your home directory, not system folders.${NC}"
}

# Basics: System Information
learn_basics_sysinfo() {
    clear
    echo ""
    draw_box "      SYSTEM INFORMATION            "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}DISK & STORAGE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}lsblk${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List block devices ${NHYPRBLUE}(disks, partitions)${NC}"
    echo ""
    echo -e "${NARTIC}lsblk -f${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show filesystem types and UUIDs${NC}"
    echo ""
    echo -e "${NARTIC}df -h${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show disk space usage ${NHYPRBLUE}(human readable)${NC}"
    echo ""
    echo -e "${NARTIC}du -sh folder/${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show size of a folder${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}USB & HARDWARE:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}lsusb${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List USB devices${NC}"
    echo ""
    echo -e "${NARTIC}lspci${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}List PCI devices (graphics, network, etc)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}MOUNTING:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo mount /dev/sdb1 /mnt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Mount a partition to /mnt${NC}"
    echo ""
    echo -e "${NARTIC}sudo umount /mnt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Unmount${NC}"
    echo ""
    echo -e "${NARTIC}sudo mount --bind /source /destination${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Bind mount ${NHYPRBLUE}(mount folder to another location)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}SYSTEM CONTROL:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}sudo sysctl --system${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reload all sysctl settings${NC}"
    echo ""
    echo -e "${NARTIC}sudo mkinitcpio -P${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Regenerate all initramfs images${NC}"
    echo -e "${WHITE}     Required after kernel module changes${NC}"
    echo ""
    echo -e "${NARTIC}sudo systemctl daemon-reload${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Reload systemd after service file changes${NC}"
    echo ""
    echo -e "${NARTIC}update-desktop-database${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Update application menu entries${NC}"
}

# Basics: Building Packages
learn_basics_building() {
    clear
    echo ""
    draw_box "       BUILDING PACKAGES            "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}MAKEPKG - BUILD AUR PACKAGES:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}The manual way to install AUR packages:${NC}"
    echo ""
    echo -e "${NARTIC}git clone https://aur.archlinux.org/package.git${NC}"
    echo -e "${NARTIC}cd package${NC}"
    echo -e "${NARTIC}makepkg -si${NC}"
    echo ""
    echo -e "${WHITE}Makepkg flags:${NC}"
    echo -e "${NHYPRBLUE}-s${NC}  ${WHITE}= Install dependencies automatically${NC}"
    echo -e "${NHYPRBLUE}-i${NC}  ${WHITE}= Install package after building${NC}"
    echo -e "${NHYPRBLUE}-c${NC}  ${WHITE}= Clean up build files after${NC}"
    echo -e "${NHYPRBLUE}-r${NC}  ${WHITE}= Remove build dependencies after${NC}"
    echo ""
    echo -e "${NARTIC}makepkg -si${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Most common: build, install deps, install package${NC}"
    echo ""
    echo -e "${NARTIC}makepkg -sirc${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Full clean build${NC}"
    echo ""
    echo -e "${RED}! NEVER run makepkg as root/sudo!${NC}"
    echo -e "${WHITE}  It will refuse to run for security reasons.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}CMAKE - COMPILING SOFTWARE:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Typical cmake build process:${NC}"
    echo ""
    echo -e "${NARTIC}mkdir build && cd build${NC}"
    echo -e "${NARTIC}cmake ..${NC}"
    echo -e "${NARTIC}make -j\$(nproc)${NC}"
    echo -e "${NARTIC}sudo make install${NC}"
    echo ""
    echo -e "${WHITE}The ${NHYPRBLUE}-j\$(nproc)${NC} uses all CPU cores for faster builds${NC}"
}

# Basics: Understanding sudo
learn_basics_sudo() {
    clear
    echo ""
    draw_box "     UNDERSTANDING SUDO & ROOT      "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT IS SUDO?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}sudo = \"Super User DO\"${NC}"
    echo -e "${WHITE}Run a command with root ${NHYPRBLUE}(administrator)${WHITE} privileges.${NC}"
    echo ""
    echo -e "${NARTIC}sudo pacman -S package${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install package as root${NC}"
    echo ""
    echo -e "${NARTIC}su${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Switch to root user ${NHYPRBLUE}(enter root password)${NC}"
    echo ""
    echo -e "${NARTIC}sudo -i${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Start root shell ${NHYPRBLUE}(using your password)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHEN TO USE SUDO:${NC}"
    draw_border
    echo ""
    echo -e "${GREEN}OK USE sudo for:${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Installing/removing packages ${NHYPRBLUE}(pacman, paru)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Editing system config files ${NHYPRBLUE}(/etc/...)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Managing services ${NHYPRBLUE}(systemctl)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Mounting drives${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Changing system settings${NC}"
    echo ""
    echo -e "${RED}x DO NOT use sudo for:${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} wget, aria2c, curl ${NHYPRBLUE}(downloading files)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}git clone${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}makepkg (will refuse to run!)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Running GUI applications${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Anything in your home directory${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHY NOT SUDO FOR DOWNLOADS?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}If you run: ${RED}sudo wget http://example.com/file${NC}"
    echo ""
    echo -e "${WHITE}Problems:${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}File is owned by root, not you${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}You can't edit/delete without sudo${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Security risk: malicious code runs as root${NC}"
    echo ""
    echo -e "${GREEN}Better:${NC} ${NARTIC}wget http://example.com/file${NC}"
    echo -e "${WHITE}File is owned by you, in your directory.${NC}"
}

# Basics: Shells - Bash vs Fish
learn_basics_shells() {
    clear
    echo ""
    draw_box "       SHELLS: BASH VS FISH         "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT IS A SHELL?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}A shell is the program that interprets your commands.${NC}"
    echo -e "${WHITE}Nordix uses ${NARTIC}fish${WHITE} as the default shell.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}BASH vs FISH:${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}Bash${NC} ${WHITE}(Bourne Again Shell)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Standard shell on most Linux systems${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Scripts use ${NHYPRBLUE}#!/bin/bash${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} More compatible with tutorials/scripts${NC}"
    echo ""
    echo -e "${NHYPRBLUE}Fish${NC} ${WHITE}(Friendly Interactive Shell)${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Better autocompletion${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Syntax highlighting${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}More user-friendly${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE} Different syntax than bash${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHEN TO SWITCH TO BASH:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Some commands/scripts require bash syntax.${NC}"
    echo -e "${WHITE}If something doesn't work in fish:${NC}"
    echo ""
    echo -e "${NARTIC}bash${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Start a bash session${NC}"
    echo ""
    echo -e "${NARTIC}bash script.sh${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run a script with bash${NC}"
    echo ""
    echo -e "${NARTIC}exit${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Return to fish${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}SHEBANG - #!/bin/bash${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}The first line of a script tells which shell to use:${NC}"
    echo ""
    echo -e "${NARTIC}#!/bin/bash${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run this script with bash${NC}"
    echo ""
    echo -e "${NARTIC}#!/bin/fish${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run this script with fish${NC}"
    echo ""
    echo -e "${NARTIC}#!/usr/bin/env python${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run with python${NC}"
}

# Basics: Environment Variables
learn_basics_environment() {
    clear
    echo ""
    draw_box "   ENVIRONMENT VARIABLES & EXPORT   "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT ARE ENVIRONMENT VARIABLES?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Variables that programs can read to configure behavior.${NC}"
    echo ""
    echo -e "${NARTIC}echo \$HOME${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Print your home directory${NC}"
    echo ""
    echo -e "${NARTIC}echo \$USER${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Print your username${NC}"
    echo ""
    echo -e "${NARTIC}echo \$PATH${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Print directories searched for commands${NC}"
    echo ""
    echo -e "${NARTIC}env${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show all environment variables${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}EXPORT - SET VARIABLES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}export MYVAR=\"hello\"${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Set variable for current session${NC}"
    echo ""
    echo -e "${NARTIC}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Add directory to PATH${NC}"
    echo ""
    echo -e "${WHITE}Without export:${NC}"
    echo -e "${NARTIC}MYVAR=\"hello\"${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Only available in current shell, not child processes${NC}"
    echo ""
    echo -e "${WHITE}With export:${NC}"
    echo -e "${NARTIC}export MYVAR=\"hello\"${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Available to all programs started from this shell${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}TEMPORARY VS PERMANENT:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Temporary (current session only):${NC}"
    echo -e "${NARTIC}export EDITOR=nano${NC}"
    echo ""
    echo -e "${WHITE}Permanent (add to ~/.bashrc or ~/.config/fish/config.fish):${NC}"
    echo -e "${NARTIC}echo 'export EDITOR=nano' >> ~/.bashrc${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}INLINE VARIABLES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game wine game.exe${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Set variable for just this command${NC}"
}

# Basics: Debugging Programs
learn_basics_debugging() {
    clear
    echo ""
    draw_box "   DEBUGGING & TROUBLESHOOTING      "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}RUNNING PROGRAMS FROM TERMINAL:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Why run from terminal?${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}See error messages that GUI hides${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Debug why a program crashes${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}See verbose output${NC}"
    echo ""
    echo -e "${NARTIC}firefox${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run Firefox, see errors in terminal${NC}"
    echo ""
    echo -e "${NARTIC}program 2>&1 | tee log.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run and save all output to file${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}VERBOSE & DEBUG FLAGS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}program --verbose${NC}  ${WHITE}or${NC}  ${NARTIC}program -v${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}More detailed output${NC}"
    echo ""
    echo -e "${NARTIC}program --debug${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Debug mode (if supported)${NC}"
    echo ""
    echo -e "${NARTIC}DEBUG=1 program${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Enable debug via environment variable${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}VIEWING LOGS:${NC}"
    draw_border
    echo ""
    echo ""
    echo -e "${NARTIC}journalctl -xe${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show recent system logs with explanations${NC}"
    echo ""
    echo -e "${NARTIC}journalctl -u servicename${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show logs for specific service${NC}"
    echo ""
    echo -e "${NARTIC}journalctl -f${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Follow logs in real-time${NC}"
    echo ""
    echo -e "${NARTIC}dmesg | tail${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Kernel messages (hardware issues)${NC}"
    echo ""
    echo -e "${NARTIC}cat ~/.local/share/app/logs/log.txt${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Application-specific logs${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}COMMON DEBUG LOCATIONS:${NC}"
    draw_border
    echo ""
    echo ""
    echo -e "${WHITE}~/.local/share/appname/${NC}"
    echo -e "${WHITE}~/.config/appname/${NC}"
    echo -e "${WHITE}/var/log/${NC}"
}

# Basics: Wine
learn_basics_wine() {
    clear
    echo ""
    draw_box "     WINE & WINDOWS PROGRAMS        "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WHAT IS WINE?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Wine = \"Wine Is Not an Emulator\"${NC}"
    echo -e "${WHITE}Runs Windows programs on Linux by translating${NC}"
    echo -e "${WHITE}Windows API calls to Linux equivalents.${NC}"
    echo -e "${NHYPRBLUE}Poron is Steam's wine versions, and wine-protn is a wine-version of steams proton...${NC}"
    echo -e "${NHYPRBLUE}Valve has invested millions of dollars annually into developing Proton,${NC}"
    echo -e "${NHYPRBLUE}a compatibility layer enabling Windows games on Linux,${NC}"
    echo -e "${NHYPRBLUE}employing over 100 developers for open-source projects like Proton, Mesa, and Wine${NC}"
    echo -e "${NHYPRBLUE}to make Linux a strong gaming competitor to Windows, transforming Linux gaming from niche to mainstream.${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WINE PREFIX:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}A prefix is a separate Windows environment.${NC}"
    echo -e "${WHITE}Default: ${NARTIC}~/.wine${NC}"
    echo ""
    echo -e "${WHITE}Why use separate prefixes?${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Different Windows versions per app${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Isolate apps from each other${NC}"
    echo -e "${NHYPRBLUE}*${NC} ${WHITE}Different DLL configurations${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}BASIC WINE COMMANDS:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}wine program.exe${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run Windows program (uses ~/.wine)${NC}"
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game wine program.exe${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Run with specific prefix${NC}"
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game winecfg${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Configure Wine for that prefix${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}WINETRICKS:${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Winetricks installs Windows components/DLLs.${NC}"
    echo ""
    echo -e "${NARTIC}winetricks${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Open GUI for default prefix${NC}"
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game winetricks${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Open GUI for specific prefix${NC}"
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game winetricks vcrun2019${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install Visual C++ 2019 runtime${NC}"
    echo ""
    echo -e "${NARTIC}WINEPREFIX=~/.wine-game winetricks dxvk${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Install DXVK (DirectX to Vulkan)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}EXAMPLE: SETTING UP A GAME${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}export WINEPREFIX=~/.wine-mygame${NC}"
    echo -e "${NARTIC}winetricks win10 dxvk vcrun2019${NC}"
    echo -e "${NARTIC}wine setup.exe${NC}"
    echo -e "${NARTIC}wine ~/Game/game.exe${NC}"
    echo ""
    echo -e "${BLUE}TIP: Use Lutris, Heroic, Bottles for easier game setup!${NC}"
    echo -e "${BLUE}TIP: Tips, lutris is not only for games, it is excellent to run windows programs to,${NC}"
    echo -e "${BLUE}TIP: you can include every package, linux, flatpak, windows, ROM'S, steam, GOG, EPIC, Serier, Videos, Music${NC}"
    echo -e "${BLUE}TIP: Create specefic categories and you can create a system wide launcher with Lutris${NC}"
    echo -e "${BLUE}TIP: to add non supperted programs/ videos/apps, make a script and add to Lutris!${NC}"
    echo -e "${BLUE}TIP: If you have a lagre media library, i would recomend KODI instead${NC}"
    echo -e "${BLUE}TIP: Use 'protonup-qt' and 'protonplus' for e easy acces to custom wine/proton for Lutris, Heroic, Steam, Bottles${NC}"
    echo -e "${BLUE}TIP: To install protonup-qt and protonplus - sudo pacman -Sy protonup-qt protonplus${NC}"

  
}

# Basics: Getting Help
learn_basics_help() {
    clear
    echo ""
    draw_box "         GETTING HELP               "
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}QUICK HELP:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}command --help${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Quick usage summary${NC}"
    echo -e "${WHITE}     Example: pacman --help${NC}"
    echo ""
    echo -e "${NARTIC}command -h${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Short form (not all commands)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}MANUAL PAGES (COMPREHENSIVE):${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}man command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Full manual page${NC}"
    echo -e "${WHITE}     Example: man pacman${NC}"
    echo ""
    echo -e "${WHITE}Navigation in man:${NC}"
    echo -e "${NHYPRBLUE}q${NC}      ${WHITE}= quit${NC}"
    echo -e "${NHYPRBLUE}/word${NC}  ${WHITE}= search for 'word'${NC}"
    echo -e "${NHYPRBLUE}n${NC}      ${WHITE}= next search result${NC}"
    echo -e "${NHYPRBLUE}space${NC}  ${WHITE}= page down${NC}"
    echo -e "${NHYPRBLUE}b${NC}      ${WHITE}= page up${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}OTHER HELP RESOURCES:${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}tldr command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Simplified examples (install tldr first)${NC}"
    echo ""
    echo -e "${NARTIC}whatis command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}One-line description${NC}"
    echo ""
    echo -e "${NARTIC}whereis command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show location of command${NC}"
    echo ""
    echo -e "${NARTIC}which command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show which version will run${NC}"
    echo ""
    echo -e "${NARTIC}type command${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Show if alias, function, or binary${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${WHITE}ONLINE RESOURCES:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}Arch Wiki${NC}        ${WHITE}wiki.archlinux.org${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Best documentation for Arch Linux${NC}"
    echo ""
    echo -e "${BLUE}Explainshell${NC}     ${WHITE}explainshell.com${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Paste a command, get explanation${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NARTIC}Remember:${NC}"
    echo -e "${WHITE}  ${NHYPRBLUE}command --help${NC}  for quick info${NC}"
    echo -e "${WHITE}  ${NHYPRBLUE}man command${NC}     for full documentation${NC}"
}

# ============================================
# OPTION 14: SYSTEM INFORMATION & STATE ANALYZER
# ============================================
system_information() {
    clear
    echo ""
    draw_box "    SYSTEM STATE ANALYZER - NORDIX   "
    echo ""
    draw_border
    echo -e "${WHITE}Select analysis type:${NC}"
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Quick System Overview${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Full System State Analysis${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Hardware Detection (CPU/GPU/RAM)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Kernel & Driver Status${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Missing Components Check${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Storage & Filesystem Info${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Security Status Overview${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-7):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read info_option
    
    case $info_option in
        1) quick_system_overview ;;
        2) full_system_analysis ;;
        3) hardware_detection ;;
        4) kernel_driver_status ;;
        5) missing_components_check ;;
        6) storage_filesystem_info ;;
        7) security_status_overview ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    press_enter
}

quick_system_overview() {
    clear
    echo ""
    draw_box "       QUICK SYSTEM OVERVIEW         "
    echo ""
    
draw_border
    echo -e "${WHITE}SYSTEM IDENTITY${NC}"
draw_border
    echo ""
    
    echo -e "${NHYPRBLUE}Hostname:${NC}     $(hostname)"
    echo -e "${NHYPRBLUE}OS:${NC}           $(cat /etc/os-release 2>/dev/null | grep "PRETTY_NAME" | cut -d'"' -f2)"
    echo -e "${NHYPRBLUE}Kernel:${NC}       $(uname -r)"
    echo -e "${NHYPRBLUE}Architecture:${NC} $(uname -m)"
    echo -e "${NHYPRBLUE}Uptime:${NC}       $(uptime -p 2>/dev/null || uptime)"
    
    echo ""
draw_border
    echo -e "${WHITE}HARDWARE SUMMARY${NC}"
draw_border
    echo ""
    
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    cpu_cores=$(nproc)
    echo -e "${NHYPRBLUE}CPU:${NC}          $cpu_model"
    echo -e "${NHYPRBLUE}Cores:${NC}        $cpu_cores"
    
    total_ram=$(free -h | awk '/^Mem:/ {print $2}')
    used_ram=$(free -h | awk '/^Mem:/ {print $3}')
    echo -e "${NHYPRBLUE}RAM:${NC}          $used_ram / $total_ram"
    
    if command -v lspci &>/dev/null; then
        gpu_info=$(lspci | grep -i 'vga\|3d\|display' | head -1 | cut -d':' -f3 | xargs)
        echo -e "${NHYPRBLUE}GPU:${NC}          $gpu_info"
    fi
    
    root_disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')
    echo -e "${NHYPRBLUE}Root Disk:${NC}    $root_disk"
    
    echo ""
draw_border
    echo -e "${WHITE}PACKAGE STATUS${NC}"
draw_border
    echo ""
    
    total_pkgs=$(pacman -Q | wc -l)
    explicit_pkgs=$(pacman -Qe | wc -l)
    aur_pkgs=$(pacman -Qm | wc -l)
    orphan_pkgs=$(pacman -Qtdq 2>/dev/null | wc -l)
    
    echo -e "${NHYPRBLUE}Total packages:${NC}       $total_pkgs"
    echo -e "${NHYPRBLUE}Explicitly installed:${NC} $explicit_pkgs"
    echo -e "${NHYPRBLUE}AUR packages:${NC}         $aur_pkgs"
    if [ "$orphan_pkgs" -gt 0 ]; then
        echo -e "${NARTIC}Orphan packages:${NC}      $orphan_pkgs ${RED}(can be removed)${NC}"
    else
        echo -e "${NHYPRBLUE}Orphan packages:${NC}      ${GREEN}0 OK${NC}"
    fi
}

full_system_analysis() {
    clear
    echo ""
    draw_box "     FULL SYSTEM STATE ANALYSIS      "
    echo ""
    
    echo -e "${WHITE}Running comprehensive system analysis...${NC}"
    echo ""
    
draw_border
    echo -e "${WHITE}1. KERNEL & MICROCODE STATUS${NC}"
draw_border
    echo ""
    
    echo -e "${NHYPRBLUE}Running kernel:${NC} $(uname -r)"
    
    cpu_vendor=$(grep -m1 "vendor_id" /proc/cpuinfo | cut -d':' -f2 | xargs)
    if [[ "$cpu_vendor" == *"Intel"* ]]; then
        if pacman -Qi intel-ucode &>/dev/null; then
            echo -e "${GREEN}OK${NC} Intel microcode installed"
        else
            echo -e "${RED}x${NC} Intel microcode ${RED}NOT INSTALLED${NC}"
            echo -e "  ${NARTIC}- Install with: sudo pacman -S intel-ucode${NC}"
        fi
    elif [[ "$cpu_vendor" == *"AMD"* ]]; then
        if pacman -Qi amd-ucode &>/dev/null; then
            echo -e "${GREEN}OK${NC} AMD microcode installed"
        else
            echo -e "${RED}x${NC} AMD microcode ${RED}NOT INSTALLED${NC}"
            echo -e "  ${NARTIC}- Install with: sudo pacman -S amd-ucode${NC}"
        fi
    fi
    
    echo ""
    echo -e "${NHYPRBLUE}Installed kernels:${NC}"
    pacman -Qq | grep -E "^linux" | grep -v headers | while read -r kernel; do
        version=$(pacman -Qi "$kernel" 2>/dev/null | grep "Version" | cut -d':' -f2 | xargs)
        echo -e "  ${BLUE}*${NC} $kernel - $version"
    done
    
    echo ""
draw_border
    echo -e "${WHITE}2. IMPORTANT SYSTEM HOOKS${NC}"
draw_border
    echo ""
    
    if pacman -Qi pacman-contrib &>/dev/null; then
        echo -e "${GREEN}OK${NC} pacman-contrib installed (paccache available)"
    else
        echo -e "${NARTIC}!${NC} pacman-contrib not installed"
        echo -e "  ${NARTIC}- Install for paccache: sudo pacman -S pacman-contrib${NC}"
    fi
    
    echo ""
    echo -e "${NHYPRBLUE}mkinitcpio HOOKS:${NC}"
    if [ -f /etc/mkinitcpio.conf ]; then
        hooks=$(grep "^HOOKS=" /etc/mkinitcpio.conf | cut -d'=' -f2)
        echo -e "  $hooks"
        
        if lsmod | grep -q zfs 2>/dev/null; then
            if echo "$hooks" | grep -q "zfs"; then
                echo -e "${GREEN}OK${NC} ZFS hook present"
            else
                echo -e "${RED}x${NC} ZFS module loaded but hook missing!"
            fi
        fi
    fi
    
    echo ""
draw_border
    echo -e "${WHITE}3. SERVICES STATUS${NC}"
draw_border
    echo ""
    
    failed_services=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
    if [ "$failed_services" -gt 0 ]; then
        echo -e "${RED}x $failed_services failed service(s) detected!${NC}"
        systemctl --failed --no-legend 2>/dev/null | head -5
    else
        echo -e "${GREEN}OK${NC} No failed services"
    fi
}

hardware_detection() {
    clear
    echo ""
    draw_box "       HARDWARE DETECTION            "
    echo ""
    
draw_border
    echo -e "${WHITE}CPU INFORMATION${NC}"
draw_border
    echo ""
    
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    cpu_vendor=$(grep "vendor_id" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    cpu_cores=$(nproc)
    cpu_threads=$(grep -c "processor" /proc/cpuinfo)
    
    echo -e "${NHYPRBLUE}Model:${NC}        $cpu_model"
    echo -e "${NHYPRBLUE}Vendor:${NC}       $cpu_vendor"
    echo -e "${NHYPRBLUE}Cores:${NC}        $cpu_cores"
    echo -e "${NHYPRBLUE}Threads:${NC}      $cpu_threads"
    
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo -e "${NHYPRBLUE}Governor:${NC}     $governor"
    fi
    
    echo ""
draw_border
    echo -e "${WHITE}GPU INFORMATION${NC}"
draw_border
    echo ""
    
    if command -v lspci &>/dev/null; then
        echo -e "${NHYPRBLUE}Detected GPUs:${NC}"
        lspci | grep -i 'vga\|3d\|display' | while read -r line; do
            echo -e "  ${BLUE}*${NC} $(echo "$line" | cut -d':' -f3 | xargs)"
        done
        
        echo ""
        echo -e "${NHYPRBLUE}GPU Driver Status:${NC}"
        
        if lspci | grep -qi nvidia; then
            if pacman -Qi nvidia-dkms &>/dev/null || pacman -Qi nvidia &>/dev/null; then
                echo -e "  ${GREEN}OK${NC} NVIDIA proprietary driver installed"
            else
                echo -e "  ${NARTIC}!${NC} NVIDIA card detected but no proprietary driver"
            fi
        fi
        
        if lspci | grep -qi "amd\|radeon"; then
            echo -e "  ${GREEN}OK${NC} AMD GPU uses built-in amdgpu driver"
            if pacman -Qi vulkan-radeon &>/dev/null; then
                echo -e "  ${GREEN}OK${NC} Vulkan RADV driver installed"
            fi
        fi
        
        if lspci | grep -qi "intel.*graphics"; then
            echo -e "  ${GREEN}OK${NC} Intel GPU uses built-in i915 driver"
        fi
    fi
    
}

kernel_driver_status() {
    clear
    echo ""
    draw_box "      KERNEL & DRIVER STATUS         "
    echo ""
    
    draw_border
    echo -e "${WHITE}KERNEL INFORMATION${NC}"
    draw_border
    echo ""
    
    echo -e "${NHYPRBLUE}Running:${NC}  $(uname -r)"
    echo -e "${NHYPRBLUE}Version:${NC}  $(uname -v)"
    
    echo ""
    echo -e "${NHYPRBLUE}Installed Kernels:${NC}"
    pacman -Qq | grep -E "vmlinuz-linux" | grep -v headers | while read -r kernel; do
        version=$(pacman -Qi "$kernel" 2>/dev/null | grep "Version" | cut -d':' -f2 | xargs)
        echo -e "  ${BLUE}*${NC} $kernel - $version"
    done
    
    echo ""
    draw_border
    echo -e "${WHITE}KEY LOADED MODULES${NC}"
    draw_border
    echo ""
    
    important_modules=("zfs" "nvidia" "amdgpu" "i915" "snd_hda_intel" "btusb" "iwlwifi")
    for mod in "${important_modules[@]}"; do
        if lsmod | grep -q "^$mod"; then
            echo -e "  ${GREEN}OK${NC} $mod"
        fi
    done
    
    echo ""
    draw_border
    echo -e "${WHITE}KERNEL PARAMETERS${NC}"
    draw_border
    echo ""
    
    echo -e "${NHYPRBLUE}Current cmdline:${NC}"
    cat /proc/cmdline | fold -s -w 60
}

missing_components_check() {
    clear
    echo ""
    draw_box "     MISSING COMPONENTS CHECK        "
    echo ""
    
    echo -e "${WHITE}Checking for recommended Nordix components...${NC}"
    echo ""
    
    draw_border
    echo -e "${WHITE}MICROCODE${NC}"
    draw_border
    echo ""
    
    cpu_vendor=$(grep -m1 "vendor_id" /proc/cpuinfo | cut -d':' -f2 | xargs)
    if [[ "$cpu_vendor" == *"Intel"* ]]; then
        if pacman -Qi intel-ucode &>/dev/null; then
            echo -e "  ${GREEN}$OK{NC} intel-ucode installed"
        else
            echo -e "  ${RED}x${NC} intel-ucode ${RED}MISSING - SECURITY RISK${NC}"
            echo -e "      ${NARTIC} sudo pacman -S intel-ucode${NC}"
        fi
    elif [[ "$cpu_vendor" == *"AMD"* ]]; then
        if pacman -Qi amd-ucode &>/dev/null; then
            echo -e "  ${GREEN}$OK{NC} amd-ucode installed"
        else
            echo -e "  ${RED}$x{NC} amd-ucode ${RED}MISSING - SECURITY RISK${NC}"
            echo -e "      ${NARTIC} sudo pacman -S amd-ucode${NC}"
        fi
    fi
    
    echo ""
    draw_border
    echo -e "${WHITE}ESSENTIAL PACKAGES${NC}"
    draw_border
    echo ""
    
    essential=("base-devel" "git" "paru" "linux-firmware")
    for pkg in "${essential[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -e "  ${GREEN}OK${NC} $pkg"
        else
            echo -e "  ${RED}x${NC} $pkg ${RED}(MISSING)${NC}"
        fi
    done
    
    echo ""
    draw_border
    echo -e "${WHITE}MAINTENANCE TOOLS${NC}"
    draw_border
    echo ""
    
    maintenance=("pacman-contrib" "pkgfile" "htop" "btop")
    for pkg in "${maintenance[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -e "  ${GREEN}$OK{NC} $pkg"
        else
            echo -e "  ${NARTIC}$x{NC} $pkg (recommended)"
        fi
    done
}

storage_filesystem_info() {
    clear
    echo ""
    draw_box "     STORAGE & FILESYSTEM INFO       "
    echo ""
    
    draw_border
    echo -e "${WHITE}DISK USAGE${NC}"
    draw_border
    echo ""
    
    df -h -x tmpfs -x devtmpfs 2>/dev/null | head -15
    
    echo ""
    draw_border
    echo -e "${WHITE}BLOCK DEVICES${NC}"
    draw_border
    echo ""
    
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT 2>/dev/null | head -15
    
    if command -v zpool &>/dev/null; then
        echo ""
    draw_border
        echo -e "${WHITE}ZFS POOLS${NC}"
    draw_border
        echo ""
        
        zpool list 2>/dev/null
        
        echo ""
        echo -e "${NHYPRBLUE}ZFS Datasets:${NC}"
        zfs list -o name,used,avail,refer,mountpoint 2>/dev/null | head -10
    fi
}

security_status_overview() {
    clear
    echo ""
    draw_box "       SECURITY STATUS OVERVIEW      "
    echo ""
    
    draw_border
    echo -e "${WHITE}FIREWALL STATUS${NC}"
    draw_border
    echo ""
    
    if command -v ufw &>/dev/null; then
        if systemctl is-active ufw &>/dev/null; then
            echo -e "  ${GREEN}OK${NC} UFW firewall is active"
        else
            echo -e "  ${NARTIC}!${NC} UFW installed but not active"
        fi
    else
        echo -e "  ${NARTIC}!${NC} No firewall detected"
    fi
    
    echo ""
draw_border
    echo -e "${WHITE}RECENT SECURITY UPDATES${NC}"
draw_border
    echo ""
    
    last_update=$(grep "starting full system upgrade" /var/log/pacman.log 2>/dev/null | tail -1 | cut -d']' -f1 | tr -d '[')
    if [ -n "$last_update" ]; then
        echo -e "${NHYPRBLUE}Last system update:${NC} $last_update"
    fi
    
    updates_available=$(checkupdates 2>/dev/null | wc -l)
    if [ "$updates_available" -gt 0 ]; then
        echo -e "${NARTIC}!${NC} $updates_available updates available"
    else
        echo -e "${GREEN}OK${NC} System is up to date"
    fi
}

# ============================================
# OPTION 15: BOOT OPTIMIZATION
# ============================================
boot_optimization() {
    clear
    echo ""
    draw_box "    BOOT OPTIMIZATION - NORDIX       "
    echo ""

    echo -e "${WHITE}Select analysis type:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Boot Time Analysis ${NHYPRBLUE}(systemd-analyze)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Slowest Services ${NHYPRBLUE}blame)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Critical Chain Analysis${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Disable Unnecessary Services${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Generate Boot Graph ${NHYPRBLUE}(SVG)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-6):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read boot_option
    
    case $boot_option in
        1) boot_time_analysis ;;
        2) boot_blame_analysis ;;
        3) boot_critical_chain ;;
        4) disable_unnecessary_services ;;
        5) generate_boot_graph ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    press_enter
}

boot_time_analysis() {
    clear
    echo ""
    draw_box "       BOOT TIME ANALYSIS            "
    echo ""
    
draw_border
    echo -e "${WHITE}CURRENT BOOT TIME${NC}"
draw_border
    echo ""
    
    systemd-analyze
    
    echo ""
    boot_info=$(systemd-analyze 2>/dev/null)
    total_time=$(echo "$boot_info" | grep -oP '= \d+\.\d+s' | grep -oP '\d+\.\d+')
    
    if [ -n "$total_time" ]; then
        total_int=${total_time%.*}
draw_border
        if [ "$total_int" -lt 5 ]; then
            echo -e "${GREEN} Excellent boot time! Under 5 seconds. ${NC}"
        elif [ "$total_int" -lt 10 ]; then
            echo -e "${GREEN} Good boot time. Under 10 seconds.${NC}"
        elif [ "$total_int" -lt 20 ]; then
            echo -e "${NARTIC} Acceptable boot time. Could be improved.${NC}"
        else
            echo -e "${RED} Slow boot time. Optimization recommended.${NC}"
        fi
    fi
}

boot_blame_analysis() {
    clear
    echo ""
    draw_box "    SLOWEST BOOT SERVICES (BLAME)    "
    echo ""
    
    echo -e "${WHITE}Top 25 slowest services during boot:${NC}"
    echo ""
draw_border
    echo ""
    
    systemd-analyze blame | head -25
    
    echo ""
draw_border
    echo ""
    echo -e "${WHITE}Services taking >5s should be investigated.${NC}"
    echo -e "${WHITE}Consider disabling unnecessary services.${NC}"
}

boot_critical_chain() {
    clear
    echo ""
    draw_box "     BOOT CRITICAL CHAIN             "
    echo ""
    
    echo -e "${WHITE}Services in the critical boot path:${NC}"
    echo ""
draw_border
    echo ""
    
    systemd-analyze critical-chain
    
    echo ""
draw_border
    echo ""
    echo -e "${WHITE}The '@' shows time when service started.${NC}"
    echo -e "${WHITE}The '+' shows how long it took.${NC}"
}



disable_unnecessary_services() {
    clear
    echo ""
    draw_box "   DISABLE UNNECESSARY SERVICES      "
    echo ""
    draw_border   
    echo -e "${WHITE}Common services that may be disabled, please google them before you disable them:${NC}"
    draw_border
    services=("bluetooth.service" "cups.service" "avahi-daemon.service" "postfix.service" "sendmail.service" "ModemManager.service" "lvm2-monitor.sercvice" "lvm2-lvmpolld.socket" "iscsi.service" "nfs-client.target" "iscsid.service")
    
    for svc in "${services[@]}"; do
        if systemctl is-enabled "$svc" &>/dev/null; then
            echo -e "${NHYPRBLUE}$svc${NC} - ${GREEN}enabled${NC}"
        fi
    done
    
    echo ""
    echo -e "${WHITE}Enter service name to disable (or 'q' to quit):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read service_name
    
    if [ "$service_name" != "q" ] && [ -n "$service_name" ]; then
        if confirm_action "Disable $service_name?"; then
            sudo systemctl disable "$service_name"
            sudo systemctl stop "$service_name" 2>/dev/null
            echo -e "${GREEN}OK${NC} $service_name disabled"
        fi
    fi
}

generate_boot_graph() {
    clear
    echo ""
    draw_box "       GENERATE BOOT GRAPH           "
    echo ""
    
    output_file="$HOME/boot-analysis-$(date +%Y%m%d-%H%M%S).svg"
    
    if confirm_action "Generate boot graph to $output_file?"; then
        systemd-analyze plot > "$output_file"
        echo ""
        echo -e "${GREEN}OK${NC} Boot graph saved to: ${NARTIC}$output_file${NC}"
        echo -e "${WHITE}Open with a web browser to see the visualization.${NC}"
    fi
}

# ============================================
# OPTION 16: AUR SECURITY CHECK
# ============================================
aur_security_check() {
    clear
    echo ""
    draw_box "    AUR SECURITY CHECK - NORDIX      "
    echo ""
    draw_border
    echo -e "${WHITE}Select security check:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Check AUR package before install${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Audit installed AUR packages${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}View PKGBUILD of AUR package${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}AUR Security Best Practices${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read aur_option
    
    case $aur_option in
        1) check_aur_package_security ;;
        2) audit_installed_aur ;;
        3) view_aur_pkgbuild ;;
        4) aur_security_practices ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    press_enter
}

check_aur_package_security() {
    clear
    echo ""
    draw_box "   CHECK AUR PACKAGE SECURITY        "
    echo ""
    
    echo -e "${WHITE}Enter AUR package name to check:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read aur_pkg
    
    if [ -z "$aur_pkg" ]; then
        echo -e "${RED}No package name entered!${NC}"
        return
    fi
    
    echo ""
    echo -e "${WHITE}Fetching information for: ${NARTIC}$aur_pkg${NC}"
    echo ""
    
    aur_info=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg=$aur_pkg")
    
    if echo "$aur_info" | grep -q '"resultcount":0'; then
        echo -e "${RED}Package not found in AUR!${NC}"
        return
    fi
    
draw_border
    echo -e "${WHITE}PACKAGE INFORMATION${NC}"
draw_border
    echo ""
    
    name=$(echo "$aur_info" | grep -oP '"Name":"\K[^"]+')
    version=$(echo "$aur_info" | grep -oP '"Version":"\K[^"]+')
    maintainer=$(echo "$aur_info" | grep -oP '"Maintainer":"\K[^"]+')
    votes=$(echo "$aur_info" | grep -oP '"NumVotes":\K\d+')
    
    echo -e "${NHYPRBLUE}Name:${NC}        $name"
    echo -e "${NHYPRBLUE}Version:${NC}     $version"
    echo -e "${NHYPRBLUE}Maintainer:${NC}  ${maintainer:-${RED}ORPHANED${NC}}"
    echo -e "${NHYPRBLUE}Votes:${NC}       $votes"
    
    echo ""
draw_border
    echo -e "${WHITE}SECURITY ASSESSMENT${NC}"
draw_border
    echo ""
    
    if [ -z "$maintainer" ] || [ "$maintainer" = "null" ]; then
        echo -e "${RED}x${NC} Package is ORPHANED (no maintainer)"
    else
        echo -e "${GREEN}OK${NC} Has active maintainer"
    fi
    
    if [ "$votes" -lt 10 ]; then
        echo -e "${NARTIC}!${NC} Low vote count (<10) - less community review"
    elif [ "$votes" -gt 100 ]; then
        echo -e "${GREEN}OK${NC} High vote count (>100) - well reviewed"
    fi
    
    echo ""
    echo -e "${WHITE}Would you like to view the PKGBUILD? [Y/n]: ${NC}"
    read -r view_pkgbuild
    if [[ "$view_pkgbuild" =~ ^[yY]|$ ]]; then
        echo ""
        curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$aur_pkg" | head -80
        echo ""
        echo -e "${NARTIC}(Showing first 80 lines)${NC}"
    fi
}

audit_installed_aur() {
    clear
    echo ""
    draw_box "    AUDIT INSTALLED AUR PACKAGES     "
    echo ""
    
    echo -e "${WHITE}Checking all foreign (AUR) packages...${NC}"
    echo ""
    
    aur_packages=$(pacman -Qm)
    aur_count=$(echo "$aur_packages" | wc -l)
    
    echo -e "${NHYPRBLUE}Found $aur_count AUR/foreign packages${NC}"
    echo ""
    
    echo "$aur_packages" | head -20
    
    if [ "$aur_count" -gt 20 ]; then
        echo ""
        echo -e "${NARTIC}(Showing first 20 of $aur_count)${NC}"
    fi
}

view_aur_pkgbuild() {
    clear
    echo ""
    draw_box "       VIEW AUR PKGBUILD             "
    echo ""
    
    echo -e "${WHITE}Enter AUR package name:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read aur_pkg
    
    if [ -z "$aur_pkg" ]; then
        echo -e "${RED}No package name entered!${NC}"
        return
    fi
    
    echo ""
    echo -e "${WHITE}Fetching PKGBUILD for: ${NARTIC}$aur_pkg${NC}"
    echo ""
draw_border
    echo ""
    
    curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$aur_pkg"
    
    echo ""
draw_border
    echo ""
    echo -e "${NARTIC}Look for suspicious commands like 'curl | bash'${NC}"
}

aur_security_practices() {
    clear
    echo ""
    draw_box "   AUR SECURITY BEST PRACTICES     "
  echo -e "${NHYPRBLUE}Heuristic checks only – not a security guarantee${NC}"
echo -e "${WHITE}Always review PKGBUILD and comments before installing AUR packages.${NC}"
echo ""
draw_border
    echo -e "${WHITE}1. ALWAYS REVIEW PKGBUILD${NC}"
draw_border
    echo ""
    echo -e "${NARTIC}paru -G package_name${NC}"
    echo -e "${NHYPRBLUE}❯ ${NC}${NARTIC}Downloads PKGBUILD for review${NC}"
    echo ""
    
draw_border
    echo -e "${WHITE}2. NORDIX PACKAGE PRIORITY${NC}"
draw_border
    echo ""
    echo -e "${WHITE}Arch-based systems make extensive use of shared libraries, a key component for efficiency and performance. With the first three options, you are using this system, so you should choose them first, if you don't like searching with pacman, you can use the cosmic app store to search for packages, but then install them with pacman or paru:${NC}"
    echo ""
    draw_border
    echo -e "${BLUE}1.${NC} ${NARTIC}CachyOS repos ${NHYPRBLUE}(optimized)${NC}"
    echo -e "${BLUE}2.${NC} ${NARTIC}AUR ${NHYPRBLUE}(only when necessary)${NC}"
    echo -e "${BLUE}2.${NC} ${NARTIC}Build from sorce ${NHYPRBLUE}(advance)${NC}"
    draw_border
    echo ""
    draw_border
    echo -e "${RED}Avoid:${NC}"
    echo -e "${BLUE}1${NC} ${NARTIC}AppImage ${NHYPRBLUE}(no system integration but much better than flatpak and snap)${NC}"
    echo -e "${BLUE}2${NC} ${NARTIC}Flatpak ${NHYPRBLUE}(bloat, sandboxing overhead)${NC}"
    echo -e "${BLUE}3${NC} ${NARTIC}Snap ${NHYPRBLUE}(proprietary, slow startup)${NC}"
    echo ""
    draw_border
    echo -e "${GREEN}Native packages = Better performance${NC}"
}

# OPTION 17: NETWORK DIAGNOSTICS

network_diagnostics() {
    clear
    echo ""
    draw_box "     NETWORK DIAGNOSTICS - NORDIX    "
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}Select diagnostic:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Quick Connectivity Check${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Show IP Addresses${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}DNS Resolution Test${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}WiFi Networks${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Restart Network Services${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}DNS Adblock ${NHYPRBLUE}(test & configure)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option (1-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read net_option
    
    case $net_option in
        1)
           quick_connectivity_check 
            ;;
        2)
           show_ip_addresses
            ;;
        3)
           dns_resolution_test
            ;;
        4) 
           wifi_networks
            ;;
        5) 
           restart_network_services
            ;;
        6) 
           dns_adblock_menu 
           ;;
        *) 
           echo -e "${RED}Invalid option!${NC}" ;;
    esac
    press_enter
}

quick_connectivity_check() {
    clear
    echo ""
    draw_box "     QUICK CONNECTIVITY CHECK        "
    echo ""
    
    echo -e "${WHITE}Testing network connectivity...${NC}"
    echo ""
    
draw_border
    echo -e "${WHITE}PING TESTS${NC}"
draw_border
    echo ""
    
    gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    if [ -n "$gateway" ]; then
        echo -ne "${WHITE}Gateway ($gateway): ${NC}"
        if ping -c 1 -W 2 "$gateway" &>/dev/null; then
            echo -e "${GREEN}OK OK${NC}"
        else
            echo -e "${RED}x FAILED${NC}"
        fi
    fi
    
    echo -ne "${WHITE}DNS (1.1.1.1): ${NC}"
    if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
        echo -e "${GREEN}OK OK${NC}"
    else
        echo -e "${RED}x FAILED${NC}"
    fi
    
    echo -ne "${WHITE}Internet (archlinux.org): ${NC}"
    if ping -c 1 -W 3 archlinux.org &>/dev/null; then
        echo -e "${GREEN}OK OK${NC}"
    else
        echo -e "${RED}x FAILED${NC}"
    fi
}

show_ip_addresses() {
    clear
    echo ""
    draw_box "        SHOW IP ADDRESSES            "
    echo ""
    
draw_border
    echo -e "${WHITE}NETWORK INTERFACES${NC}"
draw_border
    echo ""
    
    ip -br addr
    
    echo ""
draw_border
    echo -e "${WHITE}DEFAULT GATEWAY${NC}"
draw_border
    echo ""
    
    ip route | grep default
}

dns_resolution_test() {
    clear
    echo ""
    draw_box "       DNS RESOLUTION TEST           "
    echo ""
    
    echo -e "${WHITE}Testing DNS resolution...${NC}"
    echo ""
    
    domains=("archlinux.org" "google.com" "github.com")
    
    for domain in "${domains[@]}"; do
        echo -ne "${WHITE}$domain: ${NC}"
        if host "$domain" &>/dev/null; then
            ip=$(host "$domain" | grep "has address" | head -1 | awk '{print $4}')
            echo -e "${GREEN}OK${NC} $ip"
        else
            echo -e "${RED}x FAILED${NC}"
        fi
    done
    
    echo ""
    echo -e "${NHYPRBLUE}DNS Servers in use:${NC}"
    cat /etc/resolv.conf | grep nameserver
}

wifi_networks() {
    clear
    echo ""
    draw_box "         WIFI NETWORKS               "
    echo ""
    
    if command -v nmcli &>/dev/null; then
        echo -e "${WHITE}Available WiFi networks:${NC}"
        echo ""
        nmcli device wifi list
    else
        echo -e "${NARTIC}NetworkManager (nmcli) not found.${NC}"
        echo -e "${WHITE}Using iw instead:${NC}"
        echo ""
        sudo iw dev | grep Interface
    fi
}

restart_network_services() {
    clear
    echo ""
    draw_box "    RESTART NETWORK SERVICES         "
    echo ""
    draw_border
    echo -e "${WHITE}Available network services:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Restart NetworkManager${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Restart systemd-networkd${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Restart systemd-resolved${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Restart all network services${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option (1-4):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    draw_border
    read restart_opt
    
    case $restart_opt in
        1)
            if confirm_action "Restart NetworkManager?"; then
                sudo systemctl restart NetworkManager
                echo -e "${GREEN}[OK]${NC} NetworkManager restarted"
            fi
            ;;
        2)
            if confirm_action "Restart systemd-networkd?"; then
                sudo systemctl restart systemd-networkd
                echo -e "${GREEN}[OK]${NC} systemd-networkd restarted"
            fi
            ;;
        3)
            if confirm_action "Restart systemd-resolved?"; then
                sudo systemctl restart systemd-resolved
                echo -e "${GREEN}[OK]${NC} systemd-resolved restarted"
            fi
            ;;
        4)
            if confirm_action "Restart all network services?"; then
                sudo systemctl restart NetworkManager 2>/dev/null
                sudo systemctl restart systemd-networkd 2>/dev/null
                sudo systemctl restart systemd-resolved 2>/dev/null
                echo -e "${GREEN}[OK]${NC} All network services restarted"
            fi
            ;;
    esac
}

# NORDIX DNS ADBLOCK TEST


dns_adblock_test() {
    clear
    echo ""
    draw_box "       DNS ADBLOCK TEST             "
    echo ""
    draw_border
    echo -e "${WHITE}Testing if AdGuard DNS adblock is working...${NC}"
    draw_border
    echo ""

    # Domains that SHOULD be blocked (adblock is broken if these resolve)
  declare -A MUST_BLOCK=(
        ["doubleclick.net"]="Google Ads"
        ["googleadservices.com"]="Google Ad Services"
        ["pagead2.googlesyndication.com"]="Google Page Ads"
        ["pixel.facebook.com"]="Facebook Tracking"
        ["ad.doubleclick.net"]="DoubleClick Ads"
        ["adservice.google.com"]="Google Ad Service"
        ["analytics.tiktok.com"]="TikTok Analytics"
        ["tracking.epicgames.com"]="Epic Games Tracking"
        ["telemetry.microsoft.com"]="Microsoft Telemetry"
    )

    # Domains that CANNOT always be blocked (would break services)
  declare -A CANNOT_BLOCK=(
        ["graph.facebook.com"]="Facebook API - blocking breaks login on many sites"
        ["googlesyndication.com"]="Google base domain - only subdomains blocked"
        ["ads.spotify.com"]="Spotify - serves ads from same domain as content"
        ["ads.yahoo.com"]="Yahoo - not on AdGuard blocklist"
        ["telemetry.microsoft.com"]="Microsoft Telemetry - their business model"
        ["settings-win.data.microsoft.com"]="Windows Settings - deeply integrated"
        ["watson.telemetry.microsoft.com"]="Windows Error Reporting - Microsoft core"
    )

    blocked=0
    not_blocked=0
    total=${#MUST_BLOCK[@]}


# Test domains that MUST be blocked

    draw_border
    echo -e "${WHITE}Testing critical ad/tracking domains:${NC}"
    draw_border
    echo ""

    for domain in "${!MUST_BLOCK[@]}"; do
        description="${MUST_BLOCK[$domain]}"
        result=$(resolvectl query "$domain" 2>&1)

    if echo "$result" | grep -qiE "0\.0\.0\.0|^::\$|NXDOMAIN|Filtered|no-signature|not found"; then
       echo -e "${GREEN}[OK]${NC} ${NARTIC}$domain${NC}"
       echo -e "  ${NHYPRBLUE}❯${NC} ${WHITE}$description ${GREEN}(BLOCKED)${NC}"
            ((blocked++))
    else
            ip=$(echo "$result" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
       echo -e "${RED}[x]${NC} ${NARTIC}$domain${NC}"
       echo -e "  ${NHYPRBLUE}❯${NC} ${WHITE}$description ${RED}(NOT BLOCKED: $ip)${NC}"
            ((not_blocked++))
        fi
    done

    echo ""

 # Test domains that cannot always be blocked
    draw_border
    echo -e "${WHITE}Domains that cannot always be blocked:${NC}"
    echo -e "${NARTIC}(blocking these would break services)${NC}"
    draw_border
    echo ""

    for domain in "${!CANNOT_BLOCK[@]}"; do
        description="${CANNOT_BLOCK[$domain]}"
        result=$(resolvectl query "$domain" 2>&1)

        if echo "$result" | grep -qiE "0\.0\.0\.0|^::\$|NXDOMAIN|Filtered|no-signature|not found"; then
            echo -e "${GREEN}[OK]${NC} ${NARTIC}$domain${NC}"
            echo -e "  ${NHYPRBLUE}❯${NC} ${WHITE}$description ${GREEN}(BLOCKED)${NC}"
        else
            echo -e "${NARTIC}─${NC} ${NARTIC}$domain${NC}"
            echo -e "  ${NHYPRBLUE}❯${NC} ${WHITE}$description ${NARTIC}(allowed)${NC}"
        fi
    done

    echo ""

    # Results
    draw_border
    echo -e "${WHITE}RESULTS${NC}"
    draw_border
    echo ""
    echo -e "${GREEN}Blocked:${NC}     $blocked / $total critical domains"
    echo ""

    if [ "$total" -gt 0 ]; then
        percentage=$((blocked * 100 / total))
        
    if [ "$percentage" -eq 100 ]; then
            echo -e "${GREEN}[OK] Adblock is working perfectly!${NC}"
    elif [ "$percentage" -ge 80 ]; then
            echo -e "${GREEN}[OK] Adblock is working! ($percentage% blocked)${NC}"
    elif [ "$percentage" -ge 50 ]; then
            echo -e "${YELLOW}! Adblock partially working ($percentage% blocked)${NC}"
            echo -e "${WHITE}  Try reconfiguring DNS in the menu.${NC}"
    else
            echo -e "${RED}[X] Adblock is not working correctly ($percentage% blocked)${NC}"
            echo -e "${WHITE}  Run 'Reconfigure DNS' from the menu.${NC}"
        fi
    fi

    echo ""
    draw_border
    echo -e "${WHITE}DNS Configuration Status${NC}"
    draw_border
    echo ""

    # Show current DNS server
    current_dns=$(resolvectl status 2>/dev/null | grep "Current DNS Server" | head -1 | awk '{print $NF}')
    if [ -n "$current_dns" ]; then
        if echo "$current_dns" | grep -q "94.140"; then
            echo -e "${GREEN}[OK]${NC} ${WHITE}DNS Server: ${NARTIC}$current_dns ${NHYPRBLUE}(AdGuard)${NC}"
        else
            echo -e "${YELLOW}!${NC} ${WHITE}DNS Server: ${NARTIC}$current_dns ${NHYPRBLUE}(not AdGuard)${NC}"
        fi
    else
        echo -e "${RED}[X]${NC} ${WHITE}DNS Server: ${RED}Not detected${NC}"
    fi

    # Check encryption
    encrypted=$(resolvectl status 2>/dev/null | grep -i "DNSOverTLS" | head -1)
    if echo "$encrypted" | grep -qi "yes"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}DNS-over-TLS: ${GREEN}Encrypted${NC}"
    else
        echo -e "${RED}[X]${NC} ${WHITE}DNS-over-TLS: ${RED}Not encrypted${NC}"
    fi

    # Check DNSSEC
    dnssec=$(resolvectl status 2>/dev/null | grep -i "DNSSEC" | head -1)
    if echo "$dnssec" | grep -qi "yes"; then
        echo -e "${GREEN}[OK]${NC} ${WHITE}DNSSEC: ${GREEN}Enabled${NC}"
    else
        echo -e "${YELLOW}!${NC} ${WHITE}DNSSEC: ${NARTIC}Not verified${NC}"
    fi

    echo ""
    draw_border
    echo -e "${NARTIC}Note: Some domains cannot be blocked without breaking${NC}"
    echo -e "${NARTIC}services like Facebook login or embedded content.${NC}"
    echo -e "${NARTIC}For maximum ad blocking, also use uBlock Origin in your browser.${NC}"
    draw_border
}
# DNS ADBLOCK MENU


dns_adblock_menu() {
    clear
    echo ""
    draw_box "       NORDIX DNS ADBLOCK           "
    echo ""
    draw_border
    echo -e "${WHITE}DNS Adblock options:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Test adblock ${NHYPRBLUE}(check if blocking works)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Show DNS status${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Test custom domain${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Reconfigure DNS ${NHYPRBLUE}(fix if not working)${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Learn about DNS adblock${NC}"
    echo ""
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Back${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-5):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read dns_option

    case $dns_option in
        1) dns_adblock_test ;;
        2) dns_show_status ;;
        3) dns_test_custom ;;
        4) dns_reconfigure ;;
        5) dns_learn_adblock ;;
        0) return ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    press_enter
    dns_adblock_menu
}


# SHOW DNS STATUS


dns_show_status() {
    clear
    echo ""
    draw_box "         DNS STATUS                 "
    echo ""
    draw_border
    echo -e "${WHITE}Global DNS Configuration${NC}"
    draw_border
    echo ""
    
    resolvectl status | head -15
    
    echo ""
    draw_border
    echo -e "${WHITE}Active DNS Server${NC}"
    draw_border
    echo ""
    
    resolvectl status | grep -E "DNS Server|DNSOverTLS|DNSSEC" | head -10
}

# TEST CUSTOM DOMAIN


dns_test_custom() {
    clear
    echo ""
    draw_box "       TEST CUSTOM DOMAIN           "
    echo ""
    draw_border
    echo -e "${WHITE}Enter domain to test:${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read test_domain

    if [ -z "$test_domain" ]; then
        echo -e "${RED}No domain entered!${NC}"
        return
    fi

    echo ""
    echo -e "${WHITE}Testing: ${NARTIC}$test_domain${NC}"
    echo ""
    draw_border
    echo ""

    result=$(resolvectl query "$test_domain" 2>&1)
    echo "$result"

    echo ""
    draw_border
    echo ""

    if echo "$result" | grep -qiE "0\.0\.0\.0|^::\$|NXDOMAIN|Filtered|no-signature|not found"; then
        echo -e "${GREEN}[OK] Domain is BLOCKED by adblock${NC}"
    else
        echo -e "${RED}! Domain is NOT blocked ${NHYPRBLUE}(resolved normally)${NC}"
    fi
}

# RECONFIGURE DNS

dns_reconfigure() {
    clear
    echo ""
    draw_box "       RECONFIGURE DNS              "
    echo ""
    draw_border
    echo -e "${WHITE}This will reconfigure Nordix Adblock DNS${NC}"
    draw_border
    echo ""

    if confirm_action "Reconfigure DNS with AdGuard adblock?"; then
        echo ""
        echo -e "${WHITE}Creating resolved configuration...${NC}"
        
        sudo mkdir -p /etc/systemd/resolved.conf.d
        sudo tee /etc/systemd/resolved.conf.d/nordix-dns.conf > /dev/null << 'EOF'
[Resolve]
DNS=94.140.14.14#dns.adguard-dns.com
DNS=94.140.15.15#dns.adguard-dns.com
FallbackDNS=1.1.1.2#security.cloudflare-dns.com
FallbackDNS=9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
Cache=yes
CacheFromLocalhost=yes
EOF

        echo -e "${WHITE}Creating NetworkManager configuration...${NC}"
        
        sudo mkdir -p /etc/NetworkManager/conf.d
        sudo tee /etc/NetworkManager/conf.d/nordix-dns.conf > /dev/null << 'EOF'
[main]
dns=systemd-resolved

[connection]
ipv4.ignore-auto-dns=true
ipv6.ignore-auto-dns=true
EOF

        echo -e "${WHITE}Linking resolv.conf...${NC}"
        sudo rm -f /etc/resolv.conf
        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

        echo -e "${WHITE}Configuring network connections...${NC}"
        
        for CONN in $(nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep -E "ethernet|wifi" | cut -d: -f1); do
            sudo nmcli connection modify "$CONN" ipv4.ignore-auto-dns yes 2>/dev/null
            sudo nmcli connection modify "$CONN" ipv6.ignore-auto-dns yes 2>/dev/null
            sudo nmcli connection modify "$CONN" ipv4.dns "94.140.14.14 94.140.15.15" 2>/dev/null
            echo -e "${NARTIC}  Configured: $CONN${NC}"
        done

        echo -e "${WHITE}Restarting services...${NC}"
        sudo systemctl restart systemd-resolved
        sudo systemctl restart NetworkManager

        # Reconnect active connection
        ACTIVE=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -1)
        if [ -n "$ACTIVE" ]; then
            echo -e "${WHITE}Reconnecting: $ACTIVE${NC}"
            sudo nmcli connection down "$ACTIVE" 2>/dev/null
            sleep 2
            sudo nmcli connection up "$ACTIVE" 2>/dev/null
        fi

        echo ""
        echo -e "${GREEN}[ok] DNS reconfigured!${NC}"
        echo ""
        echo -e "${WHITE}Run adblock test to verify it's working.${NC}"
    fi
}


# LEARN ABOUT DNS ADBLOCK
dns_learn_adblock() {
    clear
    echo ""
    draw_box "     UNDERSTANDING DNS ADBLOCK      "
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS DNS ADBLOCK?${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}DNS adblock works by returning fake IPs for ad domains.${NC}"
    echo -e "${WHITE}When your browser tries to load an ad, it gets blocked.${NC}"
    echo ""
    echo -e "${NARTIC}Example:${NC}"
    echo -e "${WHITE}  You visit: news-site.com${NC}"
    echo -e "${WHITE}  Site tries to load: ads.google.com${NC}"
    echo -e "${WHITE}  AdGuard returns: 0.0.0.0 ${NHYPRBLUE}(blocked!)${NC}"
    echo -e "${WHITE}  Result: No ads loaded${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}WHAT NORDIX BLOCKS${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Advertising networks${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Tracking pixels${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Analytics services${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Malware domains${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Phishing sites${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}WHAT IS NOT BLOCKED${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Some domains are not blocked to avoid breaking services:${NC}"
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}ads.google.com ${WHITE}- would break Google services${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}YouTube ads ${WHITE}- served from same domain as videos${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Sponsored content ${WHITE}- embedded in pages${NC}"
    echo ""
    draw_border
    echo -e "${WHITE}ADDITIONAL BLOCKING${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}For more blocking, use a browser extension:${NC}"
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}uBlock Origin ${WHITE}- best ad blocker${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Privacy Badger ${WHITE}- tracker blocking${NC}"
    echo ""
    echo -e "${WHITE}DNS + Browser extension = maximum protection${NC}"
}

# OPTION 18:  ABOUT NORDIX   



about_nordix() {
    clear
    echo ""
    echo ""
    echo -e "${NHYPRBLUE}    ____  ___ ______ _______ _______ ____________    ____   ${NC}"
    echo -e "${NGLACIER}    |  \ |  |/  __  \|  __  \|   __ \ \_    _/\  \  /  /    ${NC}"
    echo -e "${NGLACIER}    |   \|  |  |  |  | |__)  |  |  | |  |  |   \  \/  /     ${NC}"
    echo -e "${NGLACIER}    |  |\   |  |__|  |  __  <|  |__| | _|  |_  /  /\  \     ${NC}"
    echo -e "${NGLACIER}  --|__| \__|\______/|__| \__|______/ /______\/__/  \__\-- ${NC}"
    echo -e "${NVBLUE}.__________________________________________________________.${NC}"
    echo -e "${NVBLUE}...........................     ............................${NC}"
    echo -e "${NVBLUE}.................                     ...................${NC}"
    echo -e "${NARTIC}..........                                ............${NC}"
    echo -e "${NVBLUE}......                                     ......${NC}"
    echo -e "${NGLACIER}...                                       ...${NC}"
    echo -e "${BLUE}.                                       .${NC}"
    echo ""
    draw_box "      What is Nordix        "
    echo ""  
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Performance-focused Arch Linux with tools to empower new users and showcase Linux's true potential.
To share the so-called "Linux Power User" experience to everyone and the goal to build a community for us who have systems as a hobby. ${NC}"  
    echo ""
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC} My Enthusiast View on Nordix and Yggdrasil

 - The purpose of truth - a desire to find friends

I have a vision of a platform to unite enthusiasts

 - There are many enthusiasts who spend all their time on their projects, thousands of hours.
 - Projects that are so good that you can't believe it's true!
 - Sadly, many of these projects will never find a place in a mainstream Linux distro.

Nordix is what I'm building with the vision to change this

Instead of projects ending up in a corner on AUR and never getting a fair chance,
I would like to create a platform where we can all share our common interests.
I am not a project manager, I have built Nordix to be your host.
I don't want other people's projects to be swallowed up by Nordix and the developers to be hidden and forgotten.

 - I therefore want everyone who wants to participate with their projects to keep their own repos.
 - I want everyone to continue to be project leaders for their own projects,
  the only difference is that they have been given a home: "Nordix"
 - Instead, I plan to list each project participant's project first in the Nordix repo,
  with thanks for the contribution and link to the original repo
 - I have a vision of us creating our own platform where we can discuss our interests.

'Even though the project is free of charge
 we are all responsible for paying by showing respect.
Jimmy Källhagen – Nordix_' 
${NC}"
    draw_border
    back_action
}

# ============================================
# MAIN LOOP
# ============================================
while true; do
    show_menu
    echo ""
    echo -e "${WHITE}Enter your choice (0-18):${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read choice
    
    case $choice in
        1) 
            update_system
            ;;
        2) 
            system_maintenance
            ;;
        3)
            system_repair
            ;;
        4)
            system_service   
            ;;
        5)
            install_package         
            ;;
        6)
            search_packages
            ;;
        7)
            remove_package
            ;;
        8)  
            list_package_files
            ;;
        9)
            package_info
            ;;
        10)
            show_installed
            ;;
        11) 
            search_installed
            ;;
        12) 
            show_history
            ;;
        13)
            learn_commands
            ;;
        14)
            system_information
            ;;
        15)
            boot_optimization
            ;;
        16)
            aur_security_check
            ;;
        17)
            network_diagnostics
            ;;
        18)
           about_nordix
            ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye and hope you enjoyed Nordix Arch Helper!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please enter a number between 0 and 18.${NC}"
            sleep 2
            ;;
    esac
done
