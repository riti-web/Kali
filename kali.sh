#!/bin/bash

# Colors
RED='\033[1;31m'
GRN='\033[1;32m'
CYA='\033[1;36m'
YEL='\033[1;33m'
NC='\033[0m'     # No color
BLU='\033[1;34m' # Blue color

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
echo -e "${GRN}1) Check device"
echo -e "2) Install"
echo -e "${RED}3) Remove"
echo -e "${YEL}4) Exit${NC}"
echo
read -p "Enter your choice: " choice

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
    echo -e "${CYA}[*] Checking your device...${NC}"
    if command -v termux-setup-storage >/dev/null 2>&1; then
        echo -e "${GRN}[✓] Termux detected, device supported.${NC}"
        return 0
    else
        echo -e "${RED}[✗] Device not supported! Please run in Termux.${NC}"
        return 1
    fi
}

if [ "$choice" == "1" ]; then
    clear
    check_device
    echo -e "${YEL}Exiting after device check...${NC}"
    exit 0

elif [ "$choice" == "2" ]; then
    clear
    check_device
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Install aborted due to device check failure.${NC}"
        exit 1
    fi

    echo -e "${CYA}[*] Setting up storage permission...${NC}"
    termux-setup-storage
    check_status "Storage setup"

    echo -e "${CYA}[*] Installing wget...${NC}"
    pkg install wget -y
    check_status "wget install"

    echo -e "${CYA}[*] Downloading Kali Nethunter installer...${NC}"
    wget -O install-nethunter-termux https://offs.ec/2MceZWr
    check_status "Download script"

    echo -e "${CYA}[*] Giving strong permission (chmod 777)...${NC}"
    chmod 777 install-nethunter-termux
    check_status "Give permission"

    echo -e "${GRN}[*] Running installer...${NC}"
    ./install-nethunter-termux
    if [ $? -eq 0 ]; then
        echo -e "${GRN}[✓] Successful install! Kali Linux installation complete.${NC}"
    else
        echo -e "${RED}[✗] Install problem occurred!${NC}"
    fi

elif [ "$choice" == "3" ]; then
    clear
    echo -e "${RED}[*] Removing Kali Linux files...${NC}"
    rm -rf install-nethunter-termux kali-arm64 kali-armhf kali-fs kalinethunter
    check_status "Remove files"

    echo -e "${RED}[✓] Kali Linux removed!${NC}"

elif [ "$choice" == "4" ]; then
    echo -e "${YEL}Exiting...${NC}"
    exit 0

else
    echo -e "${RED}Invalid choice!${NC}"
fi