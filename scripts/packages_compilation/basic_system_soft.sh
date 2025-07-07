#!/bin/bash

set -eu

pushd /sources


#?###########################################################
#?                                                          #
#                      *man-pages-6.14*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [man-pages-6.14]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf man-pages-6.14.tar.xz
pushd man-pages-6.14
  rm -v man3/crypt*
  make -R GIT=false prefix=/usr install
#-----------------------------------------------------------#

  popd
rm -rf man-pages-6.14

tput setaf 2
echo "[man-pages-6.14] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *iana-etc-20250618*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [iana-etc-20250618]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf iana-etc-20250618.tar.gz
pushd iana-etc-20250618
  cp services protocols /etc
#-----------------------------------------------------------#

  popd
rm -rf iana-etc-20250618

tput setaf 2
echo "[iana-etc-20250618] is compiled !!!"
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

#-----------------------------------------------------------#
tar -xf glibc-2.41.tar.xz
pushd glibc-2.41
  patch -Np1 -i ../glibc-2.41-fhs-1.patch

  mkdir -v build
  pushd build
    echo "rootsbindir=/usr/sbin" > configparms
    ../configure --prefix=/usr                  \
                --disable-werror                \
                --disable-nscd                  \
                libc_cv_slibdir=/usr/lib        \
                --enable-stack-protector=strong \
                --enable-kernel=5.4
    make

    echo "Do you wish to the command `make check` (it's extremly long) ?"
    select yn in "Yes" "No"; do
      case $yn in
        Yes )
          make check
          break;;
        No ) break;;
      esac

    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    make install
    sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
    localedef -i en_US -f UTF-8 en_US.UTF-8cat

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    tar -xf ../../tzdata2025b.tar.gz

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
              asia australasia backward; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO tz

    tzselect

    ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
    popd
#-------------------------------cat ----------------------------#

  popd
rm -rf glibc-2.41

tput setaf 2
echo "[glibc-2.41] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *zlib-1.3.1*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [zlib-1.3.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf zlib-1.3.1.tar.gz
pushd zlib-1.3.1
  ./configure --prefix=/usr
  make
  make check
  make install
  rm -fv /usr/lib/libz.a
#-----------------------------------------------------------#

  popd
rm -rf zlib-1.3.1

tput setaf 2
echo "[zlib-1.3.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *bzip2-1.0.8*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [bzip2-1.0.8]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf bzip2-1.0.8.tar.gz
pushd bzip2-1.0.8
  patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
  sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
  sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

  make -f Makefile-libbz2_so
  make clean

  make
  make PREFIX=/usr install

  cp -av libbz2.so.* /usr/lib
  ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

  cp -v bzip2-shared /usr/bin/bzip2
  for i in /usr/bin/{bzcat,bunzip2}; do
    ln -sfv bzip2 $i
  done

  rm -fv /usr/lib/libbz2.a
#-----------------------------------------------------------#

  popd
rm -rf bzip2-1.0.8

tput setaf 2
echo "[bzip2-1.0.8] is compiled !!!"
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
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/xz-5.8.1
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf xz-5.8.1

tput setaf 2
echo "[xz-5.8.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *lz4-1.10.0*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [lz4-1.10.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf z4-1.10.0.tar.gz
pushd lz4-1.10.0
  make BUILD_STATIC=no PREFIX=/usr
  make -j1 check
  make BUILD_STATIC=no PREFIX=/usr install
#-----------------------------------------------------------#

  popd
rm -rf lz4-1.10.0

tput setaf 2
echo "[lz4-1.10.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *zstd-1.5.7*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [zstd-1.5.7]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf zstd-1.5.7.tar.gz
pushd zstd-1.5.7
  make prefix=/usr
  make check
  make prefix=/usr install
  rm -v /usr/lib/libzstd.a
#-----------------------------------------------------------#

  popd
rm -rf zstd-1.5.7

tput setaf 2
echo "[zstd-1.5.7] is compiled !!!"
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
  tar -xf file-5.46.tar.gz
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf file-5.46

tput setaf 2
echo "[file-5.46] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *readline-8.3-rc2*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [readline-8.3-rc2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf tar -xf readline-8.3-rc2.tar.gz
pushd readline-8.3-rc2
  sed -i '/MV.*old/d' Makefile.in
  sed -i '/{OLDSUFF}/c:' support/shlib-install
  sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

  ./configure --prefix=/usr    \
              --disable-static \
              --with-curses    \
              --docdir=/usr/share/doc/readline-8.3-rc2
  make SHLIB_LIBS="-lncursesw"
  make install
  install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3-rc2
#-----------------------------------------------------------#

  popd
rm -rf readline-8.3-rc2

tput setaf 2
echo "[readline-8.3-rc2] is compiled !!!"
tput sgr0


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
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf m4-1.4.20

tput setaf 2
echo "[m4-1.4.20] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                         *bc-7.0.3*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [bc-7.0.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf bc-7.0.3.tar.xz
pushd bc-7.0.3
  CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
  make
  make test
  make install
#-----------------------------------------------------------#

  popd
rm -rf bc-7.0.3

tput setaf 2
echo "[bc-7.0.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *flex-2.6.4*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [flex-2.6.4]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf flex-2.6.4.tar.gz
pushd flex-2.6.4
  ./configure --prefix=/usr \
              --docdir=/usr/share/doc/flex-2.6.4 \
              --disable-static
  make
  make check
  make install

  ln -sv flex   /usr/bin/lex
  ln -sv flex.1 /usr/share/man/man1/lex.1
#-----------------------------------------------------------#

  popd
rm -rf flex-2.6.4

tput setaf 2
echo "[flex-2.6.4] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *tcl8.6.16*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [tcl8.6.16]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf tcl8.6.16-src.tar.gz
pushd tcl8.6.16
  SRCDIR=$(pwd)
  pushd unix
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --disable-rpath
    make
    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.10|/usr/lib/tdbc1.1.10|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.10/generic|/usr/include|"     \
        -e "s|$SRCDIR/pkgs/tdbc1.1.10/library|/usr/lib/tcl8.6|"  \
        -e "s|$SRCDIR/pkgs/tdbc1.1.10|/usr/include|"             \
        -i pkgs/tdbc1.1.10/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.2|/usr/lib/itcl4.3.2|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.2/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.3.2|/usr/include|"            \
        -i pkgs/itcl4.3.2/itclConfig.sh

    unset SRCDIR

    make test
    make install
    chmod -v u+w /usr/lib/libtcl8.6.so
    make install-private-headers

    ln -sfv tclsh8.6 /usr/bin/tclsh

    mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

    popd
  tar -xf ../tcl8.6.16-html.tar.gz --strip-components=1
  mkdir -v -p /usr/share/doc/tcl-8.6.16
  cp -v -r  ./html/* /usr/share/doc/tcl-8.6.16
#-----------------------------------------------------------#

  popd
rm -rf tcl8.6.16

tput setaf 2
echo "[tcl8.6.16] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *expect-5.45.4*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [expect-5.45.4]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf expect5.45.4.tar.gz
pushd expect-5.45.4
  # TODO: need to be improve, script need to stop if it's not "ok"
  python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
  patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
  ./configure --prefix=/usr           \
              --with-tcl=/usr/lib     \
              --enable-shared         \
              --disable-rpath         \
              --mandir=/usr/share/man \
              --with-tclinclude=/usr/include
  make
  make test
  make install
  ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
#-----------------------------------------------------------#

  popd
rm -rf expect-5.45.4

tput setaf 2
echo "[expect-5.45.4] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *dejagnu-1.6.3*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [dejagnu-1.6.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf dejagnu-1.6.3.tar.gz
pushd dejagnu-1.6.3
  mkdir -v build
  pushd build
    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

    make check

    make install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.3
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
    popd
#-----------------------------------------------------------#

  popd
rm -rf dejagnu-1.6.3

tput setaf 2
echo "[dejagnu-1.6.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *pkgconf-2.5.1*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [pkgconf-2.5.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf pkgconf-2.5.1.tar.xz
pushd pkgconf-2.5.1
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/pkgconf-2.5.1
  make
  make install
  make install
  install -v -dm755  /usr/share/doc/dejagnu-1.6.3
  install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
#-----------------------------------------------------------#

  popd
rm -rf pkgconf-2.5.1

tput setaf 2
echo "[pkgconf-2.5.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *binutils-2.44*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [binutils-2.44]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf binutils-2.44.tar.xz
pushd binutils-2.44
  mkdir -v build
  pushd build
  ../configure --prefix=/usr       \
              --sysconfdir=/etc   \
              --enable-ld=default \
              --enable-plugins    \
              --enable-shared     \
              --disable-werror    \
              --enable-64-bit-bfd \
              --enable-new-dtags  \
              --with-system-zlib  \
              --enable-default-hash-style=gnu
  make tooldir=/usr
  make -k check
  # todo: `grep '^FAIL:' $(find -name '*.log')`` - gestion d'erreur ici
  make tooldir=/usr install
  rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/
#-----------------------------------------------------------#

  popd
rm -rf binutils-2.44

tput setaf 2
echo "[binutils-2.44] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gmp-6.3.0*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gmp-6.3.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gmp-6.3.0.tar.xz
pushd gmp-6.3.0
  sed -i '/long long t1;/,+1s/()/(...)/' configure
  ./configure --prefix=/usr    \
              --enable-cxx     \
              --disable-static \
              --docdir=/usr/share/doc/gmp-6.3.0
  make
  make html
  make check 2>&1 | tee gmp-check-log
  awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
  make install
  make install-html
#-----------------------------------------------------------#

  popd
rm -rf gmp-6.3.0

tput setaf 2
echo "[gmp-6.3.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *mpfr-4.2.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [mpfr-4.2.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf mpfr-4.2.2.tar.xz
pushd mpfr-4.2.2
  ./configure --prefix=/usr        \
              --disable-static     \
              --enable-thread-safe \
              --docdir=/usr/share/doc/mpfr-4.2.2
  make
  make html
  make check
  make install
  make install-html
#-----------------------------------------------------------#

  popd
rm -rf mpfr-4.2.2

tput setaf 2
echo "[mpfr-4.2.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *mpc-1.3.1*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [mpc-1.3.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf mpc-1.3.1.tar.gz
pushd mpc-1.3.1
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/mpc-1.3.1
  make
  make html
  make check
  make install
  make install-html
#-----------------------------------------------------------#

  popd
rm -rf mpc-1.3.1

tput setaf 2
echo "[mpc-1.3.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *attr-2.5.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [attr-2.5.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf attr-2.5.2.tar.gz
pushd attr-2.5.2
  ./configure --prefix=/usr     \
              --disable-static  \
              --sysconfdir=/etc \
              --docdir=/usr/share/doc/attr-2.5.2
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf attr-2.5.2

tput setaf 2
echo "[attr-2.5.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *acl-2.3.2*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [acl-2.3.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf acl-2.3.2.tar.xz
pushd acl-2.3.2
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/acl-2.3.2
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf acl-2.3.2

tput setaf 2
echo "[acl-2.3.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *libcap-2.76*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libcap-2.76]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libcap-2.76.tar.xz
pushd libcap-2.76
  sed -i '/install -m.*STA/d' libcap/Makefile
  make prefix=/usr lib=lib
  make test
  make prefix=/usr lib=lib install
#-----------------------------------------------------------#

  popd
rm -rf libcap-2.76

tput setaf 2
echo "[libcap-2.76] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *libxcrypt-4.4.38*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libxcrypt-4.4.38]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libxcrypt-4.4.38.tar.xz
pushd libxcrypt-4.4.38
  ./configure --prefix=/usr                \
              --enable-hashes=strong,glibc \
              --enable-obsolete-api=no     \
              --disable-static             \
              --disable-failure-tokens
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf libxcrypt-4.4.38

tput setaf 2
echo "[libxcrypt-4.4.38] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *shadow-4.18.0*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [shadow-4.18.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf shadow-4.18.0.tar.xz
pushd shadow-4.18.0
  sed -i 's/groups$(EXEEXT) //' src/Makefile.in
  find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
  find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
  find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

  sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
      -e 's:/var/spool/mail:/var/mail:'                   \
      -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
      -i etc/login.defs

  touch /usr/bin/passwd
  ./configure --sysconfdir=/etc   \
              --disable-static    \
              --with-{b,yes}crypt \
              --without-libbsd    \
              --with-group-name-max-length=32

  make
  make exec_prefix=/usr install
  make -C man install-man
#-----------------------------------------------------------#

  popd
rm -rf shadow-4.18.0

tput setaf 2
echo "[shadow-4.18.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gcc-15.1.0*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gcc-15.1.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gcc-15.1.0.tar.xz
pushd gcc-15.1.0
  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
    ;;
  esac

  mkdir -v build
  pushd build
    ../configure --prefix=/usr            \
                LD=ld                    \
                --enable-languages=c,c++ \
                --enable-default-pie     \
                --enable-default-ssp     \
                --enable-host-pie        \
                --disable-multilib       \
                --disable-bootstrap      \
                --disable-fixincludes    \
                --with-system-zlib
    make
    ulimit -s -H unlimited

    sed -e '/cpython/d'               -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
    sed -e 's/no-pic /&-no-pie /'     -i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
    sed -e 's/300000/(1|300000)/'     -i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
    sed -e 's/{ target nonpic } //' \
        -e '/GOTPCREL/d'              -i ../gcc/testsuite/gcc.target/i386/fentryname3.c

    chown -R tester .
    su tester -c "PATH=$PATH make -k check"

    # TODO: parser ici pour extraire le resultat des test : `../contrib/test_summary`

    make install
    # TODO: Ici aussi faire les gestions de tests
    # TODO: De la...
    chown -v -R root:root \
        /usr/lib/gcc/$(gcc -dumpmachine)/15.1.0/include{,-fixed}
    # TODO: ...a la.

    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1
    ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.1.0/liblto_plugin.so \
            /usr/lib/bfd-plugins/

    # TODO: Ici aussi faire les gestions de tests
    # TODO: De la...
    echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'
    grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
    grep -B4 '^ /usr/include' dummy.log
    grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " dummy.log
    grep found dummy.log
    rm -v a.out dummy.log
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
    # TODO: ...a la.

    popd
#-----------------------------------------------------------#

  popd
rm -rf gcc-15.1.0

tput setaf 2
echo "[gcc-15.1.0] is compiled !!!"
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
  ./configure --prefix=/usr           \
              --mandir=/usr/share/man \
              --with-shared           \
              --without-debug         \
              --without-normal        \
              --with-cxx-shared       \
              --enable-pc-files       \
              --with-pkg-config-libdir=/usr/lib/pkgconfig
  make
  make DESTDIR=$PWD/dest install
  install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
  rm -v  dest/usr/lib/libncursesw.so.6.5
  sed -e 's/^#if.*XOPEN.*$/#if 1/' \
      -i dest/usr/include/curses.h
  cp -av dest/* /

  for lib in ncurses form panel menu ; do
      ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
      ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
  done

  ln -sfv libncursesw.so /usr/lib/libcurses.so
  cp -v -R doc -T /usr/share/doc/ncurses-6.5-20250531
#-----------------------------------------------------------#

  popd
rm -rf ncurses-6.5-20250531

tput setaf 2
echo "[ncurses-6.5-20250531] is compiled !!!"
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
  ./configure --prefix=/usr
  make
  make html

  chown -R tester .
  su tester -c "PATH=$PATH make check"

  make install
  install -d -m755           /usr/share/doc/sed-4.9
  install -m644 doc/sed.html /usr/share/doc/sed-4.9
#-----------------------------------------------------------#

  popd
rm -rf sed-4.9

tput setaf 2
echo "[sed-4.9] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *psmic-23.7*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [psmic-23.7]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf psmic-23.7.tar.xz
pushd psmic-23.7
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf psmic-23.7

tput setaf 2
echo "[psmic-23.7] is compiled !!!"
tput sgr0


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
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/gettext-0.25
  make
  make check
  make install
  chmod -v 0755 /usr/lib/preloadable_libintl.so
#-----------------------------------------------------------#

  popd
rm -rf gettext-0.25

tput setaf 2
echo "[gettext-0.25] is compiled !!!"
tput sgr0


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
  ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf bison-3.8.2

tput setaf 2
echo "[bison-3.8.2] is compiled !!!"
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
  sed -i "s/echo/#echo/" src/egrep.sh
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf grep-3.12

tput setaf 2
echo "[grep-3.12] is compiled !!!"
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

#-----------------------------------------------------------#
tar -xf bash-5.3-rc2.tar.gz
pushd bash-5.3-rc2
  ./configure --prefix=/usr             \
              --without-bash-malloc     \
              --with-installed-readline \
              --docdir=/usr/share/doc/bash-5.3-rc2
  make
  chown -R tester .

su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

  make install
  exec /usr/bin/bash --login
#-----------------------------------------------------------#

  popd
rm -rf bash-5.3-rc2

tput setaf 2
echo "[bash-5.3-rc2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libtool-2.5.4*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libtool-2.5.4]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libtool-2.5.4.tar.xz
pushd libtool-2.5.4
  ./configure --prefix=/usr
  make
  make check
  make install
  rm -fv /usr/lib/libltdl.a
#-----------------------------------------------------------#

  popd
rm -rf libtool-2.5.4

tput setaf 2
echo "[libtool-2.5.4] is compiled !!!"
tput sgr0
