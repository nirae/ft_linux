set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${GREEN}Network part${NC}\n"
printf "${GREEN}Create /etc/systemd/network/10-eth-dhcp.network with minimal DHCP configuration${NC}\n"
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF

printf "${GREEN}Link /run/systemd/resolve/resolv.conf -> /etc/resolv.conf${NC}\n"
ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf

printf "${GREEN}Create /etc/hostname${NC}\n"
echo "ndubouil" > /etc/hostname

printf "${GREEN}Create /etc/hosts${NC}\n"
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF

printf "${GREEN}Create /etc/inputrc${NC}\n"
cat > /etc/inputrc << "EOF"
# Début de /etc/inputrc
# Modifié par Chris Lynn <roryo@roryo.dynup.net>

# Permettre à l'invite de commande d'aller à la ligne
set horizontal-scroll-mode Off

# Activer l'entrée sur 8 bits
set meta-flag On
set input-meta On

# Ne pas supprimer le 8ème bit
set convert-meta Off

# Conserver le 8ème bit à l'affichage
set output-meta On

# none, visible ou audible
set bell-style none

# Toutes les indications qui suivent font correspondre la séquence
# d'échappement contenue dans le 1er argument à la fonction
# spécifique de readline
"\eOd": backward-word
"\eOc": forward-word

# Pour la console linux
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# pour xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# pour Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# Fin de /etc/inputrc
EOF

printf "${GREEN}Create /etc/shells${NC}\n"
cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

printf "${GREEN}Create /etc/systemd/coredump.conf.d/maxuse.conf${NC}\n"
mkdir -pv /etc/systemd/coredump.conf.d || true
cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
[Coredump]
MaxUse=5G
EOF

printf "${GREEN}Create /etc/fstab${NC}\n"
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda3 / ext4 defaults 1 1
/dev/sda4 /boot ext4 defaults 0 2
/dev/sda5     swap         swap     pri=1               0     0

# End /etc/fstab
EOF
