#!/bin/bash

# ? Virtual partition
umount -v $LFS/dev/pts
mountpoint -q $LFS/dev/shm && umount -v $LFS/dev/shm
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

# ? Physical partition
umount -v $LFS/boot
/sbin/swapoff -v /dev/sdb2
umount -v $LFS
