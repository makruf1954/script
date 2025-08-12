#!/bin/bash
clear

# =============================================
#           [ Konfigurasi Warna ]
# =============================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'
export ORANGE='\033[0;91m'
# =============================================
#          [ Fungsi Pengecekan IP ]
check_ip_and_get_info() {
    local ip=$1
    while IFS= read -r line; do
        # Hapus karakter khusus dan spasi berlebih
        line=$(echo "$line" | tr -d '\r' | sed 's/[^[:print:]]//g' | xargs)

        # Split baris menjadi array
        read -ra fields <<< "$line"

        # Kolom 4 = IP Address (index 3)
        if [[ "${fields[3]}" == "$ip" ]]; then
            client_name="${fields[1]}"  # Kolom 2
            exp_date="${fields[2]}"     # Kolom 3

            # Bersihkan tanggal dari karakter khusus
            exp_date=$(echo "$exp_date" | sed 's/[^0-9-]//g' | xargs)

            return 0
        fi
    done <<< "$permission_file"
    return 1
}

# =============================================
#          [ Main Script ]
# =============================================

# Ambil data dari GitHub dengan timeout
permission_file=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/makruf1954/permission/refs/heads/main/gnome)

# Validasi file permission
if [ -z "$permission_file" ]; then
    echo -e "${RED}❌ Gagal mengambil data lisensi!${NC}"
    exit 1
fi

# Ambil IP VPS dengan metode alternatif
IP_VPS=$(curl -s ipv4.icanhazip.com)

# =============================================
#          [ Pengecekan IP ]
# =============================================
echo -e "${GREEN}⌛ Memeriksa lisensi...${NC}"
if check_ip_and_get_info "$IP_VPS"; then

    # Validasi format tanggal ISO 8601
    if ! [[ "$exp_date" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        echo -e "${RED}❌ Format tanggal invalid: '$exp_date' (harus YYYY-MM-DD)${NC}"
        exit 1
    fi

    # Validasi tanggal menggunakan date
    if ! date -d "$exp_date" "+%s" &>/dev/null; then
        echo -e "${RED}❌ Tanggal tidak valid secara kalender: $exp_date${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Your IP is not registered in the license!${NC}"
    echo -e "➥ Hubungi admin ${CYAN}「 ✦ @Azure10 ✦ 」${NC}"
    exit 1
fi

# =============================================
#          [ Hitung Hari Tersisa ]
# =============================================
current_epoch=$(date +%s)
exp_epoch=$(date -d "$exp_date" +%s)

if (( exp_epoch < current_epoch )); then
    echo -e "${RED}❌ Masa aktif telah habis!${NC}"
    exit 1
fi

days_remaining=$(( (exp_epoch - current_epoch) / 86400 ))

# =============================================
#          [ Pengecekan Dependency ]
# =============================================
if ! command -v jq &>/dev/null; then
    echo -e "${YELLOW}⚠️ Installing jq...${NC}"
    sudo apt-get install jq -y
fi

# IP Information Setup
IPINFO_TOKEN="Abc12345"  # Ganti dengan token Anda

# System Information
get_sys_info() {
    # OS Info
    OS=$(lsb_release -ds | sed 's/"//g' 2>/dev/null || cat /etc/*release | head -n1)
    SERONLINE=$(uptime -p | cut -d " " -f 2-10000)

    # Memory Info
    RAM=$(free -m | awk '/Mem:/ {printf "%.0fM", $2}')
    SWAP=$(free -m | awk '/Swap:/ {printf "%.0fM", $2}')

    # CPU Info
    CORE=$(nproc)
    CPU_USAGE=$(top -bn1 | awk '/Cpu/ {printf "%.1f%%", 100 - $8}')
}

# Network Information
get_net_info() {
    # IP Address
    IPVPS=$(curl -s4 --connect-timeout 3 ifconfig.me || echo "Unknown")
    ISP=$(curl -s --connect-timeout 3 ip-api.com/json/${IPVPS} | grep -Po '"isp":\s*"\K[^"]*' || echo "Unknown")
    CITY=$(curl -s --connect-timeout 3 ip-api.com/json/${IPVPS} | grep -Po '"city":\s*"\K[^"]*' || echo "Unknown")

    if [ -z "$ISP" ]; then
        ISP=$(curl -s ipapi.co/org)
    fi
    if [ -z "$CITY" ]; then
        CITY=$(curl -s ipapi.co/city)
    fi

    # Domain Info
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not Set")
}

# Uptime Calculation
get_uptime() {
    uptime_sec=$(awk '{print $1}' /proc/uptime | cut -d. -f1)
    days=$((uptime_sec/86400))
    hours=$(( (uptime_sec%86400)/3600 ))
    minutes=$(( (uptime_sec%3600)/60 ))

    if [ $days -gt 0 ]; then
        echo "${days}d ${hours}h ${minutes}m"
    else
        echo "${hours}h ${minutes}m"
    fi
}

#######################################
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
MYIP=$(curl -sS ipv4.icanhazip.com)
#######################################
colornow=$(cat /etc/phreakers/theme/color.conf)
export NC="\e[0m"
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export yl='\033[0;33m';
export RED="\033[0;31m"
export COLOR1="$(cat /etc/phreakers/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/phreakers/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"

WH='\033[1;37m'
#######################################
# Server Information
date_server=$(date -u +"%Y-%m-%d")
wkt_server=$(timedatectl | grep "Time zone" | awk '{print $3}' | tr -d '()')

# RAM Information
tram=$(free -h | awk '/Mem:/ {print $2}')
uram=$(free -h | awk '/Mem:/ {print $3}')
#######################################
# Network Information
ipsaya=$(curl -s4 ifconfig.me)
IPVPS=$(curl -s4 ifconfig.me)
ISP=$(curl -s ipinfo.io/org | cut -d ' ' -f 2-10)
CITY=$(curl -s ipinfo.io/city)
#######################################

mai="datediff "$Exp" "$DATE""

# CERTIFICATE STATUS
d1=$(date -d "$Exp2" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))

WKT=$(curl -s ipinfo.io/timezone?token=$ipn )
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R | cut -d " " -f -5)
MYIP=$(curl -sS ipv4.icanhazip.com)

cd
if [ ! -e /etc/per/id ]; then
  mkdir -p /etc/per
  echo "" > /etc/per/id
  echo "" > /etc/per/token
elif [ ! -e /etc/perlogin/id ]; then
  mkdir -p /etc/perlogin
  echo "" > /etc/perlogin/id
  echo "" > /etc/perlogin/token
elif [ ! -e /usr/bin/id ]; then
  echo "" > /usr/bin/idchat
  echo "" > /usr/bin/token
fi

if [ ! -e /etc/xray/ssh ]; then
  echo "" > /etc/xray/ssh
elif [ ! -e /etc/xray/sshx ]; then
  mkdir -p /etc/xray/sshx
elif [ ! -e /etc/xray/sshx/listlock ]; then
  echo "" > /etc/xray/sshx/listlock
elif [ ! -e /etc/vmess ]; then
  mkdir -p /etc/vmess
elif [ ! -e /etc/vmess/listlock ]; then
  echo "" > /etc/vmess/listlock
elif [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
elif [ ! -e /etc/vless/listlock ]; then
  echo "" > /etc/vless/listlock
elif [ ! -e /etc/trojan ]; then
  mkdir -p /etc/trojan
elif [ ! -e /etc/trojan/listlock ]; then
  echo "" > /etc/trojan/listlock
fi
clear
MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
LOADCPU=$(printf '%-0.00001s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
CORE=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
# usage
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
vnstat -i ${vnstat_profile} >/etc/t1
bulan=$(date +%b)
tahun=$(date +%y)
ba=$(curl -s https://pastebin.com/raw/0gWiX6hE)
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
todayd=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')
if [ "$(grep -wc ${bulan} /etc/t1)" != '0' ]; then
    bulan=$(date +%b)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $9}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $10}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $3}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $4}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $6}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $7}')
else
    bulan2=$(date +%Y-%m)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $8}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $9}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $2}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $3}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $5}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $6}')
fi
if [ "$(grep -wc yesterday /etc/t1)" != '0' ]; then
    yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
    yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
    yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
    yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
    yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
    yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
    yesterday=NULL
    yesterday_v=NULL
    yesterday_rx=NULL
    yesterday_rxv=NULL
    yesterday_tx=NULL
    yesterday_txv=NULL
fi

# // SSH Websocket Proxy
ssh_ws=$( systemctl status ws-stunnel | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $ssh_ws == "running" ]]; then
    status_ws="${COLOR1}ON${NC}"
else
    status_ws="${RED}OFF${NC}"
fi

# // nginx
nginx=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    status_nginx="${COLOR1}ON${NC}"
else
    status_nginx="${RED}OFF${NC}"
    systemctl start nginx
fi

# // Dropbear
dropbear_status=$(/etc/init.d/dropbear status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $dropbear_status == "running" ]]; then
   status_beruangjatuh="${COLOR1}ON${NC}"
else
   status_beruangjatuh="${RED}OFF${NC}"
fi

# // SSH Websocket Proxy
xray=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $xray == "running" ]]; then
    status_xray="${COLOR1}ON${NC}"
else
    status_xray="${RED}OFF${NC}"
fi
# STATUS EXPIRED ACTIVE
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[4$below" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}( Registered )${Font_color_suffix}"
Error="${Green_font_prefix}${Font_color_suffix}${Red_font_prefix}[ EXPIRED ]${Font_color_suffix}"

today=$(date -d "0 days" +"%Y-%m-%d")
if [[ $today < $Exp2 ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi
# TOTAL ACC CREATE VMESS WS
vmess=$(grep -c -E "^#vmg " "/etc/xray/config.json")
# TOTAL ACC CREATE  VLESS WS
vless=$(grep -c -E "^#vlg " "/etc/xray/config.json")
# TOTAL ACC CREATE  TROJAN
trtls=$(grep -c -E "^#trg " "/etc/xray/config.json")
# TOTAL ACC CREATE OVPN SSH
total_ssh=$(grep -c -E "^### " "/etc/xray/ssh")
#total_ssh="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"

# Main Display
clear
get_sys_info
get_net_info
clear

# Fungsi typing
TYPING_SPEED=0.002
typing_echo() {
    local text="$1"
    local speed="${2:-$TYPING_SPEED}"
    while IFS= read -r -n1 char; do
        printf "%s" "$char"
        sleep "$speed"
    done <<< "$text"
    echo
}

# Header
echo -e "$COLOR1╭═══════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}            ${WH}• NAIFI PROJECT PREMIUM •            ${NC} $COLOR1│${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# Info Server
echo -e "$COLOR1╭═══════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ $NC${WH}❈ System OS          ${COLOR1}: ${WH}$MODEL2${NC}"
echo -e "$COLOR1│ $NC${WH}❈ Memory Usage       ${COLOR1}: ${WH}$uram / $tram${NC}"
echo -e "$COLOR1│ $NC${WH}❈ Core & CPU Usage   ${COLOR1}: ${WH}$CORE Core & $cpu_usage${NC}"
echo -e "$COLOR1│ $NC${WH}❈ ISP                ${COLOR1}: ${WH}$ISP${NC}"
echo -e "$COLOR1│ $NC${WH}❈ City               ${COLOR1}: ${WH}$CITY${NC}"
echo -e "$COLOR1│ $NC${WH}❈ Domain             ${COLOR1}: ${WH}$(cat /etc/xray/domain)${NC}"
echo -e "$COLOR1│ $NC${WH}❈ IP-VPS             ${COLOR1}: ${WH}$IPVPS${NC}"
echo -e "$COLOR1│ $NC${WH}❈ Uptime             ${COLOR1}: ${WH}$SERONLINE${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# Status Service
echo -e "$COLOR1╭═════════════════ • ${NC}${WH}STATUS SERVER${NC}${COLOR1} • ═══════════════╮${NC}"
echo -e " ${WH} SSH WS : ${status_ws}  XRAY : ${status_xray}  NGINX : ${status_nginx}  DROPBEAR : ${status_beruangjatuh}${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# List Account
echo -e "   $COLOR1╭════════════════════════════════════════════╮${NC}"
echo -e "            ${WH}LIST ACCOUNT PREMIUM${NC}"
echo -e "   $COLOR1      ═════════════════════════════════${NC}"
echo -e "            ${WH}SSH     = ${COLOR1}$total_ssh${NC} ${WH}ACCOUNT${NC}"
echo -e "            ${WH}VMESS   = ${COLOR1}$vmess${NC} ${WH}ACCOUNT${NC}"
echo -e "            ${WH}VLESS   = ${COLOR1}$vless${NC} ${WH}ACCOUNT${NC}"
echo -e "            ${WH}TROJAN  = ${COLOR1}$trtls${NC} ${WH}ACCOUNT${NC}"
echo -e "   $COLOR1╰═════════════════════════════════════════════╯${NC}"

# Menu List (Typing Effect)
echo -e "$COLOR1╭═══════════════════ • ${NC}${WH}LIST MENU${NC}${COLOR1} • ═════════════════╮${NC}"
menu_list=$(cat <<EOF
[01] • SSH VPN      [06] • RUNNING
[02] • VMESS        [07] • RESTART
[03] • VLESS        [08] • REBOOT
[04] • TROJAN       [09] • UPDATE
[05] • BACKUP       [10] • SETTING

[12] 🔍 CEK USER ONLINE
[15] 🧬 AKSES GENOM PRO ADMIN 🧬
EOF
)
typing_echo "$menu_list"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# Traffic Info
echo -e "$COLOR1╭═══════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Traffic${NC}      ${WH}Today     Yesterday       Month${NC}"
echo -e "$COLOR1│ ${COLOR1}Total${NC}    ${COLOR1}$todayd $today_v    $yesterday $yesterday_v     $month $month_v${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# Script Info
echo -e "$COLOR1╭═══════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Versi Script  ${COLOR1}: ${WH}$(cat /opt/.ver) Latest Version${NC}"
echo -e "$COLOR1│ ${WH}Author        ${COLOR1}: ${WH}NAIFI PROJECT${NC}"
echo -e "$COLOR1│ ${WH}Client        ${COLOR1}: ${WH}$client_name${NC}"
echo -e "$COLOR1│ ${WH}Sisa Hari     ${COLOR1}: ${WH}$days_remaining hari${NC}"
echo -e "$COLOR1│ ${WH}Expire Date   ${COLOR1}: ${WH}$exp_date${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════════╯${NC}"

# Input
echo -ne " ${WHITE}Select menu ${COLOR1}: ${WHITE}"
read opt
case $opt in
  01|1) clear; sshws ;;
  02|2) clear; m-vmess ;;
  03|3) clear; m-vless ;;
  04|4) clear; m-trojan ;;
  05|5) clear; menu-backup ;;
  06|6) clear; cekservice ;;
  07|7) clear; running ;;
  08|8) clear; reboot ;;
  09|9) clear; m-update ;;
  10) clear; system ;;
  12) clear; online ;;
  15) clear; admin ;;
  00|0) clear; menu ;;
  *) clear; menu ;;
esac
