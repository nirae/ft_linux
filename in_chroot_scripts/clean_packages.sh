# IN CHROOT

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -e /usr/lib/libz.a ]
then
    rm -f /usr/lib/lib{bfd,opcodes}.a
    rm -f /usr/lib/libctf{,-nobfd}.a
    rm -f /usr/lib/libbz2.a
    rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
    rm -f /usr/lib/libltdl.a
    rm -f /usr/lib/libfl.a
    rm -f /usr/lib/libz.a
    printf "${GREEN}old library removed${NC}\n"
fi

find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

if [ -e /tools ]
then
    rm -rf /tools
fi

if [ id "userdel" &>/dev/null ]
then
    userdel -r tester
fi
