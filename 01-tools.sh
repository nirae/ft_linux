#! /usr/bin/env bash

# real	95m50.974s
# user	78m53.509s
# sys	11m44.143s

set -ex

# USER == lfs

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

# Binutils
DIR=$LFS/sources/binutils-2.35
if [ -e $DIR ]
then
    cd $DIR

    if [ -e $DIR/build  ]
    then
        rm -rf $DIR/build
    fi
    start=`date +%s`
    printf "${GREEN}[START] ${DIR}${NC}\n"
    
    mkdir -v $DIR/build
    cd $DIR/build
    ../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT --disable-nls --disable-werror
    make
    make install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    if [ $? ]
    then
        printf "${GREEN}[DONE] ${DIR} in ${time}${NC}\n"
    else
        printf "${RED}[FAIL] ${DIR} in ${time}${NC}\n"
        exit 1
    fi
    
    mv $DIR $DIR.ok
else
    printf "[ALREADY] ${DIR}\n"
fi

# GCC
DIR=$LFS/sources/gcc-10.2.0
if [ -e $DIR ]
then
    cd $DIR
    if [ -e $DIR/build  ]
    then
        rm -rf $DIR/build
    fi
    start=`date +%s`
    printf "${GREEN}[START] ${DIR}${NC}\n"

    if [ -e $LFS/sources/mpfr-4.1.0 ]
    then
        mv -v $LFS/sources/mpfr-4.1.0 $DIR/mpfr 
        mv -v $LFS/sources/gmp-6.2.0 $DIR/gmp 
        mv -v $LFS/sources/mpc-1.1.0 $DIR/mpc
    fi
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    mkdir -v $DIR/build
    cd $DIR/build
    ../configure                                   \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++
    make
    make install
    cd $DIR
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    if [ $? ]
    then
        printf "${GREEN}[DONE] ${DIR} in ${time}${NC}\n"
    else
        printf "${RED}[FAIL] ${DIR} in ${time}${NC}\n"
        exit 1
    fi
    mv $DIR $DIR.ok

else
    printf "[ALREADY] GCC\n"
fi

# Linux API Headers
DIR=$LFS/sources/linux-5.8.3
if [ -e $DIR ]
then
    start=`date +%s`
    printf "${GREEN}[START] ${DIR}${NC}\n"
    cd $DIR

    make mrproper
    make headers
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    cp -rv usr/include $LFS/usr

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Linux API Headers in ${time}${NC}\n"
else
    printf "[ALREADY] Linux API Headers\n"
fi

# GLibc
DIR=$LFS/sources/glibc-2.32
if [ -e $DIR ]
then
    if [ -e build  ]
    then
        rm -rf $DIR/build
    fi
    start=`date +%s`
    printf "${GREEN}[START] ${DIR}${NC}\n"
    cd $DIR

    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac
    patch -Np1 -i ../glibc-2.32-fhs-1.patch
    mkdir -v $DIR/build && cd $DIR/build
    ../configure                             \
    --prefix=/usr                      \
    --host=$LFS_TGT                    \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2                \
    --with-headers=$LFS/usr/include    \
    libc_cv_slibdir=/lib
    make && make DESTDIR=$LFS install

    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] GLibc in ${time}${NC}\n"
    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    output=$(readelf -l a.out | grep '/ld-linux')
    printf "${GREEN}GLibc check:\n ${output}${NC}\n"
    rm -v dummy.c a.out
    $LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
    mv $DIR $DIR.ok
else
    printf "[ALREADY] GLibc\n"
fi

# Libstdc++
DIR=$LFS/sources/gcc-10.2.0.ok
if [ -e $DIR ]
then
    cd $DIR

    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v $DIR/build && cd $DIR/build
    start=`date +%s`
    ../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0
    make && make DESTDIR=$LFS install
    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Libstdc++ in ${time}${NC}\n"
    mv $DIR $DIR.ok

else
    printf "[ALREADY] Libstdc++\n"
fi

# 3.6

# M4
DIR=$LFS/sources/m4-1.4.18
if [ -e $DIR ]
then
    cd $DIR
    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

    start=`date +%s`
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] M4 in ${time}${NC}\n"
    mv $DIR $DIR.ok

else
    printf "[ALREADY] M4\n"
fi

# Ncurses
DIR=$LFS/sources/ncurses-6.2
if [ -e $DIR ]
then
    cd $DIR
    sed -i s/mawk// configure

    mkdir build
    pushd build
    ../configure
    make -C include
    make -C progs tic
    popd

    start=`date +%s`
    ./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec
    make
    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
    echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
    mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
    ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Ncurses in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Ncurses\n"
fi

# Bash
DIR=$LFS/sources/bash-5.0
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc
    make && make DESTDIR=$LFS install
    mv $LFS/usr/bin/bash $LFS/bin/bash
    ln -sv bash $LFS/bin/sh
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Bash in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Bash\n"
fi

# Coreutils
DIR=$LFS/sources/coreutils-8.32
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
    make && make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
    mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
    mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
    mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
    mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Coreutils in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Coreutils\n"
fi

# Difftils
DIR=$LFS/sources/diffutils-3.7
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr --host=$LFS_TGT
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Difftils in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Diffutils\n"
fi

# File
DIR=$LFS/sources/file-5.39
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr --host=$LFS_TGT
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] File in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] File\n"
fi

# Findutils
DIR=$LFS/sources/findutils-4.7.0
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make && make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/find $LFS/bin
    sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Findutils in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Findutils\n"
fi

# Gawk
DIR=$LFS/sources/gawk-5.1.0
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./config.guess)
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Gawk in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Gawk\n"
fi

# Grep
DIR=$LFS/sources/grep-3.4
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Grep in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Grep\n"
fi

# Gzip
DIR=$LFS/sources/gzip-1.10
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr --host=$LFS_TGT
    make && make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/gzip $LFS/bin
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Gzip in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Gzip\n"
fi

#Make
DIR=$LFS/sources/make-4.3
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Make in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Make\n"
fi

#Patch
DIR=$LFS/sources/patch-2.7.6
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Patch in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Patch\n"
fi

#Sed
DIR=$LFS/sources/sed-4.8
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Sed in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Sed\n"
fi

#Tar
DIR=$LFS/sources/tar-1.32
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --bindir=/bin
    make && make DESTDIR=$LFS install
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Tar in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Tar\n"
fi

#XZ
DIR=$LFS/sources/xz-5.2.5
if [ -e $DIR ]
then
    cd $DIR
    start=`date +%s`
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5
    make && make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
    mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
    ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
    end=`date +%s`

    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] XZ in ${time}${NC}\n"
    mv $DIR $DIR.ok
else
    printf "[ALREADY] XZ\n"
fi

# Binutils - passe 2
DIR=$LFS/sources/binutils-2.35.ok
if [ -e $DIR ]
then
    cd $DIR

    if [ -e build  ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v $DIR/build && cd $DIR/build
    start=`date +%s`
    ../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd
    make && make DESTDIR=$LFS install
    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] Binutils - passe 2 in ${time}${NC}\n"
    
    mv $DIR $DIR.ok
else
    printf "[ALREADY] Binutils - passe 2\n"
fi

# GCC - passe 2
DIR=$LFS/sources/gcc-10.2.0.ok.ok
if [ -e $DIR ]
then
    cd $DIR

    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    if [ -e $DIR/build ]
    then
        rm -rf $DIR/build
    fi
    mkdir -v $DIR/build && cd $DIR/build
    mkdir -pv $LFS_TGT/libgcc
    ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
    start=`date +%s`
    ../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --prefix=/usr                                  \
    CC_FOR_TARGET=$LFS_TGT-gcc                     \
    --with-build-sysroot=$LFS                      \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++
    make && make DESTDIR=$LFS install
    ln -sv gcc $LFS/usr/bin/cc
    end=`date +%s`
    time=$(displaytime `expr $end - $start`)
    printf "${GREEN}[DONE] GCC - passe 2 in ${time}${NC}\n"
    # rm -rf $DIR/build
    mv $DIR $DIR.ok

else
    printf "[ALREADY] GCC - passe 2\n"
fi

