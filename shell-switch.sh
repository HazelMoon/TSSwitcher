#!/bin/bash

RESET="\e[0m"; CYAN="\e[1;36m"; GREEN="\e[32m"; RED="\e[31m"; BOLD="\e[1m"
T_BLU="\e[38;5;81m"; T_PNK="\e[38;5;211m"; T_WHT="\e[38;5;255m"
NB_YLW="\e[38;5;226m"; NB_WHT="\e[38;5;255m"; NB_PUR="\e[38;5;93m"; NB_BLK="\e[38;5;236m"
L_ORG="\e[38;5;202m"; L_WHT="\e[38;5;255m"; L_PNK="\e[38;5;161m"
B_PNK="\e[38;5;198m"; B_PUR="\e[38;5;129m"; B_BLU="\e[38;5;26m"
P_PNK="\e[38;5;198m"; P_YLW="\e[38;5;226m"; P_BLU="\e[38;5;39m"
A_BLK="\e[38;5;235m"; A_GRY="\e[38;5;246m"; A_WHT="\e[38;5;255m"; A_PUR="\e[38;5;93m"

# State
current_ascii="default"
current_flag="trans"
selected=0

update_active_shell() {
    if pgrep -x "noctalia" > /dev/null; then ACTIVE="v5"
    elif pgrep -f "noctalia-shell" > /dev/null; then ACTIVE="v4"
    elif pgrep -f "dms" > /dev/null; then ACTIVE="dank"
    else ACTIVE="none"; fi
}

check_installed() {
    if command -v "$1" &> /dev/null || [ -d "/etc/xdg/quickshell/$2" ]; then return 0; else return 1; fi
}

get_status() {
    if check_installed "$1" "$2"; then
        echo -ne "${GREEN}(INSTALLED)${RESET}"
        [[ "$ACTIVE" == "$3" ]] && echo -e " ${CYAN}${BOLD}◀ ACTIVE${RESET}" || echo ""
    else
        echo -e "${RED}(MISSING)${RESET}"
    fi
}

smart_uninstall() {
    local bin_name=$1
    local bin_path=$(which "$bin_name" 2>/dev/null)
    if [[ -z "$bin_path" ]]; then return; fi
    local pkg_owner=$(pacman -Qo "$bin_path" 2>/dev/null | awk '{print $5}')
    if [[ -n "$pkg_owner" ]]; then
        sudo pacman -Rs "$pkg_owner" --noconfirm < /dev/tty
    else
        sudo rm -f "$bin_path" < /dev/tty
    fi
}

handle_action() {
    local pkg_name=$1; local repo_url=$2; local run_cmd=$3; local bin_check=$4; local dir_check=$5
    if check_installed "$bin_check" "$dir_check"; then
        pkill -x "noctalia"; pkill -x "dms"; pkill -f "noctalia-shell"
        nohup $run_cmd >/dev/null 2>&1 & disown
    else
        clear
        local tmp_dir=$(mktemp -d)
        git clone "$repo_url" "$tmp_dir" < /dev/tty
        cd "$tmp_dir" || return
        makepkg -si --noconfirm < /dev/tty
        cd - > /dev/null; rm -rf "$tmp_dir"
        read -n1 -p "Done. Press any key..." < /dev/tty
    fi
}

draw_ascii() {
    local term_width=$1
    local box_width=$2
    local pad=$(( (box_width - 80) / 2 ))
    
    # ASCII Art Lines
    L[0]='████████╗███████╗███████╗   ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗███████╗██████╗ '
    L[1]='╚══██╔══╝██╔════╝██╔════╝   ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔══██╗'
    L[2]='   ██║   ███████╗███████╗   ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║█████╗  ██████╔╝'
    L[3]='   ██║   ╚════██║╚════██║   ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║██╔══╝  ██╔══██╗'
    L[4]='   ██║   ███████║███████║   ███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║███████╗██║  ██║'
    L[5]='   ╚═╝   ╚══════╝╚══════╝   ╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝'

    case $current_flag in
        "trans")    C=("$T_BLU" "$T_PNK" "$T_WHT" "$T_WHT" "$T_PNK" "$T_BLU") ;;
        "enby")     C=("$NB_YLW" "$NB_WHT" "$NB_PUR" "$NB_PUR" "$NB_BLK" "$NB_BLK") ;;
        "lesbian")  C=("$L_ORG" "$L_ORG" "$L_WHT" "$L_WHT" "$L_PNK" "$L_PNK") ;;
        "bi")       C=("$B_PNK" "$B_PNK" "$B_PUR" "$B_PUR" "$B_BLU" "$B_BLU") ;;
        "pan")      C=("$P_PNK" "$P_PNK" "$P_YLW" "$P_YLW" "$P_BLU" "$P_BLU") ;;
        "ace")      C=("$A_BLK" "$A_GRY" "$A_WHT" "$A_WHT" "$A_PUR" "$A_PUR") ;;
    esac

    local margin=$(( (term_width - box_width) / 2 ))
    for i in {0..5}; do
        printf "%${margin}s║ %${pad}s%b%s${RESET}%$((box_width - pad - 80))s ║\n" "" "" "${C[$i]}" "${L[$i]}" ""
    done
}

draw_menu() {
    local options=("$@")
    local term_cols=$(tput cols 2>/dev/null || echo 80)
    local term_rows=$(tput lines 2>/dev/null || echo 24)
    local box_width=86 # Fixed width for the internal box
    local margin=$(( (term_cols - box_width - 4) / 2 ))
    [ $margin -lt 0 ] && margin=0

    update_active_shell
    clear
    
    # Vertical Centering
    for ((i=0; i<$(( (term_rows / 2) - 10 )); i++)); do echo ""; done

    # Top Border
    printf "%${margin}s╔" ""
    for ((i=0; i<box_width+2; i++)); do printf "═"; done
    printf "╗\n"

    # ASCII
    draw_ascii "$term_cols" "$box_width"
    
    # Text Content
    local desc="the boredom of a TGirl v1"
    local status="Active Shell: $ACTIVE"
    
    printf "%${margin}s║ %$(( (box_width - 15) / 2 ))s%b%$(( (box_width - 13) / 2 ))s ║\n" "" "" "${T_BLU}T${T_PNK}G${T_WHT}i${T_PNK}r${T_BLU}l${RESET} v1" ""
    printf "%${margin}s║ %$(( (box_width - ${#status}) / 2 ))s%s%$(( (box_width - ${#status} + 1) / 2 ))s ║\n" "" "" "$status" ""
    printf "%${margin}s║ %${box_width}s ║\n" "" ""

    # Menu Options
    for i in "${!options[@]}"; do
        # Strip ANSI codes for length calc
        local opt_clean=$(echo -e "${options[$i]}" | sed 's/\x1b\[[0-9;]*m//g')
        local len=${#opt_clean}
        local fill=$(( box_width - len - 10 ))
        
        if [ "$i" -eq "$selected" ]; then
            printf "%${margin}s║    ${CYAN}▶ %b${RESET}%${fill}s ║\n" "" "${options[$i]}" ""
        else
            printf "%${margin}s║      %b%${fill}s ║\n" "" "${options[$i]}" ""
        fi
    done

    # Bottom Border
    printf "%${margin}s╚" ""
    for ((i=0; i<box_width+2; i++)); do printf "═"; done
    printf "╝\n"
}

while true; do
    update_active_shell
    main_opts=(
        "V4 Legacy      $(get_status 'noctalia-shell' 'noctalia-shell' 'v4')"
        "V5 Testing     $(get_status 'noctalia' 'noctalia' 'v5')"
        "Dank Material  $(get_status 'dms' 'dms' 'dank')"
        "Manage Shells"
        "Settings"
        "Exit"
    )
    draw_menu "${main_opts[@]}"
    
    read -rsn3 key < /dev/tty
    case "$key" in
        $'\x1b[A') ((selected--)); [ $selected -lt 0 ] && selected=5 ;;
        $'\x1b[B') ((selected++)); [ $selected -gt 5 ] && selected=0 ;;
        "") 
            case $selected in
                0) handle_action "noctalia-shell" "https://aur.archlinux.org/noctalia-shell.git" "qs -c noctalia-shell" "noctalia-shell" "noctalia-shell" ;;
                1) handle_action "noctalia" "https://aur.archlinux.org/noctalia-git.git" "noctalia" "noctalia" "noctalia" ;;
                2) handle_action "dms-shell" "https://aur.archlinux.org/dms-shell-git.git" "dms run" "dms" "dms" ;;
                3) m_selected=0
                    while true; do
                        m_opts=("Uninstall V4" "Uninstall V5" "Uninstall Dank" "Back")
                        selected=$m_selected; draw_menu "${m_opts[@]}"; read -rsn3 mkey < /dev/tty
                        case "$mkey" in
                            $'\x1b[A') ((m_selected--)); [ $m_selected -lt 0 ] && m_selected=3 ;;
                            $'\x1b[B') ((m_selected++)); [ $m_selected -gt 3 ] && m_selected=0 ;;
                            "") case $m_selected in
                                    0) smart_uninstall "noctalia-shell" ;;
                                    1) smart_uninstall "noctalia" ;;
                                    2) smart_uninstall "dms" ;;
                                    3) break ;;
                                esac ;;
                        esac
                    done; selected=3 ;;
                4) s_selected=0
                    while true; do
                        s_opts=("ASCII Style: $current_ascii" "Flag: $current_flag" "Back")
                        selected=$s_selected; draw_menu "${s_opts[@]}"; read -rsn3 skey < /dev/tty
                        case "$skey" in
                            $'\x1b[A') ((s_selected--)); [ $s_selected -lt 0 ] && s_selected=2 ;;
                            $'\x1b[B') ((s_selected++)); [ $s_selected -gt 2 ] && s_selected=0 ;;
                            "") case $s_selected in
                                    0) [[ "$current_ascii" == "default" ]] && current_ascii="small" || current_ascii="default" ;;
                                    1) f_selected=0; flags=("trans" "enby" "lesbian" "bi" "pan" "ace" "back")
                                        while true; do
                                            selected=$f_selected; draw_menu "${flags[@]}"; read -rsn3 fkey < /dev/tty
                                            case "$fkey" in
                                                $'\x1b[A') ((f_selected--)); [ $f_selected -lt 0 ] && f_selected=6 ;;
                                                $'\x1b[B') ((f_selected++)); [ $f_selected -gt 6 ] && f_selected=0 ;;
                                                "") [[ $f_selected -eq 6 ]] && break; current_flag="${flags[$f_selected]}"; break ;;
                                            esac
                                        done; s_selected=1 ;;
                                    2) break ;;
                                esac ;;
                        esac
                    done; selected=4 ;;
                5) clear; exit ;;
            esac ;;
    esac
done
