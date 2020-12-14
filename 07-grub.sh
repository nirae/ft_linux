#! /usr/bin/env bash

# ROOT

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

set -e

printf "${GREEN}Grub setup${NC}\n"

chroot "$LFS" /usr/bin/env -i          \
    HOME=/root TERM="$TERM"            \
    PS1='(lfs chroot) \u:\w\$ '        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login < /vagrant/in_chroot_scripts/grub.sh
