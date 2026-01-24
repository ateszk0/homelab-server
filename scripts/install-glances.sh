#!/bin/bash
# ------------------------------------------------------------------
# Script Name: install-glances.sh
# Description: Installs Glances on Debian 12/Proxmox VE 8 using pip
#              to bypass broken repository packages.
# ------------------------------------------------------------------

echo "--- removing old versions ---"
systemctl stop glances
apt remove glances -y
apt autoremove -y

echo "--- Installing Python dependencies ---"
apt update
apt install python3-pip python3-venv -y

echo "--- Installing Glances via PIP ---"
# Note: --break-system-packages is required on Debian 12 bookworm
pip3 install "glances[web]" --break-system-packages --ignore-installed

echo "--- Firewall Configuration ---"
iptables -I INPUT -p tcp --dport 61208 -j ACCEPT

echo "Done! Don't forget to enable the systemd service located in configs/systemd/"