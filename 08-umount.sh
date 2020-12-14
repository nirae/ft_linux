#! /usr/bin/env bash

# ROOT

set -e

umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

umount -v $LFS/boot
umount -v $LFS
