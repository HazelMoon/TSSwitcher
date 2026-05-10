#!/bin/bash

RESET="\e[0m"; CYAN="\e[1;36m"; GREEN="\e[32m"; RED="\e[31m"; BOLD="\e[1m"
T_BLU="\e[38;5;81m"; T_PNK="\e[38;5;211m"; T_WHT="\e[38;5;255m"
NB_YLW="\e[38;5;226m"; NB_WHT="\e[38;5;255m"; NB_PUR="\e[38;5;93m"; NB_BLK="\e[38;5;236m"
L_ORG="\e[38;5;202m"; L_WHT="\e[38;5;255m"; L_PNK="\e[38;5;161m"
B_PNK="\e[38;5;198m"; B_PUR="\e[38;5;129m"; B_BLU="\e[38;5;26m"
P_PNK="\e[38;5;198m"; P_YLW="\e[38;5;226m"; P_BLU="\e[38;5;39m"
A_BLK="\e[38;5;235m"; A_GRY="\e[38;5;246m"; A_WHT="\e[38;5;255m"; A_PUR="\e[38;5;93m"

current_ascii="default"
current_flag="trans"
selected=0

update_active_shell() {
    if pgrep -x "noctalia" > /dev/null; then ACTIVE="v5"
    elif pgrep -f "noctalia-shell" > /dev/null; then ACTIVE="v4"
    elif pgrep -f "dms" > /dev/null; then ACTIVE="dank"
    else ACTIVE="none"; fi
}

get_status() {
    local shell_id=$1
    local install_path=$2
    local internal_id=$3
    local label=""
    
    if command -v "$shell_id" &> /dev/null || [ -d "/etc/xdg/quickshell/$install_path" ]; then
        label="${GREEN}(INSTALLED)${RESET}"
    else
        label="${RED}(MISSING)${RESET}"
    fi

    if [[ "$ACTIVE" == "$internal_id" ]]; then
        echo -e "$label ${CYAN}${BOLD}◀ ACTIVE${RESET}"
    else
        echo -e "$label"
    fi
}

draw_ascii() {
    local pad=$1
    if [[ "$current_ascii" == "default" ]]; then
        local L1='████████╗███████╗███████╗   ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗███████╗██████╗ '
        local L2='╚══██╔══╝██╔════╝██╔════╝   ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔══██╗'
        local L3='   ██║   ███████╗███████╗   ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║█████╗  ██████╔╝'
        local L4='   ██║   ╚════██║╚════██║   ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║██╔══╝  ██╔══██╗'
        local L5='   ██║   ███████║███████║   ███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║███████╗██║  ██║'
        local L6='   ╚═╝   ╚══════╝╚══════╝   ╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝'
    else
        local L1='████████╗███████╗███████╗'
        local L2='╚══██╔══╝██╔════╝██╔════╝'
        local L3='   ██║   ███████╗███████╗'
        local L4='   ██║   ╚════██║╚════██║'
        local L5='   ██║   ███████║███████║'
        local L6='   ╚═╝   ╚══════╝╚══════╝'
    fi

    case $current_flag in
        "trans")    C=("$T_BLU" "$T_PNK" "$T_WHT" "$T_WHT" "$T_PNK" "$T_BLU") ;;
        "enby")     C=("$NB_YLW" "$NB_WHT" "$NB_PUR" "$NB_PUR" "$NB_BLK" "$NB_BLK") ;;
        "lesbian")  C=("$L_ORG" "$L_ORG" "$L_WHT" "$L_WHT" "$L_PNK" "$L_PNK") ;;
        "bi")       C=("$B_PNK" "$B_PNK" "$B_PUR" "$B_PUR" "$B_BLU" "$B_BLU") ;;
        "pan")      C=("$P_PNK" "$P_PNK" "$P_YLW" "$P_YLW" "$P_BLU" "$P_BLU") ;;
        "ace")      C=("$A_BLK" "$A_GRY" "$A_WHT" "$A_WHT" "$A_PUR" "$A_PUR") ;;
    esac

    for i in {0..5}; do
        local line_var="L$((i+1))"
        printf "%${pad}s%b%s${RESET}\n" "" "${C[$i]}" "${!line_var}"
    done
}

draw_menu() {
    local options=("$@")
    local term_cols=$(tput cols 2>/dev/null || echo 80)
    local term_lines=$(tput lines 2>/dev/null || echo 24)
    update_active_shell
    local desc_colored="the boredom of a ${T_BLU}T${T_PNK}G${T_WHT}i${T_PNK}r${T_BLU}l${RESET} v1"
    local status_line="Active Shell: $ACTIVE"
    
    clear
    for ((i=0; i<$(( (term_lines / 2) - 12 )); i++)); do echo ""; done

    local ascii_width=80
    [[ "$current_ascii" == "small" ]] && ascii_width=25
    local pad=$(( (term_cols - ascii_width) / 2 ))
    [ $pad -lt 0 ] && pad=0

    draw_ascii "$pad"
    echo ""
    printf "%$(( (term_cols - 25) / 2 ))s%b\n" "" "$desc_colored"
    printf "%$(( (term_cols - ${#status_line}) / 2 ))s%s\n" "" "$status_line"

    echo ""
    echo ""

    local menu_pad=$(( (term_cols - 40) / 2 ))
    for i in "${!options[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            printf "%${menu_pad}s${CYAN} ▶  %b${RESET}\n" "" "${options[$i]}"
        else
            printf "%${menu_pad}s   %b\n" "" "${options[$i]}"
        fi
    done
}

# Main Execution Loop
while true; do
    update_active_shell
    main_opts=(
        "V4 Legacy      $(get_status 'noctalia-shell' 'noctalia-shell' 'v4')"
        "V5 Testing     $(get_status 'noctalia' 'noctalia' 'v5')"
        "Dank Material  $(get_status 'dms' 'dms' 'dank')"
        "Settings"
        "Exit"
    )
    draw_menu "${main_opts[@]}"
    
    read -rsn3 key < /dev/tty
    case "$key" in
        $'\x1b[A') ((selected--)); [ $selected -lt 0 ] && selected=4 ;;
        $'\x1b[B') ((selected++)); [ $selected -gt 4 ] && selected=0 ;;
        "") 
            case $selected in
                0) pkill -x "noctalia"; pkill -x "dms"; nohup qs -c noctalia-shell >/dev/null 2>&1 & disown ;;
                1) pkill -f "noctalia-shell"; pkill -x "dms"; nohup noctalia >/dev/null 2>&1 & disown ;;
                2) pkill -x "noctalia"; pkill -f "noctalia-shell"; nohup dms run >/dev/null 2>&1 & disown ;;
                3) 
                    selected=0
                    while true; do
                        sub_opts=("ASCII: $current_ascii" "Flag: $current_flag" "Back")
                        draw_menu "${sub_opts[@]}"
                        read -rsn3 skey < /dev/tty
                        case "$skey" in
                            $'\x1b[A') ((selected--)); [ $selected -lt 0 ] && selected=2 ;;
                            $'\x1b[B') ((selected++)); [ $selected -gt 2 ] && selected=0 ;;
                            "") 
                                case $selected in
                                    0) [[ "$current_ascii" == "default" ]] && current_ascii="small" || current_ascii="default" ;;
                                    1) 
                                        f_selected=0; flags=("trans" "enby" "lesbian" "bi" "pan" "ace" "back")
                                        while true; do
                                            draw_menu "${flags[@]}"; read -rsn3 fkey < /dev/tty
                                            case "$fkey" in
                                                $'\x1b[A') ((f_selected--)); [ $f_selected -lt 0 ] && f_selected=6 ;;
                                                $'\x1b[B') ((f_selected++)); [ $f_selected -gt 6 ] && f_selected=0 ;;
                                                "") [[ $f_selected -eq 6 ]] && break; current_flag="${flags[$f_selected]}"; break ;;
                                            esac
                                            selected=$f_selected
                                        done; selected=1 ;;
                                    2) selected=3; break ;;
                                esac ;;
                        esac
                    done ;;
                4) clear; exit ;;
            esac ;;
    esac
done
