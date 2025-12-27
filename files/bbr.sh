#!/bin/bash
# Edition : Stable Edition V3.0
# Author  : Pondok-Vpn
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
NC='\e[0m'
clear

echo ""
echo -e "${green}Installing TCP BBR Mod By Pondok-Vpn${NC}"
echo -e "Please Wait BBR Installation Will Start . . ."
sleep 3
clear

touch /usr/local/sbin/bbr

Add_To_New_Line(){
	if [ "$(tail -n1 $1 | wc -l)" == "0"  ];then
		echo "" >> "$1"
	fi
	echo "$2" >> "$1"
}

Check_And_Add_Line(){
	if [ -z "$(cat "$1" | grep "$2")" ];then
		Add_To_New_Line "$1" "$2"
	fi
}

Install_BBR(){
echo -e "\e[32;1m================================\e[0m"
echo -e "\e[32;1mInstalling TCP BBR...\e[0m"
if [ -n "$(lsmod | grep bbr)" ];then
	echo -e "\e[0;32mTCP BBR Already Installed.\e[0m"
	return 1
fi
echo -e "\e[0;32mStarting To Install BBR...\e[0m"
modprobe tcp_bbr
Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
sysctl -p
if [ -n "$(sysctl net.ipv4.tcp_available_congestion_control | grep bbr)" ] && [ -n "$(sysctl net.ipv4.tcp_congestion_control | grep bbr)" ] && [ -n "$(lsmod | grep tcp_bbr)" ];then
	echo -e "\e[0;32mTCP BBR Install Success!\e[0m"
else
	echo -e "\e[1;31mFailed To Install BBR!\e[0m"
fi
echo -e "\e[32;1m================================\e[0m"
}

Optimize_Parameters(){
echo -e "\e[32;1m================================\e[0m"
echo -e "\e[32;1mOptimizing System Parameters...\e[0m"
modprobe ip_conntrack

# Limits
Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 65535"
Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 65535"
Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"

# Sysctl
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_forward = 1"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
sysctl -p

echo -e "\e[0;32mSystem Parameters Optimized Successfully.\e[0m"
echo -e "\e[32;1m================================\e[0m"
}

Install_BBR
Optimize_Parameters
rm -f /root/bbr.sh >/dev/null 2>&1

echo -e '\e[32;1m============================================================\e[0m'
echo -e '\e[0;32m                  Installation Success!                     \e[0m'
echo -e '\e[32;1m============================================================\e[0m'
sleep 2
