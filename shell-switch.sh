#!/bin/bash

# --- Hyfetch Color Palette ---
RESET="\e[0m"; CYAN="\e[1;36m"; GREEN="\e[32m"; RED="\e[31m"; BOLD="\e[1m"
T_BLU="\e[38;5;81m"; T_PNK="\e[38;5;211m"; T_WHT="\e[38;5;255m"
NB_YLW="\e[38;5;226m"; NB_WHT="\e[38;5;255m"; NB_PUR="\e[38;5;93m"; NB_BLK="\e[38;5;236m"
L_ORG="\e[38;5;202m"; L_WHT="\e[38;5;255m"; L_PNK="\e[38;5;161m"
B_PNK="\e[38;5;198m"; B_PUR="\e[38;5;129m"; B_BLU="\e[38;5;26m"
P_PNK="\e[38;5;198m"; P_YLW="\e[38;5;226m"; P_BLU="\e[38;5;39m"
A_BLK="\e[38;5;235m"; A_GRY="\e[38;5;246m"; A_WHT="\e[38;5;255m"; A_PUR="\e[38;5;93m"

# State
current_flag="trans"
selected=0
last_cols=0; last_rows=0

update_active_shell() {
    if pgrep -x "noctalia" > /dev/null; then ACTIVE="v5"
    elif pgrep -f "noctalia-shell" > /dev/null; then ACTIVE="v4"
    elif pgrep -f "dms" > /dev/null; then ACTIVE="dank"
    else ACTIVE="none"; fi
}

check_installed() {
    if pacman -Qq "$1" &> /dev/null || command -v "$1" &> /dev/null; then return 0; else return 1; fi
}

get_status_text() {
    local status_msg=""
    if check_installed "$1"; then
        status_msg="${GREEN}(INSTALLED)${RESET}"
        [[ "$ACTIVE" == "$2" ]] && status_msg="${status_msg} ${CYAN}${BOLD}◀ ACTIVE${RESET}"
    else
        status_msg="${RED}(MISSING)${RESET}"
    fi
    echo -e "$status_msg"
}

smart_uninstall() {
    local target=$1
    if pacman -Qq "$target" &> /dev/null; then
        tput cup $(( $(tput lines) - 1 )) 2; echo -e "${CYAN}Removing $target...${RESET}"
        sudo pacman -Rs "$target" --noconfirm < /dev/tty
        last_cols=0
    else
        tput cup $(( $(tput lines) - 1 )) 2; echo -e "${RED}Package $target not found.${RESET}"
        sleep 1.5
    fi
}

handle_action() {
    local pkg=$1; local url=$2; local cmd=$3; local check=$4
    if check_installed "$check"; then
        pkill -x "noctalia"; pkill -x "dms"; pkill -f "noctalia-shell"
        nohup $cmd >/dev/null 2>&1 & disown
    else
        clear; echo -e "${CYAN}Installing $pkg...${RESET}"
        if [[ "$pkg" == *"git" ]]; then
            local tmp=$(mktemp -d); git clone "$url" "$tmp" < /dev/tty
            cd "$tmp" && makepkg -si --noconfirm < /dev/tty && cd - > /dev/null && rm -rf "$tmp"
        else
            sudo pacman -S "$pkg" --noconfirm < /dev/tty
        fi
        last_cols=0; read -n1 -s -r -p "Done. Press any key..." < /dev/tty
    fi
}

draw_menu() {
    local -n labels=$1
    local -n statuses=$2
    local cols=$(tput cols); local rows=$(tput lines)
    update_active_shell

    if [ "$cols" -ne "$last_cols" ] || [ "$rows" -ne "$last_rows" ]; then
        clear; tput smacs
        tput cup 0 0; printf "l"; for ((i=0; i<cols-2; i++)); do printf "q"; done; printf "k"
        tput cup $((rows-1)) 0; printf "m"; for ((i=0; i<cols-2; i++)); do printf "q"; done; printf "j"
        for ((r=1; r<rows-1; r++)); do tput cup $r 0; printf "x"; tput cup $r $((cols-1)); printf "x"; done
        tput rmacs
        local h=$(( 10 + ${#labels[@]} )); start_row=$(( (rows - h) / 2 ))
        
        local L1='████████╗███████╗███████╗   ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗███████╗██████╗ '
        local L2='╚══██╔══╝██╔════╝██╔════╝   ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔══██╗'
        local L3='   ██║   ███████╗███████╗   ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║█████╗  ██████╔╝'
        local L4='   ██║   ╚════██║╚════██║   ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║██╔══╝  ██╔══██╗'
        local L5='   ██║   ███████║███████║   ███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║███████╗██║  ██║'
        local L6='   ╚═╝   ╚══════╝╚══════╝   ╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝'
        
        case $current_flag in
            "trans")   C=("$T_BLU" "$T_PNK" "$T_WHT" "$T_WHT" "$T_PNK" "$T_BLU") ;;
            "enby")    C=("$NB_YLW" "$NB_WHT" "$NB_PUR" "$NB_PUR" "$NB_BLK" "$NB_BLK") ;;
            "lesbian") C=("$L_ORG" "$L_ORG" "$L_WHT" "$L_WHT" "$L_PNK" "$L_PNK") ;;
            "bi")      C=("$B_PNK" "$B_PNK" "$B_PUR" "$B_PUR" "$B_BLU" "$B_BLU") ;;
            "pan")     C=("$P_PNK" "$P_PNK" "$P_YLW" "$P_YLW" "$P_BLU" "$P_BLU") ;;
            "ace")     C=("$A_BLK" "$A_GRY" "$A_WHT" "$A_WHT" "$A_PUR" "$A_PUR") ;;
        esac

        local pad=$(( (cols - 86) / 2 ))
        for i in {0..5}; do
            local v="L$((i+1))"; tput cup $((start_row + i)) $pad; echo -e "${C[$i]}${!v}${RESET}"
        done
        last_cols=$cols; last_rows=$rows
    fi

    local sub="Active Shell: $ACTIVE"; tput cup $((start_row + 7)) 0; tput el
    tput cup $((start_row + 7)) $(( (cols - ${#sub}) / 2 )); echo -e "$sub"

    for i in "${!labels[@]}"; do
        tput cup $((start_row + 9 + i)) 0; tput el
        
        # Center the label text strictly
        local label_raw="${labels[$i]}"
        local cursor_label="  $label_raw"
        [[ "$i" -eq "$selected" ]] && cursor_label="▶ $label_raw"

        local c_pos=$(( (cols - ${#cursor_label}) / 2 ))
        tput cup $((start_row + 9 + i)) $c_pos
        echo -ne "${CYAN}${cursor_label}${RESET}"
        
        # Draw status to the side without affecting label centering
        if [[ -n "${statuses[$i]}" ]]; then
            echo -ne "  ${statuses[$i]}"
        fi

        tput smacs; tput cup $((start_row + 9 + i)) 0; printf "x"; tput cup $((start_row + 9 + i)) $((cols-1)); printf "x"; tput rmacs
    done
}

tput civis; trap 'tput cnorm; clear; exit' SIGINT SIGTERM

while true; do
    L_MAIN=("Noctalia V4" "Noctalia V5" "Dank Material" "Manage Shells" "Settings" "Exit")
    S_MAIN=("$(get_status_text 'noctalia-shell' 'v4')" "$(get_status_text 'noctalia-git' 'v5')" "$(get_status_text 'dms-shell' 'dank')" "" "" "")
    draw_menu L_MAIN S_MAIN; read -rsn3 key < /dev/tty
    case "$key" in
        $'\x1b[A') ((selected--)); [[ $selected -lt 0 ]] && selected=5 ;;
        $'\x1b[B') ((selected++)); [[ $selected -gt 5 ]] && selected=0 ;;
        "") case $selected in
                0) handle_action "noctalia-shell" "" "qs -c noctalia-shell" "noctalia-shell" ;;
                1) handle_action "noctalia-git" "https://aur.archlinux.org/noctalia-git.git" "noctalia" "noctalia-git" ;;
                2) handle_action "dms-shell" "" "dms run" "dms-shell" ;;
                3) m_sel=0; while true; do
                    L_MNG=("Uninstall V4" "Uninstall V5" "Uninstall Dank" "Back")
                    S_MNG=("" "" "" ""); selected=$m_sel; draw_menu L_MNG S_MNG; read -rsn3 mk < /dev/tty
                    case "$mk" in
                        $'\x1b[A') ((m_sel--)); [[ $m_sel -lt 0 ]] && m_sel=3 ;;
                        $'\x1b[B') ((m_sel++)); [[ $m_sel -gt 3 ]] && m_sel=0 ;;
                        "") case $m_sel in 0) smart_uninstall "noctalia-shell" ;; 1) smart_uninstall "noctalia-git" ;; 2) smart_uninstall "dms-shell" ;; 3) break ;; esac ;;
                    esac
                   done; selected=3 ;;
                4) s_sel=0; while true; do
                    L_SET=("Flag" "Back")
                    S_SET=("($current_flag)" ""); selected=$s_sel; draw_menu L_SET S_SET; read -rsn3 sk < /dev/tty
                    case "$sk" in
                        $'\x1b[A') ((s_sel--)); [[ $s_sel -lt 0 ]] && s_sel=1 ;;
                        $'\x1b[B') ((s_sel++)); [[ $s_sel -gt 1 ]] && s_sel=0 ;;
                        "") case $s_sel in
                                0) f_sel=0; f_list=("trans" "enby" "lesbian" "bi" "pan" "ace")
                                   while true; do
                                       L_FLG=("Trans" "Enby" "Lesbian" "Bi" "Pan" "Ace" "Back")
                                       S_FLG=("" "" "" "" "" "" ""); selected=$f_sel; draw_menu L_FLG S_FLG; read -rsn3 fk < /dev/tty
                                       case "$fk" in
                                           $'\x1b[A') ((f_sel--)); [[ $f_sel -lt 0 ]] && f_sel=6 ;;
                                           $'\x1b[B') ((f_sel++)); [[ $f_sel -gt 6 ]] && f_sel=0 ;;
                                           "") [[ $f_sel -eq 6 ]] && break; current_flag="${f_list[$f_sel]}"; last_cols=0; break ;;
                                       esac
                                   done ;;
                                1) break ;;
                            esac ;;
                    esac
                   done; selected=4 ;;
                5) tput cnorm; clear; exit ;;
            esac ;;
    esac
done
