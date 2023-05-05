from kalilinux/kali-rolling

# Install packages
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing  -y \
  pciutils \
  iputils-ping \
  openssh-server \
  hashcat \
  rdesktop \
  procps \
  wpasupplicant \
  isc-dhcp-common \
  isc-dhcp-client \
  arping \
  vim \
  tmux \
  screen \
  wordlists \
  pkg-config \
  libnl-3-dev \
  gcc \
  libssl-dev \
  libnl-genl-3-dev \
  python3 \
  git \
  wireless-tools \
  make \
  aircrack-ng \
  wget \
  nano

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
