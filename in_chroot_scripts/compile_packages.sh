# IN CHROOT

set -ev

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

# Man-pages
DIR=/sources/man-pages-5.08
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    make

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Tcl
DIR=/sources/tcl8.6.10-src/tcl8.6.10
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    SRCDIR=$(pwd)
    cd unix
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
    make
    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh
    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.1/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.1|/usr/include|"            \
        -i pkgs/tdbc1.1.1/tdbcConfig.sh
    sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" \
        -e "s|$SRCDIR/pkgs/itcl4.2.0/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.2.0|/usr/include|"            \
        -i pkgs/itcl4.2.0/itclConfig.sh
    unset SRCDIR
    make test || true
    make install
    chmod -v u+w /usr/lib/libtcl8.6.so
    make install-private-headers
    ln -sfv tclsh8.6 /usr/bin/tclsh

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Expect-5.45.4 
DIR=/sources/expect5.45.4
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
    make
    make test || true
    make install
    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# DejaGNU-1.6.2
DIR=/sources/dejagnu-1.6.2
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    
    ./configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi
    make install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.2
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2
    make check || true

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Iana-Etc-20200821 
DIR=/sources/iana-etc-20200821 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    cp services protocols /etc

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Glibc-2.32
DIR=/sources/glibc-2.32
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    patch -Np1 -i ../glibc-2.32-fhs-1.patch || true
    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v $DIR/build && cd $DIR/build
    ../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=3.2                      \
             --enable-stack-protector=strong          \
             --with-headers=/usr/include              \
             libc_cv_slibdir=/lib
    make
    case $(uname -m) in
        i?86)   ln -sfnv $PWD/elf/ld-linux.so.2        /lib ;;
        x86_64) ln -sfnv $PWD/elf/ld-linux-x86-64.so.2 /lib ;;
    esac
    make check || true
    touch /etc/ld.so.conf || true
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    make install
    cp -v ../nscd/nscd.conf /etc/nscd.conf || true
    mkdir -pv /var/cache/nscd || true
    install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
    install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service

    mkdir -pv /usr/lib/locale || true
    localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
    localedef -i en_US -f ISO-8859-1 en_US
    localedef -i en_US -f UTF-8 en_US.UTF-8
    localedef -i fr_FR -f ISO-8859-1 fr_FR
    localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
    localedef -i fr_FR -f UTF-8 fr_FR.UTF-8

    cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    if [ ! -e etcetera ]
    then
        cp ../../tzdata2020a/* .
    fi

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
            asia australasia backward pacificnew systemv; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO

    ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime

    cat > /etc/ld.so.conf << "EOF"
# Début de /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

    cat >> /etc/ld.so.conf << "EOF"
# Ajout d'un répertoire include
include /etc/ld.so.conf.d/*.conf

EOF
    mkdir -pv /etc/ld.so.conf.d



    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Zlib-1.2.11 
DIR=/sources/zlib-1.2.11 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install
    mv -v /usr/lib/libz.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Bzip2-1.0.8 
DIR=/sources/bzip2-1.0.8 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=/usr install
    cp -v bzip2-shared /bin/bzip2
    cp -av libbz2.so* /lib
    ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
    rm -v /usr/bin/{bunzip2,bzcat,bzip2}
    ln -sv bzip2 /bin/bunzip2
    ln -sv bzip2 /bin/bzcat

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi


# Xz-5.2.5 
DIR=/sources/xz-5.2.5 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.5
    make
    make check || true
    make install
    mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
    mv -v /usr/lib/liblzma.so.* /lib
    ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Zstd-1.4.5  
DIR=/sources/zstd-1.4.5  
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    make
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
    mv -v /usr/lib/libzstd.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# File-5.39  
DIR=/sources/file-5.39    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Readline-8.0  
DIR=/sources/readline-8.0    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    ./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.0
    make SHLIB_LIBS="-lncursesw"
    make SHLIB_LIBS="-lncursesw" install
    mv -v /usr/lib/lib{readline,history}.so.* /lib
    chmod -v u+w /lib/lib{readline,history}.so.*
    ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
    ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# M4-1.4.18
DIR=/sources/m4-1.4.18    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Bc-3.1.5
DIR=/sources/bc-3.1.5    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    PREFIX=/usr CC=gcc CFLAGS="-std=c99" ./configure.sh -G -O3
    make
    make test || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Flex-2.6.4
DIR=/sources/flex-2.6.4    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
    make
    make check || true
    make install
    ln -s flex /usr/bin/lex

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Binutils-2.35
DIR=/sources/binutils-2.35    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v build && cd build
    ../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
    make tooldir=/usr
    make -k check || true
    make tooldir=/usr install


    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# GMP-6.2.0
DIR=/sources/gmp-6.2.0    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    cp -v configfsf.guess config.guess
    cp -v configfsf.sub   config.sub
    ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.0
            make
    make html
    make check 2>&1 | tee gmp-check-log || true
    awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
    make install
    make install-html


    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# MPFR-4.1.0 
DIR=/sources/mpfr-4.1.0    
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
    make
    make html
    make check || true
    make install
    make install-html

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# MPC-1.1.0 
DIR=/sources/mpc-1.1.0     
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.1.0
    make
    make html
    make check || true
    make install
    make install-html

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Attr-2.4.48 
DIR=/sources/attr-2.4.48     
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.4.48
    make
    make check || true
    make install
    mv -v /usr/lib/libattr.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Acl-2.2.53
DIR=/sources/acl-2.2.53     
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr         \
            --disable-static      \
            --libexecdir=/usr/lib \
            --docdir=/usr/share/doc/acl-2.2.53
    make
    make install
    mv -v /usr/lib/libacl.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Libcap-2.42 
DIR=/sources/libcap-2.42     
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/install -m.*STACAPLIBNAME/d' libcap/Makefile
    make lib=lib
    make test || true
    make lib=lib PKGCONFIGDIR=/usr/lib/pkgconfig install
    chmod -v 755 /lib/libcap.so.2.42
    mv -v /lib/libpsx.a /usr/lib
    rm -v /lib/libcap.so
    ln -sfv ../../lib/libcap.so.2 /usr/lib/libcap.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Shadow-4.8.1
DIR=/sources/shadow-4.8.1     
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
    sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
        -e 's:/var/spool/mail:/var/mail:'                 \
        -i etc/login.defs
    sed -i 's/1000/999/' etc/useradd
    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc \
                --with-group-name-max-length=32
    make
    make install
    pwconv
    grpconv
    passwd "root"

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# GCC-10.2.0 
DIR=/sources/gcc-10.2.0      
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
    ;;
    esac
    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v build && cd build
    ../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
    make
    ulimit -s 32768
    chown -Rv tester . 
    su tester -c "PATH=$PATH make -k check || true"
    ../contrib/test_summary | grep -A7 Summ
    make install
    rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/
    chown -v -R root:root /usr/lib/gcc/*linux-gnu/10.2.0/include{,-fixed}
    ln -sv ../usr/bin/cpp /lib
    install -v -dm755 /usr/lib/bfd-plugins
    ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/10.2.0/liblto_plugin.so /usr/lib/bfd-plugins/
    echo 'int main(){}' > dummy.c
    cc dummy.c -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'
    grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
    grep -B4 '^ /usr/include' dummy.log
    grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " dummy.log
    grep found dummy.log
    rm -v dummy.c a.out dummy.log
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Pkg-config-0.29.2 
DIR=/sources/pkg-config-0.29.2      
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr              \
                --with-internal-glib       \
                --disable-host-tool        \
                --docdir=/usr/share/doc/pkg-config-0.29.2
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  Ncurses-6.2 
DIR=/sources/ncurses-6.2       
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
    make
    make install
    mv -v /usr/lib/libncursesw.so.6* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
    for lib in ncurses form panel menu
    do
        rm -vf                    /usr/lib/lib${lib}.so
        echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
    done
    rm -vf                     /usr/lib/libcursesw.so
    echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
    ln -sfv libncurses.so      /usr/lib/libcurses.so
    mkdir -v       /usr/share/doc/ncurses-6.2
    cp -v -R doc/* /usr/share/doc/ncurses-6.2

    make distclean
    ./configure --prefix=/usr    \
                --with-shared    \
                --without-normal \
                --without-debug  \
                --without-cxx-binding \
                --with-abi-version=5 
    make sources libs
    cp -av lib/lib*.so.5* /usr/lib

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Sed-4.8 
DIR=/sources/sed-4.8       
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --bindir=/bin
    make
    make html
    chown -Rv tester .
    su tester -c "PATH=$PATH make check || true"
    make install
    install -d -m755           /usr/share/doc/sed-4.8
    install -m644 doc/sed.html /usr/share/doc/sed-4.8

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Psmisc-23.3 
DIR=/sources/psmisc-23.3
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make install
    mv -v /usr/bin/fuser   /bin
    mv -v /usr/bin/killall /bin

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Gettext-0.21 
DIR=/sources/gettext-0.21       
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21
    make
    make check || true
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Bison-3.7.1 
DIR=/sources/bison-3.7.1       
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.1
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Grep-3.4 
DIR=/sources/grep-3.4       
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --bindir=/bin
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Bash-5.0
DIR=/sources/bash-5.0
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch || true
    ./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.0 \
            --without-bash-malloc            \
            --with-installed-readline
    make
    chown -Rv tester .
#     su tester << EOF
# PATH=$PATH make tests < $(tty) || true
# EOF
    make install
    mv -vf /usr/bin/bash /bin

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Libtool-2.4.6 
DIR=/sources/libtool-2.4.6        
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# GDBM-1.18.1
DIR=/sources/gdbm-1.18.1        
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -r -i '/^char.*parseopt_program_(doc|args)/d' src/parseopt.c
    ./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Gperf-3.1
DIR=/sources/gperf-3.1        
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
    make -j1 check
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Expat-2.2.9
DIR=/sources/expat-2.2.9        
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.2.9./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
    make check || true
    make install
    install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.9 || true

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  Inetutils-1.9.4 
DIR=/sources/inetutils-1.9.4         
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
    make
    make check || true
    make install
    mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin || true
    mv -v /usr/bin/ifconfig /sbin || true

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  Perl-5.32.0 
DIR=/sources/perl-5.32.0          
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl      \
             -Darchlib=/usr/lib/perl5/5.32/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
    make
    make test || true
    make install
    unset BUILD_ZLIB BUILD_BZIP2

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# XML::Parser-2.46
DIR=/sources/XML-Parser-2.46          
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    perl Makefile.PL
    make
    make test || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Intltool-0.51.0 
DIR=/sources/intltool-0.51.0           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    ./configure --prefix=/usr
    make
    make check || true
    make install
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Autoconf-2.69 
DIR=/sources/autoconf-2.69           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '361 s/{/\\{/' bin/autoscan.in
    ./configure --prefix=/usr
    make
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Automake-1.16.2 
DIR=/sources/automake-1.16.2           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i "s/''/etags/" t/tags-lisp-space.sh
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.2
    make
    make -j4 check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Kmod-27
DIR=/sources/kmod-27           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib
    make
    make install
    for target in depmod insmod lsmod modinfo modprobe rmmod
    do
        ln -sfv ../bin/kmod /sbin/$target
    done

    ln -sfv kmod /bin/lsmod

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Libelf de Elfutils-0.180
DIR=/sources/elfutils-0.180           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --disable-debuginfod --libdir=/lib
    make
    make check || true
    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /lib/libelf.a

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Libffi-3.3 
DIR=/sources/libffi-3.3           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --disable-static --with-gcc-arch=native
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# OpenSSL-1.1.1g
DIR=/sources/openssl-1.1.1g          
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
    make
    make test || true
    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1g
    cp -vfr doc/* /usr/share/doc/openssl-1.1.1g

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Python-3.8.5 
DIR=/sources/Python-3.8.5           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
    make
    make install
    chmod -v 755 /usr/lib/libpython3.8.so
    chmod -v 755 /usr/lib/libpython3.so
    ln -sfv pip3.8 /usr/bin/pip3

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Ninja-1.10.0
DIR=/sources/ninja-1.10.0           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/int Guess/a \
    int   j = 0;\
    char* jobs = getenv( "NINJAJOBS" ); if ( jobs != NULL ) j = atoi( jobs ); if ( j > 0 ) return j;' src/ninja.cc
    python3 configure.py --bootstrap
    ./ninja ninja_test
    ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Meson-0.55.0
DIR=/sources/meson-0.55.0           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    python3 setup.py build
    python3 setup.py install --root=dest
    cp -rv dest/* /

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Coreutils-8.32
DIR=/sources/coreutils-8.32           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    patch -Np1 -i ../coreutils-8.32-i18n-1.patch
    sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
    autoreconf -fiv
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
    make
    make NON_ROOT_USERNAME=tester check-root
    echo "dummy:x:102:tester" >> /etc/group
    chown -Rv tester . 
    su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
    sed -i '/dummy/d' /etc/group
    make install
    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
    mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
    mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
    mv -v /usr/bin/{head,nice,sleep,touch} /bin

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Check-0.15.2
DIR=/sources/check-0.15.2           
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --disable-static
    make
    make check || true
    make docdir=/usr/share/doc/check-0.15.2 install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Diffutils-3.7 
DIR=/sources/diffutils-3.7            
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Gawk-5.1.0 
DIR=/sources/gawk-5.1.0            
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr
    make
    make check || true
    make install
    mkdir -v /usr/share/doc/gawk-5.1.0
    cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Findutils-4.7.0 
DIR=/sources/findutils-4.7.0            
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make
    # chown -Rv tester .
    # su tester -c "PATH=$PATH make check || true"
    make install
    mv -v /usr/bin/find /bin
    sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Groff-1.22.4
DIR=/sources/groff-1.22.4            
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    PAGE=A4 ./configure --prefix=/usr
    make -j1
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# GRUB-2.04 
DIR=/sources/grub-2.04             
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
    make
    make install
    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Less-551 
DIR=/sources/less-551             
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Gzip-1.10  
DIR=/sources/gzip-1.10              
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install
    mv -v /usr/bin/gzip /bin

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  IPRoute2-5.8.0 
DIR=/sources/iproute2-5.8.0              
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8
    sed -i 's/.m_ipt.o//' tc/Makefile
    make
    make DOCDIR=/usr/share/doc/iproute2-5.8.0 install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Kbd-2.3.0
DIR=/sources/kbd-2.3.0              
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    patch -Np1 -i ../kbd-2.3.0-backspace-1.patch
    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    ./configure --prefix=/usr --disable-vlock
    make
    make check || true
    make install
    rm -v /usr/lib/libtswrap.{a,la,so*}

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Libpipeline-1.5.3
DIR=/sources/libpipeline-1.5.3              
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Make-4.3
DIR=/sources/make-4.3             
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Patch-2.7.6 
DIR=/sources/patch-2.7.6
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Man-DB-2.9.3 
DIR=/sources/man-db-2.9.3
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    sed -i '/find/s@/usr@@' init/systemd/man-db.service.in

    ./configure --prefix=/usr                        \
                --docdir=/usr/share/doc/man-db-2.9.3 \
                --sysconfdir=/etc                    \
                --disable-setuid                     \
                --enable-cache-owner=bin             \
                --with-browser=/usr/bin/lynx         \
                --with-vgrind=/usr/bin/vgrind        \
                --with-grap=/usr/bin/grap
    make
    make check || true
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Tar-1.32 
DIR=/sources/tar-1.32
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    FORCE_UNSAFE_CONFIGURE=1  \
    ./configure --prefix=/usr \
            --bindir=/bin
    make
    make check || true
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.32

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Texinfo-6.7 
DIR=/sources/texinfo-6.7 
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr --disable-static
    make
    make check || true
    make install
    make TEXMF=/usr/share/texmf install-tex

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Vim-8.2.1361 
DIR=/sources/vim-8.2.1361
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr
    make
    # chown -Rv tester .
    # su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
    make install
    ln -sv vim /usr/bin/vi
    for L in  /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done
    ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.1361
    cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  Systemd-246 
DIR=/sources/systemd-246
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ln -sf /bin/true /usr/bin/xsltproc
    # cd $LFS/sources && cp /vagrant/packages-sources/systemd-man-pages-246.tar.xz .
    tar -xf ../systemd-man-pages-246.tar.xz
    # cp -r ../systemd-man-pages-246/build/man .
    sed '177,$ d' -i src/resolve/meson.build
    sed -i 's/GROUP="render", //' rules.d/50-udev-default.rules.in
    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -p $DIR/build && cd $DIR/build

    LANG=en_US.UTF-8                    \
    meson --prefix=/usr                 \
        --sysconfdir=/etc             \
        --localstatedir=/var          \
        -Dblkid=true                  \
        -Dbuildtype=release           \
        -Ddefault-dnssec=no           \
        -Dfirstboot=false             \
        -Dinstall-tests=false         \
        -Dkmod-path=/bin/kmod         \
        -Dldconfig=false              \
        -Dmount-path=/bin/mount       \
        -Drootprefix=                 \
        -Drootlibdir=/lib             \
        -Dsplit-usr=true              \
        -Dsulogin-path=/sbin/sulogin  \
        -Dsysusers=false              \
        -Dumount-path=/bin/umount     \
        -Db_lto=false                 \
        -Drpmmacrosdir=no             \
        -Dhomed=false                 \
        -Duserdb=false                \
        ..
        # -Dman=true                    \
        # -Ddocdir=/usr/share/doc/systemd-246 \
        # ..

    LANG=en_US.UTF-8 ninja
    LANG=en_US.UTF-8 ninja install
    rm -f /usr/bin/xsltproc
    systemd-machine-id-setup
    systemctl preset-all
    systemctl disable systemd-time-wait-sync.service
    rm -f /usr/lib/sysctl.d/50-pid-max.conf

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# D-Bus-1.12.20 
DIR=/sources/dbus-1.12.20
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr                       \
            --sysconfdir=/etc                   \
            --localstatedir=/var                \
            --disable-static                    \
            --disable-doxygen-docs              \
            --disable-xml-docs                  \
            --docdir=/usr/share/doc/dbus-1.12.20 \
            --with-console-auth-dir=/run/console
    make
    make install
    mv -v /usr/lib/libdbus-1.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
    ln -sv /etc/machine-id /var/lib/dbus
    sed -i 's:/var/run:/run:' /lib/systemd/system/dbus.socket

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# Procps-3.3.16 
DIR=/sources/procps-ng-3.3.16
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    ./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.16 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd
    make
    make check || true
    make install
    cp /usr/lib/libprocps.so.* /lib
    # mv -v /usr/lib/libprocps.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

#  Util-linux-2.36 
DIR=/sources/util-linux-2.36
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    mkdir -pv /var/lib/hwclock
    ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
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
    make
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

# E2fsprogs-1.45.6 
DIR=/sources/e2fsprogs-1.45.6
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`

    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v $DIR/build && cd $DIR/build
    ../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

    make
    make check || true
    make install
    chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] $DIR in ${time}${NC}\n"

    mv $DIR $DIR-install-ok
else
    printf "[ALREADY] $DIR\n"
fi

rm -rf /tmp/*
