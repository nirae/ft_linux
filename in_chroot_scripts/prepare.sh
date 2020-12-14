# IN CHROOT

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ ! -e /home ]
then
    mkdir -pv /{boot,home,mnt,opt,srv}
    printf "${GREEN}creating /{boot,home,mnt,opt,srv}${NC}\n"
else
    printf "/{boot,home,mnt,opt,srv} already exist\n"
fi

if [ ! -e /etc/opt ]
then
    mkdir -pv /etc/{opt,sysconfig}
    printf "${GREEN}creating /etc/{opt,sysconfig}${NC}\n"
else
    printf "/etc/{opt,sysconfig} already exist\n"
fi

if [ ! -e /lib/firmware ]
then
    mkdir -pv /lib/firmware
    printf "${GREEN}creating /lib/firmware${NC}\n"
else
    printf "/lib/firmware already exist\n"
fi

if [ ! -e /media/floppy ]
then
    mkdir -pv /media/{floppy,cdrom}
    printf "${GREEN}creating /media/{floppy,cdrom}${NC}\n"
else
    printf "/media/{floppy,cdrom} already exist\n"
fi

if [ ! -e /usr/local/bin ]
then
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    printf "${GREEN}creating /usr/{,local/}{bin,include,lib,sbin,src}${NC}\n"
else
    printf "/usr/{,local/}{bin,include,lib,sbin,src} already exist\n"
fi

if [ ! -e /usr/local/share ]
then
    mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
    printf "${GREEN}creating /usr/{,local/}share/{color,dict,doc,info,locale,man}${NC}\n"
else
    printf "/usr/{,local/}share/{color,dict,doc,info,locale,man} already exist\n"
fi

if [ ! -e /usr/local/share/color ]
then
    mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
    printf "${GREEN}creating /usr/{,local/}share/{color,dict,doc,info,locale,man}${NC}\n"
else
    printf "/usr/{,local/}share/{color,dict,doc,info,locale,man} already exist\n"
fi

if [ ! -e /usr/local/share/misc ]
then
    mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
    printf "${GREEN}creating /usr/{,local/}share/{misc,terminfo,zoneinfo}${NC}\n"
else
    printf "/usr/{,local/}share/{misc,terminfo,zoneinfo} already exist\n"
fi

if [ ! -e /usr/local/share/man/man1 ]
then
    mkdir -pv /usr/{,local/}share/man/man{1..8}
    printf "${GREEN}creating /usr/{,local/}share/man/man{1..8}${NC}\n"
else
    printf "/usr/{,local/}share/man/man{1..8} already exist\n"
fi

if [ ! -e /var/mail ]
then
    mkdir -pv /var/{cache,local,log,mail,opt,spool}
    printf "${GREEN}creating /var/{cache,local,log,mail,opt,spool}${NC}\n"
else
    printf "/var/{cache,local,log,mail,opt,spool} already exist\n"
fi

if [ ! -e /var/lib/color ]
then
    mkdir -pv /var/lib/{color,misc,locate}
    printf "${GREEN}creating /var/lib/{color,misc,locate}${NC}\n"
else
    printf "/var/lib/{color,misc,locate} already exist\n"
fi

if [ ! -h /var/run ]
then
    ln -sfv /run /var/run
    printf "${GREEN}creating /var/run${NC}\n"
else
    printf "/var/run already exist\n"
fi

if [ ! -h /var/lock ]
then
    ln -sfv /run/lock /var/lock
    printf "${GREEN}creating /var/lock${NC}\n"
else
    printf "/var/lock already exist\n"
fi

if [ ! -e /root ]
then
    install -dv -m 0750 /root
    printf "${GREEN}creating /root${NC}\n"
else
    printf "/root already exist\n"
fi

if [ ! -e /tmp ]
then
    install -dv -m 1777 /tmp /var/tmp
    printf "${GREEN}creating /tmp${NC}\n"
else
    printf "/tmp already exist\n"
fi

if [ ! -h /etc/mtab ]
then
    ln -svf /proc/self/mounts /etc/mtab
    printf "${GREEN}creating /etc/mtab${NC}\n"
else
    printf "/etc/mtab already exist\n"
fi

if [ ! -e /etc/hosts ]
then
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    printf "${GREEN}creating /etc/hosts${NC}\n"
else
    printf "/etc/hosts already exist\n"
fi


cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

printf "${GREEN}creating /etc/passwd${NC}\n"

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-bus-proxy:x:72:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

printf "${GREEN}creating /etc/group${NC}\n"

if [ id "tester" &>/dev/null ]
then
    printf "user tester already exist\n"
else
    echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
    echo "tester:x:101:" >> /etc/group
    install -o tester -d /home/tester
    printf "${GREEN}creating user tester${NC}\n"
fi

if [ ! -e /var/log/wtmp ]
then
    touch /var/log/{btmp,lastlog,faillog,wtmp}
    chgrp -v utmp /var/log/lastlog
    chmod -v 664  /var/log/lastlog
    chmod -v 600  /var/log/btmp
    printf "${GREEN}creating /var/log/{btmp,lastlog,faillog,wtmp}${NC}\n"
else
    printf "/var/log/{btmp,lastlog,faillog,wtmp} already exist\n"
fi

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

# Compilation

# Libstdc++ - Passe 2
DIR=/sources/gcc-10.2.0.ok.ok.ok
if [ -e $DIR ]
then

    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi

    mkdir -v $DIR/build && cd $DIR/build
    start=`date +%s`
    
    ../libstdc++-v3/configure            \
        CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
        --prefix=/usr                    \
        --disable-multilib               \
        --disable-nls                    \
        --host=$(uname -m)-lfs-linux-gnu \
        --disable-libstdcxx-pch
    make && make install
    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Libstdc++ in ${time}${NC}\n"
    
    mv $DIR $DIR.ok
    # rm -rf $DIR

else
    printf "[ALREADY] Libstdc++\n"
fi

# Gettext
DIR=/sources/gettext-0.21
if [ -e $DIR ]
then

    cd $DIR
    start=`date +%s`
    
    ./configure --disable-shared
    make

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Gettext in ${time}${NC}\n"

    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Gettext\n"
fi

# Bison
DIR=/sources/bison-3.7.1
if [ -e $DIR ]
then
    cd $DIR

    start=`date +%s`
    
    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.7.1
    make && make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Bison in ${time}${NC}\n"

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Bison\n"
fi

# Perl
DIR=/sources/perl-5.32.0
if [ -e $DIR ]
then
    cd $DIR

    start=`date +%s`
    
    sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl     \
             -Darchlib=/usr/lib/perl5/5.32/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl
    make && make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Perl in ${time}${NC}\n"

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Perl\n"
fi

# Python
DIR=/sources/Python-3.8.5
if [ -e $DIR ]
then
    cd $DIR

    start=`date +%s`
    
    ./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip
    make && make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Python in ${time}${NC}\n"

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Python\n"
fi

# Texinfo
DIR=/sources/texinfo-6.7
if [ -e $DIR ]
then
    cd $DIR

    start=`date +%s`
    
    ./configure --prefix=/usr
    make && make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Texinfo in ${time}${NC}\n"

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Texinfo\n"
fi

# Util-linux
DIR=/sources/util-linux-2.36
if [ -e $DIR ]
then
    cd $DIR

    mkdir -pv /var/lib/hwclock

    start=`date +%s`
    
    ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --docdir=/usr/share/doc/util-linux-2.36 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python
    make && make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Util-linux in ${time}${NC}\n"

    mv $DIR $DIR.ok
    # rm -rf $DIR
else
    printf "[ALREADY] Util-linux\n"
fi

printf "${GREEN}Cleaning ...${NC}\n"

if [ -e /usr/lib/libbfd.la ]
then
    find /usr/{lib,libexec} -name \*.la -delete
    printf "${GREEN}Remove /usr/{lib,libexec}${NC}\n"
fi

if [ -e /usr/share/info/bash.info ]
then
    rm -rf /usr/share/{info,man,doc}/*
    printf "${GREEN}Remove /usr/share/{info,man,doc}/*${NC}\n"
fi
