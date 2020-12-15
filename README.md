# Ft_Linux

> In this subject, you have to build a basic, but functional, linux distribution.

Based on the [LFS 10.0-systemd](http://fr.linuxfromscratch.org/view/lfs-systemd-stable/)

## Setup the base VM

I used a Vagrant **debian / buster64** box for the base VM and ansible for the provisionning

First, you need some ansible plugins

```sh
$ make ansible-setup
```

Download the sources packages, the list is in the file `wget-list`

```sh
$ make download-packages
```

To setup the base VM :

```sh
$ make up
```

This will run the debian virtual machine and launch Ansible to get the prerequisites of LFS.

- `LFS` (/mnt/lfs) env variable for all users
- Some basic packages (gcc, make, libc, coreutils, python3...)
- Symlink `/bin/sh` -> `/bin/bash`
- `lfs` user and group, clean `.bashrc`
- 3 partitions for: `/`, `/boot` and `swap`, mounted on `/mnt/lfs`, with owner `lfs`
- Download, copy in `/mnt/lfs/sources` and decompress all packages archives
- First directories on `/mnt/lfs`: [bin, etc, lib, lib64, sbin, usr, var, tools]

Run the script `utils/version-check.sh` to check if you have all the prerequisites

All of these files will be on the VM, at `/vagrant/`

## Starting LFS

For all the packages compilation steps, before panicking if it fails, try to remove the source package on the `$LFS/sources`, copy the tar archive, decompress and relaunch the script. In most cases, it solves the problem

```sh
$ rm -rf $LFS/sources/gcc-10.2.0
$ cp /vagrant/packages-sources/gcc-10.2.0.tar.xz $LFS/sources
$ tar xvf $LFS/sources/gcc-10.2.0.tar.xz
continue...
```

If not works, investigate the problem

At any moment, you can run the script `utils/chroot.sh` to get a chroot shell in `/mnt/lfs`

### 1 - Install the cross compilation tools and the temporary tools

Connect to the `lfs` user, password `lfs`

```sh
$ ssh lfs@localhost -p 2222
Password: lfs
```

Or

```sh
$ make lfs-ssh
```

Launch the `01-tools.sh` script

```sh
$ /vagrant/01-tools.sh
```

It will install:

- Binutils-2.35 — Pass 1
- GCC-10.2.0 — Pass 1
- Linux-5.8.3 API Headers
- Glibc-2.32
- Libstdc++ de GCC-10.2.0, pass 1
- M4-1.4.18
- Ncurses-6.2
- Bash-5.0
- Coreutils-8.32
- Diffutils-3.7
- File-5.39
- Findutils-4.7.0
- Gawk-5.1.0
- Grep-3.4
- Gzip-1.10
- Make-4.3
- Patch-2.7.6
- Sed-4.8
- Tar-1.32
- Xz-5.2.5
- Binutils-2.35 — Pass 2
- GCC-10.2.0 — Pass 2

### 2 - Install the temporary tools in the chroot

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `02-tools_root.sh` script

```sh
$ /vagrant/02-tools_root.sh
```

This script will create and mount some directories, change the owner of `/mnt/lfs` to `root`, enter in a chroot on `/mnt/lfs` and install some temporary tools in the chroot

- Libstdc++ de GCC-10.2.0, Pass 2
- Gettext-0.21
- Bison-3.7.1
- Perl-5.32.0
- Python-3.8.5
- Texinfo-6.7
- Util-linux-2.36 

---

After this step, you can backup the /mnt/lfs directory to come back if it fails later

```sh
$ /vagrant/utils/backup.sh
```

For my case, it take ~ **62m55**. Move the backup archive on the shared `/vagrant/` directory

### 3 - Install base packages in the chroot

The biggest and longer part

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `03-installation_chroot.sh` script

```sh
$ /vagrant/03-installation_chroot.sh
```

It will clean the sources packages and enter in a chroot on `/mnt/lfs` and install all the packages. If you get an error, please apply the **Starting LFS** instructions

- Man-pages-5.08
- Tcl-8.6.10
- Expect-5.45.4
- DejaGNU-1.6.2
- Iana-Etc-20200821
- Glibc-2.32
- Zlib-1.2.11
- Bzip2-1.0.8
- Xz-5.2.5
- Zstd-1.4.5
- File-5.39
- Readline-8.0
- M4-1.4.18
- Bc-3.1.5
- Flex-2.6.4
- Binutils-2.35
- GMP-6.2.0
- MPFR-4.1.0
- MPC-1.1.0
- Attr-2.4.48
- Acl-2.2.53
- Libcap-2.42
- Shadow-4.8.1
- GCC-10.2.0
- Pkg-config-0.29.2
- Ncurses-6.2
- Sed-4.8
- Psmisc-23.3
- Gettext-0.21
- Bison-3.7.1
- Grep-3.4
- Bash-5.0
- Libtool-2.4.6
- GDBM-1.18.1
- Gperf-3.1
- Expat-2.2.9
- Inetutils-1.9.4
- Perl-5.32.0
- XML::Parser-2.46
- Intltool-0.51.0
- Autoconf-2.69
- Automake-1.16.2
- Kmod-27
- Libelf de Elfutils-0.180
- Libffi-3.3
- OpenSSL-1.1.1g
- Python-3.8.5
- Ninja-1.10.0
- Meson-0.55.0
- Coreutils-8.32
- Check-0.15.2
- Diffutils-3.7
- Gawk-5.1.0
- Findutils-4.7.0
- Groff-1.22.4
- GRUB-2.04
- Less-551
- Gzip-1.10
- IPRoute2-5.8.0
- Kbd-2.3.0
- Libpipeline-1.5.3
- Make-4.3
- Patch-2.7.6
- Man-DB-2.9.3
- Tar-1.32
- Texinfo-6.7
- Vim-8.2.1361
- Systemd-246
- D-Bus-1.12.20
- Procps-3.3.16
- Util-linux-2.36
- E2fsprogs-1.45.6 

### 4 - Clean the temporary tools

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `04-cleaning_chroot.sh` script

```sh
$ /vagrant/04-cleaning_chroot.sh
```

It will enter in a chroot on `/mnt/lfs` and remove all temporary libraries and tools

### 5 - System configuration

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `05-system_configuration.sh` script

```sh
$ /vagrant/05-system_configuration.sh
```

This setup is very simple, basic systemd and network configuration. Also the `/etc/fstab` for partitions. You can change it with your preferences

### 6 - Linux kernel compilation

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `06-linux.sh` script

```sh
$ /vagrant/06-linux.sh
```

This script will enter in the chroot, compile the **Linux 5.8.3** kernel, and create some files like `/etc/lsb-release` ans `/etc/os-release`. Feel free to change it.

### 7 - Grub configuration

Connect to the `root` user

```sh
$ vagrant ssh
$ sudo su
```

Launch the `07-grub.sh` script

```sh
$ /vagrant/07-grub.sh
```

This script will enter in the chroot and configure the Grub bootloader. It will install on `/dev/sda`, and the configuration file looks like this :

```
set default=0
set timeout=5

insmod ext2
set root=(hd0,4)

menuentry "GNU/Linux, Linux 5.8.3-ndubouil" {
        linux   /vmlinuz-5.8.3-ndubouil root=/dev/sda3 ro
}
```

Change it with the details of your partitions. Be careful

Launch the `08-umont.sh` script to umount the temporary directories

```sh
$ /vagrant/08-umont.sh
```

If you want somme additional packages, you can run the `09-bonus.sh` script in `root`. Highly recommended, it will install:

- OpenSSH
- Curl
- Git
- Wget
- Rsync
- Sudo

Without, you will have a distribution without software to download other packages...

**Now you can restart and boot on YOUR Linux distro!**

## Errors

### Grub

If you failed the **Grub** configuration and your distro can't boot, don't worry. There are 2 solutions.

On the Grub boot page, you can press `e` and change the configuration file temporary. If it solve the boot problem, don't forget to change the real `/boot/grub/grub.cfg`

If you need to re-install a package, or re-compile or whatever. The old **debian buster** partition is still there (on `/dev/sda1` in this case). You can boot on this partition :

On the Grub boot page, press `c` to get the grub shell

You can list the partitions with :

``` sh
grub> ls
(hd0) (hd0,msdos2) (hd0,msdos1)
```

List the content of a partition :

``` sh
grub> ls -l (hd0,msdos1)/boot/
```

To boot on the old partition, you need to get the name (`(hd0,msdos1)` here), set as root and select the kernel and init binary

``` sh
grub> set root=(hd0,1)
grub> linux /boot/vmlinuz-3.13.0-29-generic root=/dev/sda1
grub> initrd /boot/initrd.img-3.13.0-29-generic
grub> boot
```

## Pack the VM in a Vagrant box

In the directory `vagrant-box`, change the `packer.json` with the name of your VM in Virtualbox

```sh
$ make build
```

To add the box in your vagrant. You can change the name of the box in the `Makefile`

```sh
$ make add
```

Now just run `vagrant init ft_linux` in a new directory and `vagrant add`

My box is available on the Vagrant Hub [here](https://app.vagrantup.com/nirae/boxes/ft_linux)

## Resources

https://www.linux.com/training-tutorials/how-rescue-non-booting-grub-2-linux/

http://fr.linuxfromscratch.org/view/lfs-systemd-stable/

http://fr.linuxfromscratch.org/view/blfs-systemd-svn/
