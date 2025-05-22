#!/bin/bash
# Chạy app.js tối đa 45p (2700 giây)
timeout 2700 node /home/MQTT/mqtt_update_price_new.js >> logfile.log 2>&1

#crontab -e
#30 14 * * 4 /home/MQTT/run_app.sh
#(crontab -l 2>/dev/null; echo "30 14 * * 4 /home/MQTT/run_app.sh") | crontab -


