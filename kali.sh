#!/bin/bash

# Check if terminal supports colors
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ $(tput colors) -ge 8 ]; then
    RED='\033[1;31m'    # Bold Red for errors
    GRN='\033[1;32m'    # Bold Green for success
    BLU='\033[1;34m'    # Bold Blue for banner and headers
    YEL='\033[1;33m'    # Bold Yellow for prompts and exit
    MAG='\033[1;35m'    # Bold Magenta for menu options and headers
    WHT='\033[1;37m'    # Bold White for neutral text
    CYAN='\033[0;36m'   # Cyan for informational messages
    ORNG='\033[1;33m'   # Bold Yellow as fallback for orange
    PINK='\033[1;35m'   # Bold Magenta as fallback for pink
    LBLU='\033[0;34m'   # Light Blue for subtle highlights
    LGRAY='\033[0;37m'  # Light Gray for subtle text
    NC='\033[0m'        # No color
else
    # Fallback to no colors if terminal doesn't support them
    RED='' GRN='' BLU='' YEL='' MAG='' WHT='' CYAN='' ORNG='' PINK='' LBLU='' LGRAY='' NC=''
fi

# Clear screen
clear

# Function for typewriter effect
typewriter() {
    text="$1"
    delay=0.05
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo -e "${NC}"
}

# Install figlet if not already installed
if ! command -v figlet >/dev/null 2>&1; then
    echo -e "${WHT}[*] Installing figlet for animation...${NC}"
    pkg install figlet -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Failed to install figlet. Animation may be limited.${NC}"
    fi
fi

# Welcome animation
echo -e "${BLU}"
if command -v figlet >/dev/null 2>&1; then
    figlet -f standard "NetHunter"
else
    echo "NetHunter"
fi
echo -e "${NC}"
echo -e "${CYAN}"
typewriter "Welcome to Kali NetHunter Installer by Yatharth"
echo -e "${NC}"
sleep 1

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
echo -e "${MAG}4) Backup Kali${NC}"
echo -e "${MAG}5) Restore Kali${NC}"
echo -e "${MAG}6) Exit${NC}"
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
    echo -e"${WHT}[*] Analyzing device specifications...${NC}"

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

# Function to display a spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='---'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}[%c]${NC}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to fully remove Kali NetHunter
remove_kali() {
    echo -e "${WHT}[*] Starting Kali NetHunter removal process...${NC}"
    sleep 1

    # Stop any running NetHunter processes
    echo -e "${WHT}[*] Stopping NetHunter processes...${NC}"
    if [ -f "$HOME/kali-arm64/usr/bin/nethunter" ]; then
        "$HOME/kaliევ" stop &
        spinner $!  # Show spinner while stopping processes
        check_status "Stop NetHunter processes"
    else
        echo -e "${YEL}[!] No NetHunter processes found.${NC}"
    fi
    sleep 1

    # Remove Kali NetHunter directories
    echo -e "${WHT}[*] Removing Kali NetHunter directories...${NC}"
    rm -rf "$HOME/kali-arm64" "$HOME/kali-armhf" "$HOME/kali-fs" "$HOME/kalinethunter" "$HOME/install-nethunter-termux" &
    spinner $!  # Show spinner while removing directories
    check_status "Remove directories"
    sleep 1

    # Remove NetHunter symbolic links and commands
    echo -e "${WHT}[*] Removing NetHunter commands and links...${NC}"
    rm -f /data/data/com.termux/files/usr/bin/nethunter /data/data/com.termux/files/usr/bin/nh &
    spinner $!  # Show spinner while removing links
    check_status "Remove commands"
    sleep 1

    # Remove NetHunter-related configurations in ~/.bashrc
    echo -e "${WHT}[*] Cleaning up .bashrc configurations...${NC}"
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/nethunter/d' "$HOME/.bashrc" &
        sed -i '/nh/d' "$HOME/.bashrc" &
        spinner $!  # Show spinner while cleaning .bashrc
        check_status "Clean .bashrc"
    else
        echo -e "${YEL}[!] No .bashrc file found.${NC}"
    fi
    sleep 1

    # Remove Termux boot scripts related to NetHunter
    echo -e "${WHT}[*] Removing Termux boot scripts...${NC}"
    rm -rf "$HOME/.termux/boot/nethunter*" &
    spinner $!  # Show spinner while removing boot scripts
    check_status "Remove boot scripts"
    sleep 1

    # Check if any residual files remain
    if [ -d "$HOME/kali-arm64" ] || [ -f /data/data/com.termux/files/usr/bin/nethunter ]; then
        echo -e "${RED}[✗] Some files could not be removed. Please check manually.${NC}"
    else
        echo -e "${GRN}[✓] Kali NetHunter fully removed!${NC}"
        echo -e "${CYAN}"
        typewriter "Removal completed successfully!"
        echo -e "${NC}"
    fi
}

# Function to backup Kali NetHunter
backup_kali() {
    echo -e "${WHT}[包裹

System: [ *] Backing up Kali NetHunter rootfs...${NC}"
    # Check for sufficient storage (at least 5GB recommended)
    STORAGE=$(df -h $HOME | tail -n 1 | awk '{print $4}' | grep -o '[0-9]\+')
    if [ -z "$STORAGE" ] || [ "$STORAGE" -lt 5 ]; then
        echo -e "${RED}[✗] Insufficient storage space! Minimum 5GB required.${NC}"
        return 1
    fi
    # Create a timestamped backup file
    TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
    BACKUP_FILE="$HOME/storage/downloads/kali-arm64-$TIMESTAMP.tar.xz"
    tar -cJf "$BACKUP_FILE" "$HOME/kali-arm64" &
    spinner $!
    check_status "Backup rootfs"
    if [ $? -eq 0 ]; then
        echo -e "${GRN}[✓] Backup saved to $BACKUP_FILE${NC}"
    fi
}

# Function to restore Kali NetHunter
restore_kali() {
    echo -e "${WHT}[*] Restoring Kali NetHunter rootfs...${NC}"
    # List available backups
    BACKUPS=($(ls -1 $HOME/storage/downloads/kali-arm64-*.tar.xz 2>/dev/null))
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        echo -e "${RED}[✗] No backup files found in ~/storage/downloads!${NC}"
        return 1
    fi
    echo -e "${BLU}Available backups:${NC}"
    for i in "${!BACKUPS[@]}"; do
        echo -e "${MAG}$((i+1))) ${BACKUPS[i]}${NC}"
    done
    echo -e "${YEL}"
    read -p "Select a backup to restore (number): " backup_choice
    echo -e "${NC}"
    if ! [[ "$backup_choice" =~ ^[0-9]+$ ]] || [ "$backup_choice" -lt 1 ] || [ "$backup_choice" -gt ${#BACKUPS[@]} ]; then
        echo -e "${RED}[✗] Invalid backup selection!${NC}"
        return 1
    fi
    BACKUP_FILE="${BACKUPS[$((backup_choice-1))]}"
    # Remove existing kali-arm64 directory if it exists
    if [ -d "$HOME/kali-arm64" ]; then
        rm -rf "$HOME/kali-arm64" &
        spinner $!
        check_status "Remove existing kali-arm64"
    fi
    # Extract the backup
    tar -xJf "$BACKUP_FILE" -C "$HOME" &
    spinner $!
    check_status "Restore rootfs"
    if [ $? -eq 0 ]; then
        echo -e "${GRN}[✓] Kali NetHunter restored from $BACKUP_FILE${NC}"
    fi
}

# Main logic
case $choice in
    1)
        clear
        check_device
        if [ $? -eq 0 ]; then
            recommend_kali_version
            echo -e "${YEL}Press Enter to exit...${NC}"
            read -r
        fi
        echo -e "${YEL}Exiting after device check...${NC}"
        echo -e "${GRN}Enter command (bash kali.sh) ${NC}"
        exit 0
        ;;
    2)
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
        ;;
    3)
        clear
        remove_kali
        ;;
    4)
        clear
        backup_kali
        ;;
    5)
        clear
        restore_kali
        ;;
    6)
        echo -e "${YEL} THANK YOU ${NC}"
        echo -e "${YEL}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        ;;
esac