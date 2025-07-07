#!/bin/bash

# Colors
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
WHT='\033[1;37m'
NC='\033[0m' 

# Spinner function
spinner() {
    local msg="$1"
    local pid=$2
    local spinstr='|/-\'
    local temp
    echo -ne "${WHT}[*] $msg...${NC}"
    while kill -0 "$pid" 2>/dev/null; do
        temp=${spinstr#?}
        printf "\r${WHT}[*] $msg... [%c]${NC}" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done
    wait "$pid"
    if [ $? -eq 0 ]; then
        printf "\r${WHT}[*] $msg...${NC} ${GRN}Done${NC}\n"
        return 0
    else
        printf "\r${WHT}[*] $msg...${NC} ${RED}Failed${NC}\n"
        return 1
    fi
}

# Status check function
check_status() {
    if [ $1 -ne 0 ]; then
        echo -e "${RED}[✗] Error: $2 failed!${NC}"
        return 1
    else
        echo -e "${GRN}[✓] $2 completed.${NC}"
        return 0
    fi
}

# Device check
check_device() {
    echo -e "${WHT}[*] Checking device compatibility...${NC}"
    if command -v termux-setup-storage >/dev/null 2>&1; then
        echo -e "${GRN}[✓] Termux detected, device supported.${NC}"
        return 0
    else
        echo -e "${RED}[✗] Device not supported! Please run in Termux.${NC}"
        return 1
    fi
}

# Recommend version
recommend_kali_version() {
    echo -e "${WHT}[*] Analyzing device specifications...${NC}"
    sleep 1
    ARCH=$(uname -m)
    echo -e "${WHT}[*] CPU Architecture: $ARCH${NC}"
    RAM=$(free -m | awk '/Mem:/ {print $2}')
    echo -e "${WHT}[*] Total RAM: ${RAM}MB${NC}"
    STORAGE=$(df -h "$HOME" | tail -n 1 | awk '{print $4}' | grep -oE '[0-9]+' | head -n 1)
    [ -z "$STORAGE" ] && STORAGE=0
    echo -e "${WHT}[*] Available Storage: ${STORAGE}GB${NC}"
    if [ "$RAM" -ge 4000 ] && [ "$STORAGE" -ge 10 ] && [ "$ARCH" = "aarch64" ]; then
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Full${NC}"
    elif [ "$RAM" -ge 2000 ] && [ "$STORAGE" -ge 5 ]; then
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Minimal${NC}"
    else
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Nano${NC}"
    fi
}

# Existing install check
check_existing_installation() {
    if [ -d "$HOME/kali-arm64" ] || [ -d "$HOME/kali-armhf" ] || [ -d "$HOME/kali-fs" ]; then
        echo -e "${YEL}[!] Kali NetHunter appears to be installed already.${NC}"
        echo -e "${YEL}Do you want to reinstall? This will overwrite existing files. (y/n)${NC}"
        read -p " Confirm: " confirm
        if ! echo "$confirm" | grep -qi '^y$'; then
            echo -e "${YEL}Installation cancelled.${NC}"
            exit 1
        fi
    fi
}

clear

# Banner
echo -e "${BLU}"
echo "┌──────────────────────────┐"
echo "│     Kali NetHunter       │"
echo "│       by Yatharth        │"
echo "└──────────────────────────┘"
echo -e "${NC}"

# Menu
echo -e "${BLU}┌──────────────────────────┐${NC}"
echo -e "${BLU}│ NetHunter Installer Menu │${NC}"
echo -e "${BLU}└──────────────────────────┘${NC}"
echo -e "${PUR} [1] Check Device${NC}"
echo -e "${PUR} [2] Install Kali${NC}"
echo -e "${PUR} [3] Remove Kali${NC}"
echo -e "${PUR} [4] Exit${NC}"
echo -e "${YEL}"
read -p " Select an option: " choice
echo -e "${NC}"

# Menu logic
case "$choice" in
    1)
        clear
        check_device
        if [ $? -eq 0 ]; then
            recommend_kali_version
            echo -e "${YEL}Press Enter to return to menu...${NC}"
            read -r
            exec "$0"
        fi
        echo -e "${YEL}Exiting device check...${NC}"
        exit 1
        ;;
    2)
        clear
        check_device || { echo -e "${RED}[✗] Installation aborted due to device check failure.${NC}"; exit 1; }

        check_existing_installation

        echo -e "${WHT}[*] Setting up storage permissions...${NC}"
        if [ -d "$HOME/storage/shared" ]; then
            echo -e "${GRN}[✓] Storage already configured.${NC}"
        else
            termux-setup-storage &
            spinner "Configuring storage" $!
            check_status $? "Storage setup" || exit 1
        fi

        echo -e "${WHT}[*] Installing wget...${NC}"
        pkg install wget -y &
        spinner "Installing wget" $!
        check_status $? "wget installation" || exit 1

        echo -e "${WHT}[*] Downloading Kali NetHunter installer...${NC}"
        wget -O install-nethunter-termux https://offs.ec/2MceZWr &
        spinner "Downloading installer" $!
        if check_status $? "Installer download"; then
            [ ! -s install-nethunter-termux ] && { echo -e "${RED}[✗] Error: Downloaded file is empty or corrupted!${NC}"; exit 1; }
        else
            exit 1
        fi

        echo -e "${WHT}[*] Setting permissions...${NC}"
        chmod +x install-nethunter-termux
        check_status $? "Permission setup" || exit 1

        echo -e "${WHT}[*] Running installer...${NC}"
        ./install-nethunter-termux &
        spinner "Running installer" $!
        check_status $? "Kali NetHunter installation" || exit 1

        echo -e "${GRN}[✓] Success! Kali NetHunter installed.${NC}"
        ;;
    3)
        clear
        echo -e "${YEL}[!] WARNING: This will remove all Kali NetHunter files. Continue? (y/n)${NC}"
        read -p " Confirm: " confirm
        if ! echo "$confirm" | grep -qi '^y$'; then
            echo -e "${YEL}Removal cancelled.${NC}"
            exit 1
        fi
        echo -e "${WHT}[*] Removing Kali NetHunter files...${NC}"
        rm -rf install-nethunter-termux kali-arm64 kali-armhf kali-fs kalinethunter &
        spinner "Removing files" $!
        check_status $? "File removal" || exit 1
        echo -e "${GRN}[✓] Kali NetHunter removed successfully!${NC}"
        ;;
    4)
        echo -e "${YEL}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice! Please select a valid option.${NC}"
        exit 1
        ;;
esac