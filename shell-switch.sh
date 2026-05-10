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
last_cols=0
last_rows=0

update_active_shell() {
    if pgrep -x "noctalia" > /dev/null; then ACTIVE="v5"
    elif pgrep -f "noctalia-shell" > /dev/null; then ACTIVE="v4"
    elif pgrep -f "dms" > /dev/null; then ACTIVE="dank"
    else ACTIVE="none"; fi
}

check_installed() {
    if pacman -Qq "$1" &> /dev/null || command -v "$1" &> /dev/null; then return 0; else return 1; fi
}

get_status() {
    if check_installed "$1"; then
        echo -ne "${GREEN}(INSTALLED)${RESET}"
        [[ "$ACTIVE" == "$3" ]] && echo -ne " ${CYAN}${BOLD}◀ ACTIVE${RESET}"
    else
        echo -ne "${RED}(MISSING)${RESET}"
    fi
}

smart_uninstall() {
    local target=$1
    if pacman -Qq "$target" &> /dev/null; then
        tput cup $(( $(tput lines) - 1 )) 2
        echo -e "${CYAN}Removing $target...${RESET}"
        sudo pacman -Rs "$target" --noconfirm < /dev/tty
        last_cols=0
    else
        tput cup $(( $(tput lines) - 1 )) 2
        echo -e "${RED}Package $target not found.${RESET}"
        sleep 1.5
    fi
}

handle_action() {
    local pkg_name=$1; local repo_url=$2; local run_cmd=$3; local bin_check=$4
    if check_installed "$bin_check"; then
        pkill -x "noctalia"; pkill -x "dms"; pkill -f "noctalia-shell"
        nohup $run_cmd >/dev/null 2>&1 & disown
    else
        clear
        echo -e "${CYAN}Installing $pkg_name...${RESET}"
        if [[ "$pkg_name" == *"git" ]]; then
            local tmp_dir=$(mktemp -d)
            git clone "$repo_url" "$tmp_dir" < /dev/tty
            cd "$tmp_dir" && makepkg -si --noconfirm < /dev/tty
            cd - > /dev/null && rm -rf "$tmp_dir"
        else
            sudo pacman -S "$pkg_name" --noconfirm < /dev/tty
        fi
        last_cols=0
        read -n1 -s -r -p "Finished. Press any key..." < /dev/tty
    fi
}

draw_menu() {
    local options=("$@")
    local cols=$(tput cols); local rows=$(tput lines)
    update_active_shell

    if [ "$cols" -ne "$last_cols" ] || [ "$rows" -ne "$last_rows" ]; then
        clear
        tput smacs 
        tput cup 0 0; printf "l"; for ((i=0; i<cols-2; i++)); do printf "q"; done; printf "k"
        tput cup $((rows-1)) 0; printf "m"; for ((i=0; i<cols-2; i++)); do printf "q"; done; printf "j"
        for ((r=1; r<rows-1; r++)); do
            tput cup $r 0; printf "x"
            tput cup $r $((cols-1)); printf "x"
        done
        tput rmacs 

        local content_height=$(( 10 + ${#options[@]} ))
        start_row=$(( (rows - content_height) / 2 ))

        local L1='████████╗███████╗███████╗   ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗███████╗██████╗ '
        local L2='╚══██╔══╝██╔════╝██╔════╝   ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔══██╗'
        local L3='   ██║   ███████╗███████╗   ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║█████╗  ██████╔╝'
        local L4='   ██║   ╚════██║╚════██║   ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║██╔══╝  ██╔══██╗'
        local L5='   ██║   ███████║███████║   ███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║███████╗██║  ██║'
        local L6='   ╚═╝   ╚══════╝╚══════╝   ╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝'

        case $current_flag in
            "trans")    C=("$T_BLU" "$T_PNK" "$T_WHT" "$T_WHT" "$T_PNK" "$T_BLU") ;;
            "enby")     C=("$NB_YLW" "$NB_WHT" "$NB_PUR" "$NB_PUR" "$NB_BLK" "$NB_BLK") ;;
            "lesbian")  C=("$L_ORG" "$L_ORG" "$L_WHT" "$L_WHT" "$L_PNK" "$L_PNK") ;;
            "bi")       C=("$B_PNK" "$B_PNK" "$B_PUR" "$B_PUR" "$B_BLU" "$B_BLU") ;;
            "pan")      C=("$P_PNK" "$P_PNK" "$P_YLW" "$P_YLW" "$P_BLU" "$P_BLU") ;;
            "ace")      C=("$A_BLK" "$A_GRY" "$A_WHT" "$A_WHT" "$A_PUR" "$A_PUR") ;;
        esac

        local ascii_pad=$(( (cols - 86) / 2 ))
        for i in {0..5}; do
            local line_var="L$((i+1))"
            tput cup $((start_row + i)) $ascii_pad
            echo -e "${C[$i]}${!line_var}${RESET}"
        done
        last_cols=$cols; last_rows=$rows
    fi

    local status="Active Shell: $ACTIVE"
    tput cup $((start_row + 7)) 0; tput el # Clear line
    tput cup $((start_row + 7)) $(( (cols - ${#status}) / 2 ))
    echo -e "$status"

    for i in "${!options[@]}"; do
        tput cup $((start_row + 9 + i)) 0; tput el # Clear line
        local opt_clean=$(echo -e "${options[$i]}" | sed 's/\x1b\[[0-9;]*m//g')
        local opt_pad=$(( (cols - ${#opt_clean} - 4) / 2 ))
        tput cup $((start_row + 9 + i)) $opt_pad
        [[ "$i" -eq "$selected" ]] && echo -e "${CYAN}▶ ${options[$i]}${RESET}" || echo -e "  ${options[$i]}"
    done
    
    tput smacs
    for i in {7..15}; do
        tput cup $((start_row + i)) 0; printf "x"
        tput cup $((start_row + i)) $((cols-1)); printf "x"
    done
    tput rmacs
}

tput civis
trap 'tput cnorm; clear; exit' SIGINT SIGTERM

while true; do
    main_opts=(
        "Noctalia V4      $(get_status 'noctalia-shell' 'noctalia-shell' 'v4')"
        "Noctalia V5      $(get_status 'noctalia-git' 'noctalia-git' 'v5')"
        "Dank Material    $(get_status 'dms-shell' 'dms' 'dank')"
        "Manage Shells"
        "Settings"
        "Exit"
    )
    draw_menu "${main_opts[@]}"
    
    read -rsn3 key < /dev/tty
    case "$key" in
        $'\x1b[A') ((selected--)); [[ $selected -lt 0 ]] && selected=5 ;;
        $'\x1b[B') ((selected++)); [[ $selected -gt 5 ]] && selected=0 ;;
        "") 
            case $selected in
                0) handle_action "noctalia-shell" "" "qs -c noctalia-shell" "noctalia-shell" ;;
                1) handle_action "noctalia-git" "https://aur.archlinux.org/noctalia-git.git" "noctalia" "noctalia-git" ;;
                2) handle_action "dms-shell" "" "dms run" "dms-shell" ;;
                3) m_selected=0
                    while true; do
                        m_opts=("Uninstall Noctalia V5" "Uninstall Dank Material" "Back")
                        selected=$m_selected; draw_menu "${m_opts[@]}"; read -rsn3 mkey < /dev/tty
                        case "$mkey" in
                            $'\x1b[A') ((m_selected--)); [[ $m_selected -lt 0 ]] && m_selected=2 ;;
                            $'\x1b[B') ((m_selected++)); [[ $m_selected -gt 2 ]] && m_selected=0 ;;
                            "") case $m_selected in
                                    0) smart_uninstall "noctalia-git" ;;
                                    1) smart_uninstall "dms-shell" ;;
                                    2) break ;;
                                esac ;;
                        esac
                    done; selected=3 ;;
                4) s_selected=0
                    while true; do
                        s_opts=("ASCII Style: $current_ascii" "Flag: $current_flag" "Back")
                        selected=$s_selected; draw_menu "${s_opts[@]}"; read -rsn3 skey < /dev/tty
                        case "$skey" in
                            $'\x1b[A') ((s_selected--)); [[ $s_selected -lt 0 ]] && s_selected=2 ;;
                            $'\x1b[B') ((s_selected++)); [[ $s_selected -gt 2 ]] && s_selected=0 ;;
                            "") case $s_selected in
                                    0) [[ "$current_ascii" == "default" ]] && current_ascii="small" || current_ascii="default"; last_cols=0 ;;
                                    1) f_selected=0; flags=("trans" "enby" "lesbian" "bi" "pan" "ace" "back")
                                        while true; do
                                            selected=$f_selected; draw_menu "${flags[@]}"; read -rsn3 fkey < /dev/tty
                                            case "$fkey" in
                                                $'\x1b[A') ((f_selected--)); [[ $f_selected -lt 0 ]] && f_selected=6 ;;
                                                $'\x1b[B') ((f_selected++)); [[ $f_selected -gt 6 ]] && f_selected=0 ;;
                                                "") [[ $f_selected -eq 6 ]] && break; current_flag="${flags[$f_selected]}"; last_cols=0; break ;;
                                            esac
                                        done; s_selected=1 ;;
                                    2) break ;;
                                esac ;;
                        esac
                    done; selected=4 ;;
                5) tput cnorm; clear; exit ;;
            esac ;;
    esac
done
