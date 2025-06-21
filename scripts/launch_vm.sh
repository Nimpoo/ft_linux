#!/bin/bash

qemu-system-x86_64 \
	-enable-kvm \
	-m 28G \
	-smp cores=16,threads=2,sockets=1 \
	-cpu host \
	-net nic,model=virtio \
	-net user \
	-device virtio-balloon \
	-vga virtio \
	-full-screen \
	-daemonize \
	-hda ubuntu-proud.qcow2 \
	-hdb lfs.iso
# Don't forget to run this command before to create your LFS hard drive : `dd if=/dev/zero of=lfs.iso bs=4M count=3840 conv=fdatasync status=progress`
