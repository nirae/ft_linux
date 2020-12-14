#! /usr/bin/env bash
# ROOT

# DOWNLOAD THE PACKAGES FIRST -> in packages-sources

set -e

printf "${GREEN}Install more programs${NC}\n"

cd $LFS/sources

if [ ! -e $LFS/sources/blfs-systemd-units-20200828.tar.xz ]
then
    cp /vagrant/packages-sources/blfs-systemd-units-20200828.tar.xz .
fi
if [ ! -e $LFS/sources/blfs-systemd-units-20200828 ]
then
    tar xvf blfs-systemd-units-20200828.tar.xz
fi

if [ ! -e $LFS/sources/openssh-8.3p1.tar.gz ]
then
    cp /vagrant/packages-sources/openssh-8.3p1.tar.gz .
fi
if [ ! -e $LFS/sources/openssh-8.3p1 ] && [ ! -e $LFS/sources/openssh-8.3p1-install-ok ]
then
    tar xvf openssh-8.3p1.tar.gz
fi

if [ ! -e $LFS/sources/libtasn1-4.16.0.tar.gz ]
then
    cp /vagrant/packages-sources/libtasn1-4.16.0.tar.gz .
fi
if [ ! -e $LFS/sources/libtasn1-4.16.0 ] && [ ! -e $LFS/sources/libtasn1-4.16.0-install-ok ]
then
    tar xvf libtasn1-4.16.0.tar.gz
fi

if [ ! -e $LFS/sources/p11-kit-0.23.20.tar.xz ]
then
    cp /vagrant/packages-sources/p11-kit-0.23.20.tar.xz .
fi
if [ ! -e $LFS/sources/p11-kit-0.23.20 ] && [ ! -e $LFS/sources/p11-kit-0.23.20-install-ok ]
then
    tar xvf p11-kit-0.23.20.tar.xz
fi

if [ ! -e $LFS/sources/make-ca-1.7.tar.xz ]
then
    cp /vagrant/packages-sources/make-ca-1.7.tar.xz .
fi
if [ ! -e $LFS/sources/make-ca-1.7 ] && [ ! -e $LFS/sources/make-ca-1.7-install-ok ]
then
    tar xvf make-ca-1.7.tar.xz
fi

if [ ! -e $LFS/sources/curl-7.71.1.tar.xz ]
then
    cp /vagrant/packages-sources/curl-7.71.1.tar.xz .
    cp /vagrant/packages-sources/curl-7.71.1-security_fixes-1.patch .
fi
if [ ! -e $LFS/sources/curl-7.71.1 ] && [ ! -e $LFS/sources/curl-7.71.1-install-ok ]
then
    tar xvf curl-7.71.1.tar.xz
fi

if [ ! -e $LFS/sources/git-2.28.0.tar.xz ]
then
    cp /vagrant/packages-sources/git-2.28.0.tar.xz .
fi
if [ ! -e $LFS/sources/git-2.28.0 ] && [ ! -e $LFS/sources/git-2.28.0-install-ok ]
then
    tar xvf git-2.28.0.tar.xz
fi

if [ ! -e $LFS/sources/git-manpages-2.28.0.tar.xz ]
then
    cp /vagrant/packages-sources/git-manpages-2.28.0.tar.xz .
fi

if [ ! -e $LFS/sources/wget-1.20.3.tar.gz ]
then
    cp /vagrant/packages-sources/wget-1.20.3.tar.gz .
fi
if [ ! -e $LFS/sources/wget-1.20.3 ] && [ ! -e $LFS/sources/wget-1.20.3-install-ok ]
then
    tar xvf wget-1.20.3.tar.gz
fi

if [ ! -e $LFS/sources/popt-1.18.tar.gz ]
then
    cp /vagrant/packages-sources/popt-1.18.tar.gz .
fi
if [ ! -e $LFS/sources/popt-1.18 ] && [ ! -e $LFS/sources/popt-1.18-install-ok ]
then
    tar xvf popt-1.18.tar.gz
fi

if [ ! -e $LFS/sources/rsync-3.2.3.tar.gz ]
then
    cp /vagrant/packages-sources/rsync-3.2.3.tar.gz .
fi
if [ ! -e $LFS/sources/rsync-3.2.3 ] && [ ! -e $LFS/sources/rsync-3.2.3-install-ok ]
then
    tar xvf rsync-3.2.3.tar.gz
fi

if [ ! -e $LFS/sources/sudo-1.9.2.tar.gz ]
then
    cp /vagrant/packages-sources/sudo-1.9.2.tar.gz .
fi
if [ ! -e $LFS/sources/sudo-1.9.2 ] && [ ! -e $LFS/sources/sudo-1.9.2-install-ok ]
then
    tar xvf sudo-1.9.2.tar.gz
fi

chroot "$LFS" /usr/bin/env -i          \
    HOME=/root TERM="$TERM"            \
    PS1='(lfs chroot) \u:\w\$ '        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login < /vagrant/in_chroot_scripts/bonus.sh
