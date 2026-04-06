#!/bin/bash
##============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                      #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0  #
 # Copyright (c) 2025 Jimmy Källhagen                                         #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                     #
##============================================================================##

# ============================================
# Nordix CLI Dataset
# ZFS Dataset Management for Nordix
# ============================================

# ============================================
# NORDIX COLOR THEME
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
# TUI HELPER FUNCTIONS
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
    read
}

# ============================================
# ZFS CHECK FUNCTIONS
# ============================================

check_zfs() {
    if ! command -v zfs &>/dev/null; then
        echo -e "${RED}[X]${NC} ${WHITE}ZFS is not installed!${NC}"
        echo -e "${NARTIC}Install ZFS: ${NHYPRBLUE}sudo pacman -S zfs-utils${NC}"
        exit 1
    fi
}

# Get list of pools
get_pools() {
    zpool list -H -o name 2>/dev/null
}

# Get list of datasets
get_datasets() {
    local pool="$1"
    if [ -n "$pool" ]; then
        zfs list -H -o name -r "$pool" 2>/dev/null
    else
        zfs list -H -o name 2>/dev/null
    fi
}

# ============================================
# PROPERTY DEFINITIONS
# Common ZFS properties with descriptions
# ============================================

declare -A PROP_DESC=(
    # Performance properties
    ["compression"]="Compression algorithm (off|lz4|zstd|gzip|lzjb|zle)"
    ["recordsize"]="Block size for files (default 128K, range 512B-16M)"
    ["atime"]="Update access time on read (on|off) - off improves performance"
    ["relatime"]="Update atime only if mtime/ctime changed (on|off)"
    ["sync"]="Sync write behavior (standard|always|disabled)"
    ["primarycache"]="ARC caching (all|metadata|none)"
    ["secondarycache"]="L2ARC caching (all|metadata|none)"
    ["logbias"]="Optimize for latency or throughput (latency|throughput)"
    ["redundant_metadata"]="Metadata redundancy (all|most|some|none)"
    ["special_small_blocks"]="Small block threshold for special vdev"
    
    # Space properties
    ["quota"]="Maximum space this dataset can use"
    ["refquota"]="Maximum space excluding snapshots/children"
    ["reservation"]="Guaranteed space for this dataset"
    ["refreservation"]="Guaranteed space excluding snapshots"
    
    # Data integrity
    ["checksum"]="Checksum algorithm (on|off|fletcher2|fletcher4|sha256|sha512|skein)"
    ["copies"]="Number of data copies (1|2|3) - more = safer but uses space"
    ["dedup"]="Deduplication (on|off|verify|sha256|sha512|skein)"
    
    # Mount properties
    ["mountpoint"]="Where dataset is mounted (path|none|legacy)"
    ["canmount"]="Auto-mount behavior (on|off|noauto)"
    ["readonly"]="Read-only mount (on|off)"
    ["setuid"]="Allow setuid binaries (on|off)"
    ["exec"]="Allow program execution (on|off)"
    ["devices"]="Allow device files (on|off)"
    
    # Snapshot properties
    ["snapdir"]="Snapshot directory visibility (hidden|visible)"
    ["snapdev"]="Snapshot device visibility (hidden|visible)"
    
    # Security properties
    ["encryption"]="Encryption algorithm (off|on|aes-128-ccm|aes-192-ccm|aes-256-ccm|aes-128-gcm|aes-192-gcm|aes-256-gcm)"
    ["keyformat"]="Key format (none|raw|hex|passphrase)"
    ["keylocation"]="Key location (prompt|file:///path)"
    
    # ACL/Permissions
    ["acltype"]="ACL type (off|nfsv4|posix|posixacl)"
    ["aclinherit"]="ACL inheritance (discard|noallow|restricted|passthrough|passthrough-x)"
    ["xattr"]="Extended attributes (on|off|sa)"
    
    # NFS/SMB
    ["sharenfs"]="NFS share options (on|off|options)"
    ["sharesmb"]="SMB share options (on|off|options)"
    
    # Other
    ["dnodesize"]="Dnode size (legacy|auto|1k|2k|4k|8k|16k)"
    ["normalization"]="Unicode normalization (none|formC|formD|formKC|formKD)"
    ["casesensitivity"]="Case sensitivity (sensitive|insensitive|mixed)"
    ["utf8only"]="UTF-8 only filenames (on|off)"
)

# Nordix recommended settings
declare -A NORDIX_RECOMMENDED=(
    ["compression"]="zstd"
    ["atime"]="off"
    ["relatime"]="on"
    ["xattr"]="sa"
    ["acltype"]="posixacl"
    ["dnodesize"]="auto"
    ["primarycache"]="all"
    ["secondarycache"]="all"
    ["checksum"]="on"
)

# ============================================
# DATASET FUNCTIONS
# ============================================

# List all datasets
list_datasets() {
    clear
    echo ""
    draw_box "         LIST DATASETS            "
    echo ""
    draw_border
    echo -e "${WHITE}All ZFS datasets on this system:${NC}"
    draw_border
    echo ""
    
    echo -e "${NHYPRBLUE}NAME                                    USED    AVAIL   REFER   MOUNTPOINT${NC}"
    zfs list -o name,used,avail,refer,mountpoint 2>/dev/null | tail -n +2 | while read -r line; do
        echo -e "${NARTIC}$line${NC}"
    done
    
    echo ""
    draw_border
    
    # Show pool summary
    echo ""
    echo -e "${WHITE}Pool Summary:${NC}"
    echo ""
    zpool list -o name,size,alloc,free,frag,cap,health 2>/dev/null
    
    press_enter
}

# Create new dataset
create_dataset() {
    clear
    echo ""
    draw_box "        CREATE DATASET            "
    echo ""
    draw_border
    echo -e "${WHITE}Available pools:${NC}"
    draw_border
    echo ""
    
    local pools=($(get_pools))
    local i=1
    
    for pool in "${pools[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$pool${NC}"
        ((i++))
    done
    
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Select pool ${NHYPRBLUE}(1-${#pools[@]})${NGLACIER}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#pools[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local pool="${pools[$((selection-1))]}"
    
    # Show existing datasets in pool
    echo ""
    echo -e "${WHITE}Existing datasets in ${NHYPRBLUE}$pool${WHITE}:${NC}"
    zfs list -H -o name -r "$pool" 2>/dev/null | while read -r ds; do
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$ds${NC}"
    done
    
    echo ""
    draw_border
    echo -e "${WHITE}Enter new dataset name:${NC}"
    echo -e "${NARTIC}(Will be created as ${pool}/name or ${pool}/parent/name)${NC}"
    draw_border
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r ds_name
    
    if [ -z "$ds_name" ]; then
        echo -e "${RED}No name entered!${NC}"
        press_enter
        return
    fi
    
    local new_dataset="${pool}/${ds_name}"
    
    echo ""
    draw_border
    echo -e "${WHITE}Dataset creation options:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Quick create ${NHYPRBLUE}(inherit all from parent)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Nordix optimized ${NHYPRBLUE}(recommended settings)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Custom ${NHYPRBLUE}(choose properties)${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r create_option
    
    local create_cmd="sudo zfs create"
    
    case $create_option in
        1)
            # Quick create - no extra options
            ;;
        2)
            # Nordix optimized
            create_cmd="$create_cmd -o compression=zstd -o atime=off -o relatime=on"
            create_cmd="$create_cmd -o xattr=sa -o acltype=posixacl -o dnodesize=auto"
            ;;
        3)
            # Custom - let user choose
            echo ""
            draw_border
            echo -e "${WHITE}Set custom properties:${NC}"
            draw_border
            
            # Compression
            echo ""
            echo -e "${WHITE}Compression ${NHYPRBLUE}(off|lz4|zstd|gzip)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r comp
            [ -n "$comp" ] && create_cmd="$create_cmd -o compression=$comp"
            
            # Quota
            echo ""
            echo -e "${WHITE}Quota ${NHYPRBLUE}(e.g., 100G, 1T, or empty for none)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r quota
            [ -n "$quota" ] && create_cmd="$create_cmd -o quota=$quota"
            
            # Mountpoint
            echo ""
            echo -e "${WHITE}Mountpoint ${NHYPRBLUE}(path, 'none', or empty for default)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r mountpoint
            [ -n "$mountpoint" ] && create_cmd="$create_cmd -o mountpoint=$mountpoint"
            
            # Recordsize
            echo ""
            echo -e "${WHITE}Recordsize ${NHYPRBLUE}(128K default, 1M for large files, or empty)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r recsize
            [ -n "$recsize" ] && create_cmd="$create_cmd -o recordsize=$recsize"
            ;;
        *)
            echo -e "${RED}Invalid option, using quick create.${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${WHITE}Creating dataset: ${NHYPRBLUE}$new_dataset${NC}"
    echo -e "${NARTIC}Command: $create_cmd $new_dataset${NC}"
    
    if confirm_action "Create this dataset?"; then
        echo ""
        if $create_cmd "$new_dataset"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset created!${NC}"
            echo ""
            zfs list "$new_dataset" 2>/dev/null
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to create dataset!${NC}"
        fi
    fi
    
    press_enter
}

# Delete dataset
delete_dataset() {
    clear
    echo ""
    draw_box "        DELETE DATASET            "
    echo ""
    draw_border
    echo -e "${RED}WARNING: This will permanently delete data!${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        local used=$(zfs get -H -o value used "$ds" 2>/dev/null)
        local mountpoint=$(zfs get -H -o value mountpoint "$ds" 2>/dev/null)
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC} ${WHITE}($used, $mountpoint)${NC}"
        ((i++))
    done
    
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Select dataset ${NHYPRBLUE}(1-${#datasets[@]})${NGLACIER}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local dataset="${datasets[$((selection-1))]}"
    
    # Check for children
    local children=$(zfs list -H -o name -r "$dataset" 2>/dev/null | grep -v "^${dataset}$" | wc -l)
    local snapshots=$(zfs list -H -t snapshot -o name -r "$dataset" 2>/dev/null | wc -l)
    
    echo ""
    echo -e "${WHITE}Dataset: ${NHYPRBLUE}$dataset${NC}"
    echo -e "${WHITE}Child datasets: ${NHYPRBLUE}$children${NC}"
    echo -e "${WHITE}Snapshots: ${NHYPRBLUE}$snapshots${NC}"
    
    if [ "$children" -gt 0 ] || [ "$snapshots" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}!${NC} ${WHITE}This dataset has children or snapshots.${NC}"
        echo -e "${WHITE}Use recursive delete? ${NHYPRBLUE}[y/N]${NC}"
        echo -ne "${NHYPRBLUE}❯ ${NC}"
        read -r recursive
        
        if [[ "$recursive" =~ ^[yY]$ ]]; then
            echo ""
            echo -e "${RED}FINAL WARNING:${NC}"
            echo -e "${WHITE}This will delete ${NHYPRBLUE}$dataset${WHITE} and ALL children/snapshots!${NC}"
            echo ""
            echo -e "${WHITE}Type ${NHYPRBLUE}DELETE${WHITE} to confirm:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r confirm
            
            if [ "$confirm" = "DELETE" ]; then
                if sudo zfs destroy -r "$dataset"; then
                    echo ""
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset deleted recursively!${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to delete dataset!${NC}"
                fi
            else
                echo -e "${RED}Cancelled.${NC}"
            fi
        else
            echo -e "${RED}Cancelled. Remove children/snapshots first.${NC}"
        fi
    else
        if confirm_action "Delete $dataset? This cannot be undone!"; then
            if sudo zfs destroy "$dataset"; then
                echo ""
                echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset deleted!${NC}"
            else
                echo -e "${RED}[X]${NC} ${WHITE}Failed to delete dataset!${NC}"
            fi
        fi
    fi
    
    press_enter
}

# View dataset properties
view_properties() {
    clear
    echo ""
    draw_box "       VIEW DATASET PROPERTIES    "
    echo ""
    draw_border
    echo -e "${WHITE}Select dataset:${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Select dataset ${NHYPRBLUE}(1-${#datasets[@]})${NGLACIER}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local dataset="${datasets[$((selection-1))]}"
    
    clear
    echo ""
    draw_box "    PROPERTIES: ${dataset}    "
    echo ""
    draw_border
    echo -e "${WHITE}View options:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Common properties ${NHYPRBLUE}(most useful)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Performance properties${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Space/quota properties${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Security properties${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}All properties${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r view_option
    
    echo ""
    draw_border
    
    case $view_option in
        1)
            echo -e "${WHITE}Common Properties:${NC}"
            draw_border
            echo ""
            for prop in compression atime mountpoint quota used available referenced compressratio recordsize; do
                local value=$(zfs get -H -o value "$prop" "$dataset" 2>/dev/null)
                local source=$(zfs get -H -o source "$prop" "$dataset" 2>/dev/null)
                printf "${NHYPRBLUE}❯${NC} ${NARTIC}%-18s${NC} ${WHITE}%-15s${NC} ${NHYPRBLUE}(%s)${NC}\n" "$prop" "$value" "$source"
            done
            ;;
        2)
            echo -e "${WHITE}Performance Properties:${NC}"
            draw_border
            echo ""
            for prop in compression recordsize atime relatime sync primarycache secondarycache logbias special_small_blocks; do
                local value=$(zfs get -H -o value "$prop" "$dataset" 2>/dev/null)
                local source=$(zfs get -H -o source "$prop" "$dataset" 2>/dev/null)
                printf "${NHYPRBLUE}❯${NC} ${NARTIC}%-20s${NC} ${WHITE}%-15s${NC} ${NHYPRBLUE}(%s)${NC}\n" "$prop" "$value" "$source"
            done
            ;;
        3)
            echo -e "${WHITE}Space/Quota Properties:${NC}"
            draw_border
            echo ""
            for prop in used available referenced quota refquota reservation refreservation compressratio; do
                local value=$(zfs get -H -o value "$prop" "$dataset" 2>/dev/null)
                printf "${NHYPRBLUE}❯${NC} ${NARTIC}%-18s${NC} ${WHITE}%s${NC}\n" "$prop" "$value"
            done
            ;;
        4)
            echo -e "${WHITE}Security Properties:${NC}"
            draw_border
            echo ""
            for prop in encryption keyformat keystatus readonly setuid exec devices xattr acltype; do
                local value=$(zfs get -H -o value "$prop" "$dataset" 2>/dev/null)
                printf "${NHYPRBLUE}❯${NC} ${NARTIC}%-18s${NC} ${WHITE}%s${NC}\n" "$prop" "$value"
            done
            ;;
        5)
            echo -e "${WHITE}All Properties:${NC}"
            draw_border
            echo ""
            zfs get all "$dataset" 2>/dev/null | tail -n +2 | while read -r line; do
                echo -e "${NARTIC}$line${NC}"
            done
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    
    press_enter
}

# Set/modify property
set_property() {
    clear
    echo ""
    draw_box "        SET DATASET PROPERTY      "
    echo ""
    draw_border
    echo -e "${WHITE}Select dataset:${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    draw_border
    echo ""
    echo -e "${NGLACIER}Select dataset ${NHYPRBLUE}(1-${#datasets[@]})${NGLACIER}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local dataset="${datasets[$((selection-1))]}"
    
    clear
    echo ""
    draw_box "   SET PROPERTY: ${dataset}   "
    echo ""
    draw_border
    echo -e "${WHITE}Select property category:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Compression${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Quota/Space limits${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Mountpoint${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Performance ${NHYPRBLUE}(atime, recordsize, sync)${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Cache settings${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Data integrity ${NHYPRBLUE}(checksum, copies)${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}Custom property${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r prop_category
    
    local property=""
    local value=""
    
    case $prop_category in
        1)
            echo ""
            echo -e "${WHITE}Current compression: ${NHYPRBLUE}$(zfs get -H -o value compression "$dataset")${NC}"
            echo ""
            echo -e "${WHITE}Available options:${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}off${NC}     - No compression"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}lz4${NC}     - Fast, good compression ${NHYPRBLUE}(recommended)${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}zstd${NC}    - Better compression, still fast ${GREEN}(Nordix default)${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}zstd-3${NC}  - Higher compression level"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}gzip${NC}    - High compression, slower"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}gzip-9${NC}  - Maximum compression, slowest"
            echo ""
            echo -e "${WHITE}Enter compression type:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            property="compression"
            ;;
        2)
            echo ""
            echo -e "${WHITE}Current values:${NC}"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}quota:${NC}          $(zfs get -H -o value quota "$dataset")"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}refquota:${NC}       $(zfs get -H -o value refquota "$dataset")"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}reservation:${NC}    $(zfs get -H -o value reservation "$dataset")"
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}refreservation:${NC} $(zfs get -H -o value refreservation "$dataset")"
            echo ""
            echo -e "${WHITE}Select property:${NC}"
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}quota ${NHYPRBLUE}(max space including children/snapshots)${NC}"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}refquota ${NHYPRBLUE}(max space for this dataset only)${NC}"
            echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}reservation ${NHYPRBLUE}(guaranteed space)${NC}"
            echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}refreservation ${NHYPRBLUE}(guaranteed, this dataset only)${NC}"
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r quota_opt
            
            case $quota_opt in
                1) property="quota" ;;
                2) property="refquota" ;;
                3) property="reservation" ;;
                4) property="refreservation" ;;
                *) echo -e "${RED}Invalid!${NC}"; press_enter; return ;;
            esac
            
            echo ""
            echo -e "${WHITE}Enter value ${NHYPRBLUE}(e.g., 100G, 1T, or 'none' to remove)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            ;;
        3)
            echo ""
            echo -e "${WHITE}Current mountpoint: ${NHYPRBLUE}$(zfs get -H -o value mountpoint "$dataset")${NC}"
            echo ""
            echo -e "${WHITE}Enter new mountpoint:${NC}"
            echo -e "${NARTIC}(path like /mnt/data, 'none', or 'legacy')${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            property="mountpoint"
            ;;
        4)
            echo ""
            echo -e "${WHITE}Performance properties:${NC}"
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}atime ${NHYPRBLUE}(on|off)${NC} - Current: $(zfs get -H -o value atime "$dataset")"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}relatime ${NHYPRBLUE}(on|off)${NC} - Current: $(zfs get -H -o value relatime "$dataset")"
            echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}recordsize ${NHYPRBLUE}(4K-16M)${NC} - Current: $(zfs get -H -o value recordsize "$dataset")"
            echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}sync ${NHYPRBLUE}(standard|always|disabled)${NC} - Current: $(zfs get -H -o value sync "$dataset")"
            echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}logbias ${NHYPRBLUE}(latency|throughput)${NC} - Current: $(zfs get -H -o value logbias "$dataset")"
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r perf_opt
            
            case $perf_opt in
                1) property="atime"; echo -e "${WHITE}Enter value (on/off):${NC}" ;;
                2) property="relatime"; echo -e "${WHITE}Enter value (on/off):${NC}" ;;
                3) property="recordsize"; echo -e "${WHITE}Enter value (e.g., 128K, 1M):${NC}" ;;
                4) property="sync"; echo -e "${WHITE}Enter value (standard/always/disabled):${NC}" ;;
                5) property="logbias"; echo -e "${WHITE}Enter value (latency/throughput):${NC}" ;;
                *) echo -e "${RED}Invalid!${NC}"; press_enter; return ;;
            esac
            
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            ;;
        5)
            echo ""
            echo -e "${WHITE}Cache properties:${NC}"
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}primarycache (ARC)${NC} - Current: $(zfs get -H -o value primarycache "$dataset")"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}secondarycache (L2ARC)${NC} - Current: $(zfs get -H -o value secondarycache "$dataset")"
            echo ""
            echo -e "${WHITE}Options: ${NHYPRBLUE}all${NC} | ${NHYPRBLUE}metadata${NC} | ${NHYPRBLUE}none${NC}"
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r cache_opt
            
            case $cache_opt in
                1) property="primarycache" ;;
                2) property="secondarycache" ;;
                *) echo -e "${RED}Invalid!${NC}"; press_enter; return ;;
            esac
            
            echo -e "${WHITE}Enter value (all/metadata/none):${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            ;;
        6)
            echo ""
            echo -e "${WHITE}Data integrity properties:${NC}"
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}checksum${NC} - Current: $(zfs get -H -o value checksum "$dataset")"
            echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}copies${NC} - Current: $(zfs get -H -o value copies "$dataset")"
            echo ""
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r int_opt
            
            case $int_opt in
                1)
                    property="checksum"
                    echo -e "${WHITE}Options: on, off, fletcher2, fletcher4, sha256, sha512, skein${NC}"
                    ;;
                2)
                    property="copies"
                    echo -e "${WHITE}Options: 1, 2, 3 (more copies = more safety, uses more space)${NC}"
                    ;;
                *) echo -e "${RED}Invalid!${NC}"; press_enter; return ;;
            esac
            
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            ;;
        7)
            echo ""
            echo -e "${WHITE}Enter property name:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r property
            
            if [ -z "$property" ]; then
                echo -e "${RED}No property entered!${NC}"
                press_enter
                return
            fi
            
            echo ""
            echo -e "${WHITE}Current value: ${NHYPRBLUE}$(zfs get -H -o value "$property" "$dataset" 2>/dev/null || echo "N/A")${NC}"
            echo ""
            echo -e "${WHITE}Enter new value:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r value
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            press_enter
            return
            ;;
    esac
    
    if [ -z "$value" ]; then
        echo -e "${RED}No value entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Setting ${NHYPRBLUE}$property${WHITE} = ${NHYPRBLUE}$value${WHITE} on ${NHYPRBLUE}$dataset${NC}"
    
    if confirm_action "Apply this change?"; then
        echo ""
        if sudo zfs set "$property=$value" "$dataset"; then
            echo -e "${GREEN}[OK]${NC} ${WHITE}Property set!${NC}"
            echo ""
            echo -e "${WHITE}New value: ${NHYPRBLUE}$(zfs get -H -o value "$property" "$dataset")${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to set property!${NC}"
        fi
    fi
    
    press_enter
}

# Inherit property from parent
inherit_property() {
    clear
    echo ""
    draw_box "      INHERIT PROPERTY            "
    echo ""
    draw_border
    echo -e "${WHITE}Reset property to inherit from parent dataset${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    echo -e "${NGLACIER}Select dataset:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local dataset="${datasets[$((selection-1))]}"
    
    echo ""
    echo -e "${WHITE}Enter property name to inherit:${NC}"
    echo -e "${NARTIC}(e.g., compression, quota, mountpoint)${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r property
    
    if [ -z "$property" ]; then
        echo -e "${RED}No property entered!${NC}"
        press_enter
        return
    fi
    
    local current=$(zfs get -H -o value "$property" "$dataset" 2>/dev/null)
    local source=$(zfs get -H -o source "$property" "$dataset" 2>/dev/null)
    
    echo ""
    echo -e "${WHITE}Property: ${NHYPRBLUE}$property${NC}"
    echo -e "${WHITE}Current value: ${NHYPRBLUE}$current${NC}"
    echo -e "${WHITE}Source: ${NHYPRBLUE}$source${NC}"
    
    if [ "$source" = "inherited" ] || [ "$source" = "default" ]; then
        echo ""
        echo -e "${NARTIC}Property is already inherited/default.${NC}"
        press_enter
        return
    fi
    
    if confirm_action "Inherit $property from parent?"; then
        if sudo zfs inherit "$property" "$dataset"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Property now inherited!${NC}"
            echo -e "${WHITE}New value: ${NHYPRBLUE}$(zfs get -H -o value "$property" "$dataset")${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to inherit property!${NC}"
        fi
    fi
    
    press_enter
}

# Show available properties reference
property_reference() {
    clear
    echo ""
    draw_box "     ZFS PROPERTY REFERENCE       "
    echo ""
    draw_border
    echo -e "${WHITE}Select category:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Performance properties${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Space/Quota properties${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Data integrity properties${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Mount properties${NC}"
    echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Security properties${NC}"
    echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Nordix recommended settings${NC}"
    echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}All properties${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r ref_option
    
    clear
    echo ""
    
    case $ref_option in
        1)
            draw_box "   PERFORMANCE PROPERTIES     "
            echo ""
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}compression${NC}"
            echo -e "${WHITE}  ${PROP_DESC[compression]}${NC}"
            echo -e "${GREEN}  Recommended: zstd or lz4${NC}"
            echo ""
            echo -e "${NHYPRBLUE}recordsize${NC}"
            echo -e "${WHITE}  ${PROP_DESC[recordsize]}${NC}"
            echo -e "${GREEN}  Use 1M for large files (video, backups)${NC}"
            echo ""
            echo -e "${NHYPRBLUE}atime${NC}"
            echo -e "${WHITE}  ${PROP_DESC[atime]}${NC}"
            echo -e "${GREEN}  Recommended: off${NC}"
            echo ""
            echo -e "${NHYPRBLUE}relatime${NC}"
            echo -e "${WHITE}  ${PROP_DESC[relatime]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}sync${NC}"
            echo -e "${WHITE}  ${PROP_DESC[sync]}${NC}"
            echo -e "${RED}  WARNING: disabled can cause data loss on crash${NC}"
            echo ""
            echo -e "${NHYPRBLUE}primarycache${NC}"
            echo -e "${WHITE}  ${PROP_DESC[primarycache]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}secondarycache${NC}"
            echo -e "${WHITE}  ${PROP_DESC[secondarycache]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}logbias${NC}"
            echo -e "${WHITE}  ${PROP_DESC[logbias]}${NC}"
            ;;
        2)
            draw_box "    SPACE/QUOTA PROPERTIES    "
            echo ""
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}quota${NC}"
            echo -e "${WHITE}  ${PROP_DESC[quota]}${NC}"
            echo -e "${NARTIC}  Example: zfs set quota=100G pool/data${NC}"
            echo ""
            echo -e "${NHYPRBLUE}refquota${NC}"
            echo -e "${WHITE}  ${PROP_DESC[refquota]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}reservation${NC}"
            echo -e "${WHITE}  ${PROP_DESC[reservation]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}refreservation${NC}"
            echo -e "${WHITE}  ${PROP_DESC[refreservation]}${NC}"
            ;;
        3)
            draw_box "   DATA INTEGRITY PROPERTIES  "
            echo ""
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}checksum${NC}"
            echo -e "${WHITE}  ${PROP_DESC[checksum]}${NC}"
            echo -e "${GREEN}  Recommended: on (default, uses fletcher4)${NC}"
            echo ""
            echo -e "${NHYPRBLUE}copies${NC}"
            echo -e "${WHITE}  ${PROP_DESC[copies]}${NC}"
            echo -e "${GREEN}  Use 2 for important data on single disk${NC}"
            echo ""
            echo -e "${NHYPRBLUE}dedup${NC}"
            echo -e "${WHITE}  ${PROP_DESC[dedup]}${NC}"
            echo -e "${RED}  WARNING: Uses lots of RAM! Not recommended.${NC}"
            ;;
        4)
            draw_box "      MOUNT PROPERTIES        "
            echo ""
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}mountpoint${NC}"
            echo -e "${WHITE}  ${PROP_DESC[mountpoint]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}canmount${NC}"
            echo -e "${WHITE}  ${PROP_DESC[canmount]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}readonly${NC}"
            echo -e "${WHITE}  ${PROP_DESC[readonly]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}setuid${NC}"
            echo -e "${WHITE}  ${PROP_DESC[setuid]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}exec${NC}"
            echo -e "${WHITE}  ${PROP_DESC[exec]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}devices${NC}"
            echo -e "${WHITE}  ${PROP_DESC[devices]}${NC}"
            ;;
        5)
            draw_box "     SECURITY PROPERTIES      "
            echo ""
            draw_border
            echo ""
            echo -e "${NHYPRBLUE}encryption${NC}"
            echo -e "${WHITE}  ${PROP_DESC[encryption]}${NC}"
            echo -e "${NARTIC}  Must be set at creation time!${NC}"
            echo ""
            echo -e "${NHYPRBLUE}keyformat${NC}"
            echo -e "${WHITE}  ${PROP_DESC[keyformat]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}keylocation${NC}"
            echo -e "${WHITE}  ${PROP_DESC[keylocation]}${NC}"
            echo ""
            echo -e "${NHYPRBLUE}acltype${NC}"
            echo -e "${WHITE}  ${PROP_DESC[acltype]}${NC}"
            echo -e "${GREEN}  Recommended: posixacl${NC}"
            echo ""
            echo -e "${NHYPRBLUE}xattr${NC}"
            echo -e "${WHITE}  ${PROP_DESC[xattr]}${NC}"
            echo -e "${GREEN}  Recommended: sa (system attribute)${NC}"
            ;;
        6)
            draw_box "  NORDIX RECOMMENDED SETTINGS "
            echo ""
            draw_border
            echo -e "${WHITE}Optimized for performance:${NC}"
            draw_border
            echo ""
            for prop in "${!NORDIX_RECOMMENDED[@]}"; do
                echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$prop${NC} = ${GREEN}${NORDIX_RECOMMENDED[$prop]}${NC}"
            done
            echo ""
            draw_border
            echo ""
            echo -e "${WHITE}Apply all to a dataset? Enter dataset name or press Enter to skip:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r apply_dataset
            
            if [ -n "$apply_dataset" ]; then
                if zfs list "$apply_dataset" &>/dev/null; then
                    if confirm_action "Apply Nordix settings to $apply_dataset?"; then
                        for prop in "${!NORDIX_RECOMMENDED[@]}"; do
                            echo -ne "${WHITE}Setting $prop... ${NC}"
                            if sudo zfs set "$prop=${NORDIX_RECOMMENDED[$prop]}" "$apply_dataset" 2>/dev/null; then
                                echo -e "${GREEN}[OK]${NC}"
                            else
                                echo -e "${YELLOW}[SKIP]${NC}"
                            fi
                        done
                        echo ""
                        echo -e "${GREEN}[OK]${NC} ${WHITE}Nordix settings applied!${NC}"
                    fi
                else
                    echo -e "${RED}Dataset not found!${NC}"
                fi
            fi
            ;;
        7)
            draw_box "     ALL ZFS PROPERTIES       "
            echo ""
            echo -e "${WHITE}All available ZFS properties:${NC}"
            draw_border
            echo ""
            for prop in "${!PROP_DESC[@]}"; do
                echo -e "${NHYPRBLUE}$prop${NC}"
                echo -e "${WHITE}  ${PROP_DESC[$prop]}${NC}"
                echo ""
            done | sort
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    
    press_enter
}

# Rename dataset
rename_dataset() {
    clear
    echo ""
    draw_box "        RENAME DATASET            "
    echo ""
    draw_border
    echo -e "${WHITE}Select dataset to rename:${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    echo -e "${NGLACIER}Select dataset:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local dataset="${datasets[$((selection-1))]}"
    local pool="${dataset%%/*}"
    
    echo ""
    echo -e "${WHITE}Current name: ${NHYPRBLUE}$dataset${NC}"
    echo ""
    echo -e "${WHITE}Enter new name ${NHYPRBLUE}(full path like $pool/newname)${WHITE}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r newname
    
    if [ -z "$newname" ]; then
        echo -e "${RED}No name entered!${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${WHITE}Rename: ${NHYPRBLUE}$dataset${WHITE} -> ${NHYPRBLUE}$newname${NC}"
    
    if confirm_action "Rename dataset?"; then
        if sudo zfs rename "$dataset" "$newname"; then
            echo ""
            echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset renamed!${NC}"
        else
            echo -e "${RED}[X]${NC} ${WHITE}Failed to rename dataset!${NC}"
        fi
    fi
    
    press_enter
}

# Mount/unmount dataset
mount_dataset() {
    clear
    echo ""
    draw_box "       MOUNT/UNMOUNT DATASET      "
    echo ""
    draw_border
    echo -e "${WHITE}Select operation:${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Mount a dataset${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Unmount a dataset${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Mount all datasets${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Show mount status${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r mount_option
    
    case $mount_option in
        1)
            echo ""
            echo -e "${WHITE}Unmounted datasets:${NC}"
            echo ""
            
            local unmounted=()
            while IFS= read -r ds; do
                local mounted=$(zfs get -H -o value mounted "$ds" 2>/dev/null)
                if [ "$mounted" = "no" ]; then
                    unmounted+=("$ds")
                    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$ds${NC}"
                fi
            done < <(get_datasets)
            
            if [ ${#unmounted[@]} -eq 0 ]; then
                echo -e "${NARTIC}All datasets are mounted.${NC}"
                press_enter
                return
            fi
            
            echo ""
            echo -e "${WHITE}Enter dataset name to mount:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r ds_mount
            
            if [ -n "$ds_mount" ]; then
                if sudo zfs mount "$ds_mount"; then
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset mounted!${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to mount!${NC}"
                fi
            fi
            ;;
        2)
            echo ""
            echo -e "${WHITE}Mounted datasets:${NC}"
            echo ""
            
            while IFS= read -r ds; do
                local mounted=$(zfs get -H -o value mounted "$ds" 2>/dev/null)
                local mountpoint=$(zfs get -H -o value mountpoint "$ds" 2>/dev/null)
                if [ "$mounted" = "yes" ]; then
                    echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}$ds${NC} ${WHITE}($mountpoint)${NC}"
                fi
            done < <(get_datasets)
            
            echo ""
            echo -e "${WHITE}Enter dataset name to unmount:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r ds_umount
            
            if [ -n "$ds_umount" ]; then
                if sudo zfs unmount "$ds_umount"; then
                    echo -e "${GREEN}[OK]${NC} ${WHITE}Dataset unmounted!${NC}"
                else
                    echo -e "${RED}[X]${NC} ${WHITE}Failed to unmount! (may be in use)${NC}"
                fi
            fi
            ;;
        3)
            echo ""
            echo -e "${WHITE}Mounting all datasets...${NC}"
            if sudo zfs mount -a; then
                echo -e "${GREEN}[OK]${NC} ${WHITE}All datasets mounted!${NC}"
            else
                echo -e "${YELLOW}!${NC} ${WHITE}Some datasets may have failed to mount.${NC}"
            fi
            ;;
        4)
            echo ""
            draw_border
            echo -e "${WHITE}Dataset Mount Status:${NC}"
            draw_border
            echo ""
            
            printf "${NHYPRBLUE}%-40s %-10s %s${NC}\n" "DATASET" "MOUNTED" "MOUNTPOINT"
            
            while IFS= read -r ds; do
                local mounted=$(zfs get -H -o value mounted "$ds" 2>/dev/null)
                local mountpoint=$(zfs get -H -o value mountpoint "$ds" 2>/dev/null)
                
                if [ "$mounted" = "yes" ]; then
                    printf "${NARTIC}%-40s${NC} ${GREEN}%-10s${NC} ${WHITE}%s${NC}\n" "$ds" "$mounted" "$mountpoint"
                else
                    printf "${NARTIC}%-40s${NC} ${RED}%-10s${NC} ${WHITE}%s${NC}\n" "$ds" "$mounted" "$mountpoint"
                fi
            done < <(get_datasets)
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    
    press_enter
}

# Dataset comparison (show differences between two datasets)
compare_datasets() {
    clear
    echo ""
    draw_box "       COMPARE DATASETS           "
    echo ""
    draw_border
    echo -e "${WHITE}Compare properties between two datasets${NC}"
    draw_border
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    echo -e "${WHITE}Select first dataset:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel1
    
    if ! [[ "$sel1" =~ ^[0-9]+$ ]] || [ "$sel1" -lt 1 ] || [ "$sel1" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    echo -e "${WHITE}Select second dataset:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel2
    
    if ! [[ "$sel2" =~ ^[0-9]+$ ]] || [ "$sel2" -lt 1 ] || [ "$sel2" -gt ${#datasets[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        press_enter
        return
    fi
    
    local ds1="${datasets[$((sel1-1))]}"
    local ds2="${datasets[$((sel2-1))]}"
    
    clear
    echo ""
    draw_box "       PROPERTY COMPARISON        "
    echo ""
    draw_border
    echo -e "${WHITE}Comparing: ${NHYPRBLUE}$ds1${WHITE} vs ${NHYPRBLUE}$ds2${NC}"
    draw_border
    echo ""
    
    printf "${NHYPRBLUE}%-20s %-20s %-20s${NC}\n" "PROPERTY" "$ds1" "$ds2"
    echo ""
    
    for prop in compression recordsize atime quota mountpoint checksum copies primarycache sync encryption; do
        local val1=$(zfs get -H -o value "$prop" "$ds1" 2>/dev/null)
        local val2=$(zfs get -H -o value "$prop" "$ds2" 2>/dev/null)
        
        if [ "$val1" = "$val2" ]; then
            printf "${NARTIC}%-20s${NC} ${WHITE}%-20s %-20s${NC}\n" "$prop" "$val1" "$val2"
        else
            printf "${NARTIC}%-20s${NC} ${YELLOW}%-20s${NC} ${YELLOW}%-20s${NC} ${RED}[DIFF]${NC}\n" "$prop" "$val1" "$val2"
        fi
    done
    
    press_enter
}

# ============================================
# MAIN MENU
# ============================================

show_main_menu() {
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
    draw_box "        NORDIX CLI DATASET          "
    echo ""
    echo ""
    draw_border
    echo -e "${WHITE}ZFS Dataset Management${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}List datasets${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Create dataset${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Delete dataset${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}View properties${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Set property${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Inherit property ${NHYPRBLUE}(reset to parent)${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Property reference ${NHYPRBLUE}(documentation)${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Rename dataset${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Mount/Unmount${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Compare datasets${NC}"
    echo ""
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-10)${NGLACIER}:${NC}"
    echo ""
}

# ============================================
# MAIN
# ============================================

check_zfs

while true; do
    show_main_menu
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1) list_datasets ;;
        2) create_dataset ;;
        3) delete_dataset ;;
        4) view_properties ;;
        5) set_property ;;
        6) inherit_property ;;
        7) property_reference ;;
        8) rename_dataset ;;
        9) mount_dataset ;;
        10) compare_datasets ;;
        0)
            clear
            echo ""
            draw_border
            echo -e "${GREEN}Thank you for using Nordix CLI Dataset!${NC}"
            echo -e "${NARTIC}Nordix follows the law of performance.${NC}"
            draw_border
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
