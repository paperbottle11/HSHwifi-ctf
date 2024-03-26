#!/bin/bash

set -x

ROOT_DIR=`dirname "$(realpath $0)"`

CONTAINER_NAME=ctf

NUM_RADIOS=20

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

# Start Recon AP 
macchanger -m 00:7c:d5:2d:a6:66 wlan2
hostapd -K -B AP-guest.conf

# Add Guest clients
macchanger -m F8:95:EA:02:25:16 wlan6 # Apple
wpa_supplicant -c client-guest.conf -i wlan6 -K -B

macchanger -m C4:93:D9:47:A2:80 wlan7 # Samsung
wpa_supplicant -c client-guest.conf -i wlan7 -K -B

macchanger -m 44:07:0B:0C:33:F2 wlan8 # Google
wpa_supplicant -c client-guest.conf -i wlan8 -K -B

macchanger -m 50:7A:C5:0C:33:F2 wlan9 # Apple
wpa_supplicant -c client-guest.conf -i wlan9 -K -B

macchanger -m 74:9E:AF:0C:33:F2 wlan10 # Apple
wpa_supplicant -c client-guest.conf -i wlan10 -K -B

# Start AP for psk cracking
macchanger -r wlan3
hostapd -K -B AP-crack.conf
macchanger -r wlan11
wpa_supplicant -c client-crack.conf -i wlan11 -K -B

# Start Hidden SSID AP
macchanger -r wlan4
hostapd -K -B AP-hidden.conf
macchanger -r wlan12
wpa_supplicant -c client-hidden.conf -i wlan12 -K -B

# Start Hidden 5GHz AP
macchanger -r wlan5
hostapd -K -B AP-5ghz.conf
macchanger -r wlan13
wpa_supplicant -c client-5ghz.conf -i wlan13 -K -B

# Start Extra APs
macchanger -r wlan14
macchanger -r wlan15
macchanger -r wlan16
macchanger -r wlan17
macchanger -r wlan18

hostapd -K -B AP-extra.conf
hostapd -K -B AP-extra2.conf
hostapd -K -B AP-extra3.conf
hostapd -K -B AP-extra4.conf
hostapd -K -B AP-extra5.conf

# Start Tavern Twin
macchanger -m 00:00:00:00:00:99 wlan19
hostapd -K -B AP-eviltwin.conf