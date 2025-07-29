#!/bin/bash

qemu-system-x86_64 \
	-enable-kvm \
	-m 28G \
	-smp cores=16,threads=2,sockets=1 \
	-cpu host \
	-net nic,model=virtio -net user,hostfwd=tcp::22222-:22 \
	-device virtio-balloon \
	-vga virtio \
	-full-screen \
	-daemonize \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=OVMF_VARS.fd \
	-hda lfs.qcow2

# Don't forget to run this command before to create your LFS hard drive :
# * `dd if=/dev/zero of=lfs.iso bs=4M count=3840 conv=fdatasync status=progress`
# * OR
# * `qemu-img create -f qcow2 /sgoinfre/mayoub/vms/lfs.qcow2 -o preallocation=off 18G`
