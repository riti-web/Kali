#!/bin/bash

# Colors
RED='\033[1;31m'    # Red for errors
GRN='\033[1;32m'    # Green for success
BLU='\033[1;34m'    # Blue for banner and headers
YEL='\033[1;33m'    # Yellow for prompts and exit
PUR='\033[1;35m'    # Purple for menu options
WHT='\033[1;37m'    # White for neutral text
NC='\033[0m'        # No color

# Spinner animation function
spinner() {
    local msg=$1
    local pid=$!
    local spinstr='|/-\'
    local temp
    echo -ne "${WHT}[*] $msg...${NC}"
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        printf "\r${WHT}[*] $msg... [%c]${NC}" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done
    printf "\r${WHT}[*] $msg...${NC} ${GRN}Done${NC}\n"
}

clear

# Banner
echo -e "${BLU}"
echo "┌──────────────────────────┐"
echo "│     Kali NetHunter       │"
echo "│   by Yatharth            │"
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

# Function to check last command status
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Error: $1 failed!${NC}"
        return 1
    else
        echo -e "${GRN}[✓] $1 completed.${NC}"
        return 0
    fi
}

# Function to check device
check_device() {
    echo -e "${WHT}[*] Checking device compatibility...${NC}"
    command -v termux-setup-storage >/dev/null 2>&1 &
    spinner "Verifying Termux"
    if command -v termux-setup-storage >/dev/null 2>&1; then
        echo -e "${GRN}[✓] Termux detected, device supported.${NC}"
        return 0
    else
        echo -e "${RED}[✗] Device not supported! Please run in Termux.${NC}"
        return 1
    fi
}

# Function to recommend Kali NetHunter version
recommend_kali_version() {
    echo -e "${WHT}[*] Analyzing device specifications...${NC}"
    sleep 1 & spinner "Checking specs"

    # Check CPU architecture
    ARCH=$(uname -m)
    echo -e "${WHT}[*] CPU Architecture: $ARCH${NC}"

    # Check total RAM (in MB)
    RAM=$(free -m | awk '/Mem:/ {print $2}')
    echo -e "${WHT}[*] Total RAM: ${RAM}MB${NC}"

    # Check available storage in home directory (in GB)
    STORAGE=$(df -h $HOME | tail -n 1 | awk '{print $4}' | grep -o '[0-9]\+')
    if [ -z "$STORAGE" ]; then
        STORAGE=0
    fi
    echo -e "${WHT}[*] Available Storage: ${STORAGE}GB${NC}"

    # Recommend Kali version based on specs
    if [ "$RAM" -ge 4000 ] && [ "$STORAGE" -ge 10 ] && [ "$ARCH" = "aarch64" ]; then
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Full (High-end device detected)${NC}"
    elif [ "$RAM" -ge 2000 ] && [ "$STORAGE" -ge 5 ]; then
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Minimal (Mid-range device detected)${NC}"
    else
        echo -e "${GRN}[✓] Recommended: Kali NetHunter Nano (Low-end device detected)${NC}"
    fi
}

# Function to check for existing NetHunter installation
check_existing_installation() {
    if [ -d "$HOME/kali-arm64" ] || [ -d "$HOME/kali-armhf" ] || [ -d "$HOME/kali-fs" ]; then
        echo -e "${YEL}[!] Kali NetHunter appears to be installed already.${NC}"
        echo -e "${YEL}Do you want to reinstall? This will overwrite existing files. (y/n)${NC}"
        read -p " Confirm: " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo -e "${YEL}Installation cancelled.${NC}"
            exit 0
        fi
    fi
}

# Menu logic
case "$choice" in
    1)
        clear
        check_device
        if [ $? -eq 0 ]; then
            recommend_kali_version
            echo -e "${YEL}Press Enter to return to menu...${NC}"
            read -r
        fi
        echo -e "${YEL}Exiting device check...${NC}"
        exit 0
        ;;
    2)
        clear
        check_device
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Installation aborted due to device check failure.${NC}"
            exit 1
        fi

        check_existing_installation

        echo -e "${WHT}[*] Setting up storage permissions...${NC}"
        termux-setup-storage &
        spinner "Configuring storage"
        check_status "Storage setup" || exit 1

        echo -e "${WHT}[*] Installing wget...${NC}"
        pkg install wget -y &
        spinner "Installing wget"
        check_status "wget installation" || exit 1

        echo -e "${WHT}[*] Downloading Kali NetHunter installer...${NC}"
        # Use official Kali NetHunter URL (update this if needed)
        wget -O install-nethunter-termux https://kali.download/nethunter-images/installer/install-nethunter-termux &
        spinner "Downloading installer"
        if check_status "Installer download"; then
            if [ ! -s install-nethunter-termux ]; then
                echo -e "${RED}[✗] Error: Downloaded file is empty or corrupted!${NC}"
                exit 1
            fi
        else
            exit 1
        fi

        echo -e "${WHT}[*] Setting permissions (chmod +x)...${NC}"
        chmod +x install-nethunter-termux &
        spinner "Setting permissions"
        check_status "Permission setup" || exit 1

        echo -e "${WHT}[*] Running installer...${NC}"
        ./install-nethunter-termux &
        spinner "Running installer"
        if [ $? -eq 0 ]; then
            echo -e "${GRN}[✓] Success! Kali NetHunter installed.${NC}"
        else
            echo -e "${RED}[✗] Installation failed!${NC}"
            exit 1
        fi
        ;;
    3)
        clear
        echo -e "${YEL}[!] WARNING: This will remove all Kali NetHunter files. Continue? (y/n)${NC}"
        read -p " Confirm: " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo -e "${YEL}Removal cancelled.${NC}"
            exit 0
        fi
        echo -e "${WHT}[*] Removing Kali NetHunter files...${NC}"
        rm -rf install-nethunter-termux kali-arm64 kali-armhf kali-fs kalinethunter &
        spinner "Removing files"
        check_status "File removal"
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