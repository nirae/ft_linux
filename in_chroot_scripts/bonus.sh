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

# openssh-8.3p1
DIR=/sources/openssh-8.3p1
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    install  -v -m700 -d /var/lib/sshd
    chown    -v root:sys /var/lib/sshd

    groupadd -g 50 sshd
    useradd  -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g sshd           \
            -s /bin/false     \
            -u 50 sshd
    
    ./configure --prefix=/usr                     \
            --sysconfdir=/etc/ssh             \
            --with-md5-passwords              \
            --with-privsep-path=/var/lib/sshd
    make

    make install
    install -v -m755    contrib/ssh-copy-id /usr/bin

    install -v -m644    contrib/ssh-copy-id.1 \
                        /usr/share/man/man1
    install -v -m755 -d /usr/share/doc/openssh-8.3p1
    install -v -m644    INSTALL LICENCE OVERVIEW README* \
                        /usr/share/doc/openssh-8.3p1

    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

    cd /sources/blfs-systemd-units-20200828
    make install-sshd
    cd $DIR

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# libtasn1-4.16.0
DIR=/sources/libtasn1-4.16.0 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr --disable-static
    make
    make install
    make -C doc/reference install-data-local

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# p11-kit-0.23.20
DIR=/sources/p11-kit-0.23.20 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    sed '20,$ d' -i trust/trust-extract-compat.in
    cat >> trust/trust-extract-compat.in << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Generate a new trust store
/usr/sbin/make-ca -f -g
EOF
    ./configure --prefix=/usr     \
                --sysconfdir=/etc \
                --with-trust-paths=/etc/pki/anchors
    make
    make install
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
            /usr/bin/update-ca-certificates
    ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# make-ca-1.7
# DIR=/sources/make-ca-1.7 
# if [ -e $DIR ]
# then
#     cd $DIR
#     start=`date +%s`
    
#     make install
#     install -vdm755 /etc/ssl/local
#     /usr/sbin/make-ca -g
#     systemctl enable update-pki.timer


#     end=`date +%s`
#     time=$(displaytime `expr $end - $start`)
#     printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

#     mv $DIR $DIR-install-ok
# else
#     printf "[ALREADY] $DIR\n"
# fi

# curl-7.71.1
DIR=/sources/curl-7.71.1
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    patch -Np1 -i ../curl-7.71.1-security_fixes-1.patch
    ./configure --prefix=/usr                           \
            --disable-static                        \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs
    make
    make install
    rm -rf docs/examples/.deps
    find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \;
    install -v -d -m755 /usr/share/doc/curl-7.71.1
    cp -v -R docs/*     /usr/share/doc/curl-7.71.1

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# git-2.28.0
DIR=/sources/git-2.28.0
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr \
            --with-gitconfig=/etc/gitconfig \
            --with-python=python3
    make
    tar -xf ../git-manpages-2.28.0.tar.xz \
        -C /usr/share/man --no-same-owner --no-overwrite-dir

    make perllibdir=/usr/lib/perl5/5.32/site_perl install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# wget-1.20.3
DIR=/sources/wget-1.20.3
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl
    make
    make install


    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# popt-1.18
DIR=/sources/popt-1.18
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr --disable-static
    make
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# rsync-3.2.3
DIR=/sources/rsync-3.2.3
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    groupadd -g 48 rsyncd
    useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd \
    -s /bin/false -u 48 rsyncd
    ./configure --prefix=/usr    \
            --disable-lz4    \
            --disable-xxhash \
            --without-included-zlib
    make
    make install

    cat > /etc/rsyncd.conf << "EOF"
# This is a basic rsync configuration file
# It exports a single module without user authentication.

motd file = /home/rsync/welcome.msg
use chroot = yes

[localhost]
    path = /home/rsync
    comment = Default rsync module
    read only = yes
    list = yes
    uid = rsyncd
    gid = rsyncd

EOF

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# sudo-1.9.2
DIR=/sources/sudo-1.9.2
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr              \
            --libexecdir=/usr/lib      \
            --with-secure-path         \
            --with-all-insults         \
            --with-env-editor          \
            --docdir=/usr/share/doc/sudo-1.9.2 \
            --with-passprompt="[sudo] password for %p: "
    make
    make install &&
    ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0

    cat > /etc/sudoers.d/sudo << "EOF"
Defaults secure_path="/usr/bin:/bin:/usr/sbin:/sbin"
%wheel ALL=(ALL) ALL
EOF

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Which
DIR=/usr/bin/which
if [ ! -e $DIR ]
then
    start=`date +%s`
    
    cat > /usr/bin/which << "EOF"
#!/bin/bash
type -pa "$@" | head -n 1 ; exit ${PIPESTATUS[0]}
EOF
    chmod -v 755 /usr/bin/which
    chown -v root:root /usr/bin/which

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

else
    printf "[ALREADY] $DIR\n"
fi
