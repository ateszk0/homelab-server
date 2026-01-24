
# 🛠️ System Setup Guide & Command Log

This document serves as a comprehensive log of commands and configurations used to build the Homelab server on the Dynabook laptop.

## 1. Proxmox Host Configuration
*Context: Commands executed in the Proxmox VE Shell.*

### Storage Setup (External 1TB SSD)
Mounting the USB drive permanently via UUID.
```bash
# 1. Identify disks
lsblk
# 2. Get UUID
blkid
# 3. Edit fstab
nano /etc/fstab
# Add: UUID=<YOUR_UUID> /mnt/ssd ext4 defaults 0 0
# 4. Mount
mkdir -p /mnt/ssd
mount -a
```



### System Optimization
Reducing swap usage to protect the SSD and setting up the "UPS" script.
```bash
# Swapiness
nano /etc/sysctl.conf # Add: vm.swappiness=5
sysctl -p

#Battery Monitor Script Setup
nano /usr/local/bin/battery-monitor.sh # (See scripts/ folder)
chmod +x /usr/local/bin/battery-monitor.sh
crontab -e 
# Add: */5 * * * * /usr/local/bin/battery-monitor.sh
```

## 2. LXC Container Setup (Hypervisor Level)
Context: Connecting the Host hardware to the Container (ID 101/102).

Bind Mounts & Passthrough
Connecting the storage folder and GPU to the container.
```bash
# Stop Container
pct stop 101

# Bind Mount Folder (Host -> Container)
pct set 101 -mp0 /mnt/ssd,mp=/mnt/external_drive

# Edit Config for GPU/Device Passthrough
nano /etc/pve/lxc/101.conf
# (See configs/proxmox/lxc-passthrough.conf for details)
```
## 3. Container Internals (Docker & Networking)
Context: Commands executed inside the LXC Container.

### Networking (NordVPN Meshnet)
Setting up remote access without port forwarding.
```bash
# Install
sh <(curl -sSf [https://downloads.nordcdn.com/apps/linux/install.sh](https://downloads.nordcdn.com/apps/linux/install.sh))

# Login & Configure
nordvpn login --token <YOUR_TOKEN>
nordvpn set meshnet on
nordvpn set technology nordlynx

# Whitelist devices for routing
nordvpn meshnet peer routing allow <phone-name>.nord
```
### Immich & File Permissions
Fixing common EACCES and ENOENT errors on external drives.

```bash
# Create Directory Structure
mkdir -p /mnt/external_drive/immich/library
mkdir -p /mnt/external_drive/immich/upload
mkdir -p /mnt/external_drive/immich/thumbs

# Create "Magic Files" (Bypass Docker Checks)
touch /mnt/external_drive/immich/library/.immich
touch /mnt/external_drive/immich/upload/.immich

# Fix Permissions (The "Brute Force" Fix)
# Ensures Docker user (1000) can write to the USB drive
chmod -R 777 /mnt/external_drive/immich
chown -R 1000:1000 /mnt/external_drive/immich
```
### Resource Scheduling (Cron)
Stopping heavy AI workloads during the day to save RAM.
```bash
crontab -e
#----------------------------------
0 8 * * * docker stop immich_machine_learning
0 22 * * * docker start immich_machine_learning
```
## 4. Troubleshooting Reference
IOWAIT High? Run iotop to check USB drive latency.
Smartctl Error? Ensure type: sat is set in Scrutiny config.
Battery Script: Logs are located at /var/log/battery_shutdown.log