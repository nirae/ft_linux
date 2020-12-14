#! /usr/bin/env bash

# ROOT

# real	16m17.159s
# user	14m18.992s
# sys	2m8.515s

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -z "$(find $LFS/{usr,lib,var,etc,bin,sbin,tools} -maxdepth 0 -user "$(id -u)")" ]
then
    chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
        x86_64) chown -R root:root $LFS/lib64 ;;
    esac
    printf "${GREEN}changing $LFS owner to root${NC}\n"
else
    printf "$LFS is already owned by root\n"
fi

if [ ! -e $LFS/dev ]
then
    mkdir -pv $LFS/{dev,proc,sys,run}
    printf "${GREEN}creating $LFS/{dev,proc,sys,run}${NC}\n"
else
    printf "$LFS/{dev,proc,sys,run} already exist\n"
fi

if [ ! -e $LFS/dev/console ]
then
    mknod -m 600 $LFS/dev/console c 5 1
    printf "${GREEN}creating $LFS/dev/console${NC}\n"
else
    printf "$LFS/dev/console already exist\n"
fi

if [ ! -e $LFS/dev/null ]
then
    mknod -m 666 $LFS/dev/null c 1 3
    printf "${GREEN}creating $LFS/dev/null${NC}\n"
else
    printf "$LFS/dev/null already exist\n"
fi

if [ ! -e $LFS/dev/sda ]
then
    mount -v --bind /dev $LFS/dev
    printf "${GREEN}mount bind /dev on $LFS/dev${NC}\n"
else
    printf "$LFS/dev already mounted on $LFS/dev\n"
fi

mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc || true
mount -vt sysfs sysfs $LFS/sys || true
mount -vt tmpfs tmpfs $LFS/run || true

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

printf "${GREEN}Execute in_chroot_scripts/prepare.sh script in the chroot${NC}\n"

chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h < /vagrant/in_chroot_scripts/prepare.sh
