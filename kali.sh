
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
    local spinstr='|/-\\'
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

if [ "$choice" == "1" ]; then
    clear
    check_device
    if [ $? -eq 0 ]; then
        recommend_kali_version
        echo -e "${YEL}Press Enter to exit...${NC}"
        read -r
    fi
    echo -e "${YEL}Exiting after device check...${NC}"
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
    echo -e "${WHT}[*] Removing Kali Linux files...${NC}"
    rm -rf install-nethunter-termux kali-arm64 kali-armhf kali-fs kalinethunter
    check_status "Remove files"

    echo -e "${GRN}[✓] Kali Linux removed!${NC}"

elif [ "$choice" == "4" ]; then
    echo -e "${YEL}Exiting...${NC}"
    exit 0

else
    echo -e "${RED}Invalid choice!${NC}"
fi