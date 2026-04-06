#!/bin/bash
##============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                      #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0  #
 # Copyright (c) 2025 Jimmy Källhagen                                         #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                     #
##============================================================================##
# zfs-helper.sh - User-friendly ZFS management helper
# Version 1.0 - Nordix Edition
# Features: ZFS/ZPool management, snapshots, datasets, scrub, ARC monitoring
#
# ============================================
# CONFIGURATION - Nordix Theme Colors
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
# STARTUP CHECK - Verify ZFS is available
# ============================================
startup_check() {
    if ! command -v zfs &>/dev/null; then
        clear
        echo ""
        draw_border
        echo -e "${RED}          ZFS NOT INSTALLED            ${NC}"
        draw_border
        echo ""
        echo -e "${WHITE}Nordix ZFS Helper requires ${NARTIC}zfs-utils${WHITE} to function.${NC}"
        echo ""
        echo -e "${WHITE}Would you like to install ZFS now? [Y/n]: ${NC}"
        read -r install_zfs

        case "$install_zfs" in
            [yY]|[yY][eE][sS]|"")
                echo ""
                echo -e "${WHITE}Installing ZFS...${NC}"
                sudo pacman -S --needed zfs-utils

                if command -v zfs &>/dev/null; then
                    echo ""
                    echo -e "${GREEN}[OK] ZFS installed successfully!${NC}"
                    press_enter
                else
                    echo ""
                    echo -e "${RED}[X] ZFS installation failed!${NC}"
                    exit 1
                fi
                ;;
            *)
                echo ""
                echo -e "${RED}ZFS is required for Nordix ZFS Helper.${NC}"
                exit 1
                ;;
        esac
    fi

    # Check if ZFS kernel module is loaded
    if ! lsmod | grep -q "^zfs"; then
        echo -e "${YELLOW}! ZFS kernel module not loaded. Loading...${NC}"
        sudo modprobe zfs 2>/dev/null || {
            echo -e "${RED}[X] Failed to load ZFS module!${NC}"
            echo -e "${WHITE}You may need to reboot or install ZFS DKMS.${NC}"
            press_enter
        }
    fi
}

# ============================================
# HELPER FUNCTIONS
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
    echo -ne "${NHYPRBLUE}Press Enter to continue...${NC}"
    read
}

back_to_menu() {
    echo ""
    echo -ne "${WHITE}Press Enter to go back to menu...${NC}"
    read
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
    draw_box "          Nordix ZFS Helper          "
    echo ""
    echo ""

    draw_border
    echo -e "${WHITE}What would you like to do?${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}ZFS Quick Status${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Pool Management ${NGLACIER}- ${NHYPRBLUE}(zpool)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Dataset Management ${NGLACIER}- ${NHYPRBLUE}(zfs)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Snapshot Management${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Scrub & Health Check${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}ARC Cache Monitor ${NGLACIER}- ${NHYPRBLUE}(Performance)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}ZFS Properties & Tuning${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Create New Pool${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Boot Environments ${NGLACIER}- ${NHYPRBLUE}(ZFSBootMenu)${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Learn ZFS Commands ${NGLACIER}- ${NHYPRBLUE}(Educational)${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Nordix ZFS Tuning Guide${NC}"
    echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Troubleshooting${NC}"
    echo ""
    echo -e "${BLUE} 0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-12):${NC}"
    echo ""
}

# ============================================
# 1. ZFS QUICK STATUS
# ============================================
zfs_quick_status() {
    clear
    echo ""
    draw_box "          ZFS QUICK STATUS           "
    echo ""

    draw_border
    echo -e "${WHITE}POOL STATUS${NC}"
    draw_border
    echo ""

    if zpool list &>/dev/null; then
        zpool list
        echo ""

        # Check pool health
        pool_health=$(zpool status -x 2>/dev/null)
        if [[ "$pool_health" == "all pools are healthy" ]]; then
            echo -e "${GREEN}[OK] All pools are healthy${NC}"
        else
            echo -e "${YELLOW}! Pool issues detected:${NC}"
            zpool status -x
        fi
    else
        echo -e "${YELLOW}! No ZFS pools found${NC}"
    fi

    echo ""
    draw_border
    echo -e "${WHITE}DATASET USAGE${NC}"
    draw_border
    echo ""

    zfs list -o name,used,avail,refer,mountpoint 2>/dev/null | head -20 || echo -e "${NARTIC}No datasets found${NC}"

    echo ""
    draw_border
    echo -e "${WHITE}ARC CACHE SUMMARY${NC}"
    draw_border
    echo ""




    if [ -f /proc/spl/kstat/zfs/arcstats ]; then
        arc_size=$(awk '/^size/ {print $3}' /proc/spl/kstat/zfs/arcstats 2>/dev/null)
        arc_max=$(awk '/^c_max/ {print $3}' /proc/spl/kstat/zfs/arcstats 2>/dev/null)
        arc_hits=$(awk '/^hits/ {print $3}' /proc/spl/kstat/zfs/arcstats 2>/dev/null)
        arc_misses=$(awk '/^misses/ {print $3}' /proc/spl/kstat/zfs/arcstats 2>/dev/null)

        if [ -n "$arc_size" ] && [ -n "$arc_max" ]; then
            arc_size_gb=$(echo "scale=2; $arc_size / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
            arc_max_gb=$(echo "scale=2; $arc_max / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")

            echo -e "${NHYPRBLUE}ARC Size:${NC}     ${arc_size_gb} GB / ${arc_max_gb} GB"

            if [ -n "$arc_hits" ] && [ -n "$arc_misses" ]; then
                total=$((arc_hits + arc_misses))
                if [ "$total" -gt 0 ]; then
                    hit_rate=$(echo "scale=2; $arc_hits * 100 / $total" | bc 2>/dev/null || echo "N/A")
                    echo -e "${NHYPRBLUE}Hit Rate:${NC}     ${hit_rate}%"
                fi
            fi
        fi
    else
        echo -e "${NARTIC}ARC stats not available${NC}"
    fi

    echo ""
    draw_border
    echo -e "${WHITE}RECENT SNAPSHOTS${NC}"
    draw_border
    echo ""

    zfs list -t snapshot -o name,creation -s creation 2>/dev/null | tail -5 || echo -e "${NARTIC}No snapshots found${NC}"

    back_to_menu
}

# 2. POOL MANAGEMENT
pool_management() {
    clear
    echo ""
    draw_box "         POOL MANAGEMENT             "
    echo ""
    draw_border
    echo -e "${WHITE}Select pool operation:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}List all pools${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Show pool status ${NHYPRBLUE}(detailed)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Show pool I/O statistics${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Show pool history${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Export a pool${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Import a pool${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Upgrade pool features${NC}"
    echo -e "${BLUE}8${NC} ${NVFROST}-${NC} ${NARTIC}Show pool properties${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-8):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read pool_option

    case $pool_option in
        1)
            clear
            echo ""
            draw_box "           ALL ZFS POOLS             "
            echo ""
            draw_border
            echo ""
            zpool list -v
            ;;
        2)
            clear
            echo ""
            draw_box "        DETAILED POOL STATUS         "
            echo ""
            echo -e "${WHITE}Enter pool name ${NHYPRBLUE}(or press Enter for all):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            echo ""
            draw_border
            echo ""
            if [ -z "$pool_name" ]; then
                zpool status -v
            else
                zpool status -v "$pool_name"
            fi
            ;;
        3)
            clear
            echo ""
            draw_box "        POOL I/O STATISTICS          "
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Showing I/O stats ${NHYPRBLUE}(press Ctrl+C to stop):${NC}"
            echo ""
            zpool iostat -v 2 5
            ;;
        4)
            clear
            echo ""
            draw_box "           POOL HISTORY              "
            echo ""
            echo -e "${WHITE}Enter pool name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            echo ""
            draw_border
            echo ""
            if [ -n "$pool_name" ]; then
                zpool history "$pool_name" | tail -30
            else
                echo -e "${RED}No pool name entered!${NC}"
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "           EXPORT POOL               "
            echo ""
            echo -e "${WHITE}Available pools:${NC}"
            zpool list -H -o name
            echo ""
            echo -e "${WHITE}Enter pool name to export:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                if confirm_action "Export pool ${pool_name}?"; then
                    sudo zpool export "$pool_name" && echo -e "${GREEN}[OK] Pool exported${NC}" || echo -e "${RED}[X] Export failed${NC}"
                fi
            fi
            ;;
        6)
            clear
            echo ""
            draw_box "           IMPORT POOL               "
            echo ""
            echo -e "${WHITE}Searching for importable pools...${NC}"
            echo ""
            draw_border
            echo ""
            sudo zpool import
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter pool name to import ${NHYPRBLUE}(or leave empty to cancel):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                if confirm_action "Import pool ${pool_name}?"; then
                    sudo zpool import "$pool_name" && echo -e "${GREEN}[OK] Pool imported${NC}" || echo -e "${RED}[X] Import failed${NC}"
                fi
            fi
            ;;
        7)
            clear
            echo ""
            draw_box "        UPGRADE POOL FEATURES        "
            echo ""
            echo -e "${WHITE}Enter pool name to upgrade:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                echo ""
                echo -e "${WHITE}Current feature flags:${NC}"
                zpool get all "$pool_name" | grep feature
                echo ""
                if confirm_action "Upgrade pool ${pool_name} to latest features?"; then
                    sudo zpool upgrade "$pool_name" && echo -e "${GREEN}[OK] Pool upgraded${NC}" || echo -e "${RED}[X] Upgrade failed${NC}"
                fi
            fi
            ;;
        8)
            clear
            echo ""
            draw_box "         POOL PROPERTIES             "
            echo ""
            echo -e "${WHITE}Enter pool name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            echo ""
            draw_border
            echo ""
            if [ -n "$pool_name" ]; then
                zpool get all "$pool_name"
            else
                echo -e "${RED}No pool name entered!${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# 3. DATASET MANAGEMENT
dataset_management() {
    clear
    echo ""
    draw_box "        DATASET MANAGEMENT           "
    echo ""
    draw_border
    echo -e "${WHITE}Select dataset operation:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}List all datasets${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Create new dataset${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Destroy dataset${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Rename dataset${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Mount/Unmount dataset${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Show dataset properties${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Set dataset property${NC}"
    echo -e "${BLUE}8${NC} ${NVFROST}-${NC} ${NARTIC}Show space usage ${NHYPRBLUE}(detailed)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-8):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read ds_option

    case $ds_option in
        1)
            clear
            echo ""
            draw_box "          ALL DATASETS               "
            echo ""
            draw_border
            echo ""
            zfs list -o name,used,avail,refer,mountpoint,compression,compressratio
            ;;
        2)
            clear
            echo ""
            draw_box "        CREATE NEW DATASET           "
            echo ""
            echo -e "${WHITE}Current datasets:${NC}"
            zfs list -o name | head -10
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter new dataset name ${NHYPRBLUE}(e.g., pool/data):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            if [ -n "$ds_name" ]; then
                echo ""
                echo -e "${WHITE}Apply Nordix performance settings? ${NHYPRBLUE}[Y/n]:${NC}"
                read -r apply_nordix

                if [[ "$apply_nordix" =~ ^[nN] ]]; then
                    sudo zfs create "$ds_name" && echo -e "${GREEN}[OK] Dataset created${NC}"
                else
                    sudo zfs create \
                        -o compression=zstd \
                        -o atime=off \
                        -o relatime=on \
                        -o xattr=sa \
                        -o acltype=posixacl \
                        "$ds_name" && echo -e "${GREEN}[OK] Dataset created with Nordix settings${NC}"
                fi
            fi
            ;;
        3)
            clear
            echo ""
            draw_box "         DESTROY DATASET             "
            echo ""
            echo -e "${RED}WARNING: This will permanently delete the dataset!${NC}"
            echo ""
            echo -e "${WHITE}Current datasets:${NC}"
            zfs list -o name
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter dataset name to destroy:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            if [ -n "$ds_name" ]; then
                echo ""
                echo -e "${RED}Are you absolutely sure you want to destroy ${ds_name}?${NC}"
                echo -e "${WHITE}Type the dataset name again to confirm:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read confirm_name
                if [ "$ds_name" = "$confirm_name" ]; then
                    sudo zfs destroy "$ds_name" && echo -e "${GREEN}[OK] Dataset destroyed${NC}" || echo -e "${RED}[X] Destroy failed${NC}"
                else
                    echo -e "${YELLOW}! Names did not match. Cancelled.${NC}"
                fi
            fi
            ;;
        4)
            clear
            echo ""
            draw_box "         RENAME DATASET              "
            echo ""
            echo -e "${WHITE}Current datasets:${NC}"
            zfs list -o name
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter current dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read old_name
            echo -e "${WHITE}Enter new dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read new_name
            if [ -n "$old_name" ] && [ -n "$new_name" ]; then
                if confirm_action "Rename ${old_name} to ${new_name}?"; then
                    sudo zfs rename "$old_name" "$new_name" && echo -e "${GREEN}[OK] Dataset renamed${NC}"
                fi
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "       MOUNT/UNMOUNT DATASET         "
            echo ""
            echo -e "${WHITE}Current datasets:${NC}"
            zfs list -o name,mounted,mountpoint
            echo ""
            draw_border
            echo ""
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Mount dataset${NC}"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Unmount dataset${NC}"
            echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Mount all datasets${NC}"
            echo ""
            echo -ne "${NHYPRBLUE}> ${NC}"
            read mount_opt
            case $mount_opt in
                1)
                    echo -e "${WHITE}Enter dataset name to mount:${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read ds_name
                    [ -n "$ds_name" ] && sudo zfs mount "$ds_name" && echo -e "${GREEN}[OK] Mounted${NC}"
                    ;;
                2)
                    echo -e "${WHITE}Enter dataset name to unmount:${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read ds_name
                    [ -n "$ds_name" ] && sudo zfs unmount "$ds_name" && echo -e "${GREEN}[OK] Unmounted${NC}"
                    ;;
                3)
                    sudo zfs mount -a && echo -e "${GREEN}[OK] All datasets mounted${NC}"
                    ;;
            esac
            ;;
        6)
            clear
            echo ""
            draw_box "       DATASET PROPERTIES            "
            echo ""
            echo -e "${WHITE}Enter dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            echo ""
            draw_border
            echo ""
            [ -n "$ds_name" ] && zfs get all "$ds_name"
            ;;
        7)
            clear
            echo ""
            draw_box "       SET DATASET PROPERTY          "
            echo ""
            echo -e "${WHITE}Enter dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            echo ""
            echo -e "${WHITE}Common properties:${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${NARTIC}compression=zstd${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${NARTIC}atime=off${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${NARTIC}recordsize=128K${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=2${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${NARTIC}quota=100G${NC}"
            echo ""
            echo -e "${WHITE}Enter property=value:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read property
            if [ -n "$ds_name" ] && [ -n "$property" ]; then
                sudo zfs set "$property" "$ds_name" && echo -e "${GREEN}[OK] Property set${NC}"
            fi
            ;;
        8)
            clear
            echo ""
            draw_box "      DETAILED SPACE USAGE           "
            echo ""
            draw_border
            echo ""
            zfs list -o name,used,usedbysnapshots,usedbydataset,usedbychildren,avail
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# ============================================
# 4. SNAPSHOT MANAGEMENT
# ============================================
snapshot_management() {
    clear
    echo ""
    draw_box "       SNAPSHOT MANAGEMENT           "
    echo ""
    draw_border
    echo -e "${WHITE}Select snapshot operation:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}List all snapshots${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Create snapshot${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Create recursive snapshot ${NHYPRBLUE}(all children)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Delete snapshot${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Rollback to snapshot${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Clone snapshot to new dataset${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Compare snapshots ${NHYPRBLUE}(diff)${NC}"
    echo -e "${BLUE}8${NC} ${NVFROST}-${NC} ${NARTIC}Send snapshot to file ${NHYPRBLUE}(backup)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-8):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read snap_option

    case $snap_option in
        1)
            clear
            echo ""
            draw_box "          ALL SNAPSHOTS              "
            echo ""
            draw_border
            echo ""
            zfs list -t snapshot -o name,used,refer,creation -s creation
            ;;
        2)
            clear
            echo ""
            draw_box "         CREATE SNAPSHOT             "
            echo ""
            echo -e "${WHITE}Available datasets:${NC}"
            zfs list -o name -H
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            echo -e "${WHITE}Enter snapshot name ${NHYPRBLUE}(or press Enter for timestamp):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name

            if [ -z "$snap_name" ]; then
                snap_name="nordix-$(date +%Y%m%d-%H%M%S)"
            fi

            if [ -n "$ds_name" ]; then
                sudo zfs snapshot "${ds_name}@${snap_name}" && echo -e "${GREEN}[OK] Snapshot created: ${ds_name}@${snap_name}${NC}"
            fi
            ;;
        3)
            clear
            echo ""
            draw_box "     CREATE RECURSIVE SNAPSHOT       "
            echo ""
            echo -e "${WHITE}Available datasets:${NC}"
            zfs list -o name -H
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter parent dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            snap_name="nordix-$(date +%Y%m%d-%H%M%S)"

            if [ -n "$ds_name" ]; then
                if confirm_action "Create recursive snapshot ${ds_name}@${snap_name}?"; then
                    sudo zfs snapshot -r "${ds_name}@${snap_name}" && echo -e "${GREEN}[OK] Recursive snapshot created${NC}"
                fi
            fi
            ;;
        4)
            clear
            echo ""
            draw_box "         DELETE SNAPSHOT             "
            echo ""
            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name -H | tail -20
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter snapshot name to delete ${NHYPRBLUE}(full path):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name
            if [ -n "$snap_name" ]; then
                if confirm_action "Delete snapshot ${snap_name}?"; then
                    sudo zfs destroy "$snap_name" && echo -e "${GREEN}[OK] Snapshot deleted${NC}"
                fi
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "      ROLLBACK TO SNAPSHOT           "
            echo ""
            echo -e "${RED}WARNING: This will revert to the snapshot state!${NC}"
            echo -e "${RED}All changes after the snapshot will be lost!${NC}"
            echo ""
            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name,creation -s creation | tail -15
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter snapshot name to rollback to:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name
            if [ -n "$snap_name" ]; then
                if confirm_action "ROLLBACK to ${snap_name}? This cannot be undone!"; then
                    sudo zfs rollback -r "$snap_name" && echo -e "${GREEN}[OK] Rollback complete${NC}"
                fi
            fi
            ;;
        6)
            clear
            echo ""
            draw_box "      CLONE SNAPSHOT TO DATASET      "
            echo ""
            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name -H | tail -15
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter snapshot name to clone:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name
            echo -e "${WHITE}Enter name for new dataset:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read new_ds
            if [ -n "$snap_name" ] && [ -n "$new_ds" ]; then
                sudo zfs clone "$snap_name" "$new_ds" && echo -e "${GREEN}[OK] Clone created: ${new_ds}${NC}"
            fi
            ;;
        7)
            clear
            echo ""
            draw_box "        COMPARE SNAPSHOTS            "
            echo ""
            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name -H | tail -20
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter first snapshot:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap1
            echo -e "${WHITE}Enter second snapshot ${NHYPRBLUE}(or dataset for latest):${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap2
            echo ""
            draw_border
            echo ""
            if [ -n "$snap1" ] && [ -n "$snap2" ]; then
                zfs diff "$snap1" "$snap2" | head -50
            fi
            ;;
        8)
            clear
            echo ""
            draw_box "     SEND SNAPSHOT TO FILE           "
            echo ""
            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name -H | tail -15
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter snapshot name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name
            echo -e "${WHITE}Enter output file path:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read output_file
            if [ -n "$snap_name" ] && [ -n "$output_file" ]; then
                echo -e "${WHITE}Sending snapshot... This may take a while.${NC}"
                sudo zfs send "$snap_name" > "$output_file" && echo -e "${GREEN}[OK] Snapshot saved to ${output_file}${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# ============================================
# 5. SCRUB & HEALTH CHECK
# ============================================
scrub_health_check() {
    clear
    echo ""
    draw_box "       SCRUB & HEALTH CHECK          "
    echo ""
    draw_border
    echo -e "${WHITE}Select operation:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Start scrub on pool${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Check scrub status${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Stop running scrub${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Full health report${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Check for errors${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Clear error counters${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-6):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read scrub_option

    case $scrub_option in
        1)
            clear
            echo ""
            draw_box "           START SCRUB               "
            echo ""
            echo -e "${WHITE}Available pools:${NC}"
            zpool list -H -o name
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter pool name to scrub:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                echo ""
                echo -e "${WHITE}Starting scrub on ${NARTIC}${pool_name}${WHITE}...${NC}"
                sudo zpool scrub "$pool_name" && echo -e "${GREEN}[OK] Scrub started${NC}"
                echo ""
                echo -e "${NARTIC}Use option 2 to check progress${NC}"
            fi
            ;;
        2)
            clear
            echo ""
            draw_box "          SCRUB STATUS               "
            echo ""
            draw_border
            echo ""
            zpool status | grep -A 5 "scan:"
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Full status:${NC}"
            zpool status
            ;;
        3)
            clear
            echo ""
            draw_box "           STOP SCRUB                "
            echo ""
            echo -e "${WHITE}Enter pool name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                if confirm_action "Stop scrub on ${pool_name}?"; then
                    sudo zpool scrub -s "$pool_name" && echo -e "${GREEN}[OK] Scrub stopped${NC}"
                fi
            fi
            ;;
        4)
            clear
            echo ""
            draw_box "        FULL HEALTH REPORT           "
            echo ""
            draw_border
            echo -e "${WHITE}POOL STATUS${NC}"
            draw_border
            echo ""
            zpool status -v
            echo ""
            draw_border
            echo -e "${WHITE}POOL HEALTH CHECK${NC}"
            draw_border
            echo ""
            health=$(zpool status -x)
            if [[ "$health" == "all pools are healthy" ]]; then
                echo -e "${GREEN}[OK] $health${NC}"
            else
                echo -e "${RED}[X] Issues detected:${NC}"
                echo "$health"
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "         CHECK FOR ERRORS            "
            echo ""
            draw_border
            echo ""
            zpool status -v | grep -E "(ONLINE|DEGRADED|FAULTED|OFFLINE|REMOVED|UNAVAIL|errors:)"
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Checking for checksum errors...${NC}"
            zpool status | grep -E "^\s+[a-z]" | awk '{if ($4 > 0 || $5 > 0) print $1 ": READ=" $4 " WRITE=" $5 " CKSUM=" $6}'
            ;;
        6)
            clear
            echo ""
            draw_box "       CLEAR ERROR COUNTERS          "
            echo ""
            echo -e "${WHITE}Enter pool name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            if [ -n "$pool_name" ]; then
                if confirm_action "Clear error counters for ${pool_name}?"; then
                    sudo zpool clear "$pool_name" && echo -e "${GREEN}[OK] Error counters cleared${NC}"
                fi
            fi
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# 6. ARC CACHE MONITOR
arc_cache_monitor() {
    clear
    echo ""
    draw_box "        ARC CACHE MONITOR            "
    echo ""

    if [ ! -f /proc/spl/kstat/zfs/arcstats ]; then
        echo -e "${RED}[X] ARC stats not available${NC}"
        press_enter
        return
    fi

    draw_border
    echo -e "${WHITE}ARC STATISTICS${NC}"
    draw_border
    echo ""

    # Parse ARC stats
    arc_size=$(awk '/^size/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    arc_min=$(awk '/^c_min/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    arc_max=$(awk '/^c_max/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    arc_target=$(awk '/^c / {print $3}' /proc/spl/kstat/zfs/arcstats)
    arc_hits=$(awk '/^hits/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    arc_misses=$(awk '/^misses/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    mfu_size=$(awk '/^mfu_size/ {print $3}' /proc/spl/kstat/zfs/arcstats)
    mru_size=$(awk '/^mru_size/ {print $3}' /proc/spl/kstat/zfs/arcstats)

    # Convert to human readable
    arc_size_gb=$(echo "scale=2; $arc_size / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
    arc_min_gb=$(echo "scale=2; $arc_min / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
    arc_max_gb=$(echo "scale=2; $arc_max / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
    arc_target_gb=$(echo "scale=2; $arc_target / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")

    echo -e "${NHYPRBLUE}Current ARC Size:${NC}  ${arc_size_gb} GB"
    echo -e "${NHYPRBLUE}ARC Target:${NC}        ${arc_target_gb} GB"
    echo -e "${NHYPRBLUE}ARC Minimum:${NC}       ${arc_min_gb} GB"
    echo -e "${NHYPRBLUE}ARC Maximum:${NC}       ${arc_max_gb} GB"

    echo ""
    draw_border
    echo -e "${WHITE}CACHE EFFICIENCY${NC}"
    draw_border
    echo ""

    total_access=$((arc_hits + arc_misses))
    if [ "$total_access" -gt 0 ]; then
        hit_rate=$(echo "scale=2; $arc_hits * 100 / $total_access" | bc 2>/dev/null || echo "N/A")
        miss_rate=$(echo "scale=2; $arc_misses * 100 / $total_access" | bc 2>/dev/null || echo "N/A")

        echo -e "${NHYPRBLUE}Total Accesses:${NC}    $total_access"
        echo -e "${NHYPRBLUE}Cache Hits:${NC}        $arc_hits"
        echo -e "${NHYPRBLUE}Cache Misses:${NC}      $arc_misses"
        echo -e "${NHYPRBLUE}Hit Rate:${NC}          ${hit_rate}%"

        hit_int=${hit_rate%.*}
        if [ "$hit_int" -gt 90 ]; then
            echo -e "${GREEN}[OK] Excellent cache efficiency!${NC}"
        elif [ "$hit_int" -gt 70 ]; then
            echo -e "${YELLOW}! Good cache efficiency${NC}"
        else
            echo -e "${RED}[X] Low cache efficiency - consider increasing ARC${NC}"
        fi
    fi

    echo ""
    draw_border
    echo -e "${WHITE}MRU/MFU BREAKDOWN${NC}"
    draw_border
    echo ""

    mfu_gb=$(echo "scale=2; $mfu_size / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
    mru_gb=$(echo "scale=2; $mru_size / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "N/A")

    echo -e "${NHYPRBLUE}MFU ${NC}${NARTIC}(Most Frequently Used):${NC}  ${mfu_gb} GB"
    echo -e "${NHYPRBLUE}MRU ${NC}${NARTIC}(Most Recently Used):${NC}    ${mru_gb} GB"

    echo ""
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Live ARC monitor ${NHYPRBLUE}(arcstat)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Full ARC stats dump${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Back to menu${NC}"
    echo ""
    echo -ne "${NHYPRBLUE}> ${NC}"
    read arc_opt

    case $arc_opt in
        1)
            if command -v arcstat &>/dev/null; then
                echo ""
                echo -e "${WHITE}Press Ctrl+C to stop${NC}"
                arcstat 2 10
            else
                echo -e "${YELLOW}! arcstat not found. Install with: sudo pacman -S zfs-utils${NC}"
            fi
            ;;
        2)
            echo ""
            cat /proc/spl/kstat/zfs/arcstats
            ;;
    esac
    press_enter
}

# 7. ZFS PROPERTIES & TUNING
zfs_properties_tuning() {
    clear
    echo ""
    draw_box "     ZFS PROPERTIES & TUNING         "
    echo ""
    draw_border
    echo -e "${WHITE}Select category:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}View all dataset properties${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}View all pool properties${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Performance properties${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Compression settings${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Redundancy settings ${NHYPRBLUE}(copies)${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Quota and reservation${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Current module parameters${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-7):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read prop_option

    case $prop_option in
        1)
            clear
            echo ""
            draw_box "      ALL DATASET PROPERTIES         "
            echo ""
            echo -e "${WHITE}Enter dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            echo ""
            draw_border
            echo ""
            [ -n "$ds_name" ] && zfs get all "$ds_name"
            ;;
        2)
            clear
            echo ""
            draw_box "        ALL POOL PROPERTIES          "
            echo ""
            echo -e "${WHITE}Enter pool name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read pool_name
            echo ""
            draw_border
            echo ""
            [ -n "$pool_name" ] && zpool get all "$pool_name"
            ;;
        3)
            clear
            echo ""
            draw_box "      PERFORMANCE PROPERTIES         "
            echo ""
            echo -e "${WHITE}Enter dataset name:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name
            echo ""
            draw_border
            echo ""
            if [ -n "$ds_name" ]; then
                echo -e "${WHITE}Performance-related properties:${NC}"
                echo ""
                zfs get recordsize,atime,relatime,compression,sync,primarycache,secondarycache "$ds_name"
            fi
            ;;
        4)
            clear
            echo ""
            draw_box "       COMPRESSION SETTINGS          "
            echo ""
            echo -e "${WHITE}Current compression across all datasets:${NC}"
            echo ""
            zfs get compression,compressratio -r 2>/dev/null | head -30
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Set compression on a dataset? ${NHYPRBLUE}[y/N]:${NC}"
            read -r set_comp
            if [[ "$set_comp" =~ ^[yY] ]]; then
                echo -e "${WHITE}Enter dataset name:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read ds_name
                echo ""
                echo -e "${WHITE}Available compression algorithms:${NC}"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}off${NC}       - No compression"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}lz4${NC}       - Fast, good ratio"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}zstd ${NHYPRBLUE}(zstd-1 19)=${NC}      - Best balance ${NHYPRBLUE}(recommended)${NC}"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}zstd-fast${NC} - Faster zstd"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}gzip-9${NC}    - Maximum compression"
                echo ""
                echo -e "${WHITE}Enter algorithm:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read comp_alg
                [ -n "$ds_name" ] && [ -n "$comp_alg" ] && sudo zfs set compression="$comp_alg" "$ds_name" && echo -e "${GREEN}[OK] Compression set${NC}"
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "      REDUNDANCY SETTINGS            "
            echo ""
            echo -e "${WHITE}The ${NHYPRBLUE}copies${WHITE} property stores multiple copies of data.${NC}"
            echo -e "${WHITE}This provides extra protection beyond RAID.${NC}"
            echo ""
            echo -e "${WHITE}Current copies settings:${NC}"
            zfs get copies -r 2>/dev/null | head -20
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Set copies on a dataset? ${NHYPRBLUE}[y/N]:${NC}"
            read -r set_copies
            if [[ "$set_copies" =~ ^[yY] ]]; then
                echo -e "${WHITE}Enter dataset name:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read ds_name
                echo ""
                echo -e "${WHITE}Number of copies ${NHYPRBLUE}(1-3):${NC}"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}1${NC} - Single copy ${NHYPRBLUE}(default)${NC}"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}2${NC} - Two copies ${NHYPRBLUE}(recommended for important data)${NC}"
                echo -e "${NHYPRBLUE}>${NC} ${NARTIC}3${NC} - Three copies ${NHYPRBLUE}(maximum protection)${NC}"
                echo ""
                echo -ne "${NHYPRBLUE}> ${NC}"
                read num_copies
                [ -n "$ds_name" ] && [ -n "$num_copies" ] && sudo zfs set copies="$num_copies" "$ds_name" && echo -e "${GREEN}[OK] Copies set to ${num_copies}${NC}"
            fi
            ;;
        6)
            clear
            echo ""
            draw_box "      QUOTA AND RESERVATION          "
            echo ""
            echo -e "${WHITE}Current quotas and reservations:${NC}"
            zfs get quota,reservation,refquota,refreservation -r 2>/dev/null | grep -v "none" | head -20
            echo ""
            draw_border
            echo ""
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Set quota${NC}"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Set reservation${NC}"
            echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Remove quota${NC}"
            echo ""
            echo -ne "${NHYPRBLUE}> ${NC}"
            read quota_opt
            case $quota_opt in
                1)
                    echo -e "${WHITE}Enter dataset name:${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read ds_name
                    echo -e "${WHITE}Enter quota ${NHYPRBLUE}(e.g., 100G, 500M):${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read quota_val
                    [ -n "$ds_name" ] && [ -n "$quota_val" ] && sudo zfs set quota="$quota_val" "$ds_name" && echo -e "${GREEN}[OK] Quota set${NC}"
                    ;;
                2)
                    echo -e "${WHITE}Enter dataset name:${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read ds_name
                    echo -e "${WHITE}Enter reservation ${NHYPRBLUE}(e.g., 50G):${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read res_val
                    [ -n "$ds_name" ] && [ -n "$res_val" ] && sudo zfs set reservation="$res_val" "$ds_name" && echo -e "${GREEN}[OK] Reservation set${NC}"
                    ;;
                3)
                    echo -e "${WHITE}Enter dataset name:${NC}"
                    echo -ne "${NHYPRBLUE}> ${NC}"
                    read ds_name
                    [ -n "$ds_name" ] && sudo zfs set quota=none "$ds_name" && echo -e "${GREEN}[OK] Quota removed${NC}"
                    ;;
            esac
            ;;
        7)
            clear
            echo ""
            draw_box "     ZFS MODULE PARAMETERS           "
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Current ZFS module parameters:${NC}"
            echo ""
            cat /sys/module/zfs/parameters/* 2>/dev/null | head -30 || echo -e "${NARTIC}Parameters not accessible${NC}"
            echo ""
            echo -e "${WHITE}Key tunable parameters:${NC}"
            echo ""
            echo -e "${NHYPRBLUE}zfs_arc_max:${NC}        $(cat /sys/module/zfs/parameters/zfs_arc_max 2>/dev/null || echo 'N/A')"
            echo -e "${NHYPRBLUE}zfs_arc_min:${NC}        $(cat /sys/module/zfs/parameters/zfs_arc_min 2>/dev/null || echo 'N/A')"
            echo -e "${NHYPRBLUE}zfs_prefetch_disable:${NC} $(cat /sys/module/zfs/parameters/zfs_prefetch_disable 2>/dev/null || echo 'N/A')"
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}


# 8. CREATE NEW POOL
create_new_pool() {
    clear
    echo ""
    draw_box "         CREATE NEW POOL             "
    echo ""

    draw_border
    echo -e "${WHITE}AVAILABLE DISKS${NC}"
    draw_border
    echo ""

    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -v "loop"

    echo ""
    draw_border
    echo -e "${WHITE}SELECT POOL TYPE${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Single disk ${NHYPRBLUE}(no redundancy)${NC}"
    echo -e "${BLUE}21${NC} ${NVFROST}-${NC} ${NARTIC}Stripe ${NHYPRBLUE}(Super fast - no redundancy)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Mirror ${NHYPRBLUE}(2+ disks, RAID1)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}RAIDZ1 ${NHYPRBLUE}(3+ disks, single parity)${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}RAIDZ2 ${NHYPRBLUE}(4+ disks, double parity)${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}RAIDZ3 ${NHYPRBLUE}(5+ disks, triple parity)${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose pool type ${NHYPRBLUE}(1-5):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read pool_type

    echo ""
    echo -e "${WHITE}Enter pool name:${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read pool_name

    echo ""
    echo -e "${WHITE}Enter disk(s) ${NHYPRBLUE}(e.g., /dev/sdb /dev/sdc):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read disks

    if [ -z "$pool_name" ] || [ -z "$disks" ]; then
        echo -e "${RED}[X] Pool name and disks are required!${NC}"
        press_enter
        return
    fi

    case $pool_type in
        1) vdev_type="" ;;
        2) vdev_type="" ;;
        3) vdev_type="mirror" ;;
        4) vdev_type="raidz1" ;;
        5) vdev_type="raidz2" ;;
        6) vdev_type="raidz3" ;;
        *) echo -e "${RED}Invalid option!${NC}"; press_enter; return ;;
    esac

    echo ""
    draw_border
    echo -e "${WHITE}NORDIX OPTIMIZED SETTINGS${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Apply Nordix performance settings? ${NHYPRBLUE}[Y/n]:${NC}"
    read -r apply_settings

    if [[ "$apply_settings" =~ ^[nN] ]]; then
        create_cmd="sudo zpool create $pool_name $vdev_type $disks"
    else
        create_cmd="sudo zpool create -o ashift=12 -O compression=zstd -O atime=off -O relatime=on -O xattr=sa -O acltype=posixacl -O dnodesize=auto $pool_name $vdev_type $disks"
    fi

    echo ""
    echo -e "${WHITE}Command to execute:${NC}"
    echo -e "${NARTIC}$create_cmd${NC}"
    echo ""

    echo -e "${RED}WARNING: This will format the selected disk(s)!${NC}"
    echo -e "${RED}All data on these disks will be DESTROYED!${NC}"

    if confirm_action "Create pool ${pool_name}?"; then
        eval "$create_cmd" && {
            echo -e "${GREEN}[OK] Pool ${pool_name} created successfully!${NC}"
            echo ""
            zpool status "$pool_name"
        } || echo -e "${RED}[X] Pool creation failed!${NC}"
    fi

    press_enter
}

# ============================================
# 9. BOOT ENVIRONMENTS
# ============================================
boot_environments() {
    clear
    echo ""
    draw_box "       BOOT ENVIRONMENTS             "
    echo ""

    draw_border
    echo -e "${WHITE}ZFSBOOTMENU INTEGRATION${NC}"
    draw_border
    echo ""

    echo -e "${WHITE}Boot environments allow you to:${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Create snapshots before updates${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Roll back to previous system state${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Clone working systems${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Boot into any snapshot${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}Select operation:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}List boot environments${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Create new boot environment${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Clone existing boot environment${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Delete boot environment${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Set default boot environment${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Show bootfs property${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-6):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read be_option

    case $be_option in
        1)
            clear
            echo ""
            draw_box "      LIST BOOT ENVIRONMENTS         "
            echo ""
            draw_border
            echo ""

            # Try to find root dataset
            root_ds=$(zfs list -o name,mountpoint | grep -E "\s+/$" | awk '{print $1}')
            if [ -n "$root_ds" ]; then
                pool_name=$(echo "$root_ds" | cut -d'/' -f1)
                echo -e "${WHITE}Root dataset: ${NARTIC}$root_ds${NC}"
                echo -e "${WHITE}Pool: ${NARTIC}$pool_name${NC}"
                echo ""

                # List potential boot environments
                echo -e "${WHITE}Available boot environments:${NC}"
                zfs list -r -o name,used,creation "$pool_name" | head -20

                echo ""
                echo -e "${WHITE}Snapshots available for boot:${NC}"
                zfs list -t snapshot -o name,creation -r "$pool_name" | head -20
            else
                echo -e "${YELLOW}! Could not detect root ZFS dataset${NC}"
                echo -e "${WHITE}Available datasets:${NC}"
                zfs list -o name,mountpoint
            fi
            ;;
        2)
            clear
            echo ""
            draw_box "    CREATE BOOT ENVIRONMENT          "
            echo ""

            root_ds=$(zfs list -o name,mountpoint | grep -E "\s+/$" | awk '{print $1}')
            if [ -n "$root_ds" ]; then
                echo -e "${WHITE}Current root: ${NARTIC}$root_ds${NC}"
                echo ""
                echo -e "${WHITE}Enter name for new boot environment:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read be_name

                if [ -n "$be_name" ]; then
                    snap_name="${root_ds}@${be_name}-$(date +%Y%m%d-%H%M%S)"
                    if confirm_action "Create boot environment snapshot: ${snap_name}?"; then
                        sudo zfs snapshot -r "$snap_name" && echo -e "${GREEN}[OK] Boot environment created${NC}"
                    fi
                fi
            else
                echo -e "${RED}[X] Could not detect root dataset${NC}"
            fi
            ;;
        3)
            clear
            echo ""
            draw_box "    CLONE BOOT ENVIRONMENT           "
            echo ""

            echo -e "${WHITE}Available snapshots:${NC}"
            zfs list -t snapshot -o name -H | tail -20
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Enter snapshot to clone:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read snap_name
            echo -e "${WHITE}Enter name for new dataset:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read new_ds

            if [ -n "$snap_name" ] && [ -n "$new_ds" ]; then
                if confirm_action "Clone ${snap_name} to ${new_ds}?"; then
                    sudo zfs clone "$snap_name" "$new_ds" && echo -e "${GREEN}[OK] Clone created${NC}"
                fi
            fi
            ;;
        4)
            clear
            echo ""
            draw_box "   DELETE BOOT ENVIRONMENT           "
            echo ""
            echo -e "${RED}WARNING: Be careful not to delete your current boot environment!${NC}"
            echo ""
            echo -e "${WHITE}Available environments:${NC}"
            zfs list -o name -H
            echo ""
            echo -e "${WHITE}Enter dataset to delete:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read ds_name

            if [ -n "$ds_name" ]; then
                echo -e "${RED}Type the dataset name again to confirm:${NC}"
                echo -ne "${NHYPRBLUE}> ${NC}"
                read confirm
                if [ "$ds_name" = "$confirm" ]; then
                    sudo zfs destroy -r "$ds_name" && echo -e "${GREEN}[OK] Deleted${NC}"
                else
                    echo -e "${YELLOW}! Names did not match. Cancelled.${NC}"
                fi
            fi
            ;;
        5)
            clear
            echo ""
            draw_box "   SET DEFAULT BOOT ENVIRONMENT      "
            echo ""

            pool_name=$(zpool list -H -o name | head -1)
            current_bootfs=$(zpool get -H -o value bootfs "$pool_name" 2>/dev/null)

            echo -e "${WHITE}Current bootfs: ${NARTIC}$current_bootfs${NC}"
            echo ""
            echo -e "${WHITE}Available datasets:${NC}"
            zfs list -o name -H
            echo ""
            echo -e "${WHITE}Enter dataset to set as bootfs:${NC}"
            echo -ne "${NHYPRBLUE}> ${NC}"
            read new_bootfs

            if [ -n "$new_bootfs" ]; then
                if confirm_action "Set ${new_bootfs} as default boot dataset?"; then
                    sudo zpool set bootfs="$new_bootfs" "$pool_name" && echo -e "${GREEN}[OK] bootfs set${NC}"
                fi
            fi
            ;;
        6)
            clear
            echo ""
            draw_box "       SHOW BOOTFS PROPERTY          "
            echo ""
            draw_border
            echo ""

            for pool in $(zpool list -H -o name); do
                bootfs=$(zpool get -H -o value bootfs "$pool" 2>/dev/null)
                echo -e "${NHYPRBLUE}$pool:${NC} bootfs = ${NARTIC}$bootfs${NC}"
            done
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# ============================================
# 10. LEARN ZFS COMMANDS
# ============================================
learn_zfs_commands() {
    clear
    echo ""
    draw_box "       LEARN ZFS COMMANDS            "
    echo ""
    draw_border
    echo -e "${WHITE}Select topic:${NC}"
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}Basic ZFS concepts${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Pool commands ${NHYPRBLUE}(zpool)${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Dataset commands ${NHYPRBLUE}(zfs)${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Snapshot commands${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Property commands${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Maintenance commands${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Send/Receive ${NHYPRBLUE}(backup)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Useful tips and tricks${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-8):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read learn_option

    case $learn_option in
        1)
            learn_zfs_concepts
            ;;
        2)
            learn_zpool_commands
            ;;
        3)
            learn_zfs_dataset_commands
            ;;
        4)
            learn_snapshot_commands
            ;;
        5)
            learn_property_commands
            ;;
        6)
            learn_maintenance_commands
            ;;
        7)
            learn_send_receive
            ;;
        8)
            learn_tips_tricks
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

learn_zfs_concepts() {
    clear
    echo ""
    draw_box "       BASIC ZFS CONCEPTS            "
    echo ""

    draw_border
    echo -e "${WHITE}WHAT IS ZFS?${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}ZFS is a combined filesystem and volume manager.${NC}"
    echo -e "${NARTIC}It provides data integrity, snapshots, compression,${NC}"
    echo -e "${NARTIC}and advanced caching capabilities.${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}KEY TERMINOLOGY${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}Pool (zpool):${NC}"
    echo -e "${NARTIC}  A collection of one or more disks. The foundation of ZFS.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}Dataset:${NC}"
    echo -e "${NARTIC}  A filesystem within a pool. Can be nested hierarchically.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}Snapshot:${NC}"
    echo -e "${NARTIC}  A read-only point-in-time copy of a dataset.${NC}"
    echo -e "${NARTIC}  Snapshots are instant and use minimal space.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}Clone:${NC}"
    echo -e "${NARTIC}  A writable copy of a snapshot.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}ARC (Adaptive Replacement Cache):${NC}"
    echo -e "${NARTIC}  ZFS's intelligent RAM cache. Much faster than disk.${NC}"
    echo -e "${NARTIC}  Nordix aggressively tunes ARC for maximum performance.${NC}"
    echo ""
    echo -e "${NHYPRBLUE}Scrub:${NC}"
    echo -e "${NARTIC}  Verification of all data against checksums.${NC}"
    echo -e "${NARTIC}  Run monthly for data integrity.${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}ZFS VS TRADITIONAL FILESYSTEMS${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Built-in checksums for all data${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Copy-on-write prevents corruption${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Native compression saves space${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Instant snapshots${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Built-in RAID ${NHYPRBLUE}(RAIDZ)${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Self-healing with redundancy${NC}"
}

learn_zpool_commands() {
    clear
    echo ""
    draw_box "      POOL COMMANDS (zpool)          "
    echo ""

    draw_border
    echo -e "${WHITE}CREATING POOLS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool create poolname /dev/sdb${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create single disk pool${NC}"
    echo ""
    echo -e "${NARTIC}zpool create poolname mirror /dev/sdb /dev/sdc${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create mirrored pool ${NHYPRBLUE}(RAID1)${NC}"
    echo ""
    echo -e "${NARTIC}zpool create poolname raidz1 /dev/sdb /dev/sdc /dev/sdd${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create RAIDZ1 pool ${NHYPRBLUE}(RAID5 equivalent)${NC}"
    echo ""
    echo -e "${NARTIC}zpool create -o ashift=12 poolname /dev/sdb${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create with 4K sector alignment ${NHYPRBLUE}(recommended)${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}POOL STATUS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool list${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List all pools with capacity${NC}"
    echo ""
    echo -e "${NARTIC}zpool status${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Detailed status of all pools${NC}"
    echo ""
    echo -e "${NARTIC}zpool status -v poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Verbose status of specific pool${NC}"
    echo ""
    echo -e "${NARTIC}zpool iostat 2${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}I/O statistics every 2 seconds${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}IMPORT/EXPORT${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool export poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Safely disconnect pool${NC}"
    echo ""
    echo -e "${NARTIC}zpool import${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List available pools to import${NC}"
    echo ""
    echo -e "${NARTIC}zpool import poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Import a pool${NC}"
}

learn_zfs_dataset_commands() {
    clear
    echo ""
    draw_box "     DATASET COMMANDS (zfs)          "
    echo ""

    draw_border
    echo -e "${WHITE}CREATING DATASETS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs create pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create new dataset${NC}"
    echo ""
    echo -e "${NARTIC}zfs create -o compression=zstd pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create with compression enabled${NC}"
    echo ""
    echo -e "${NARTIC}zfs create -o mountpoint=/data pool/data${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create with specific mount point${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}LISTING DATASETS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs list${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List all datasets${NC}"
    echo ""
    echo -e "${NARTIC}zfs list -r pool${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List datasets recursively${NC}"
    echo ""
    echo -e "${NARTIC}zfs list -o name,used,avail,compression${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List with specific columns${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}MODIFYING DATASETS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs rename pool/old pool/new${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Rename dataset${NC}"
    echo ""
    echo -e "${NARTIC}zfs destroy pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Delete dataset${NC}"
    echo ""
    echo -e "${NARTIC}zfs mount pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Mount dataset${NC}"
    echo ""
    echo -e "${NARTIC}zfs unmount pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Unmount dataset${NC}"
}

learn_snapshot_commands() {
    clear
    echo ""
    draw_box "       SNAPSHOT COMMANDS             "
    echo ""

    draw_border
    echo -e "${WHITE}CREATING SNAPSHOTS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs snapshot pool/dataset@snapname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create snapshot${NC}"
    echo ""
    echo -e "${NARTIC}zfs snapshot -r pool@snapname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Recursive snapshot ${NHYPRBLUE}(all children)${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}LISTING SNAPSHOTS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs list -t snapshot${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List all snapshots${NC}"
    echo ""
    echo -e "${NARTIC}zfs list -t snapshot -o name,creation -s creation${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}List sorted by creation time${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}USING SNAPSHOTS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs rollback pool/dataset@snapname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Revert to snapshot ${NHYPRBLUE}(destroys newer data!)${NC}"
    echo ""
    echo -e "${NARTIC}zfs clone pool/dataset@snap pool/newdataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Create writable clone from snapshot${NC}"
    echo ""
    echo -e "${NARTIC}zfs diff pool/dataset@snap1 pool/dataset@snap2${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Compare two snapshots${NC}"
    echo ""
    echo -e "${NARTIC}zfs destroy pool/dataset@snapname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Delete snapshot${NC}"
}

learn_property_commands() {
    clear
    echo ""
    draw_box "       PROPERTY COMMANDS             "
    echo ""

    draw_border
    echo -e "${WHITE}VIEWING PROPERTIES${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs get all pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Show all properties${NC}"
    echo ""
    echo -e "${NARTIC}zfs get compression pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Show specific property${NC}"
    echo ""
    echo -e "${NARTIC}zfs get compression,compressratio -r pool${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Show properties recursively${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}SETTING PROPERTIES${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs set compression=zstd pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Enable zstd compression${NC}"
    echo ""
    echo -e "${NARTIC}zfs set atime=off pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Disable access time updates ${NHYPRBLUE}(performance)${NC}"
    echo ""
    echo -e "${NARTIC}zfs set recordsize=1M pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Set record size ${NHYPRBLUE}(large files)${NC}"
    echo ""
    echo -e "${NARTIC}zfs set copies=2 pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Store 2 copies of data ${NHYPRBLUE}(extra safety)${NC}"
    echo ""
    echo -e "${NARTIC}zfs set quota=100G pool/dataset${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Limit dataset to 100GB${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}COMMON NORDIX SETTINGS${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}compression=zstd${NC}    - Best balance"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}atime=off${NC}           - Better performance"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}xattr=sa${NC}            - Fast extended attributes"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}acltype=posixacl${NC}    - Linux ACL support"
}

learn_maintenance_commands() {
    clear
    echo ""
    draw_box "      MAINTENANCE COMMANDS           "
    echo ""

    draw_border
    echo -e "${WHITE}SCRUB - DATA VERIFICATION${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool scrub poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Start scrub ${NHYPRBLUE}(verify all data)${NC}"
    echo ""
    echo -e "${NARTIC}zpool scrub -s poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Stop running scrub${NC}"
    echo ""
    echo -e "${NARTIC}zpool status${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Check scrub progress${NC}"
    echo ""
    echo -e "${WHITE}Run scrub monthly for data integrity!${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}HEALTH CHECKS${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool status -x${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Quick health check${NC}"
    echo ""
    echo -e "${NARTIC}zpool clear poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Clear error counters${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}UPGRADING${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zpool upgrade${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Check for upgradable pools${NC}"
    echo ""
    echo -e "${NARTIC}zpool upgrade poolname${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Upgrade pool to latest features${NC}"
}

learn_send_receive() {
    clear
    echo ""
    draw_box "     SEND/RECEIVE (BACKUP)           "
    echo ""

    draw_border
    echo -e "${WHITE}BASIC SEND/RECEIVE${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs send pool/dataset@snap > backup.zfs${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Send snapshot to file${NC}"
    echo ""
    echo -e "${NARTIC}zfs receive pool/newdataset < backup.zfs${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Receive snapshot from file${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}INCREMENTAL SEND${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs send -i @snap1 pool/dataset@snap2 > incremental.zfs${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Send only changes between snapshots${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}REMOTE REPLICATION${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs send pool/dataset@snap | ssh remote zfs receive pool/backup${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Send to remote system via SSH${NC}"
    echo ""
    echo -e "${NARTIC}zfs send -R pool@snap | ssh remote zfs receive -F pool${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Replicate entire pool recursively${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}COMPRESSED SEND${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs send pool/dataset@snap | gzip > backup.zfs.gz${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Compress backup${NC}"
    echo ""
    echo -e "${NARTIC}gunzip -c backup.zfs.gz | zfs receive pool/restore${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Restore compressed backup${NC}"
}

learn_tips_tricks() {
    clear
    echo ""
    draw_box "      TIPS AND TRICKS                "
    echo ""

    draw_border
    echo -e "${WHITE}PERFORMANCE TIPS${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Use compression=zstd for most workloads${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Set atime=off to reduce write overhead${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}More RAM = larger ARC = faster system${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Use recordsize=1M for large files${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Use recordsize=16K for databases${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}SAFETY TIPS${NC}"
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Always use copies=2 for important data${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Run scrub monthly${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Take snapshots before updates${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Use mirrors or RAIDZ for redundancy${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}Never use RAIDZ with different disk sizes${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}USEFUL ALIASES${NC}"
    draw_border
    echo ""
    echo -e "${WHITE}Add to ~/.bashrc:${NC}"
    echo ""
    echo -e "${NARTIC}alias zlist='zfs list -o name,used,avail,compression,compressratio'${NC}"
    echo -e "${NARTIC}alias zsnap='zfs list -t snapshot -o name,used,creation'${NC}"
    echo -e "${NARTIC}alias zstatus='zpool status -v'${NC}"
    echo -e "${NARTIC}alias zarc='cat /proc/spl/kstat/zfs/arcstats | grep -E \"^(size|hits|misses)\"'${NC}"
    echo ""

    draw_border
    echo -e "${WHITE}QUICK SNAPSHOT NAMING${NC}"
    draw_border
    echo ""
    echo -e "${NARTIC}zfs snapshot pool/data@\$(date +%Y%m%d-%H%M%S)${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${WHITE}Timestamp-based snapshot names${NC}"
}

# ============================================
# 11. NORDIX ZFS TUNING GUIDE
# ============================================
nordix_tuning_guide() {
    clear
    echo ""
    draw_box "     NORDIX ZFS TUNING GUIDE         "
    echo ""
    echo ""
    echo ""
    echo ""
    draw_box "     THE NORDIX PHILOSOPHY         "
    echo ""
    echo ""
    draw_border
    echo ""
    echo -e "${NARTIC}Nordix is tuned for aggressive performance while${NC}"
    echo -e "${NARTIC}maintaining data integrity. RAM is king in Nordix.${NC}"
    echo ""
    echo -e "${WHITE}Key principle: ${NHYPRBLUE}More RAM = Faster System${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
    echo ""
   draw_box "     ARC - THE SECRET WEAPON         "
    echo ""
    echo ""
    echo ""
    draw_border
    echo ""
    echo -e "${NARTIC}ZFS ARC is not like regular filesystem cache.${NC}"
    echo -e "${NARTIC}ARC caches blocks, not files - about 3x faster than${NC}"
    echo -e "${NARTIC}regular RAM disk performance!${NC}"
    echo ""
    echo -e "${WHITE}Nordix uses compressed ARC - a 64GB system can${NC}"
    echo -e "${WHITE}behave like a 128GB+ system with good compression!${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
     draw_box "    RECOMMENDED RAM FOR NORDIX         "
    echo ""
    echo ""
    echo ""
    draw_border
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}16GB${NC}  - Minimum for desktop use"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}32GB${NC}  - Minimum for enthusiast systems"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}64GB${NC}  - Good ARC performance"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}128GB+${NC} - Maximum ARC benefits"
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
    draw_box "    NORDIX DEFAULT SETTINGS         "
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}Zpool default:${NC}"

    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}ashift=13${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}autotrim=on${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}dnodesize=auto${NC}"
    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}compatibility=openzfs-2.2-linux${NC}"
    echo ""
    echo -e  "${WHITE}Zpool ASHIFT:${NC}"
    echo -e  "${NARTIC}ashift=13 ${NHYPRBLUE}❯ ${NARTIC}For modern nmvme ssd${NHYPRBLUE}(8K sectors)${NC}"
    echo -e  "${NARTIC}ashift=13 ${NHYPRBLUE}❯ ${NARTIC}Specific RAID setup with HHD or nvme${NHYPRBLUE}(8K sectors)${NC}"
    echo -e  "${NARTIC}ashift=12 ${NHYPRBLUE}❯ ${NARTIC}For ssd and hhd${NHYPRBLUE}(4K sectors)${NC}"
    echo -e  "${NARTIC}ashift=9 ${NHYPRBLUE}❯ ${NARTIC}Old hhd${NHYPRBLUE}(512B sectors)${NC}"
    echo -e  "${NARTIC}Use ashift=12 if you are unsure${NC}"
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e  "${WHITE}Nordix uses seven datasets for a Boot Environment ${NHYPRBLUE}(BE)${NC}"
    echo -e  "${WHITE}I will only mention two of them here. ${NC}"
    echo ""
    echo -e "${WHITE}Dataset properties for root:${NC}"
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}compression=zstd-5${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}atime=off${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}relatime=on${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}xattr=sa${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}acltype=posixacl${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=2${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}recordsize=64k ${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}checksum=fletcher4${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}primarycache=all${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}secondarycache=all${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}sync=standard${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}logbias=latency${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}Dataset properties for home:${NC}"
    echo -e  "${WHITE}Use this as a guideline if you are going to create an additional storage zpool. ${NC}"
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}compression=zstd-1${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}atime=off${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}relatime=on${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}xattr=sa${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}acltype=posixacl${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=1${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}recordsize=1M ${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}checksum=fletcher4${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}primarycache=all${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}secondarycache=all${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}sync=standard${NC}"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}logbias=throughput${NC}"
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
     draw_box "   NORDIX DEFAULT TUNING OPTIONS 64GB     "
    echo -e "${WHITE}Permanent settings in /etc/modprobe.d/zfs.conf:${NC}"
     echo ""
     echo ""
    draw_border
    echo -e "${WHITE}
    ##=========================================
     #    Nordix - ZFS performance options
    ##=========================================
    echo ""
    echo ""
    echo ""
    echo ""
    draw_box "    COPIES FOR DATA INTEGRITY AND PERFORMANCE         "
    echo ""
    echo ""
    draw_border
    echo ""
    echo -e "${NARTIC}The copies property stores multiple copies of data.${NC}"
    echo -e "${NARTIC}This provides protection beyond anything else.${NC}"
    echo -e "${NARTIC}whith ZFS schecksum and copies=2-*${NC}"
    echo -e "${NARTIC}is the best protections against corruptions.${NC}" .${NC}"
    echo ""
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=1${NC} - Default, single copy"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=2${NC} - ~50% faster reads, uses 2x space"
    echo -e "${NHYPRBLUE}>${NC} ${NARTIC}copies=3${NC} - Maximum protection"
    echo ""
    echo -e "${WHITE}Nordix recommendation: ${NHYPRBLUE}copies=2 for important data and fast reads${NC}"
    echo ""
    draw_border
    echo ""
    draw_border
    echo ""
    echo ""
    echo ""
    draw_box "    RECORDSIZE & COMPRESSION         "
    echo ""
    echo ""
    draw_border
    echo ""
    echo -e "${NARTIC}Nordix has built the tool 'filestat' to measure files in a directory${NC}"
    echo -e "${NARTIC}Usege: filestat /path/to/directory ${NC}"
    echo -e "${NARTIC}this will help you to messure the files, for the recordsize and compression${NC}"
    echo ""
    echo -e "${NARTIC}dataset with many small files, set recordzize=32-64K, if it is only small files, set 16K ${NC}"
    echo -e "${NARTIC}dataset with manny small files 4k, set higher compression, zstd-5 to zstd-8${NC}"
    echo -e "${NARTIC}dataset for larger files like media librarys, set recordsize from 256K to 2M${NC}"
    echo -e "${NARTIC}dataset with manny small files 4k, set compresssion from zstd-1 to zstd-4 you can use lz4 is aso a good choise${NC}"
    echo ""
    echo -e "${NARTIC}Use filestat to messure the files, run benchmarks on the dataset you whant to optimize. ${NC}"
    echo -e "${NARTIC}ZFS is build for reead speed, it is normal to have huge more read speed than write.${NC}"
    echo -e "${NARTIC}it is the read speed that gives performance to your system${NC}"
    draw_border
    press_enter




}

# ============================================
# 12. TROUBLESHOOTING
# ============================================
troubleshooting() {
    clear
    echo ""
    draw_box "        TROUBLESHOOTING              "
    echo ""
    draw_border
    echo -e "${WHITE}Select issue category:${NC}"
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Pool won't import${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Degraded pool${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Checksum errors${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}ZFS module issues${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Boot problems${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Performance issues${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Out of space${NC}"
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(1-7):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read trouble_option

    case $trouble_option in
        1)
            clear
            echo ""
            draw_box "      POOL WON'T IMPORT              "
            echo ""
            draw_border
            echo -e "${WHITE}COMMON CAUSES AND FIXES${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}1. Pool was not exported cleanly:${NC}"
            echo -e "${NARTIC}   zpool import -f poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}2. Different hostid:${NC}"
            echo -e "${NARTIC}   zpool import -f poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}3. Disk paths changed:${NC}"
            echo -e "${NARTIC}   zpool import -d /dev/disk/by-id poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}4. Pool from older ZFS version:${NC}"
            echo -e "${NARTIC}   zpool import -o readonly=on poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}5. Recovery mode:${NC}"
            echo -e "${NARTIC}   zpool import -F poolname${NC}"
            echo -e "${NARTIC}   ${WHITE}(Rewind to last known good state)${NC}"
            ;;
        2)
            clear
            echo ""
            draw_box "        DEGRADED POOL                "
            echo ""
            draw_border
            echo -e "${WHITE}DIAGNOSING DEGRADED POOLS${NC}"
            draw_border
            echo ""
            echo -e "${NARTIC}zpool status -v${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${WHITE}Shows which disk is problematic${NC}"
            echo ""
            draw_border
            echo -e "${WHITE}FIXING DEGRADED POOLS${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}Replace failed disk:${NC}"
            echo -e "${NARTIC}zpool replace poolname /dev/old /dev/new${NC}"
            echo ""
            echo -e "${NHYPRBLUE}If disk is offline but functional:${NC}"
            echo -e "${NARTIC}zpool online poolname /dev/sdX${NC}"
            echo ""
            echo -e "${NHYPRBLUE}Clear transient errors:${NC}"
            echo -e "${NARTIC}zpool clear poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}After replacement, run scrub:${NC}"
            echo -e "${NARTIC}zpool scrub poolname${NC}"
            ;;
        3)
            clear
            echo ""
            draw_box "       CHECKSUM ERRORS               "
            echo ""
            draw_border
            echo -e "${WHITE}WHAT CHECKSUM ERRORS MEAN${NC}"
            draw_border
            echo ""
            echo -e "${NARTIC}Checksum errors indicate data corruption.${NC}"
            echo -e "${NARTIC}ZFS detected bad data via its checksums.${NC}"
            echo ""
            draw_border
            echo -e "${WHITE}FIXING CHECKSUM ERRORS${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}1. If you have redundancy (mirror/raidz):${NC}"
            echo -e "${NARTIC}   zpool scrub poolname${NC}"
            echo -e "${WHITE}   ZFS will auto-repair from good copies${NC}"
            echo ""
            echo -e "${NHYPRBLUE}2. If single disk - identify affected files:${NC}"
            echo -e "${NARTIC}   zpool status -v poolname${NC}"
            echo ""
            echo -e "${NHYPRBLUE}3. Clear error counters after fixing:${NC}"
            echo -e "${NARTIC}   zpool clear poolname${NC}"
            echo ""
            echo -e "${YELLOW}! Persistent errors may indicate failing disk${NC}"
            ;;
        4)
            clear
            echo ""
            draw_box "       ZFS MODULE ISSUES             "
            echo ""
            draw_border
            echo -e "${WHITE}COMMON MODULE PROBLEMS${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}ZFS module not loaded:${NC}"
            echo -e "${NARTIC}sudo modprobe zfs${NC}"
            echo ""
            echo -e "${NHYPRBLUE}Module version mismatch after kernel update:${NC}"
            echo -e "${NARTIC}sudo dkms autoinstall${NC}"
            echo -e "${NARTIC}sudo mkinitcpio -P${NC}"
            echo ""
            echo -e "${NHYPRBLUE}Check ZFS module status:${NC}"
            echo -e "${NARTIC}lsmod | grep zfs${NC}"
            echo -e "${NARTIC}dmesg | grep -i zfs${NC}"
            echo ""
            echo -e "${NHYPRBLUE}Rebuild ZFS DKMS:${NC}"
            echo -e "${NARTIC}sudo dkms remove zfs/\$(modinfo -F version zfs) --all${NC}"
            echo -e "${NARTIC}sudo dkms install zfs/\$(pacman -Qi zfs-dkms | grep Version | awk '{print \$3}')${NC}"
            ;;
        5)
            clear
            echo ""
            draw_box "        BOOT PROBLEMS                "
            echo ""
            draw_border
            echo -e "${WHITE}ZFSBOOTMENU TROUBLESHOOTING${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}1. Pool not found at boot:${NC}"
            echo -e "${WHITE}   In ZFSBootMenu, press 'i' for import menu${NC}"
            echo ""
            echo -e "${NHYPRBLUE}2. Wrong bootfs:${NC}"
            echo -e "${NARTIC}   zpool set bootfs=pool/ROOT/arch pool${NC}"
            echo ""
            echo -e "${NHYPRBLUE}3. Boot into recovery:${NC}"
            echo -e "${WHITE}   In ZFSBootMenu, select snapshot and boot${NC}"
            echo ""
            echo -e "${NHYPRBLUE}4. Regenerate initramfs:${NC}"
            echo -e "${NARTIC}   sudo mkinitcpio -P${NC}"
            echo ""
            echo -e "${NHYPRBLUE}5. Check mkinitcpio.conf hooks:${NC}"
            echo -e "${WHITE}   Should include: zfs${NC}"
            ;;
        6)
            clear
            echo ""
            draw_box "      PERFORMANCE ISSUES             "
            echo ""
            draw_border
            echo -e "${WHITE}DIAGNOSING SLOW ZFS${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}1. Check ARC hit rate:${NC}"
            echo -e "${NARTIC}   arcstat 1 5${NC}"
            echo -e "${WHITE}   Should be >90% for good performance${NC}"
            echo ""
            echo -e "${NHYPRBLUE}2. Check for fragmentation:${NC}"
            echo -e "${NARTIC}   zpool list -v${NC}"
            echo -e "${WHITE}   FRAG% should be <50%${NC}"
            echo ""
            echo -e "${NHYPRBLUE}3. Check disk I/O:${NC}"
            echo -e "${NARTIC}   zpool iostat -v 2${NC}"
            echo ""
            draw_border
            echo -e "${WHITE}PERFORMANCE FIXES${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}Low ARC hit rate:${NC}"
            echo -e "${WHITE}   Add more RAM or increase zfs_arc_max${NC}"
            echo ""
            echo -e "${NHYPRBLUE}High fragmentation:${NC}"
            echo -e "${WHITE}   Consider zpool rebalance (export/import)${NC}"
            echo ""
            echo -e "${NHYPRBLUE}Enable compression if not already:${NC}"
            echo -e "${NARTIC}   zfs set compression=zstd pool/dataset${NC}"
            ;;
        7)
            clear
            echo ""
            draw_box "        OUT OF SPACE                 "
            echo ""
            draw_border
            echo -e "${WHITE}FINDING SPACE USAGE${NC}"
            draw_border
            echo ""
            echo -e "${NARTIC}zfs list -o name,used,avail,usedbysnapshots${NC}"
            echo -e "${NHYPRBLUE}>${NC} ${WHITE}Shows what's using space${NC}"
            echo ""
            draw_border
            echo -e "${WHITE}FREEING SPACE${NC}"
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}1. Delete old snapshots:${NC}"
            echo -e "${NARTIC}   zfs list -t snapshot -s creation${NC}"
            echo -e "${NARTIC}   zfs destroy pool/dataset@old_snapshot${NC}"
            echo ""
            echo -e "${NHYPRBLUE}2. Check snapshot space:${NC}"
            echo -e "${NARTIC}   zfs list -o name,usedbysnapshots -r pool${NC}"
            echo ""
            echo -e "${NHYPRBLUE}3. Enable compression:${NC}"
            echo -e "${NARTIC}   zfs set compression=zstd pool/dataset${NC}"
            echo ""
            echo -e "${NHYPRBLUE}4. Find large files:${NC}"
            echo -e "${NARTIC}   du -sh /* 2>/dev/null | sort -h | tail -20${NC}"
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    press_enter
}

# ============================================
# RUN STARTUP CHECK
# ============================================
startup_check

# ============================================
# MAIN LOOP
# ============================================
while true; do
    show_menu
    echo ""
    echo -e "${WHITE}Enter your choice ${NHYPRBLUE}(0-12):${NC}"
    echo -ne "${NHYPRBLUE}> ${NC}"
    read choice

    case $choice in
        1) zfs_quick_status ;;
        2) pool_management ;;
        3) dataset_management ;;
        4) snapshot_management ;;
        5) scrub_health_check ;;
        6) arc_cache_monitor ;;
        7) zfs_properties_tuning ;;
        8) create_new_pool ;;
        9) boot_environments ;;
        10) learn_zfs_commands ;;
        11) nordix_tuning_guide ;;
        12) troubleshooting ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Goodbye from Nordix ZFS Helper!${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please enter a number between 0 and 12.${NC}"
            sleep 2
            ;;
    esac
done
