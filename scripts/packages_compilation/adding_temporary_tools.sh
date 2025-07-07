#!/bin/bash

pushd /sources


#?###########################################################
#?                                                          #
#                       *gettext-0.25*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gettext-0.25]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gettext-0.25.tar.xz
pushd gettext-0.25
  ./configure --disable-shared
  make
  cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
#-----------------------------------------------------------#

  popd
rm -rf gettext-0.25

tput setaf 2
echo "[gettext-0.25] is compiled !!!"
tput sgr0
popd


#?###########################################################
#?                                                          #
#                       *bison-3.8.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [bison-3.8.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf bison-3.8.2.tar.xz
pushd bison-3.8.2
  ./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf bison-3.8.2

tput setaf 2
echo "[bison-3.8.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *perl-5.40.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [perl-5.40.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf perl-5.40.2.tar.xz
pushd perl-5.40.2
  sh Configure -des                                        \
              -D prefix=/usr                               \
              -D vendorprefix=/usr                         \
              -D useshrplib                                \
              -D privlib=/usr/lib/perl5/5.40/core_perl     \
              -D archlib=/usr/lib/perl5/5.40/core_perl     \
              -D sitelib=/usr/lib/perl5/5.40/site_perl     \
              -D sitearch=/usr/lib/perl5/5.40/site_perl    \
              -D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
              -D vendorarch=/usr/lib/perl5/5.40/vendor_perl
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf perl-5.40.2

tput setaf 2
echo "[perl-5.40.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *Python-3.13.5*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [Python-3.13.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf Python-3.13.5.tar.xz
pushd Python-3.13.5
  ./configure --prefix=/usr       \
              --enable-shared     \
              --without-ensurepip \
              --without-static-libpython
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf Python-3.13.5

tput setaf 2
echo "[Python-3.13.5] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *texinfo-7.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [texinfo-7.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf texinfo-7.2.tar.xz
pushd texinfo-7.2
  ./configure --prefix=/usr
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf texinfo-7.2

tput setaf 2
echo "[texinfo-7.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *util-linux-2.41.1*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [util-linux-2.41.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf util-linux-2.41.1.tar.xz
pushd util-linux-2.41.1
  mkdir -pv /var/lib/hwclock
  ./configure --libdir=/usr/lib     \
              --runstatedir=/run    \
              --disable-chfn-chsh   \
              --disable-login       \
              --disable-nologin     \
              --disable-su          \
              --disable-setpriv     \
              --disable-runuser     \
              --disable-pylibmount  \
              --disable-static      \
              --disable-liblastlog2 \
              --without-python      \
              ADJTIME_PATH=/var/lib/hwclock/adjtime \
              --docdir=/usr/share/doc/util-linux-2.41.1
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf util-linux-2.41.1

tput setaf 2
echo "[util-linux-2.41.1] is compiled !!!"
tput sgr0

popd

tput setaf 4
echo "You are about to [Cleaning up]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools

tput setaf 2
echo "The chroot tasks are done."
tput sgr0
