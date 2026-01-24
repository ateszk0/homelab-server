#!/bin/bash
# ------------------------------------------------------------------
# Script Name: battery-monitor.sh
# Description: Acts as a software UPS for laptops used as servers.
#              Monitors battery level and initiates graceful shutdown
#              if power is lost and battery drops below limit.
# usage: Add to crontab -> */5 * * * * /usr/local/bin/battery-monitor.sh
# ------------------------------------------------------------------

BATTERY="BAT1"       # Check your system: ls /sys/class/power_supply/ (BAT0 or BAT1)
LIMIT=15             # Shutdown threshold in percentage

# Read current values
CAPACITY=$(cat /sys/class/power_supply/$BATTERY/capacity)
STATUS=$(cat /sys/class/power_supply/$BATTERY/status)

# Logic: If discharging AND capacity < limit -> Shutdown
if [ "$STATUS" = "Discharging" ] && [ "$CAPACITY" -lt "$LIMIT" ];
then
    LOG_MESSAGE="$(date): Critical Battery Level ($CAPACITY%). Initiating System Shutdown..."
    echo "$LOG_MESSAGE" >> /var/log/battery_shutdown.log
    
    # Send system broadcast message
    wall "$LOG_MESSAGE"
    
    # Execute Shutdown
    /usr/sbin/shutdown -h now
fi