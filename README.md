# HighSchoolHack WiFi Capture The Flag Challenges

[https://github.com/paperbottle11/HSHwifi-ctf](https://github.com/paperbottle11/HSHwifi-ctf)

VM version: Kali 2023.1

git clone https://github.com/paperbottle11/HSHwifi-ctf.git

Install packages and run commands as listed by blunderbuss-wctf/wifi-ctf



* sudo apt install docker.io
* sudo usermod -aG docker $USER
* sudo apt install net-tools
* sudo apt install hostapd
* ~~sudo apt install bridge-utils~~
* sudo apt install dnsmasq
* sudo apt install wpasupplicant
* sudo apt install macchanger

Install packages marked as missing or not found when running start.sh



* apt-get install network-manager
* apt-get install rfkill
* apt-get install wireless-tools
* apt-get install iw

This command will install the above packages in one line:
* apt-get install -y docker.io net-tools hostapd dnsmasq wpasupplicant macchanger network-manager rfkill wireless-tools iw

Once the VM is ready to start, follow these steps:
* Set the docker user and password for each team in Dockerfile (format: “root:password”)
* Build the Docker image
* Run start.sh
* Link ports to VM

Example passwords in team order:



1. gold123
2. lootmeup76
3. arrr56
4. doubloons6
5. matey78
6. pegleg73
7. blackbeard9
8. ahoy1234
9. jollyroger8
10. plunder9
11. matey123
12. treasure5
13. spittoon567
14. swashbuckler2
15. blackpearl88
16. shivermetimbers25



Setup APs and clients (All should have randomized MACs except clients for MAC Recon):



1. Open AP for MAC Recon: 5 clients (3 Apple, 1 Google, 1 Samsung)
    1. SSID: The Tabernacle Tavern
    2. Apple MACs
        1. F8:95:EA:02:25:16
        2. 50:7A:C5:0C:33:F2
        3. 74:9E:AF:0C:33:F2
    3. Google MACs (Captain Neckbeard)
        4. 44:07:0B:0C:33:F2
    4. Samsung MACs
        5. C4:93:D9:47:A2:80
2. WPA2 AP for Cracking: one client
    5. SSID: HMS LANguard
3. 5GHz band AP: one client
    6. SSID: The Hidden Treasure
4. Non-broadcasted SSID AP: one client
    7. SSID: HMS Holland
5. Extra APs to populate airspace
    8. HMS LANcaster
    9. The LAN of the Lost
    10. The Broadband Buccaneer
    11. Cannons Not Included
    12. LAN-ho!

Challenge 1: Suspicious Activity



* Something is wrong with one of the APs.
* It's like there's two of them?
* Find the SSID of the AP that has an evil twin.
* FLAG: The International Space Station

Challenge 2: MAC Recon



* Get a wifi interface up in monitor mode using airmon-ng
* Use airodump-ng to find the open AP and devices on it
* Find the MAC Address of the Google device (using the tool below)
    * [https://mac-address.alldatafeeds.com/mac-address-lookup](https://mac-address.alldatafeeds.com/mac-address-lookup)
* FLAG: MAC address of Google device (_listed above_)

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
* FLAG: cracked password from the capture file (“_sky2fly_”)

Challenge 5: Hidden 5GHz AP



* Use the ‘--band a’ option with airodump-ng to find the AP on a 5GHz channel
* FLAG: the channel the AP is broadcasting on - _36_

Challenge 6: Hidden SSID 5GHz AP



* Using the information from Challenge 4 and the procedure from Challenge 2, decloak the SSID
* FLAG: SSID of hidden AP - _The Darkside of the Moon_

Challenge 7: Hidden 5GHz AP Password



* Combining information from Challenge 4 and 5 and procedures from Challenge 3, crack the password of the hidden 5GHz AP
* FLAG: cracked password ("_mezza4_")
