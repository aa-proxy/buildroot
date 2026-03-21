#!/bin/sh

IFACE="wlan0"

while true; do
  [ -d "/sys/class/net/$IFACE" ] && break
  usleep 10000   # 10 ms
done

echo "$IFACE ready"

aa-proxy-rs --generate-hostapd

hostapd -B -t -f /var/log/hostapd /var/run/hostapd.conf