#!/bin/bash

# ? Physical partition
mount -v -t ext4 /dev/sdb3 $LFS/
mount -v -t ext4 /dev/sdb2 $LFS/boot
mount -v -t vfat /dev/sdb1 -o codepage=437,iocharset=iso8859-1 $LFS/boot/efi
/sbin/swapon -v /dev/sdb4

# ? Virtual partition for debugging or something else
mount -v --bind /dev $LFS/dev

mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
