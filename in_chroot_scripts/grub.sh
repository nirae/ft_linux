#! /usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd /boot
grub-install /dev/sda

cat > /boot/grub/grub.cfg << "EOF"
# Début de /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,4)

menuentry "GNU/Linux, Linux 5.8.3-ndubouil" {
        linux   /vmlinuz-5.8.3-ndubouil root=/dev/sda3 ro
}
EOF
