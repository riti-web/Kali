#!/bin/bash
# Colors
RED='\033[1;31m'        # Red for errors
GRN='\033[1;32m'        # Green for success
BLU='\033[1;34m'        # Blue for banner and headers
YEL='\033[1;33m'        # Yellow for prompts and exit
MAG='\033[1;35m'        # Magenta for menu options
WHT='\033[1;37m'        # White for neutral text
CYAN='\033[0;36m'       # Cyan for informational messages
BCYAN='\033[1;36m'      # Bold Cyan for emphasized info
PURP='\033[0;35m'       # Purple for secondary prompts
BPURP='\033[1;35m'      # Bold Purple for headers (replaces MAG in some places)
LGRAY='\033[0;37m'      # Light Gray for subtle text
ORNG='\033[38;5;208m'   # Orange for warnings
LBLU='\033[0;34m'       # Light Blue for subtle highlights
PINK='\033[38;5;200m'   # Pink for standout text
NC='\033[0m'            # No color
clear

# Banner
echo -e "${BLU}"
echo "##################################################"
echo "##                                              ##"
echo "##  88      a8P         db        88        88  ##"
echo "##  88    .88'         d88b       88        88  ##"
echo "##  88   88'          d8''8b      88        88  ##"
echo "##  88 d88           d8'  '8b     88        88  ##"
echo "##  8888'88.        d8YaaaaY8b    88        88  ##"
echo "##  88     '88.   d8'        '8b  88        88  ##"
echo "##  88       Y8b d8'          '8b 888888888 88  ##"
echo "##            ~Ph no. 7091507536~               ##"
echo "##############   ~By Yatharth~                  ##"
echo "####### ######## NetHunter 😈 YATHARTH ###########"
echo -e "${NC}"

# Menu
echo -e "${BLU}=== Kali NetHunter Installer ===${NC}"
echo -e "${MAG}1) Check device${NC}"
echo -e "${MAG}2) Install Kali${NC}"
echo -e "${MAG}3) Remove Kali${NC}"
echo -e "${MAG}4) Exit${NC}"
echo -e "${YEL}"
read -p "Enter your choice: " choice
echo -e "${NC}"

# Function to check last command status and show error if failed
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Error: $1 failed!${NC}"
    else
        echo -e "${GRN}[✓] $1 done.${NC}"
    fi
}

# Function to check device
check_device() {
    echo -e "${WHT}[*] Checking your device...${NC}"
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

# Function to fully remove Kali NetHunter
remove_kali() {
    echo -e "${WHT}[*] Starting Kali NetHunter removal process...${NC}"

    # Stop any running NetHunter processes
    echo -e "${WHT}[*] Stopping NetHunter processes...${NC}"
    if [ -f "$HOME/kali-arm64/usr/bin/nethunter" ]; then
        "$HOME/kali-arm64/usr/bin/nethunter" stop
        check_status "Stop NetHunter processes"
    fi

    # Remove Kali NetHunter directories
    echo -e "${WHT}[*] Removing Kali NetHunter directories...${NC}"
    rm -rf "$HOME/kali-arm64" "$HOME/kali-armhf" "$HOME/kali-fs" "$HOME/kalinethunter" "$HOME/install-nethunter-termux"
    check_status "Remove directories"

    # Remove NetHunter symbolic links and commands
    echo -e "${WHT}[*] Removing NetHunter commands and links...${NC}"
    rm -f /data/data/com.termux/files/usr/bin/nethunter
    rm -f /data/data/com.termux/files/usr/bin/nh
    check_status "Remove commands"

    # Remove NetHunter-related configurations in ~/.bashrc
    echo -e "${WHT}[*] Cleaning up .bashrc configurations...${NC}"
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/nethunter/d' "$HOME/.bashrc"
        sed -i '/nh/d' "$HOME/.bashrc"
        check_status "Clean .bashrc"
    fi

    # Remove Termux boot scripts related to NetHunter
    echo -e "${WHT}[*] Removing Termux boot scripts...${NC}"
    rm -rf "$HOME/.termux/boot/nethunter*"
    check_status "Remove boot scripts"

    # Check if any residual files remain
    if [ -d "$HOME/kali-arm64" ] || [ -f /data/data/com.termux/files/usr/bin/nethunter ]; then
        echo -e "${RED}[✗] Some files could not be removed. Please check manually.${NC}"
    else
        echo -e "${GRN}[✓] Kali NetHunter fully removed!${NC}"
    fi
}

if [ "$choice" == "1" ]; then
    clear
    check_device
    if [ $? -eq 0 ]; then
        recommend_kali_version
        echo -e "${YEL}Press Enter to exit...${NC}"
        read -r
    fi
    echo -e "${YEL}Exiting after device check...${NC}"
    echo -e "${ORNG}Enter command (bash kali.sh) ${NC}"
    exit 0

elif [ "$choice" == "2" ]; then
    clear
    check_device
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Install aborted due to device check failure.${NC}"
        exit 1
    fi

    echo -e "${WHT}[*] Setting up storage permission...${NC}"
    termux-setup-storage
    check_status "Storage setup"

    echo -e "${WHT}[*] Installing wget...${NC}"
    pkg install wget -y
    check_status "wget install"

    echo -e "${WHT}[*] Downloading Kali NetHunter installer...${NC}"
    wget -O install-nethunter-termux https://offs.ec/2MceZWr
    check_status "Download script"

    echo -e "${WHT}[*] Giving strong permission (chmod 777)...${NC}"
    chmod 777 install-nethunter-termux
    check_status "Give permission"

    echo -e "${WHT}[*] Running installer...${NC}"
    ./install-nethunter-termux
    if [ $? -eq 0 ]; then
        echo -e "${GRN}[✓] Successful install! Kali Linux installation complete.${NC}"
    else
        echo -e "${RED}[✗] Install problem occurred!${NC}"
    fi

elif [ "$choice" == "3" ]; then
    clear
    remove_kali

elif [ "$choice" == "4" ]; then
    echo -e "${YEL}Exiting...${NC}"
    exit 0

else
    echo -e "${RED}Invalid choice!${NC}"
fi