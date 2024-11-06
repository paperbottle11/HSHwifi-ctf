# HighSchoolHack WiFi Capture The Flag Challenges

[https://github.com/paperbottle11/HSHwifi-ctf](https://github.com/paperbottle11/HSHwifi-ctf)

## Overview
Every device that can connect to WiFi, such as laptops, phones, Google Home, Amazon Alexa, etc., has what is called a WiFi interface.  WiFi interfaces are what allow the software running on a device to access wireless networks around it.  They can be used to both monitor networks in a space (input) and send data to other devices (output).  WiFi hacking involves using both methods to find a network, attack it, and gain access.  To set up challenges for this, a competitor needs their own machine with WiFi interfaces and networks to attack.

If this was done on the scale of a CTF, each competitor would need to be provided a Linux machine with the appropriate technology and their own router with the network they must attack.  So, simulating this environment would save costs and the pain of setting all that up.  Luckily, there are plenty of tools and built-in modules in Linux that allow us to do this.

Every competitor (or team) needs their own virtual machine (VM) with the simulated environment in it.  Each environment needs two WiFi interfaces on it (one for montioring and one for sending packets) and a bunch of WiFi Access Points (APs for short, these are networks) to play with.  Flags are then sprinkled throughout this environment.  The competitor is only given access to a Docker container running Kali Linux on the VM.  This allows them to see the simulated networks and use the WiFi interfaces for it, but it keeps them from being able to access the senstive files running the challenges (keeps them from accessing the flags).

## Step 1: Set up the Virtual Machine
This will work on a lot of different Linux distros, but in my testing Kali linux is the best.  It saves a lot of headaches.  Get a basic Kali VM running, then do the following.

Install packages (even if these are already installed, still run every command to ensure they are updated)
```bash 
sudo apt-get install docker.io
sudo apt-get install net-tools
sudo apt-get install hostapd
sudo apt-get install dnsmasq
sudo apt-get install wpasupplicant
sudo apt-get install macchanger
sudo apt-get install network-manager
sudo apt-get install rfkill
sudo apt-get install wireless-tools
sudo apt-get install iw
```

Run this command after installing packages:
```bash 
sudo usermod -aG docker $USER
```

Clone the repo:
```bash 
git clone https://github.com/paperbottle11/HSHwifi-ctf.git
```

If you want, you can set the password to the Docker container to prevent teams from accessing each others machines.
* In the repo, open _Dockerfile_
* On line 44 (```RUN echo 'root:password' | chpasswd```), change "password" to the desired password
* Do not change ```'root:'```, as they need access to the root in order to do the challenges.

Now, build the Docker container (even if you did not touch Dockerfile, you must build the Docker container if this is the first time setting it up)
```bash 
docker build -t ctf -f Dockerfile .
```

At the top of ```start.sh``` there is a constant ```PLAYER_SSH_PORT```.  When a player uses SSH to connect to the VM where this environment is simulated, they need to be forwarded to the Docker container so they do not gain access to the VM's files.  All you have to do is set that variable to whatever port the player will be connecting to on the VM.  For example, if the player uses SSH to connect to the VM on port 22 (the default SSH port), then set the variable to 22. If you want to use my challenges, then you can just set ```PLAYER_SSH_PORT``` and run the script.  The next section explains how to customize and create your own challenges.

## Step 2: Creating Challenges

There is a multitude of challenges than can be created using this environment.  We have the power to create WiFi networks, set passwords to them, and simulate clients (devices) connected to them.  In this repo are seven challenges I have created and used in past CTFs.  I will go into detail what each needs and how to create them, and you can go from there.

### What do I need to know?
In general, every thing we simulate needs its own WiFi interface to run on.  At the top of ```start.sh```, there is a constant ```NUM_RADIOS``` that tells the script how many interfaces to simulate.  The script gives the Docker container access to two of them, enabling competitors to play around in the environment.  Every additional interface is for whatever APs and clients you want to simulate.  In this repo, there are 10 APs and 8 clients as part of the challenges, so ```NUM_RADIOS``` is set to 20 (2 + 10 + 8).  Each interface will have the name ```wlanX``` where X is the number.  Since the first two are assigned to the Docker container, ```wlan0``` and ```wlan1``` cannot be used.  Everything from ```wlan2``` to ```wlanNUM_RADIOS-1``` is available.

Also at the top of ```start.sh``` there is a constant ```PLAYER_SSH_PORT```.  When a player uses SSH to connect to the VM where this environment is simulated, they need to be forwarded to the Docker container so they do not gain access to the VM's files.  All you have to do is set that variable to whatever port the player will be connecting to on the VM.  For example, if the player uses SSH to connect to the VM on port 22 (the default SSH port), then set the variable to 22.

### Configuring an Access Point

The tool used to simulate APs is called ```hostapd```.  It takes the attributes listed in a config file you create and simulates an AP.  Below is the contents of ```AP-extra.conf```.  It creates a simple, unprotected (no password) WiFI network on channel 6 (1-14 are the 2.4ghz band).  The only things that really need to be customized are:
* the ```interface``` they will be on
* the ```ssid``` (name of the WiFI network)
* ```ignore_broadcast_ssid=0``` or ```1``` (whether or not to make it a "hidden" network)
* Which WiFI band to use
    * For 2.4ghz: ```hw_mode=g``` and set the channel to 1-11
    * For 5ghz: ```hw_mode=a``` and set the channel to 36-165
* the ```wpa``` protocol to use (```0``` means no password, ```2``` means password protected)

```conf
interface=wlan14
ssid=Star Net
macaddr_acl=0
ignore_broadcast_ssid=0
hw_mode=g
channel=6
country_code=US
driver=nl80211
wpa=0
auth_algs=1
```

Below are the contents of ```AP-crack.conf```.  This is how you create a password protected AP.  You may change the same fields as before in addition to:
* the ```wpa``` is set to ```2```
* set ```wpa_passphrase``` to the desired password

```conf
interface=wlan3
ssid=The Pillar of Autumn
macaddr_acl=0
ignore_broadcast_ssid=0
hw_mode=g
channel=6
country_code=US
ieee80211d=1
wpa=2
auth_algs=1
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
wpa_passphrase=stucco777
```

### Configuring a Client

To create a simulated client that will connect to a network, we use the ```wpa_supplicant``` tool.  Like ```hostapd```, it simulates a client using information from a config file.  Below is the contents of ```client-guest.conf```.  It creates a client that will connect to the given WiFI network.  Notice ```key_mgmt=NONE``` because that network is unprotected.  For basic use, the ```bssid``` can be left out.  It is the MAC address of the AP, and it is only needed if there are multiple APs with the same SSID (same name).

```conf
ctrl_interface=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        bssid=00:7c:d5:2d:a6:66
        ssid="The International Space Station"
        key_mgmt=NONE
}
```

The config below is from ```client-crack.conf```.  This is how to create a client that will connect to a password protected network.  The only thing that needs to be changed is the ```ssid``` and the ```psk``` (password).

```conf
ctrl_interface=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
	ssid="The Pillar of Autumn"
	scan_ssid=1
    psk="stucco777"
    key_mgmt=WPA-PSK
    pairwise=CCMP TKIP
    group=CCMP TKIP
    proto=RSN
}
```

### Simulating APs and Clients

To actually tell the start script ```start.sh``` to create these things, you add the following commands to it.
* To simulate an AP:
    * ```macchanger -r wlanX``` (where X is the interface number specified in the config file being used)
        * Note: using ```-r``` will generate a random MAC address for the AP.  If you want to set it yourself, replace it with ```-m MAC_ADDRESS```
    * ```hostapd -K -B file.conf```
* To simulate a client:
    * ```macchanger -r wlanX``` (where X is the desired interface number)
        * Note: using ```-r``` will generate a random MAC address for the AP.  If you want to set it yourself, replace it with ```-m MAC_ADDRESS```
    * ```wpa_supplicant -c file.conf -i wlanX -K -B```

See ```start.sh``` for example usage.  Creating the environment is simply stacking these commands together to build a virtual airspace full of WiFi networks and devices.  Flags could be the password to a certain AP or the MAC address of a client manufactured by Google (there are online MAC lookups competitors can use to check who manufactured a device, all you must do is set a client to have a MAC address of a Google device)


## Step 3: Planning
It is very useful to outline all APs and clients that must be created for your challenges.  Below is what I created for HighSchoolHack.

### Example Outline
1. Unprotected AP for MAC Recon: 5 clients (3 Apple, 1 Google, 1 Samsung)
    1. SSID: The International Space Station
    2. Apple MACs
        1. F8:95:EA:02:25:16
        2. 50:7A:C5:0C:33:F2
        3. 74:9E:AF:0C:33:F2
    3. Google MACs
        1. 44:07:0B:0C:33:F2
    4. Samsung MACs (FLAG)
        1. C4:93:D9:47:A2:80
2. WPA2 AP for Cracking: one client
    1. SSID: The Pillar of Autumn
3. 5GHz band AP: one client
    1. SSID: The Darkside of the Moon
4. Non-broadcasted SSID AP: one client
    1. SSID: Forward Unto Dawn
5. Filler APs
    1. Star Net
    2. Cosmo Connect
    3. Andromeda Node
    4. Airlocks Not Included
    5. Orion Node

### Example Challenge Outline (from HighSchoolHack)
In each challenge, I created an example description to hint at the solution process.

Challenge 1: Suspicious Activity
* Something is wrong with one of the APs.
* It's like there's two of them?
* Find the MAC of the AP that has an evil twin.
* FLAG: 00:00:00:00:00:99

Challenge 2: MAC Recon
* Get a wifi interface up in monitor mode using airmon-ng
* Use airodump-ng to find the open AP and devices on it
* Find the MAC Address of the Google device (using the tool below)
    * [https://macaddress.io/](https://macaddress.io/)
* FLAG: MAC address of Samsung device (_listed above_)

Challenge 3: Hidden SSID AP
* Find the device on the hidden SSID AP
* Use aireplay-ng in a new terminal window to send de-authentication packets to the client
* At the same time, have airodump-ng running to see the decloaked SSID
* FLAG: decloaked SSID - _Forward Unto Dawn_

Challenge 4: WPA2 Cracking
* Find the device on the The Pillar of Autumn AP
* Use aireplay-ng in a new terminal window to send de-authentication packets to the client
* At the same time, have airodump-ng running to capture the WPA handshake 
* Use aircrack-ng to crack the capture file
* FLAG: cracked password from the capture file (“_stucco777_”)

Challenge 5: Hidden 5GHz AP
* Use the ‘--band a’ option with airodump-ng to find the AP on a 5GHz channel
* FLAG: the channel the AP is broadcasting on - _36_

Challenge 6: Hidden SSID 5GHz AP
* Using the information from Challenge 4 and the procedure from Challenge 2, decloak the SSID
* FLAG: SSID of hidden AP - _The Darkside of the Moon_

Challenge 7: Hidden 5GHz AP Password
* Combining information from Challenge 4 and 5 and procedures from Challenge 3, crack the password of the hidden 5GHz AP
* FLAG: cracked password ("_mini1cooper_")
