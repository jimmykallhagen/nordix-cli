#!/bin/bash
##=============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                       #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0   #
 # Copyright (c) 2025 Jimmy Källhagen                                          #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                   #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                      #
##=============================================================================##

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
# AUTO-SNAPSHOT CONFIGURATION
# ============================================
AUTO_SNAPSHOT_CONFIG="/etc/nordix/auto-snapshot.conf"
AUTO_SNAPSHOT_SERVICE="nordix-auto-snapshot"
AUTO_SNAPSHOT_PREFIX="auto-snapshot"

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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}!${NC} ${WHITE}Some operations require root privileges.${NC}"
        echo -e "${NARTIC}You may be prompted for your password.${NC}"
        echo ""
    fi
}

get_pools() {
    zpool list -H -o name 2>/dev/null
}

get_datasets() {
    local pool="$1"
    if [ -n "$pool" ]; then
        zfs list -H -o name -r "$pool" 2>/dev/null
    else
        zfs list -H -o name 2>/dev/null
    fi
}

get_snapshots() {
    local dataset="$1"
    if [ -n "$dataset" ]; then
        zfs list -H -t snapshot -o name -r "$dataset" 2>/dev/null
    else
        zfs list -H -t snapshot -o name 2>/dev/null
    fi
}

# ============================================
# AUTO-SNAPSHOT FUNCTIONS
# ============================================

is_auto_snapshot_enabled() {
    systemctl is-enabled "${AUTO_SNAPSHOT_SERVICE}.timer" &>/dev/null
}

is_auto_snapshot_active() {
    systemctl is-active "${AUTO_SNAPSHOT_SERVICE}.timer" &>/dev/null
}

get_retention_days() {
    if [ -f "$AUTO_SNAPSHOT_CONFIG" ]; then
        grep "^RETENTION_DAYS=" "$AUTO_SNAPSHOT_CONFIG" 2>/dev/null | cut -d'=' -f2 | tr -d '"'
    else
        echo "14"
    fi
}

count_auto_snapshots() {
    zfs list -H -t snapshot -o name 2>/dev/null | grep -c "@${AUTO_SNAPSHOT_PREFIX}_"
}

get_auto_snapshot_usage() {
    local total=0
    while IFS= read -r snap; do
        local used=$(zfs get -H -p -o value used "$snap" 2>/dev/null)
        if [[ "$used" =~ ^[0-9]+$ ]]; then
            total=$((total + used))
        fi
    done < <(zfs list -H -t snapshot -o name 2>/dev/null | grep "@${AUTO_SNAPSHOT_PREFIX}_")
    
    if [ "$total" -ge 1073741824 ]; then
        echo "$(echo "scale=2; $total/1073741824" | bc) GB"
    elif [ "$total" -ge 1048576 ]; then
        echo "$(echo "scale=2; $total/1048576" | bc) MB"
    elif [ "$total" -ge 1024 ]; then
        echo "$(echo "scale=2; $total/1024" | bc) KB"
    else
        echo "$total B"
    fi
}

auto_snapshot_menu() {
    while true; do
        clear
        echo ""
        draw_box "     AUTO-SNAPSHOT MANAGEMENT     "
        echo ""
        
        draw_border
        echo -e "${WHITE}Current Status:${NC}"
        draw_border
        echo ""
        
        if is_auto_snapshot_enabled; then
            if is_auto_snapshot_active; then
                echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Service:${NC}    ${GREEN}Enabled & Active${NC}"
            else
                echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Service:${NC}    ${YELLOW}Enabled but Inactive${NC}"
            fi
        else
            echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Service:${NC}    ${RED}Disabled${NC}"
        fi
        
        local retention=$(get_retention_days)
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Retention:${NC}  ${WHITE}$retention days${NC}"
        
        local snap_count=$(count_auto_snapshots)
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Snapshots:${NC}  ${WHITE}$snap_count auto-snapshots${NC}"
        
        local usage=$(get_auto_snapshot_usage)
        echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Disk usage:${NC} ${WHITE}$usage${NC}"
        
        if is_auto_snapshot_active; then
            local next_run=$(systemctl list-timers "${AUTO_SNAPSHOT_SERVICE}.timer" --no-pager 2>/dev/null | grep "$AUTO_SNAPSHOT_SERVICE" | awk '{print $1, $2, $3}')
            if [ -n "$next_run" ]; then
                echo -e "${NHYPRBLUE}❯${NC} ${NARTIC}Next run:${NC}   ${WHITE}$next_run${NC}"
            fi
        fi
        
        echo ""
        draw_border
        echo -e "${WHITE}Options:${NC}"
        draw_border
        echo ""
        
        if is_auto_snapshot_enabled; then
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Disable auto-snapshots${NC}"
        else
            echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Enable auto-snapshots${NC}"
        fi
        echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Set retention period${NC}"
        echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Run now ${NHYPRBLUE}(create snapshot immediately)${NC}"
        echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}View auto-snapshots${NC}"
        echo -e "${BLUE}5${NC} ${NVFROST}-${NC} ${NARTIC}Cleanup old auto-snapshots${NC}"
        echo -e "${BLUE}6${NC} ${NVFROST}-${NC} ${NARTIC}Select datasets to snapshot${NC}"
        echo -e "${BLUE}7${NC} ${NVFROST}-${NC} ${NARTIC}View logs${NC}"
        echo ""
        echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Back to main menu${NC}"
        draw_border
        echo ""
        echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-7)${NGLACIER}:${NC}"
        echo -ne "${NHYPRBLUE}❯ ${NC}"
        read -r choice
        
        case $choice in
            1) toggle_auto_snapshot ;;
            2) set_retention_period ;;
            3) run_auto_snapshot_now ;;
            4) view_auto_snapshots ;;
            5) cleanup_auto_snapshots ;;
            6) select_auto_snapshot_datasets ;;
            7) view_auto_snapshot_logs ;;
            0) return ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

toggle_auto_snapshot() {
    echo ""
    
    if is_auto_snapshot_enabled; then
        if confirm_action "Disable auto-snapshots?"; then
            echo ""
            echo -e "${WHITE}Disabling auto-snapshot service...${NC}"
            sudo systemctl stop "${AUTO_SNAPSHOT_SERVICE}.timer" 2>/dev/null
            sudo systemctl disable "${AUTO_SNAPSHOT_SERVICE}.timer" 2>/dev/null
            echo -e "${GREEN}[OK]${NC} ${WHITE}Auto-snapshots disabled.${NC}"
            echo -e "${NARTIC}Your existing auto-snapshots are preserved.${NC}"
        fi
    else
        if [ ! -f "/etc/systemd/system/${AUTO_SNAPSHOT_SERVICE}.timer" ]; then
            echo -e "${YELLOW}!${NC} ${WHITE}Auto-snapshot service not installed.${NC}"
            echo ""
            if confirm_action "Install auto-snapshot service now?"; then
                install_auto_snapshot_service
            else
                press_enter
                return
            fi
        fi
        
        if confirm_action "Enable auto-snapshots? (daily at 03:00)"; then
            echo ""
            echo -e "${WHITE}Enabling auto-snapshot service...${NC}"
            sudo systemctl daemon-reload
            sudo systemctl enable "${AUTO_SNAPSHOT_SERVICE}.timer" 2>/dev/null
            sudo systemctl start "${AUTO_SNAPSHOT_SERVICE}.timer" 2>/dev/null
            echo -e "${GREEN}[OK]${NC} ${WHITE}Auto-snapshots enabled!${NC}"
            echo -e "${NARTIC}Snapshots will be created daily at 03:00.${NC}"
        fi
    fi
    
    press_enter
}

install_auto_snapshot_service() {
    echo ""
    echo -e "${WHITE}Installing auto-snapshot service...${NC}"
    echo ""
    
    sudo mkdir -p /etc/nordix
    
    if [ ! -f "$AUTO_SNAPSHOT_CONFIG" ]; then
        sudo tee "$AUTO_SNAPSHOT_CONFIG" > /dev/null << 'EOF'
# Nordix Auto-Snapshot Configuration
RETENTION_DAYS=14
DATASETS=""
SNAPSHOT_PREFIX="auto-snapshot"
EOF
        echo -e "${GREEN}[OK]${NC} ${WHITE}Config file created${NC}"
    fi
    
    sudo tee /usr/local/bin/nordix-auto-snapshot > /dev/null << 'SCRIPT'
#!/bin/bash
CONFIG_FILE="/etc/nordix/auto-snapshot.conf"
LOG_FILE="/var/log/nordix-auto-snapshot.log"
SNAPSHOT_PREFIX="auto-snapshot"
RETENTION_DAYS=14
DATASETS=""

log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
    echo "[$timestamp] $1"
}

load_config() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

get_datasets() {
    if [ -n "$DATASETS" ]; then
        echo "$DATASETS" | tr ' ' '\n'
    else
        zfs list -H -o name 2>/dev/null
    fi
}

create_snapshots() {
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local snapshot_name="${SNAPSHOT_PREFIX}_${timestamp}"
    local success=0 failed=0
    
    log "Starting auto-snapshot: $snapshot_name"
    
    while IFS= read -r dataset; do
        [ -z "$dataset" ] && continue
        if zfs snapshot "${dataset}@${snapshot_name}" 2>/dev/null; then
            log "  [OK] ${dataset}@${snapshot_name}"
            ((success++))
        else
            log "  [FAIL] ${dataset}@${snapshot_name}"
            ((failed++))
        fi
    done < <(get_datasets)
    
    log "Complete: $success created, $failed failed"
}

cleanup_old_snapshots() {
    local cutoff=$(date -d "$RETENTION_DAYS days ago" +%Y-%m-%d 2>/dev/null || date -v-${RETENTION_DAYS}d +%Y-%m-%d)
    log "Cleanup: removing auto-snapshots before $cutoff"
    
    zfs list -H -t snapshot -o name 2>/dev/null | grep "@${SNAPSHOT_PREFIX}_" | while read -r snap; do
        local snap_date=$(echo "$snap" | grep -oP "${SNAPSHOT_PREFIX}_\K[0-9]{4}-[0-9]{2}-[0-9]{2}")
        if [ -n "$snap_date" ] && [[ "$snap_date" < "$cutoff" ]]; then
            if zfs destroy "$snap" 2>/dev/null; then
                log "  [DEL] $snap"
            fi
        fi
    done
}

[ "$EUID" -ne 0 ] && { echo "Run as root"; exit 1; }
command -v zfs &>/dev/null || { echo "ZFS not found"; exit 1; }

mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$CONFIG_FILE")"
load_config

case "$1" in
    --create|-c) create_snapshots ;;
    --cleanup|-C) cleanup_old_snapshots ;;
    *) create_snapshots; cleanup_old_snapshots ;;
esac
SCRIPT
    
    sudo chmod +x /usr/local/bin/nordix-auto-snapshot
    echo -e "${GREEN}[OK]${NC} ${WHITE}Snapshot script installed${NC}"
    
    sudo tee /etc/systemd/system/${AUTO_SNAPSHOT_SERVICE}.service > /dev/null << EOF
[Unit]
Description=Nordix ZFS Auto-Snapshot
After=zfs.target
Requires=zfs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nordix-auto-snapshot
Nice=19
IOSchedulingClass=idle
EOF
    echo -e "${GREEN}[OK]${NC} ${WHITE}Systemd service created${NC}"
    
    sudo tee /etc/systemd/system/${AUTO_SNAPSHOT_SERVICE}.timer > /dev/null << EOF
[Unit]
Description=Nordix ZFS Auto-Snapshot Timer

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=1800

[Install]
WantedBy=timers.target
EOF
    echo -e "${GREEN}[OK]${NC} ${WHITE}Systemd timer created${NC}"
    
    sudo systemctl daemon-reload
    echo -e "${GREEN}[OK]${NC} ${WHITE}Installation complete!${NC}"
}

set_retention_period() {
    clear
    echo ""
    draw_box "      SET RETENTION PERIOD        "
    echo ""
    draw_border
    echo -e "${WHITE}Current retention: ${NHYPRBLUE}$(get_retention_days) days${NC}"
    draw_border
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}7 days ${NHYPRBLUE}(minimal)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}14 days ${NHYPRBLUE}(recommended)${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}30 days ${NHYPRBLUE}(maximum protection)${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Custom${NC}"
    echo ""
    echo -e "${NGLACIER}Choose option:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    local new_retention=""
    case $choice in
        1) new_retention=7 ;;
        2) new_retention=14 ;;
        3) new_retention=30 ;;
        4)
            echo -e "${WHITE}Enter days ${NHYPRBLUE}(1-365)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r custom
            [[ "$custom" =~ ^[0-9]+$ ]] && [ "$custom" -ge 1 ] && [ "$custom" -le 365 ] && new_retention=$custom
            ;;
    esac
    
    if [ -n "$new_retention" ]; then
        sudo mkdir -p /etc/nordix
        if [ -f "$AUTO_SNAPSHOT_CONFIG" ]; then
            sudo sed -i "s/^RETENTION_DAYS=.*/RETENTION_DAYS=$new_retention/" "$AUTO_SNAPSHOT_CONFIG"
        else
            echo "RETENTION_DAYS=$new_retention" | sudo tee "$AUTO_SNAPSHOT_CONFIG" > /dev/null
        fi
        echo -e "${GREEN}[OK]${NC} ${WHITE}Retention set to $new_retention days${NC}"
    fi
    press_enter
}

run_auto_snapshot_now() {
    echo ""
    if confirm_action "Create auto-snapshot now?"; then
        echo ""
        local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
        local snapshot_name="${AUTO_SNAPSHOT_PREFIX}_${timestamp}"
        
        while IFS= read -r dataset; do
            [ -z "$dataset" ] && continue
            echo -ne "${WHITE}$dataset@$snapshot_name... ${NC}"
            if sudo zfs snapshot "${dataset}@${snapshot_name}" 2>/dev/null; then
                echo -e "${GREEN}[OK]${NC}"
            else
                echo -e "${RED}[X]${NC}"
            fi
        done < <(get_datasets)
        
        echo -e "${GREEN}[OK]${NC} ${WHITE}Auto-snapshot complete!${NC}"
    fi
    press_enter
}

view_auto_snapshots() {
    clear
    echo ""
    draw_box "       AUTO-SNAPSHOTS             "
    echo ""
    
    local snaps=$(zfs list -t snapshot -o name,used,creation -s creation 2>/dev/null | grep "@${AUTO_SNAPSHOT_PREFIX}_")
    
    if [ -z "$snaps" ]; then
        echo -e "${NARTIC}No auto-snapshots found.${NC}"
    else
        draw_border
        echo -e "${WHITE}Auto-snapshots (newest first):${NC}"
        draw_border
        echo ""
        echo "$snaps" | tac | head -30
        echo ""
        echo -e "${NARTIC}Total: $(count_auto_snapshots) | Usage: $(get_auto_snapshot_usage)${NC}"
    fi
    press_enter
}

cleanup_auto_snapshots() {
    clear
    echo ""
    draw_box "    CLEANUP AUTO-SNAPSHOTS        "
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Normal cleanup ${NHYPRBLUE}(respect retention)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Delete ALL auto-snapshots${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Delete older than X days${NC}"
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1)
            echo -e "${WHITE}Running cleanup...${NC}"
            if [ -x /usr/local/bin/nordix-auto-snapshot ]; then
                sudo /usr/local/bin/nordix-auto-snapshot --cleanup
            fi
            echo -e "${GREEN}[OK]${NC} ${WHITE}Cleanup complete!${NC}"
            ;;
        2)
            local count=$(count_auto_snapshots)
            if confirm_action "Delete ALL $count auto-snapshots?"; then
                zfs list -H -t snapshot -o name 2>/dev/null | grep "@${AUTO_SNAPSHOT_PREFIX}_" | while read -r snap; do
                    sudo zfs destroy "$snap" 2>/dev/null && echo -e "${GREEN}[DEL]${NC} $snap"
                done
            fi
            ;;
        3)
            echo -e "${WHITE}Delete older than how many days?${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r days
            if [[ "$days" =~ ^[0-9]+$ ]]; then
                local cutoff=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d)
                zfs list -H -t snapshot -o name 2>/dev/null | grep "@${AUTO_SNAPSHOT_PREFIX}_" | while read -r snap; do
                    local snap_date=$(echo "$snap" | grep -oP "${AUTO_SNAPSHOT_PREFIX}_\K[0-9]{4}-[0-9]{2}-[0-9]{2}")
                    if [ -n "$snap_date" ] && [[ "$snap_date" < "$cutoff" ]]; then
                        sudo zfs destroy "$snap" 2>/dev/null && echo -e "${GREEN}[DEL]${NC} $snap"
                    fi
                done
            fi
            ;;
    esac
    press_enter
}

select_auto_snapshot_datasets() {
    clear
    echo ""
    draw_box "   SELECT DATASETS TO SNAPSHOT    "
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}All datasets ${NHYPRBLUE}(default)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Select specific datasets${NC}"
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1)
            sudo sed -i 's/^DATASETS=.*/DATASETS=""/' "$AUTO_SNAPSHOT_CONFIG" 2>/dev/null
            echo -e "${GREEN}[OK]${NC} ${WHITE}All datasets will be snapshotted.${NC}"
            ;;
        2)
            echo ""
            local datasets=($(get_datasets))
            local i=1
            for ds in "${datasets[@]}"; do
                echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
                ((i++))
            done
            echo ""
            echo -e "${WHITE}Enter numbers ${NHYPRBLUE}(e.g., 1 3 5)${WHITE}:${NC}"
            echo -ne "${NHYPRBLUE}❯ ${NC}"
            read -r selections
            
            local selected=""
            for sel in $selections; do
                [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le ${#datasets[@]} ] && selected="$selected ${datasets[$((sel-1))]}"
            done
            selected=$(echo "$selected" | xargs)
            
            if [ -n "$selected" ]; then
                sudo sed -i "s|^DATASETS=.*|DATASETS=\"$selected\"|" "$AUTO_SNAPSHOT_CONFIG" 2>/dev/null
                echo -e "${GREEN}[OK]${NC} ${WHITE}Selected: $selected${NC}"
            fi
            ;;
    esac
    press_enter
}

view_auto_snapshot_logs() {
    clear
    echo ""
    draw_box "      AUTO-SNAPSHOT LOGS          "
    echo ""
    
    local log="/var/log/nordix-auto-snapshot.log"
    if [ -f "$log" ]; then
        tail -40 "$log"
    else
        echo -e "${NARTIC}No logs yet.${NC}"
    fi
    press_enter
}

# ============================================
# MANUAL SNAPSHOT FUNCTIONS
# ============================================

list_snapshots() {
    clear
    echo ""
    draw_box "         LIST SNAPSHOTS           "
    echo ""
    
    local snaps=$(zfs list -t snapshot -o name,used,refer,creation -s creation 2>/dev/null)
    
    if [ -z "$snaps" ]; then
        echo -e "${NARTIC}No snapshots found.${NC}"
    else
        echo "$snaps" | head -1
        echo "$snaps" | tail -n +2 | while read -r line; do
            if echo "$line" | grep -q "@${AUTO_SNAPSHOT_PREFIX}_"; then
                echo -e "${NARTIC}$line${NC} ${NHYPRBLUE}[auto]${NC}"
            else
                echo -e "${WHITE}$line${NC}"
            fi
        done
    fi
    
    echo ""
    draw_border
    local total=$(zfs list -H -t snapshot 2>/dev/null | wc -l)
    local auto=$(count_auto_snapshots)
    echo -e "${WHITE}Total: $total | Auto: $auto | Manual: $((total-auto))${NC}"
    press_enter
}

create_snapshot() {
    clear
    echo ""
    draw_box "        CREATE SNAPSHOT           "
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
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#datasets[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local dataset="${datasets[$((sel-1))]}"
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    
    echo ""
    echo -e "${BLUE}1${NC} ${NVFROST}-${NC} ${NARTIC}Auto name ${NHYPRBLUE}(manual_$timestamp)${NC}"
    echo -e "${BLUE}2${NC} ${NVFROST}-${NC} ${NARTIC}Custom name${NC}"
    echo -e "${BLUE}3${NC} ${NVFROST}-${NC} ${NARTIC}Pre-update${NC}"
    echo -e "${BLUE}4${NC} ${NVFROST}-${NC} ${NARTIC}Pre-install${NC}"
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r opt
    
    local snap_name=""
    case $opt in
        1) snap_name="${dataset}@manual_${timestamp}" ;;
        2) echo -ne "${WHITE}Name: ${NC}"; read -r n; snap_name="${dataset}@${n}" ;;
        3) snap_name="${dataset}@pre-update_${timestamp}" ;;
        4) snap_name="${dataset}@pre-install_${timestamp}" ;;
        *) echo -e "${RED}Invalid!${NC}"; press_enter; return ;;
    esac
    
    if confirm_action "Create $snap_name?"; then
        sudo zfs snapshot "$snap_name" && echo -e "${GREEN}[OK]${NC} ${WHITE}Created!${NC}" || echo -e "${RED}[X]${NC} ${WHITE}Failed!${NC}"
    fi
    press_enter
}

create_recursive_snapshot() {
    clear
    echo ""
    draw_box "     RECURSIVE SNAPSHOT           "
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#datasets[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local target="${datasets[$((sel-1))]}"
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    
    if confirm_action "Create recursive snapshot of $target?"; then
        sudo zfs snapshot -r "${target}@recursive_${timestamp}" && echo -e "${GREEN}[OK]${NC}" || echo -e "${RED}[X]${NC}"
    fi
    press_enter
}

delete_snapshot() {
    clear
    echo ""
    draw_box "        DELETE SNAPSHOT           "
    echo ""
    
    local manual_snaps=()
    while IFS= read -r snap; do
        echo "$snap" | grep -q "@${AUTO_SNAPSHOT_PREFIX}_" || manual_snaps+=("$snap")
    done < <(get_snapshots)
    
    [ ${#manual_snaps[@]} -eq 0 ] && { echo -e "${NARTIC}No manual snapshots.${NC}"; press_enter; return; }
    
    local i=1
    for snap in "${manual_snaps[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$snap${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#manual_snaps[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local snap="${manual_snaps[$((sel-1))]}"
    if confirm_action "Delete $snap?"; then
        sudo zfs destroy "$snap" && echo -e "${GREEN}[OK]${NC}" || echo -e "${RED}[X]${NC}"
    fi
    press_enter
}

rollback_snapshot() {
    clear
    echo ""
    draw_box "       ROLLBACK SNAPSHOT          "
    echo ""
    draw_border
    echo -e "${RED}WARNING: All data after snapshot will be LOST!${NC}"
    draw_border
    echo ""
    
    local snapshots=($(get_snapshots))
    [ ${#snapshots[@]} -eq 0 ] && { echo -e "${NARTIC}No snapshots.${NC}"; press_enter; return; }
    
    local i=1
    for snap in "${snapshots[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$snap${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#snapshots[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local snap="${snapshots[$((sel-1))]}"
    
    echo ""
    echo -e "${WHITE}Type ${NHYPRBLUE}ROLLBACK${WHITE} to confirm:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r confirm
    
    [ "$confirm" = "ROLLBACK" ] || { echo -e "${RED}Cancelled.${NC}"; press_enter; return; }
    
    sudo zfs rollback -r "$snap" && echo -e "${GREEN}[OK]${NC} ${WHITE}Rolled back!${NC}" || echo -e "${RED}[X]${NC}"
    press_enter
}

clone_snapshot() {
    clear
    echo ""
    draw_box "         CLONE SNAPSHOT           "
    echo ""
    
    local snapshots=($(get_snapshots))
    [ ${#snapshots[@]} -eq 0 ] && { echo -e "${NARTIC}No snapshots.${NC}"; press_enter; return; }
    
    local i=1
    for snap in "${snapshots[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$snap${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#snapshots[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local snap="${snapshots[$((sel-1))]}"
    local pool="${snap%%/*}"
    
    echo -e "${WHITE}New dataset name:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r name
    
    [ -z "$name" ] && { echo -e "${RED}No name!${NC}"; press_enter; return; }
    
    if confirm_action "Clone to ${pool}/${name}?"; then
        sudo zfs clone "$snap" "${pool}/${name}" && echo -e "${GREEN}[OK]${NC}" || echo -e "${RED}[X]${NC}"
    fi
    press_enter
}

compare_snapshots() {
    clear
    echo ""
    draw_box "       COMPARE SNAPSHOTS          "
    echo ""
    
    local datasets=($(get_datasets))
    local i=1
    for ds in "${datasets[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$ds${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#datasets[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local dataset="${datasets[$((sel-1))]}"
    local snaps=($(zfs list -H -t snapshot -o name -s creation "$dataset" 2>/dev/null | grep "^${dataset}@"))
    
    [ ${#snaps[@]} -lt 2 ] && { echo -e "${NARTIC}Need 2+ snapshots.${NC}"; press_enter; return; }
    
    echo -e "${WHITE}First snapshot:${NC}"
    i=1; for s in "${snaps[@]}"; do echo -e "${BLUE}$i${NC} ${NARTIC}${s##*@}${NC}"; ((i++)); done
    echo -ne "${NHYPRBLUE}❯ ${NC}"; read -r s1
    
    echo -e "${WHITE}Second snapshot:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"; read -r s2
    
    [[ "$s1" =~ ^[0-9]+$ ]] && [[ "$s2" =~ ^[0-9]+$ ]] || { press_enter; return; }
    
    echo ""
    zfs diff "${snaps[$((s1-1))]}" "${snaps[$((s2-1))]}" 2>/dev/null | head -30
    press_enter
}

snapshot_info() {
    clear
    echo ""
    draw_box "        SNAPSHOT INFO             "
    echo ""
    
    local snapshots=($(get_snapshots))
    [ ${#snapshots[@]} -eq 0 ] && { echo -e "${NARTIC}No snapshots.${NC}"; press_enter; return; }
    
    local i=1
    for snap in "${snapshots[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$snap${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#snapshots[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local snap="${snapshots[$((sel-1))]}"
    echo ""
    draw_border
    echo -e "${WHITE}$snap${NC}"
    draw_border
    echo ""
    zfs get creation,used,referenced,compressratio,written "$snap" 2>/dev/null
    press_enter
}

send_snapshot() {
    clear
    echo ""
    draw_box "     SEND SNAPSHOT (BACKUP)       "
    echo ""
    
    local snapshots=($(get_snapshots))
    [ ${#snapshots[@]} -eq 0 ] && { echo -e "${NARTIC}No snapshots.${NC}"; press_enter; return; }
    
    local i=1
    for snap in "${snapshots[@]}"; do
        echo -e "${BLUE}$i${NC} ${NVFROST}-${NC} ${NARTIC}$snap${NC}"
        ((i++))
    done
    
    echo ""
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r sel
    
    [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#snapshots[@]} ] && { echo -e "${RED}Invalid!${NC}"; press_enter; return; }
    
    local snap="${snapshots[$((sel-1))]}"
    local file="${snap//\//_}.zfs.gz"
    
    echo -e "${WHITE}Output file ${NHYPRBLUE}[$file]${WHITE}:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r custom_file
    [ -n "$custom_file" ] && file="$custom_file"
    
    echo -e "${WHITE}Sending...${NC}"
    sudo zfs send "$snap" | gzip > "$file" && echo -e "${GREEN}[OK]${NC} ${WHITE}Saved to $file${NC}" || echo -e "${RED}[X]${NC}"
    press_enter
}

receive_snapshot() {
    clear
    echo ""
    draw_box "   RECEIVE SNAPSHOT (RESTORE)     "
    echo ""
    
    echo -e "${WHITE}Input file:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r file
    
    [ ! -f "$file" ] && { echo -e "${RED}File not found!${NC}"; press_enter; return; }
    
    echo -e "${WHITE}Target dataset:${NC}"
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r target
    
    [ -z "$target" ] && { echo -e "${RED}No target!${NC}"; press_enter; return; }
    
    echo -e "${WHITE}Receiving...${NC}"
    if [[ "$file" == *.gz ]]; then
        gunzip -c "$file" | sudo zfs receive -F "$target"
    else
        sudo zfs receive -F "$target" < "$file"
    fi
    [ $? -eq 0 ] && echo -e "${GREEN}[OK]${NC}" || echo -e "${RED}[X]${NC}"
    press_enter
}

pool_overview() {
    clear
    echo ""
    draw_box "       POOL OVERVIEW              "
    echo ""
    
    echo -e "${WHITE}Pools:${NC}"
    zpool list 2>/dev/null
    echo ""
    echo -e "${WHITE}Datasets:${NC}"
    zfs list 2>/dev/null
    echo ""
    local total=$(zfs list -H -t snapshot 2>/dev/null | wc -l)
    local auto=$(count_auto_snapshots)
    echo -e "${WHITE}Snapshots: $total total ($auto auto, $((total-auto)) manual)${NC}"
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
    echo -e "${NARTIC}..........                                ............${NC}"
    echo ""
    draw_box "       NORDIX CLI SNAPSHOT          "
    echo ""
    draw_border
    echo -e "${WHITE}ZFS Snapshot Management${NC}"
    draw_border
    echo ""
    echo -e "${BLUE} 1${NC} ${NVFROST}-${NC} ${NARTIC}List all snapshots${NC}"
    echo -e "${BLUE} 2${NC} ${NVFROST}-${NC} ${NARTIC}Create snapshot${NC}"
    echo -e "${BLUE} 3${NC} ${NVFROST}-${NC} ${NARTIC}Create recursive snapshot${NC}"
    echo -e "${BLUE} 4${NC} ${NVFROST}-${NC} ${NARTIC}Delete snapshot${NC}"
    echo -e "${BLUE} 5${NC} ${NVFROST}-${NC} ${NARTIC}Rollback to snapshot${NC}"
    echo -e "${BLUE} 6${NC} ${NVFROST}-${NC} ${NARTIC}Clone snapshot${NC}"
    echo -e "${BLUE} 7${NC} ${NVFROST}-${NC} ${NARTIC}Compare snapshots${NC}"
    echo -e "${BLUE} 8${NC} ${NVFROST}-${NC} ${NARTIC}Snapshot info${NC}"
    echo -e "${BLUE} 9${NC} ${NVFROST}-${NC} ${NARTIC}Send ${NHYPRBLUE}(backup)${NC}"
    echo -e "${BLUE}10${NC} ${NVFROST}-${NC} ${NARTIC}Receive ${NHYPRBLUE}(restore)${NC}"
    echo -e "${BLUE}11${NC} ${NVFROST}-${NC} ${NARTIC}Pool overview${NC}"
    echo ""
    draw_border
    if is_auto_snapshot_enabled; then
        echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Auto-snapshot ${GREEN}[ENABLED]${NC}"
    else
        echo -e "${BLUE}12${NC} ${NVFROST}-${NC} ${NARTIC}Auto-snapshot ${RED}[DISABLED]${NC}"
    fi
    draw_border
    echo ""
    echo -e "${BLUE}0${NC} ${NVFROST}-${NC} ${NARTIC}Exit${NC}"
    draw_border
    echo ""
    echo -e "${NGLACIER}Choose option ${NHYPRBLUE}(0-12)${NGLACIER}:${NC}"
}

# ============================================
# MAIN
# ============================================

check_zfs
check_root

while true; do
    show_main_menu
    echo -ne "${NHYPRBLUE}❯ ${NC}"
    read -r choice
    
    case $choice in
        1) list_snapshots ;;
        2) create_snapshot ;;
        3) create_recursive_snapshot ;;
        4) delete_snapshot ;;
        5) rollback_snapshot ;;
        6) clone_snapshot ;;
        7) compare_snapshots ;;
        8) snapshot_info ;;
        9) send_snapshot ;;
        10) receive_snapshot ;;
        11) pool_overview ;;
        12) auto_snapshot_menu ;;
        0)
            clear
            draw_border
            echo -e "${GREEN}Thank you for using Nordix CLI Snapshot!${NC}"
            draw_border
            exit 0
            ;;
        *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
    esac
done
