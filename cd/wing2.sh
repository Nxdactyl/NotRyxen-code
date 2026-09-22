#!/bin/bash

# ================================================================
#                  MACK CONTROL PANEL v3.0
#             Professional Server Management Panel
#                  Credits: NotRyxen & NyroxDev
# ================================================================

# --- COLORS & STYLES ---
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
W="\e[97m"
GR="\e[90m"
N="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
BLINK="\e[5m"

# --- SYSTEM AUTO-DETECT VARIABLES ---
detect_system() {
    # 1. OS Detection
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$PRETTY_NAME
    else
        OS_NAME=$(uname -s)
    fi

    # 2. IP Detection (Fast with timeout)
    PUBLIC_IP=$(curl -s --max-time 2 https://ipinfo.io/ip || echo "Unknown")
    LOCAL_IP=$(hostname -I | awk '{print $1}')

    # 3. RAM Usage
    if command -v free >/dev/null 2>&1; then
        RAM_USED=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    else
        RAM_USED="N/A"
    fi
}

# ================================================================
#                         UI FUNCTIONS
# ================================================================

draw_top() {
    echo -e "${B}╔══════════════════════════════════════════════════════════════╗${N}"
}

draw_line() {
    echo -e "${B}╠══════════════════════════════════════════════════════════════╣${N}"
}

draw_bottom() {
    echo -e "${B}╚══════════════════════════════════════════════════════════════╝${N}"
}

loading() {
    echo -ne "${C}  Initializing${N}"
    for i in {1..3}; do
        echo -ne "${C}.${N}"
        sleep 0.25
    done
    echo ""
}

# ================================================================
#                         MAIN HEADER
# ================================================================

header() {
    clear

    echo -e "${B}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo -e "║        ${W}${BOLD}⚡ MACK CONTROL PANEL${N}${B}                         ║"
    echo -e "║        ${GR}Professional Server Automation System${N}${B}           ║"
    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo -e "║  ${C}${BOLD}SYSTEM INFORMATION${N}${B}                                    ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo -e "║  ${GR}OS${N}        : ${W}${OS_NAME:0:43}${N}${B} ║"
    echo -e "║  ${GR}WAN IP${N}    : ${G}${PUBLIC_IP:0:43}${N}${B} ║"
    echo -e "║  ${GR}LAN IP${N}    : ${C}${LOCAL_IP:0:43}${N}${B} ║"
    echo -e "║  ${GR}RAM${N}       : ${Y}${RAM_USED:0:43}${N}${B} ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo -e "║  ${M}${BOLD}MACK SERVER MANAGEMENT${N}${B}                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${N}"

    echo -e "  ${GR}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "  ${DIM}${GR}Credits: ${W}NotRyxen${GR} & ${W}NyroxDev${N}"
    echo -e "  ${GR}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
}

# ================================================================
#                           MENU
# ================================================================

show_menu() {

    echo -e "${W}${BOLD}  AVAILABLE MODULES${N}"
    echo -e "${GR}  ────────────────────────────────────────────────────────────${N}"
    echo ""

    echo -e "  ${B}${BOLD}[1]${N}  ${C}SSL Configuration${N}"
    echo -e "       ${GR}Certbot / Nginx SSL Certificate${N}"
    echo ""

    echo -e "  ${B}${BOLD}[2]${N}  ${G}Install Wings${N}"
    echo -e "       ${GR}Nobita Wings Installation Script${N}"
    echo ""

    echo -e "  ${B}${BOLD}[3]${N}  ${Y}Wings Manager${N}"
    echo -e "       ${GR}Manage Pterodactyl Wings${N}"
    echo ""

    echo -e "  ${B}${BOLD}[4]${N}  ${M}Database Manager${N}"
    echo -e "       ${GR}MySQL / MariaDB Management${N}"
    echo ""

    echo -e "  ${B}${BOLD}[5]${N}  ${R}Uninstall${N}"
    echo -e "       ${GR}Remove Wings / Docker / Configs${N}"
    echo ""

    echo -e "${GR}  ────────────────────────────────────────────────────────────${N}"

    echo -e "  ${B}${BOLD}[0]${N}  ${W}Exit System${N}"
    echo ""
}

# ================================================================
#                        SSL CONFIGURATION
# ================================================================

ssl_setup() {

    header

    echo -e "${C}  ┌──────────────────────────────────────────────────────────┐${N}"
    echo -e "${C}  │${N} ${W}${BOLD}SSL CONFIGURATION${N}                                     ${C}│${N}"
    echo -e "${C}  ├──────────────────────────────────────────────────────────┤${N}"
    echo -e "${C}  │${N} ${GR}Public IP:${N} ${G}$PUBLIC_IP${N}"
    echo -e "${C}  └──────────────────────────────────────────────────────────┘${N}"
    echo ""

    echo -ne "${C}  ╰─➤ ${W}Enter Domain ${GR}(e.g., Node.host.com)${N}: "
    read DOMAIN

    if [[ -z "$DOMAIN" ]]; then
        echo ""
        echo -e "  ${R}${BOLD}✖ Setup Aborted${N}"
        echo -e "  ${GR}No domain was provided.${N}"
        echo ""
        sleep 1
        return
    fi

    echo ""
    echo -e "${C}  ┌─ ${W}${BOLD}INSTALLATION${N}${C} ────────────────────────────────────────┐${N}"
    echo -e "${C}  │${N} ${Y}➜${N} Installing Dependencies..."
    echo -e "${C}  └──────────────────────────────────────────────────────────┘${N}"

    apt update -y >/dev/null 2>&1
    apt install -y certbot python3-certbot-nginx > /dev/null 2>&1

    echo ""
    echo -e "${C}  ┌─ ${W}${BOLD}CERTIFICATE${N}${C} ──────────────────────────────────────────┐${N}"
    echo -e "${C}  │${N} ${Y}➜${N} Requesting Certificate"
    echo -e "${C}  │${N} ${GR}Domain:${N} ${W}$DOMAIN${N}"
    echo -e "${C}  └──────────────────────────────────────────────────────────┘${N}"

    rm -rf /etc/letsencrypt/live/$DOMAIN
    rm -rf /etc/letsencrypt/archive/$DOMAIN
    rm -rf /etc/letsencrypt/renewal/$DOMAIN.conf
    certbot certonly --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "ssl$(tr -dc a-z0-9 </dev/urandom | head -c6)@$DOMAIN"

    echo ""
    echo -e "${G}  ╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}  ║${N}  ${G}${BOLD}✔ SSL SETUP COMPLETE${N}                                ${G}║${N}"
    echo -e "${G}  ╚══════════════════════════════════════════════════════════╝${N}"
    echo ""

    read -p "  Press Enter to return..."
}

# ================================================================
#                         UNINSTALL MENU
# ================================================================

uninstall_menu() {

    clear

    echo -e "${R}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║              ⚠  DANGER ZONE: UNINSTALL                      ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${N}"

    echo -e "${R}  WARNING${N}"
    echo -e "${GR}  This operation will remove:${N}"
    echo -e "  ${R}•${N} Wings"
    echo -e "  ${R}•${N} Docker"
    echo -e "  ${R}•${N} Wings configuration"
    echo -e "  ${R}•${N} Pterodactyl Wings data"
    echo ""
    echo -e "  ${G}✓${N} Panel files will remain safe."
    echo ""

    echo -e "${R}  ────────────────────────────────────────────────────────────${N}"
    echo -ne "  ${R}${BOLD}Are you sure? [y/N]:${N} "
    read CONFIRM

    [[ "$CONFIRM" != "y" ]] && return

    echo ""
    echo -e "${Y}  [1/3]${N} ${W}Stopping Wings...${N}"

    systemctl disable --now wings 2>/dev/null
    rm -f /etc/systemd/system/wings.service
    rm -rf /etc/pterodactyl /var/lib/pterodactyl /usr/local/bin/wings
    systemctl disable --now wings 2>/dev/null
    rm -f /etc/systemd/system/wings.service
    rm -rf /etc/pterodactyl
    rm -f /usr/local/bin/wings
    rm -rf /var/lib/pterodactyl

    echo -e "${Y}  [2/3]${N} ${W}Pruning Docker...${N}"

    docker system prune -a -f 2>/dev/null

    echo ""
    echo -e "${C}  ┌──────────────────────────────────────────────────────────┐${N}"
    echo -ne "${C}  │${N} ${W}Delete Database? [y/N]: ${N}"
    read DEL_DB

    if [[ "$DEL_DB" == "y" ]]; then

        echo -ne "  ${W}DB Name: ${N}"
        read DBN

        echo -ne "  ${W}DB User: ${N}"
        read DBU

        mysql -e "DROP DATABASE IF EXISTS $DBN; DROP USER IF EXISTS '$DBU'@'127.0.0.1';" 2>/dev/null

        echo -e "  ${G}✔ Database cleared.${N}"
    fi

    echo -e "${C}  └──────────────────────────────────────────────────────────┘${N}"

    echo ""
    echo -e "${Y}  [3/3]${N} ${W}Finalizing...${N}"
    sleep 1

    echo ""
    echo -e "${G}  ╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}  ║${N}  ${G}${BOLD}✔ UNINSTALLATION FINISHED${N}                           ${G}║${N}"
    echo -e "${G}  ╚══════════════════════════════════════════════════════════╝${N}"
    echo ""

    sleep 2
}

# ================================================================
#                       STARTUP
# ================================================================

clear

echo -e "${B}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo -e "║              ${W}${BOLD}⚡ MACK CONTROL PANEL${N}${B}                    ║"
echo -e "║                 ${GR}Starting System...${N}${B}                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${N}"

loading

# Detect System Info ONCE at startup
detect_system

sleep 0.5

# ================================================================
#                         MAIN LOOP
# ================================================================

while true; do

    header
    show_menu

    echo -e "  ${GR}System ready.${N}"
    echo ""
    echo -ne "  ${C}${BOLD}root@mack-panel${N}${GR}:~#${N} "
    read opt

    case $opt in

        1)
            ssl_setup
            ;;

        2)
            bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/wings/install.sh)
            ;;

        3)
            bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/wings/mang.sh)
            ;;

        4)
            bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/ptero/refs/heads/main/ptero/wings/db.sh)
            ;;

        5)
            uninstall_menu
            ;;

        0)
            clear
            echo ""
            echo -e "${B}  ╔══════════════════════════════════════════════════════════╗${N}"
            echo -e "${B}  ║${N}                                                      ${B}║${N}"
            echo -e "${B}  ║${N}       ${G}${BOLD}👋 Thank you for using MACK PANEL${N}             ${B}║${N}"
            echo -e "${B}  ║${N}                                                      ${B}║${N}"
            echo -e "${B}  ║${N}       ${GR}Credits: ${W}NotRyxen ${GR}& ${W}NyroxDev${N}                  ${B}║${N}"
            echo -e "${B}  ║${N}                                                      ${B}║${N}"
            echo -e "${B}  ╚══════════════════════════════════════════════════════════╝${N}"
            echo ""
            exit 0
            ;;

        *)
            echo ""
            echo -e "  ${R}${BOLD}✖ Invalid Option${N}"
            echo -e "  ${GR}Please select an option from 0-5.${N}"
            sleep 1
            ;;

    esac

done
