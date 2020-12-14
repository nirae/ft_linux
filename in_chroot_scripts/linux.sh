#! /usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function displaytime {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( $D > 0 )) && printf '%d days ' $D
    (( $H > 0 )) && printf '%d hours ' $H
    (( $M > 0 )) && printf '%d minutes ' $M
    (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
    printf '%d seconds\n' $S
}

DIR=/sources/linux-5.8.3
if [ -e $DIR ]
then

    NAME=vmlinuz-5.8.3-ndubouil

    cd $DIR
    start=`date +%s`
    printf "${GREEN}[START] ${DIR} compilation${time}${NC}\n"

    make mrproper || true
    make defconfig
    echo 'CONFIG_LOCALVERSION="-ndubouil"' >> .config
    make
    make modules_install

    if [ -e /boot/$NAME ]
    then
        rm -rf /boot/$NAME
    fi
    cp -iv arch/x86/boot/bzImage /boot/$NAME

    if [ -e /boot/System.map-5.8.3 ]
    then
        rm -rf /boot/System.map-5.8.3
    fi
    cp -iv System.map /boot/System.map-5.8.3

    if [ -e /boot/config-5.8.3 ]
    then
        rm -rf /boot/config-5.8.3
    fi
    cp -iv .config /boot/config-5.8.3

    printf "${GREEN}Copy kernel documentation in /usr/share/doc/linux-5.8.${NC}\n"
    if [ -e /usr/share/doc/linux-5.8.3 ]
    then
        rm -rf /usr/share/doc/linux-5.8.3
    fi
    install -d /usr/share/doc/linux-5.8.3
    cp -r Documentation/* /usr/share/doc/linux-5.8.3

    chown -R 0:0 $DIR

    printf "${GREEN}Copy kernel sources in /usr/src/kernel-5.8.3${NC}\n"
    if [ -e /usr/src/kernel-5.8.3 ]
    then
        rm -rf /usr/src/kernel-5.8.3
    fi
    cp -r $DIR /usr/src/kernel-5.8.3

    install -v -m755 -d /etc/modprobe.d
    cat > /etc/modprobe.d/usb.conf << "EOF"
# Début de /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# Fin de /etc/modprobe.d/usb.conf
EOF

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

printf "${GREEN}Creating /etc/lsb-release${NC}\n"
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="ft_linux"
DISTRIB_RELEASE="42"
DISTRIB_CODENAME="ndubouil"
DISTRIB_DESCRIPTION="42 Ft_Linux"
EOF

printf "${GREEN}Creating /etc/os-release${NC}\n"
cat > /etc/os-release << "EOF"
NAME="ft_linux"
VERSION="42"
ID=ft_linux
PRETTY_NAME="42 Ft_Linux"
VERSION_CODENAME="ndubouil"
EOF
