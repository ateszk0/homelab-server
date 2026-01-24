



\# 🔧 Troubleshooting \& Maintenance



Common issues and their solutions for my Homelab server.



\## 1. Storage \& I/O Issues

If the system feels slow or services are crashing.



\*\*Check Disk I/O Latency:\*\*



```bash

\# Requires iotop

iotop

```



\*\*Check Mount Points:\*\* Verify if the 1TB SSD is visible to the Host and Container.

```bash

\# On Host

df -h /mnt/ssd

\# Inside Docker Container

ls -R /mnt/external\_drive

```



\## 2. Power Management



\*\*Check Battery Status (Host):\*\*





```bash

cat /sys/class/power\_supply/BAT1/capacity   # Percentage

cat /sys/class/power\_supply/BAT1/status     # Charging/Discharging

```



\*\*Check TLP Statistics:\*\*



```bash

tlp-stat -b

```



\## 3. Docker Diagnostics



\*\*View Container Logs:\*\*



```bash

docker logs -f immich\_server

docker logs -f nextcloud\_app

```



\*\*Check GPU Usage (Intel QuickSync):\*\*



```bash

intel\_gpu\_top

```

