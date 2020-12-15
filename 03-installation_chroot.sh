#! /usr/bin/env bash

# ROOT

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${GREEN}clean all sources${NC}\n"

for i in {0..10}
do
    for file in $LFS/sources/*.ok
    do
        mv -- "$file" "${file%.ok}" || true
    done
done

printf "${GREEN}Compiling packages in the chroot${NC}\n"

chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h < /vagrant/in_chroot_scripts/compile_packages.sh

