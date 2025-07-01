#!/bin/bash

pushd $LFS/sources


#?###########################################################
#?                                                          #
#                      *binutils-2.44*                      #
#                         *PASS 1*                          #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [binutils-2.44 PASS 1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

tar -xf binutils-2.44.tar.xz
pushd binutils-2.44
  mkdir -v build
  pushd build
    ../configure --prefix=$LFS/tools \
              --with-sysroot=$LFS \
              --target=$LFS_TGT   \
              --disable-nls       \
              --enable-gprofng=no \
              --disable-werror    \
              --enable-new-dtags  \
              --enable-default-hash-style=gnu
    make
    make install
    popd
  popd
rm -rf binutils-2.44

tput setaf 2
echo "[binutils-2.44] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gcc-15.1.0*                       #
#                         *PASS 1*                          #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gcc-15.1.0 PASS 1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

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

  mkdir -v build
  pushd build
    ../configure                  \
      --target=$LFS_TGT         \
      --prefix=$LFS/tools       \
      --with-glibc-version=2.41 \
      --with-sysroot=$LFS       \
      --with-newlib             \
      --without-headers         \
      --enable-default-pie      \
      --enable-default-ssp      \
      --disable-nls             \
      --disable-shared          \
      --disable-multilib        \
      --disable-threads         \
      --disable-libatomic       \
      --disable-libgomp         \
      --disable-libquadmath     \
      --disable-libssp          \
      --disable-libvtv          \
      --disable-libstdcxx       \
      --enable-languages=c,c++
    make
    make install
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
    popd
  popd
rm -rf gcc-15.1.0

tput setaf 2
echo "[gcc-15.1.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *linux-6.15.2*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [linux-6.15.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

tar -xf linux-6.15.2.tar.xz
pushd linux-6.15.2
  make mrproper
  make headers
  find usr/include -type f ! -name '*.h' -delete
  cp -rv usr/include $LFS/usr
  popd
rm -rf linux-6.15.2

tput setaf 2
echo "[linux-6.15.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *glibc-2.41*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [glibc-2.41]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

tar -xf glibc-2.41.tar.xz
pushd glibc-2.41
  case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
  esac

  patch -Np1 -i ../glibc-2.41-fhs-1.patch
  mkdir -v build
  pushd build
    echo "rootsbindir=/usr/sbin" > configparms
    ../configure                             \
          --prefix=/usr                      \
          --host=$LFS_TGT                    \
          --build=$(../scripts/config.guess) \
          --disable-nscd                     \
          libc_cv_slibdir=/usr/lib           \
          --enable-kernel=5.4
    make
    make DESTDIR=$LFS install

    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
    echo 'int main(){}' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'

    #! Just testing here
    echo "Do you wish to test if the `glibc` is correctly compiled ?"
    select yn in "Yes" "No"; do
      case $yn in
        Yes )
          echo ""
          echo "Check of the set up to use the correct start files. Press any key to continue..."
          read -n 1 -s -r -p ""
          echo ""
          grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log;

          echo ""
          echo "Check that the compiler is searching for the correct header files. Press any key to continue..."
          read -n 1 -s -r -p ""
          echo ""
          grep -B3 "^ $LFS/usr/include" dummy.log

          echo ""
          echo "Check that the new linker is being used with the correct search paths. Press any key to continue..."
          read -n 1 -s -r -p ""
          echo ""
          grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

          echo "Check if we're using the correct libc. Press any key to continue..."
          read -n 1 -s -r -p ""
          echo ""
          grep "/lib.*/libc.so.6 " dummy.log

          echo ""
          echo "Check if GCC is using the correct dynamic linker. Press any key to continue..."
          read -n 1 -s -r -p ""
          echo ""
          grep found dummy.log

          rm -v a.out dummy.log
          break;;
        No ) break;;
      esac
    done

    popd
  popd
rm -rf glibc-2.41

tput setaf 2
echo "[glibc-2.41] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                *libstdc++ from gcc-15.1.0*                #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libstdc++]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

tar -xf gcc-15.1.0.tar.xz
pushd gcc-15.1.0
  mkdir -v build
  pushd build
    ../libstdc++-v3/configure      \
        --host=$LFS_TGT            \
        --build=$(../config.guess) \
        --prefix=/usr              \
        --disable-multilib         \
        --disable-nls              \
        --disable-libstdcxx-pch    \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.1.0
    make
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
    popd
  popd
  rm -rf gcc-15.1.0

tput setaf 2
echo "[libstdc++] is compiled !!!"
tput sgr0

popd
