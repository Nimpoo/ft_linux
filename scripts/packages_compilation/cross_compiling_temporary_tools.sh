#!/bin/bash

pushd $LFS/sources


#?###########################################################
#?                                                          #
#                        *m4-1.4.20*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [m4-1.4.20]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf m4-1.4.20.tar.xz
pushd m4-1.4.20
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf m4-1.4.20

tput setaf 2
echo "[m4-1.4.20] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                   *ncurses-6.5-20250531*                  #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [ncurses-6.5-20250531]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf ncurses-6.5-20250531.tgz
pushd ncurses-6.5-20250531
  mkdir -v build
  pushd build
    ../configure --prefix=$LFS/tools AWK=gawk
    make -C include
    make -C progs tic
    install progs/tic $LFS/tools/bin
    popd
  ./configure --prefix=/usr                \
              --host=$LFS_TGT              \
              --build=$(./config.guess)    \
              --mandir=/usr/share/man      \
              --with-manpage-format=normal \
              --with-shared                \
              --without-normal             \
              --with-cxx-shared            \
              --without-debug              \
              --without-ada                \
              --disable-stripping          \
              AWK=gawk
  make
  make DESTDIR=$LFS install
  ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
  sed -e 's/^#if.*XOPEN.*$/#if 1/' \
      -i $LFS/usr/include/curses.h
#-----------------------------------------------------------#

  popd
rm -rf ncurses-6.5-20250531

tput setaf 2
echo "[ncurses-6.5-20250531] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *bash-5.3-rc2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [bash-5.3-rc2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

tar -xf bash-5.3-rc2.tar.gz
pushd bash-5.3-rc2

#-----------------------------------------------------------#
  ./configure --prefix=/usr                      \
              --build=$(sh support/config.guess) \
              --host=$LFS_TGT                    \
              --without-bash-malloc
  make
  make DESTDIR=$LFS install
  ln -sv bash $LFS/bin/sh
#-----------------------------------------------------------#

  popd
rm -rf bash-5.3-rc2

tput setaf 2
echo "[bash-5.3-rc2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *coreutils-9.7*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [coreutils-9.7]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf coreutils-9.7.tar.xz
pushd coreutils-9.7

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --enable-install-program=hostname \
              --enable-no-install-program=kill,uptime
  make
  make DESTDIR=$LFS install
  mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
  mkdir -pv $LFS/usr/share/man/man8
  mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
  sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
#-----------------------------------------------------------#

  popd
rm -rf coreutils-9.7

tput setaf 2
echo "[coreutils-9.7] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *diffutils-3.12*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [diffutils-3.12]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf diffutils-3.12.tar.xz
pushd diffutils-3.12
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              gl_cv_func_strcasecmp_works=y \
              --build=$(./build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf diffutils-3.12

tput setaf 2
echo "[diffutils-3.12] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *file-5.46*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [file-5.46]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf file-5.46.tar.gz
pushd file-5.46
  mkdir -v build
  pushd build
    ../configure --disable-bzlib      \
                --disable-libseccomp \
                --disable-xzlib      \
                --disable-zlib
    make
    popd
  ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
  make FILE_COMPILE=$(pwd)/build/src/file
  make DESTDIR=$LFS install
  rm -v $LFS/usr/lib/libmagic.la
#-----------------------------------------------------------#

  popd
rm -rf file-5.46

tput setaf 2
echo "[file-5.46] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *findutils-4.10.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [findutils-4.10.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf findutils-4.10.0.tar.xz
pushd findutils-4.10.0
  ./configure --prefix=/usr                   \
              --localstatedir=/var/lib/locate \
              --host=$LFS_TGT                 \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf findutils-4.10.0

tput setaf 2
echo "[findutils-4.10.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gawk-5.3.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gawk-5.3.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gawk-5.3.2.tar.xz
pushd gawk-5.3.2
  sed -i 's/extras//' Makefile.in
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf gawk-5.3.2

tput setaf 2
echo "[gawk-5.3.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *grep-3.12*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [grep-3.12]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf grep-3.12.tar.xz
pushd grep-3.12
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(./build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf grep-3.12

tput setaf 2
echo "[grep-3.12] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gzip-1.14*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gzip-1.14]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gzip-1.14.tar.xz
pushd gzip-1.14
  ./configure --prefix=/usr --host=$LFS_TGT
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf gzip-1.14

tput setaf 2
echo "[gzip-1.14] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *make-4.4.1*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [make-4.4.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf make-4.4.1.tar.gz
pushd make-4.4.1
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf make-4.4.1

tput setaf 2
echo "[make-4.4.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *patch-2.8*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [patch-2.8]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf patch-2.8.tar.xz
pushd patch-2.8
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf patch-2.8

tput setaf 2
echo "[patch-2.8] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                         *sed-4.9*                         #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [sed-4.9]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf sed-4.9.tar.xz
pushd sed-4.9
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(./build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf sed-4.9

tput setaf 2
echo "[sed-4.9] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                         *tar-1.35*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [tar-1.35]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf tar-1.35.tar.xz
pushd tar-1.35
  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)
  make
  make DESTDIR=$LFS install
#-----------------------------------------------------------#

  popd
rm -rf tar-1.35

tput setaf 2
echo "[tar-1.35] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *xz-5.8.1*                         #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [xz-5.8.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf xz-5.8.1.tar.xz
pushd xz-5.8.1
  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --disable-static                  \
              --docdir=/usr/share/doc/xz-5.8.1
  make
  make DESTDIR=$LFS install
  rm -v $LFS/usr/lib/liblzma.la
#-----------------------------------------------------------#

  popd
rm -rf xz-5.8.1

tput setaf 2
echo "[xz-5.8.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *binutils-2.44*                      #
#                         *PASS 2*                          #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [binutils-2.44 PASS 2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf binutils-2.44.tar.xz
pushd binutils-2.44
  sed '6031s/$add_dir//' -i ltmain.sh
  mkdir -v build
  pushd build
    ../configure                   \
        --prefix=/usr              \
        --build=$(../config.guess) \
        --host=$LFS_TGT            \
        --disable-nls              \
        --enable-shared            \
        --enable-gprofng=no        \
        --disable-werror           \
        --enable-64-bit-bfd        \
        --enable-new-dtags         \
        --enable-default-hash-style=gnu
    make
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
#-----------------------------------------------------------#

  popd
rm -rf binutils-2.44

tput setaf 2
echo "[binutils-2.44 PASS 2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gcc-15.1.0*                       #
#                         *PASS 2*                          #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gcc-15.1.0 PASS 2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gcc-15.1.0.tar.xz
pushd gcc-15.1.0
  tar -xf ../mpfr-4.2.2.tar.xz
  mv -v mpfr-4.2.2 mpfr
  tar -xf ../gmp-6.3.0.tar.xz
  mv -v gmp-6.3.0 gmp
  tar -xf ../mpc-1.3.1.tar.gz
  mv -v mpc-1.3.1 mpc

  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
    ;;
  esac

  sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

  mkdir -v build
  pushd build
    ../configure                   \
        --build=$(../config.guess) \
        --host=$LFS_TGT            \
        --target=$LFS_TGT          \
        --prefix=/usr              \
        --with-build-sysroot=$LFS  \
        --enable-default-pie       \
        --enable-default-ssp       \
        --disable-nls              \
        --disable-multilib         \
        --disable-libatomic        \
        --disable-libgomp          \
        --disable-libquadmath      \
        --disable-libsanitizer     \
        --disable-libssp           \
        --disable-libvtv           \
        --enable-languages=c,c++   \
        LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc
    make
    make DESTDIR=$LFS install
    ln -sv gcc $LFS/usr/bin/cc
#-----------------------------------------------------------#

  popd
rm -rf gcc-15.1.0

tput setaf 2
echo "[gcc-15.1.0] is compiled !!!"
tput sgr0

popd
