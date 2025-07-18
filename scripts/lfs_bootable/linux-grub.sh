#!/bin/bash

set -eu

pushd /sources


#?###########################################################
#?                                                          #
#                       *linux-6.15.6*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [linux-6.15.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf linux-6.15.6.tar.xz
pushd linux-6.15.6
  make mrproper
	make menuconfig
  make
  make modules_install
  cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.15.6-mayoub
  cp -iv System.map /boot/System.map-6.15.6
  cp -iv .config /boot/config-6.15.6
  cp -r Documentation -T /usr/share/doc/linux-6.15.6
  install -v -m755 -d /etc/modprobe.d
  cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
#-----------------------------------------------------------#

  popd

tput setaf 2
echo "[linux-6.15.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libburn-1.5.6*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libburn-1.5.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libburn-1.5.6.tar.gz
pushd libburn-1.5.6
  sed -i 's/catch_int ()/catch_int (int signum)/' test/poll.c
  ./configure --prefix=/usr --disable-static &&
  make
  make install
  install -v -dm755 /usr/share/doc/libburn-1.5.6 &&
  install -v -m644 doc/html/* /usr/share/doc/libburn-1.5.6
#-----------------------------------------------------------#

  popd
rm -rf libburn-1.5.6

tput setaf 2
echo "[libburn-1.5.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libisofs-1.5.6*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libisofs-1.5.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libisofs-1.5.6.tar.gz
pushd libisofs-1.5.6
  ./configure --prefix=/usr --disable-static &&
  make
  make install
  install -v -dm755 /usr/share/doc/libisofs-1.5.6 &&
  install -v -m644 doc/html/* /usr/share/doc/libisofs-1.5.6
#-----------------------------------------------------------#

  popd
rm -rf libisofs-1.5.6

tput setaf 2
echo "[libisofs-1.5.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *libisoburn-1.5.6*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libisoburn-1.5.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libisoburn-1.5.6.tar.gz
pushd libisoburn-1.5.6
  ./configure --prefix=/usr              \
              --disable-static           \
              --enable-pkg-check-modules &&
  make
  make install
  install -v -dm755 /usr/share/doc/libisoburn-1.5.6 &&
  install -v -m644 doc/html/* /usr/share/doc/libisoburn-1.5.6
#-----------------------------------------------------------#

  popd
rm -rf libisoburn-1.5.6

tput setaf 2
echo "[libisoburn-1.5.6] is compiled !!!"
tput sgr0


cd /tmp
grub-mkrescue --output=grub-img.iso
xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso
grub-install /dev/sda
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd1,3)
set gfxpayload=1024x768x32

menuentry "GNU/Linux, Linux 6.15.6-mayoub" {
        linux   /boot/vmlinuz-6.15.6-mayoub root=/dev/sdb3 ro
}
EOF
