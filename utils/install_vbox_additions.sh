#! /usr/bin/env bash
# ROOT

set -e

cd /root

wget https://download.virtualbox.org/virtualbox/6.1.16/VBoxGuestAdditions_6.1.16.iso
mkdir /media/VBoxGuestAdditions
mount -o loop,ro VBoxGuestAdditions_6.1.16.iso /media/VBoxGuestAdditions
sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm VBoxGuestAdditions_6.1.16.iso
umount /media/VBoxGuestAdditions
rmdir /media/VBoxGuestAdditions
