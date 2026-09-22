#!/bin/bash

# ================================================================
#                  PTERODACTYL CONTROL CENTER
#                    Professional Edition
#                    Credits: NotRyxen & Nyrox
# ================================================================

# --- COLORS & STYLING ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'
GOLD='\033[0;33m'
GRAY='\033[0;90m'
DIM='\033[2m'

# ================================================================
#                         UI HELPERS
# ================================================================

show_header() {
    clear

    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo -e "║        ${WHITE}${BOLD}⚡ PTERODACTYL CONTROL CENTER${NC}${PURPLE}                  ║"
    echo -e "║        ${GRAY}Professional Server Management System${NC}${PURPLE}          ║"
    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo -e "║  ${CYAN}MODULE${NC}${PURPLE}      : ${WHITE}$1${PURPLE}"
    echo -e "║  ${CYAN}CREDITS${NC}${PURPLE}     : ${WHITE}Jishnu & Nobita${PURPLE}"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

status_msg() {
    # $1 = Type (OK, ERR, INFO, WAIT), $2 = Message
    case $1 in
        "OK")   echo -e "  ${GREEN}[ ✔ ]${NC} $2" ;;
        "ERR")  echo -e "  ${RED}[ ✘ ]${NC} $2" ;;
        "INFO") echo -e "  ${CYAN}[ ➜ ]${NC} $2" ;;
        "WAIT") echo -e "  ${YELLOW}[ ⏳ ]${NC} $2" ;;
    esac
}

section() {
    echo ""
    echo -e "  ${PURPLE}┌─[ ${WHITE}${BOLD}$1${NC}${PURPLE} ]────────────────────────────────────────────────┐${NC}"
}

section_end() {
    echo -e "  ${PURPLE}└──────────────────────────────────────────────────────────┘${NC}"
}

pause() {
    echo ""
    echo -ne "  ${GRAY}Press [Enter] to return to main menu...${NC}"
    read
}

# ================================================================
#                     PANEL INSTALLATION
# ================================================================

install_ptero() {
    show_header "PANEL INSTALLATION"

    section "INSTALLATION"

    status_msg "INFO" "Initiating Pterodactyl installation script..."
    status_msg "INFO" "Please follow the installer instructions below."

    section_end

    sleep 1

    # Run the external script
    bash <(curl -s https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/panel/pterodactyl/install.sh)

    echo ""
    status_msg "OK" "Installation Sequence Complete."

    pause
}

# ================================================================
#                       USER MANAGEMENT
# ================================================================

create_user() {
    show_header "USER MANAGEMENT"

    if [ ! -d /var/www/pterodactyl ]; then

        section "PANEL STATUS"

        status_msg "ERR" "Panel directory not found."
        status_msg "ERR" "/var/www/pterodactyl does not exist."
        status_msg "INFO" "Please install the panel first."

        section_end

        pause
        return
    fi

    section "CREATE USER"

    echo -e "  ${GREEN}[1]${NC} ${WHITE}Custom User Create${NC}"
    echo -e "      ${GRAY}Manual Pterodactyl user creation${NC}"
    echo ""

    echo -e "  ${GREEN}[2]${NC} ${WHITE}Auto Create Admin User${NC}"
    echo -e "      ${GRAY}Automatically generate admin credentials${NC}"
    echo ""

    section_end

    echo ""
    echo -ne "  ${CYAN}${BOLD}root@ptero${NC}${GRAY}:~#${NC} "
    read choice

    cd /var/www/pterodactyl || exit

    if [ "$choice" = "1" ]; then

        show_header "USER MANAGEMENT"

        status_msg "WAIT" "Launching manual user creation..."
        php artisan p:user:make

    elif [ "$choice" = "2" ]; then

        show_header "USER MANAGEMENT"

        status_msg "WAIT" "Creating auto admin user..."

        USERNAME="user$(openssl rand -hex 2)"
        PASSWORD="$(openssl rand -base64 10)"
        EMAIL="$(openssl rand -base64 4)@email.com"
        FIRST="$(openssl rand -base64 6)"
        LAST="$(openssl rand -base64 4)"

        php artisan p:user:make -n \
            --email=${EMAIL} \
            --username=${USERNAME} \
            --password=${PASSWORD} \
            --admin=1 \
            --name-first=${FIRST} \
            --name-last=${LAST}

        echo ""

        section "GENERATED CREDENTIALS"

        echo -e "  ${CYAN}Username${NC} : ${WHITE}$USERNAME${NC}"
        echo -e "  ${CYAN}Password${NC} : ${WHITE}$PASSWORD${NC}"
        echo -e "  ${CYAN}Email${NC}    : ${WHITE}$EMAIL${NC}"

        section_end

        echo ""
        status_msg "OK" "Auto User Created!"

    else

        status_msg "ERR" "Invalid option."

    fi

    pause
}

# ================================================================
#                      PANEL UNINSTALL
# ================================================================

uninstall_logic() {

    section "REMOVING PANEL SERVICES"

    status_msg "WAIT" "Stopping Panel services..."

    systemctl stop pteroq.service 2>/dev/null || true
    systemctl disable pteroq.service 2>/dev/null || true
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload

    status_msg "OK" "Panel service stopped."

    section_end

    section "CLEANING CRONJOBS"

    status_msg "WAIT" "Removing cronjobs..."

    crontab -l | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | crontab - || true

    status_msg "OK" "Cronjobs cleaned."

    section_end

    section "REMOVING PANEL FILES"

    status_msg "WAIT" "Deleting panel files..."

    rm -rf /var/www/pterodactyl

    status_msg "OK" "Panel files removed."

    section_end

    section "DATABASE CLEANUP"

    status_msg "WAIT" "Dropping database and users..."

    mysql -u root -e "DROP DATABASE IF EXISTS panel;"
    mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    status_msg "OK" "Database cleanup complete."

    section_end

    section "NGINX CLEANUP"

    status_msg "WAIT" "Cleaning Nginx configs..."

    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    systemctl reload nginx || true

    status_msg "OK" "Nginx configuration cleaned."

    section_end
}

uninstall_ptero() {
    show_header "UNINSTALLATION"

    echo -e "  ${RED}${BOLD}⚠ DANGER ZONE${NC}"
    echo ""

    echo -e "  ${RED}This operation will permanently remove:${NC}"
    echo -e "  ${GRAY}•${NC} Pterodactyl panel files"
    echo -e "  ${GRAY}•${NC} Panel database"
    echo -e "  ${GRAY}•${NC} Pterodactyl database user"
    echo -e "  ${GRAY}•${NC} Panel service configuration"
    echo -e "  ${GRAY}•${NC} Nginx panel configuration"
    echo ""

    echo -e "  ${GREEN}Wings will remain untouched.${NC}"
    echo ""

    echo -e "  ${RED}────────────────────────────────────────────────────────────${NC}"

    echo -ne "  ${RED}${BOLD}Are you sure? (y/N):${NC} "
    read confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then

        status_msg "INFO" "Uninstallation cancelled."

        pause
        return
    fi

    echo ""

    uninstall_logic

    echo ""

    section "FINAL STATUS"

    status_msg "OK" "Panel removed successfully."
    status_msg "INFO" "Wings remains untouched."

    section_end

    pause
}

# ================================================================
#                         UPDATE PANEL
# ================================================================

update_panel() {
    show_header "SYSTEM UPDATE"

    if [ ! -d /var/www/pterodactyl ]; then

        status_msg "ERR" "Panel not found in /var/www/pterodactyl"

        pause
        return
    fi

    status_msg "INFO" "Putting panel into Maintenance Mode..."

    GITHUB_REPO="pterodactyl/panel"

    step() {
        echo -e "  ${CYAN}[ ➜ ]${NC} $1"
    }

    # --- INPUT FUNCTION ---
    ask() {
        local label=$1
        local default=$2
        local var_name=$3

        echo -ne "  ${PURPLE}•${NC} ${WHITE}$label${NC} ${GRAY}[$default]${NC}\n  ${GRAY}╰─>${NC} "

        read input

        if [ -z "$input" ]; then
            eval "$var_name=\"$default\""
        else
            eval "$var_name=\"$input\""
        fi
    }

    # --- TIMEOUT INPUT (10s AUTO-DEFAULT) ---
    ask_timeout() {
        local label=$1
        local default=$2
        local var_name=$3

        echo -ne "  ${PURPLE}•${NC} ${WHITE}$label${NC} ${GRAY}[$default]${NC}\n  ${GRAY}╰─>${NC} "

        if ! read -t 10 input; then

            echo -e "\n  ${GOLD}⌛ Timeout — using default: ${WHITE}$default${NC}"

            eval "$var_name=\"$default\""

            return
        fi

        if [ -z "$input" ]; then
            eval "$var_name=\"$default\""
        else
            eval "$var_name=\"$input\""
        fi
    }

    # ============================================================
    #                    FETCH GITHUB VERSIONS
    # ============================================================

    fetch_github_versions() {
        local repo=$1

        echo -e "  ${GRAY}Fetching releases from ${WHITE}$repo${GRAY}...${NC}" >&2

        local json

        json=$(curl -sf "https://api.github.com/repos/$repo/releases?per_page=20" 2>/dev/null) || {
            echo -e "  ${RED}Failed to fetch releases.${NC}" >&2
            return 1
        }

        echo "$json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data:
    if r.get('prerelease', False):
        continue
    tag = r.get('tag_name', '')
    if tag.startswith('v'):
        print(tag)
" 2>/dev/null || return 1
    }

    # ============================================================
    #                    VERSION SELECTOR
    # ============================================================

    select_version() {
        local repo=$1
        local var_name=$2
        local default="latest"

        echo -e "\n  ${PURPLE}::${NC} ${WHITE}${BOLD}Available Panel Versions${NC}"

        local tags=()
        local disp=()
        local i=0

        while IFS= read -r tag; do

            [[ -z "$tag" ]] && continue

            tags+=("$tag")

            i=$((i+1))

            disp+=("  ${GRAY}$i.${NC} ${WHITE}$tag${NC}")

        done < <(fetch_github_versions "$repo" 2>/dev/null) || true

        if [[ ${#tags[@]} -eq 0 ]]; then

            echo -e "  ${YELLOW}No versions found. Using latest.${NC}"

            eval "$var_name=\"$default\""

            return
        fi

        printf '%b\n' "${disp[@]}"

        local max=${#tags[@]}

        echo -ne "\n  ${PURPLE}•${NC} ${WHITE}Select version [1-$max]${NC} ${GRAY}[1 = latest]${NC}\n  ${GRAY}╰─>${NC} "

        if ! read -t 10 choice; then

            echo -e "\n  ${GOLD}⌛ Timeout — using latest: ${WHITE}${tags[0]}${NC}"

            eval "$var_name=\"${tags[0]}\""

            return
        fi

        if [[ -z "$choice" || "$choice" == "1" ]]; then

            echo -e "  ${GREEN}→ ${WHITE}${tags[0]}${NC}"

            eval "$var_name=\"${tags[0]}\""

        elif [[ "$choice" =~ ^[0-9]+$ ]] &&
             [[ $choice -ge 1 ]] &&
             [[ $choice -le $max ]]; then

            local idx=$((choice - 1))

            echo -e "  ${GREEN}→ ${WHITE}${tags[$idx]}${NC}"

            eval "$var_name=\"${tags[$idx]}\""

        else

            echo -e "  ${GREEN}→ ${WHITE}${tags[0]}${NC} (invalid input)"

            eval "$var_name=\"${tags[0]}\""

        fi
    }

    # --- START ---
    show_header "UPDATE PANEL"

    # --- DATA COLLECTION ---
    select_version "$GITHUB_REPO" "version_PANEL"

    # --- FINAL VALIDATION ---
    echo ""

    section "REVIEW CONFIGURATION"

    echo -e "  ${GRAY}Version:${NC} ${WHITE}$version_PANEL${NC}"

    section_end

    echo -ne "\n  ${CYAN}Start Installation?${NC} ${WHITE}(Y/n)${NC} ${GRAY}[auto: Y in 10s]:${NC} "

    if ! read -t 10 -n 1 -r CONFIRM; then

        echo -e "\n  ${GOLD}⏳ Timeout — proceeding automatically...${NC}"

        CONFIRM="y"
    fi

    echo ""

    if [[ ! "$CONFIRM" =~ [Nn] ]]; then

        echo -e "  ${GREEN}Proceeding to deployment...${NC}"

    else

        echo -e "  ${RED}Installation aborted by user.${NC}"

        exit
    fi

    echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"

    cd /var/www/pterodactyl

    php artisan down

    sudo rm -rf /var/www/pterodactyl/*

    cd /var/www/pterodactyl

    status_msg "INFO" "Downloading latest release..."

    # --- DOWNLOAD PTERODACTYL PANEL ---
    mkdir -p /var/www/pterodactyl

    cd /var/www/pterodactyl

    if [[ "$version_PANEL" == "latest" ]]; then

        step "Downloading latest panel release..."

        curl -Lso panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz

    else

        step "Downloading panel version $version_PANEL..."

        curl -Lso panel.tar.gz "https://github.com/pterodactyl/panel/releases/download/${version_PANEL}/panel.tar.gz"
    fi

    tar -xzf panel.tar.gz

    chmod -R 755 storage/* bootstrap/cache/

    status_msg "INFO" "Setting permissions..."

    status_msg "INFO" "Updating Composer dependencies..."

    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

    status_msg "INFO" "Clearing cache and database migration..."

    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force

    chown -R www-data:www-data /var/www/pterodactyl/*

    status_msg "INFO" "Restarting Queue Workers..."

    php artisan queue:restart
    php artisan up

    echo ""

    status_msg "OK" "Panel Updated Successfully."

    pause
}

# ================================================================
#                         MAIN MENU
# ================================================================

while true; do

    clear

    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo -e "║        ${WHITE}${BOLD}⚡ PTERODACTYL CONTROL CENTER${NC}${PURPLE}                  ║"
    echo -e "║        ${GRAY}Professional Server Management System${NC}${PURPLE}          ║"
    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"

    # --- CHECK INSTALL STATUS ---
    if [ -d "/var/www/pterodactyl" ]; then

        echo -e "║  ${WHITE}${BOLD}PANEL STATUS${NC}${PURPLE} : ${GREEN}${BOLD}INSTALLED ✔${NC}${PURPLE}                       ║"

    else

        echo -e "║  ${WHITE}${BOLD}PANEL STATUS${NC}${PURPLE} : ${RED}${BOLD}NOT INSTALLED ✘${NC}${PURPLE}                   ║"

    fi

    echo -e "║  ${WHITE}${BOLD}CREDITS${NC}${PURPLE}      : ${CYAN}Jishnu & Nobita${PURPLE}                       ║"

    echo "╚══════════════════════════════════════════════════════════════╝"

    echo -e "${NC}"

    echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${WHITE}${BOLD}CONTROL MODULES${NC}"
    echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "  ${GREEN}[1]${NC} ${WHITE}${BOLD}Install Panel${NC}"
    echo -e "      ${GRAY}Fresh Pterodactyl Panel Installation${NC}"
    echo ""

    echo -e "  ${GREEN}[2]${NC} ${WHITE}${BOLD}User Management${NC}"
    echo -e "      ${GRAY}Create Admin / User Accounts${NC}"
    echo ""

    echo -e "  ${YELLOW}[3]${NC} ${WHITE}${BOLD}Panel Update${NC}"
    echo -e "      ${GRAY}Update to a Pterodactyl Release${NC}"
    echo ""

    echo -e "  ${CYAN}[4]${NC} ${WHITE}${BOLD}Domain / SSL${NC}"
    echo -e "      ${GRAY}Configure Domain and SSL${NC}"
    echo ""

    echo -e "  ${RED}[5]${NC} ${WHITE}${BOLD}Uninstall Panel${NC}"
    echo -e "      ${GRAY}Remove Panel Data and Configuration${NC}"
    echo ""

    echo -e "  ${BLUE}[6]${NC} ${WHITE}${BOLD}phpMyAdmin${NC}"
    echo -e "      ${GRAY}Database Management${NC}"
    echo ""

    echo -e "  ${GRAY}──────────────────────────────────────────────────────────${NC}"
    echo ""

    echo -e "  ${WHITE}[0]${NC} Exit System"
    echo ""

    echo -ne "  ${CYAN}${BOLD}root@ptero${NC}${GRAY}:~#${NC} "
    read choice

    case $choice in

        1)
            install_ptero
            ;;

        2)
            create_user
            ;;

        3)
            update_panel
            ;;

        4)
            bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/panel/pterodactyl/ssl.sh)
            ;;

        5)
            uninstall_ptero
            ;;

        6)
            bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/panel/pterodactyl/phpMyAdmin.sh)
            ;;

        0)
            clear

            echo ""
            echo -e "${PURPLE}  ╔══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${PURPLE}  ║${NC}                                                      ${PURPLE}║${NC}"
            echo -e "${PURPLE}  ║${NC}       ${GREEN}${BOLD}👋 Thanks for using Pterodactyl CC${NC}          ${PURPLE}║${NC}"
            echo -e "${PURPLE}  ║${NC}                                                      ${PURPLE}║${NC}"
            echo -e "${PURPLE}  ║${NC}       ${GRAY}Credits: ${WHITE}NotRyxen & Nyrox${NC}                     ${PURPLE}║${NC}"
            echo -e "${PURPLE}  ║${NC}                                                      ${PURPLE}║${NC}"
            echo -e "${PURPLE}  ╚══════════════════════════════════════════════════════════╝${NC}"
            echo ""

            exit
            ;;

        *)
            echo ""
            echo -e "  ${RED}${BOLD}✖ Invalid option selected.${NC}"
            echo -e "  ${GRAY}Please choose an option from 0-6.${NC}"
            sleep 1
            ;;

    esac

done
