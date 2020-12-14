#! /usr/bin/env bash

# real	62m55.402s
# user	61m15.408s
# sys	2m0.033s

umount $LFS/dev{/pts,}
umount $LFS/{sys,proc,run}

echo "Backup the ${LFS} directory"

cd $LFS &&
tar -cJpf /vagrant/backup/lfs-temp-tools-10.0-systemd.tar.xz .

mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc || true
mount -vt sysfs sysfs $LFS/sys || true
mount -vt tmpfs tmpfs $LFS/run || true
