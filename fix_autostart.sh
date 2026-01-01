#!/bin/bash
# ==========================================
#         FIX AUTOSTART PROBLEMS
# ==========================================
#
# This script fixes the auto-restart loop problem
# after VPS reboot or update

clear
echo -e "\033[1;96m==========================================\033[0m"
echo -e "\033[1;97m         FIX AUTOSTART PROBLEMS\033[0m"
echo -e "\033[1;96m==========================================\033[0m"
echo ""

# Color definitions
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
CYAN='\033[1;96m'
NC='\033[0m'

# Backup original files
echo -e "${BLUE}📦 Creating backups...${NC}"
TIMESTAMP=$(date +%s)
cp ~/.bashrc ~/.bashrc.backup.$TIMESTAMP 2>/dev/null

if [ -f /etc/rc.local ]; then
    cp /etc/rc.local /etc/rc.local.backup.$TIMESTAMP 2>/dev/null
fi

echo ""
echo -e "${BLUE}🔧 Fixing .bashrc...${NC}"
# Comment out any auto-execution lines
if grep -q "menu\|update\|upp" ~/.bashrc 2>/dev/null; then
    sed -i '/menu\|update\|upp/s/^/# /' ~/.bashrc
    sed -i '/exec.*menu/d' ~/.bashrc
    sed -i '/bash.*menu/d' ~/.bashrc
    sed -i '/\.\/menu/d' ~/.bashrc
    echo -e "${GREEN}✅ .bashrc fixed (commented out problematic lines)${NC}"
else
    echo -e "${YELLOW}⚠️  No problematic lines found in .bashrc${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Fixing crontab...${NC}"
# Remove any auto-execution cron jobs
if crontab -l 2>/dev/null | grep -q "menu\|update\|upp"; then
    crontab -l | grep -v "menu\|update\|upp" | crontab -
    echo -e "${GREEN}✅ Crontab fixed (removed problematic cron jobs)${NC}"
else
    echo -e "${YELLOW}⚠️  No problematic cron jobs found${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Fixing rc.local...${NC}"
if [ -f /etc/rc.local ]; then
    if grep -q "menu\|update\|upp" /etc/rc.local; then
        sed -i '/menu\|update\|upp/s/^/# /' /etc/rc.local
        sed -i '/exec.*menu/d' /etc/rc.local
        sed -i '/bash.*menu/d' /etc/rc.local
        echo -e "${GREEN}✅ rc.local fixed${NC}"
    else
        echo -e "${YELLOW}⚠️  No problematic lines in rc.local${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  rc.local not found${NC}"
fi

echo ""
echo -e "${BLUE}🧹 Cleaning lock files...${NC}"
rm -f /tmp/update_lock.pid 2>/dev/null
rm -f /root/fim 2>/dev/null
rm -f /tmp/menu.zip 2>/dev/null
rm -rf /tmp/menu_update 2>/dev/null
rm -rf /tmp/menu_backup_* 2>/dev/null
echo -e "${GREEN}✅ Lock files cleaned${NC}"

echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}✅ FIX COMPLETED SUCCESSFULLY!${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo -e "${BLUE}1.${NC} Check current processes: ${CYAN}ps aux | grep -E \"(menu|update|upp)\"${NC}"
echo -e "${BLUE}2.${NC} Test menu manually: ${CYAN}bash /usr/local/sbin/menu${NC}"
echo -e "${BLUE}3.${NC} Reboot VPS if needed: ${CYAN}reboot${NC}"
echo -e "${BLUE}4.${NC} Monitor after reboot: ${CYAN}systemctl list-units | grep -i auto${NC}"
echo ""
echo -e "${YELLOW}⚠️  TROUBLESHOOTING:${NC}"
echo -e "${BLUE}•${NC} If problem persists, check: ${CYAN}/var/log/syslog | grep -i cron${NC}"
echo -e "${BLUE}•${NC} Restore backup: ${CYAN}cp ~/.bashrc.backup.$TIMESTAMP ~/.bashrc${NC}"
echo ""

# Optional: Show what was changed
echo -e "${BLUE}📝 Summary of changes:${NC}"
echo -e "${CYAN}• Backups created with timestamp: $TIMESTAMP${NC}"
echo -e "${CYAN}• Lock files removed${NC}"
echo -e "${CYAN}• Autostart entries disabled${NC}"

exit 0
