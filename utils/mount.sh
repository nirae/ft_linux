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
