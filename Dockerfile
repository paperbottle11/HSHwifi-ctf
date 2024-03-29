from kalilinux/kali-rolling

# Install packages
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && DEBIAN_FRONTEND=noninteractive
RUN apt-get install --fix-missing  -y pciutils
RUN apt-get install --fix-missing  -y iputils-ping
RUN apt-get install --fix-missing  -y openssh-server
RUN apt-get install --fix-missing  -y hashcat
RUN apt-get install --fix-missing  -y rdesktop
RUN apt-get install --fix-missing  -y procps
RUN apt-get install --fix-missing  -y wpasupplicant
RUN apt-get install --fix-missing  -y isc-dhcp-common
RUN apt-get install --fix-missing  -y isc-dhcp-client
RUN apt-get install --fix-missing  -y arping
RUN apt-get install --fix-missing  -y vim
RUN apt-get install --fix-missing  -y tmux
RUN apt-get install --fix-missing  -y screen
RUN apt-get install --fix-missing  -y wordlists
RUN apt-get install --fix-missing  -y pkg-config
RUN apt-get install --fix-missing  -y libnl-3-dev
RUN apt-get install --fix-missing  -y gcc
RUN apt-get install --fix-missing  -y libssl-dev
RUN apt-get install --fix-missing  -y libnl-genl-3-dev
RUN apt-get install --fix-missing  -y python3
RUN apt-get install --fix-missing  -y git
RUN apt-get install --fix-missing  -y wireless-tools
RUN apt-get install --fix-missing  -y make
RUN apt-get install --fix-missing  -y wget
RUN apt-get install --fix-missing  -y nano
RUN apt-get install --fix-missing  -y aircrack-ng

# Make home directory
RUN mkdir /home/hsh
RUN echo "cd /home/hsh" >> /root/.bashrc

# Copy rockyou.txt wordlist for aircrack-ng
RUN wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -P /home/hsh

# Remove login message
RUN touch ~/.hushlogin

# Set up SSH access
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
COPY content/sshd_config /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22/tcp
