#!/bin/bash

if pgrep -x "noctalia" > /dev/null; then ORIGINAL="v5";
elif pgrep -f "noctalia-shell" > /dev/null; then ORIGINAL="v4";
elif pgrep -f "dms" > /dev/null; then ORIGINAL="dank";
else ORIGINAL="none"; fi

PURPLE="\e[38;5;129m"
ORANGE="\e[38;5;208m"
BLUE="\e[38;5;39m"
PINK="\e[38;5;211m"
WHITE="\e[38;5;255m"
CYAN="\e[1;36m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

is_installed() {
    case $1 in
        "v4") [ -d "/etc/xdg/quickshell/noctalia-shell" ] && return 0 || return 1 ;;
        "v5") command -v noctalia &> /dev/null && return 0 || return 1 ;;
        "dank") command -v dms &> /dev/null && return 0 || return 1 ;;
    esac
}

get_status() {
    if is_installed "$1"; then echo -e "${GREEN}(INSTALLED)${RESET}"; else echo -e "${RED}(MISSING)${RESET}"; fi
}

revert_shell() {
    pkill -f "noctalia|quickshell|qs|dms"
    case $ORIGINAL in
        "v4") qs -c noctalia-shell > /dev/null 2>&1 & ;;
        "v5") noctalia > /dev/null 2>&1 & ;;
        "dank") dms run > /dev/null 2>&1 & ;;
    esac
    disown && clear && exit
}
trap revert_shell SIGINT SIGTERM

manage_pkg() {
    local action=$1; local shell=$2
    HELPER=$(command -v paru || command -v yay || echo "sudo pacman")
    clear
    case $shell in
        "v4") [[ $action == "install" ]] && $HELPER -S noctalia-shell || sudo pacman -Rs noctalia-shell ;;
        "v5") [[ $action == "install" ]] && (mkdir -p ~/builds && cd ~/builds && git clone https://aur.archlinux.org/noctalia-git.git && cd noctalia-git && makepkg -is) || sudo pacman -Rs noctalia-git ;;
        "dank") [[ $action == "install" ]] && $HELPER -S dms-shell || sudo pacman -Rs dms-shell ;;
    esac
}

draw_ui() {
    clear
    local term_cols=$(tput cols)
    local term_lines=$(tput lines)

    local a1=" _________  ________  "
    local a2="|  _   _  |/  ___  _| "
    local a3="|_/ | | \_|\ \`--. \`--. "
    local a4="    | |     \`--. \`--. "
    local a5="   _| |_   /\__/ /\__/ "
    local a6="  |_____|  \____/\____/ "

    local b1="  ______           _ _       _               "
    local b2=" /  ____|         (_) |     | |              "
    local b3=" | (___  __      ___| |_ ___| |__   ___ _ __ "
    local b4="  \___ \ \ \ /\ / / | __/ __| '_ \ / _ \ '__|"
    local b5="  ____) | \ V  V /| | || (__| | | |  __/ |   "
    local b6=" |_____/   \_/\_/ |_|\__\___|_| |_|\___|_|   "

    local desc_colored="the boredom of a ${BLUE}T${PINK}G${WHITE}i${PINK}r${BLUE}l${RESET} v1"
    local status_line="Active Shell: $ORIGINAL"
    
    local start_line=$(( (term_lines / 2) - 10 ))
    for ((i=0; i<start_line; i++)); do echo ""; done

    local ascii_width=67
    local pad=$(( (term_cols - ascii_width) / 2 ))

    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a1" "$b1"
    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a2" "$b2"
    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a3" "$b3"
    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a4" "$b4"
    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a5" "$b5"
    printf "%${pad}s${PURPLE}%s${ORANGE}%s${RESET}\n" "" "$a6" "$b6"

    echo ""
    local desc_pad=$(( (term_cols - 24) / 2 ))
    printf "%${desc_pad}s%b\n" "" "$desc_colored"
    local status_pad=$(( (term_cols - ${#status_line}) / 2 ))
    printf "%${status_pad}s%s\n\n" "" "$status_line"

    local menu_pad=$(( (term_cols - 35) / 2 ))
    for i in "${!options[@]}"; do
        if [ "$i" -eq 3 ]; then echo ""; fi
        if [ "$i" -eq "$selected" ]; then
            printf "%${menu_pad}s${CYAN} ▶  %b${RESET}\n" "" "${options[$i]}"
        else
            printf "%${menu_pad}s   %b\n" "" "${options[$i]}"
        fi
    done
}

pkill -f "noctalia|quickshell|qs|dank"
selected=0

while true; do
    options=(
        "V4 Legacy      $(get_status 'v4')"
        "V5 In Testing  $(get_status 'v5')"
        "Dank Material  $(get_status 'dank')"
        "Manage / Uninstall Shells"
        "Exit and Revert"
    )
    
    draw_ui
    read -rsn3 key
    case "$key" in
        $'\x1b[A') ((selected--)); [ "$selected" -lt 0 ] && selected=4 ;;
        $'\x1b[B') ((selected++)); [ "$selected" -gt 4 ] && selected=0 ;;
        "") break ;;
    esac
done

case $selected in
    0) ! is_installed "v4" && manage_pkg "install" "v4"; qs -c noctalia-shell > /dev/null 2>&1 & ;;
    1) ! is_installed "v5" && manage_pkg "install" "v5"; noctalia > /dev/null 2>&1 & ;;
    2) ! is_installed "dank" && manage_pkg "install" "dank"; dms run > /dev/null 2>&1 & ;;
    3)
        clear
        echo "1. Uninstall V4 | 2. Uninstall V5 | 3. Uninstall Dank | 4. Back"
        read -p "Selection: " uchoice
        case $uchoice in
            1) manage_pkg "remove" "v4" ;;
            2) manage_pkg "remove" "v5" ;;
            3) manage_pkg "remove" "dank" ;;
        esac
        exec "$0" ;;
    4) revert_shell ;;
esac

disown
clear
exit
