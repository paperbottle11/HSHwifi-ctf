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
  wget

# Make home directory
RUN mkdir /home/hsh
RUN echo "cd /home/hsh" >> /root/.bashrc

# Copy wordlist for aircrack-ng
RUN cd /home/hsh
RUN wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

# Set up SSH access
RUN mkdir /var/run/sshd
RUN echo 'root:ctf1234' | chpasswd
COPY content/sshd_config /etc/ssh/sshd_config

# Remove login message
RUN touch ~/.hushlogin

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22/tcp
