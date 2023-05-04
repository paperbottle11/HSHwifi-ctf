#!/bin/bash

set -x

ROOT_DIR=`dirname "$(realpath $0)"`

CONTAINER_NAME=ctf

NUM_RADIOS=15

PLAYER_SSH_PORT=22

# Stop host wpa_supplicant
nmcli radio wifi off

# Stop host resolved
systemctl stop systemd-resolved
systemctl disable systemd-resolved
systemctl mask systemd-resolved

# Stop hostapd and dnsmasq
pkill hostapd
pkill dnsmasq
pkill wpa_supplicant

# Make sure container isn't already running
docker stop $CONTAINER_NAME
docker container prune -f

#Start container
docker run -dt --name $CONTAINER_NAME -p $PLAYER_SSH_PORT:22 --net=bridge --cap-add=NET_ADMIN --cap-add=NET_RAW ctf-kali

# Create simulated wireless interfaces
rmmod mac80211_hwsim
modprobe mac80211_hwsim radios=$NUM_RADIOS

# Give container access to first 3 interfaces
mkdir -p /var/run/netns

pid=$(docker inspect -f '{{.State.Pid}}' ctf)
echo "Docker pid=$pid"

echo "Creating namespace symlink"
ln -s /proc/$pid/ns/net /var/run/netns/$pid

echo "Getting interface names"
phy0=$(cat /sys/class/net/wlan0/phy80211/name)
phy1=$(cat /sys/class/net/wlan1/phy80211/name)
# phy2=$(cat /sys/class/net/wlan2/phy80211/name)

echo "Adding interfaces to container"
iw phy $phy0 set netns $pid
iw phy $phy1 set netns $pid
# iw phy $phy2 set netns $pid

sleep 1

# Fix arp issue with multiple interfaces on same network
sysctl -w net.ipv4.conf.all.arp_ignore=1

# Make sure we're in the right directory
cd $ROOT_DIR

# Make sure wifi isn't blocked
rfkill unblock all

# Start AP #1
hostapd -K -B AP-guest.conf
ifconfig wlan4 up 192.168.4.1 netmask 255.255.255.0
route add -net 192.168.4.0 netmask 255.255.255.0 gw 192.168.4.1

dnsmasq -C dnsmasq-guest.conf

# Add Guest clients
# Spoof macs to look like Apple/Android devices
macchanger -m F8:95:EA:02:25:16 wlan9 # Apple
wpa_supplicant -c client-guest.conf -i wlan9 -K -B
ifconfig wlan9 up 192.168.4.2 netmask 255.255.255.0

macchanger -m C4:93:D9:47:A2:80 wlan10 # Samsung
wpa_supplicant -c client-guest.conf -i wlan11 -K -B
ifconfig wlan11 up 192.168.4.3 netmask 255.255.255.0

macchanger -m 44:07:0B:0C:33:F2 wlan11 # Google
wpa_supplicant -c client-guest.conf -i wlan12 -K -B
ifconfig wlan12 up 192.168.4.4 netmask 255.255.255.0

macchanger -m 50:7A:C5:0C:33:F2 wlan12 # Apple
wpa_supplicant -c client-guest.conf -i wlan13 -K -B
ifconfig wlan13 up 192.168.4.5 netmask 255.255.255.0

macchanger -m 74:9E:AF:0C:33:F2 wlan13 # Apple
wpa_supplicant -c client-guest.conf -i wlan14 -K -B
ifconfig wlan14 up 192.168.4.6 netmask 255.255.255.0

# Start AP for psk cracking
hostapd -K -B AP-crack.conf
wpa_supplicant -c client-crack.conf -i wlan3 -K -B

# Start Hidden SSID easteregg
hostapd -K -B AP-hidden.conf
wpa_supplicant -c client-hidden.conf -i wlan8 -K -B

# Start Hidden 5GHz AP
hostapd -K -B AP-5ghz.conf
wpa_supplicant -c client-5ghz.conf -i wlan2 -K -B
