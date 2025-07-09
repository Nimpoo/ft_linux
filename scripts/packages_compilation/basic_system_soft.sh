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
#                        *psmisc-23.7*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [psmisc-23.7]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf psmisc-23.7.tar.xz
pushd psmisc-23.7
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf psmisc-23.7

tput setaf 2
echo "[psmisc-23.7] is compiled !!!"
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


#?###########################################################
#?                                                          #
#                        *gdbm-1.25*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gdbm-1.25]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gdbm-1.25.tar.gz
pushd gdbm-1.25
  ./configure --prefix=/usr    \
              --disable-static \
              --enable-libgdbm-compat
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf gdbm-1.25

tput setaf 2
echo "[gdbm-1.25] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *gperf-3.3*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [gperf-3.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf gperf-3.3.tar.gz
pushd gperf-3.3
  ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf gperf-3.3

tput setaf 2
echo "[gperf-3.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *expat-2.7.1*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [expat-2.7.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf expat-2.7.1.tar.xz
pushd expat-2.7.1
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/expat-2.7.1
  make
  make check
  make install
  install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.1
#-----------------------------------------------------------#

  popd
rm -rf expat-2.7.1

tput setaf 2
echo "[expat-2.7.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *inetutils-2.6*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [inetutils-2.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf inetutils-2.6.tar.xz
pushd inetutils-2.6
  sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
  ./configure --prefix=/usr        \
              --bindir=/usr/bin    \
              --localstatedir=/var \
              --disable-logger     \
              --disable-whois      \
              --disable-rcp        \
              --disable-rexec      \
              --disable-rlogin     \
              --disable-rsh        \
              --disable-servers
  make
  make check
  make install
  mv -v /usr/{,s}bin/ifconfig
#-----------------------------------------------------------#

  popd
rm -rf inetutils-2.6

tput setaf 2
echo "[inetutils-2.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *less-679*                         #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [less-679]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf less-679.tar.gz
pushd less-679
  ./configure --prefix=/usr --sysconfdir=/etc
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf less-679

tput setaf 2
echo "[less-679] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *perl-5.40.2*                       #
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
  patch -Np1 -i ../perl-5.40.2-upstream_fix-1.patch

  export BUILD_ZLIB=False
  export BUILD_BZIP2=0

  sh Configure -des                                         \
              -D prefix=/usr                                \
              -D vendorprefix=/usr                          \
              -D privlib=/usr/lib/perl5/5.40/core_perl      \
              -D archlib=/usr/lib/perl5/5.40/core_perl      \
              -D sitelib=/usr/lib/perl5/5.40/site_perl      \
              -D sitearch=/usr/lib/perl5/5.40/site_perl     \
              -D vendorlib=/usr/lib/perl5/5.40/vendor_perl  \
              -D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
              -D man1dir=/usr/share/man/man1                \
              -D man3dir=/usr/share/man/man3                \
              -D pager="/usr/bin/less -isR"                 \
              -D useshrplib                                 \
              -D usethreads

  make
  TEST_JOBS=$(nproc) make test_harness
  make install

  unset BUILD_ZLIB BUILD_BZIP2
#-----------------------------------------------------------#

  popd
rm -rf perl-5.40.2

tput setaf 2
echo "[perl-5.40.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *XML::Parser-2.47*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [XML-Parser-2.47]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf XML-Parser-2.47.tar.gz
pushd XML-Parser-2.47
  perl Makefile.PL
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf XML-Parser-2.47

tput setaf 2
echo "[XML-Parser-2.47] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *intltool-0.51.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [intltool-0.51.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf intltool-0.51.0.tar.gz
pushd intltool-0.51.0
  sed -i 's:\\\${:\\\$\\{:' intltool-update.in
  ./configure --prefix=/usr
  make
  make check
  make install
  install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
#-----------------------------------------------------------#

  popd
rm -rf intltool-0.51.0

tput setaf 2
echo "[intltool-0.51.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *autoconf-2.72*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [autoconf-2.72]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf autoconf-2.72.tar.xz
pushd autoconf-2.72
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf autoconf-2.72

tput setaf 2
echo "[autoconf-2.72] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *automake-1.18.1*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [automake-1.18.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf automake-1.18.1.tar.xz
pushd automake-1.18.1
  ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
  make
  make -j$(($(nproc)>4?$(nproc):4)) check
  make install
#-----------------------------------------------------------#

  popd
rm -rf automake-1.18.1

tput setaf 2
echo "[automake-1.18.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *openSSL-3.5.0*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [openSSL-3.5.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf openSSL-3.5.0.tar.gz
pushd openSSL-3.5.0
  ./config --prefix=/usr         \
          --openssldir=/etc/ssl \
          --libdir=lib          \
          shared                \
          zlib-dynamic
  make
  HARNESS_JOBS=$(nproc) make test
  sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
  make MANSUFFIX=ssl install
  mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.5.0
  cp -vfr doc/* /usr/share/doc/openssl-3.5.0
#-----------------------------------------------------------#

  popd
rm -rf openSSL-3.5.0

tput setaf 2
echo "[openSSL-3.5.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                *libelf from elfutils-0.193*               #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libelf from elfutils-0.193]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf elfutils-0.193.tar.bz2
pushd elfutils-0.193
  ./configure --prefix=/usr        \
              --disable-debuginfod \
              --enable-libdebuginfod=dummy
  make
  make check
  make -C libelf install
  install -vm644 config/libelf.pc /usr/lib/pkgconfig
  rm /usr/lib/libelf.a
#-----------------------------------------------------------#

  popd
rm -rf elfutils-0.193

tput setaf 2
echo "[libelf from elfutils-0.193] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *libffi-3.5.1*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libffi-3.5.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libffi-3.5.1.tar.gz
pushd libffi-3.5.1
  ./configure --prefix=/usr    \
              --disable-static \
              --with-gcc-arch=native
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf libffi-3.5.1

tput setaf 2
echo "[libffi-3.5.1] is compiled !!!"
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
  ./configure --prefix=/usr          \
              --enable-shared        \
              --with-system-expat    \
              --enable-optimizations \
              --without-static-libpython
  make
  make test TESTOPTS="--timeout 120"
  make install

  #! For install pip3 :
  python3 -m ensurepip --upgrade

# ? If you want to avoid the future pip3 warning about its version :
# cat > /etc/pip.conf << EOF
# [global]
# root-user-action = ignore
# disable-pip-version-check = true
# EOF

  install -v -dm755 /usr/share/doc/python-3.13.5/html
  tar --strip-components=1  \
      --no-same-owner       \
      --no-same-permissions \
      -C /usr/share/doc/python-3.13.5/html \
      -xvf ../python-3.13.5-docs-html.tar.bz2
#-----------------------------------------------------------#

  popd
rm -rf Python-3.13.5

tput setaf 2
echo "[Python-3.13.5] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *flit_core-3.12.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [flit_core-3.12.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf flit_core-3.12.0.tar.gz
pushd flit_core-3.12.0
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist flit_core
#-----------------------------------------------------------#

  popd
rm -rf flit_core-3.12.0

tput setaf 2
echo "[flit_core-3.12.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *packaging-25.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [packaging-25.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf packaging-25.0.tar.hz
pushd packaging-25.0
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist packaging
#-----------------------------------------------------------#

  popd
rm -rf packaging-25.0

tput setaf 2
echo "[packaging-25.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *wheel-0.46.1*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [wheel-0.46.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf wheel-0.46.1.tar.gz
pushd wheel-0.46.1
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist wheel
#-----------------------------------------------------------#

  popd
rm -rf wheel-0.46.1

tput setaf 2
echo "[] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *setuptools-80.9.0*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [setuptools-80.9.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf setuptools-80.9.0.tar.gz
pushd setuptools-80.9.0
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist setuptools
#-----------------------------------------------------------#

  popd
rm -rf setuptools-80.9.0

tput setaf 2
echo "[setuptools-80.9.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *ninja-1.13.0*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [ninja-1.13.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf ninja-1.13.0.tar.gz
pushd ninja-1.13.0
  export NINJAJOBS=4
  sed -i '/int Guess/a \
    int   j = 0;\
    char* jobs = getenv( "NINJAJOBS" );\
    if ( jobs != NULL ) j = atoi( jobs );\
    if ( j > 0 ) return j;\
  ' src/ninja.cc

  python3 configure.py --bootstrap --verbose
  install -vm755 ninja /usr/bin/
  install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
  install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
#-----------------------------------------------------------#

  popd
rm -rf ninja-1.13.0

tput setaf 2
echo "[ninja-1.13.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *meson-1.8.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [meson-1.8.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf meson-1.8.2.tar.gz
pushd meson-1.8.2
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist meson
  install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
  install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
#-----------------------------------------------------------#

  popd
rm -rf meson-1.8.2

tput setaf 2
echo "[meson-1.8.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *kmod-34.2*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [kmod-34.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf kmod-34.2.tar.xz
pushd kmod-34.2
  mkdir -vp build
  pushd build
    meson setup --prefix=/usr ..    \
                --buildtype=release \
                -D manpages=false
    ninja
    ninja install
    popd
#-----------------------------------------------------------#

  popd
rm -rf kmod-34.2

tput setaf 2
echo "[kmod-34.2] is compiled !!!"
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
  patch -Np1 -i ../coreutils-9.7-upstream_fix-1.patch
  patch -Np1 -i ../coreutils-9.7-i18n-1.patch
  autoreconf -fv
  automake -af
  FORCE_UNSAFE_CONFIGURE=1 ./configure \
              --prefix=/usr            \
              --enable-no-install-program=kill,uptime

  make
  make NON_ROOT_USERNAME=tester check-root

  groupadd -g 102 dummy -U tester
  chown -R tester .
  su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
    < /dev/null
  groupdel dummy

  make install
  mv -v /usr/bin/chroot /usr/sbin
  mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
  sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
#-----------------------------------------------------------#

  popd
rm -rf coreutils-9.7

tput setaf 2
echo "[coreutils-9.7] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *diffutils-3.12*                     #
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
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf diffutils-3.12

tput setaf 2
echo "[diffutils-3.12] is compiled !!!"
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
  ./configure --prefix=/usr
  make
  chown -R tester .
  su tester -c "PATH=$PATH make check"
  rm -f /usr/bin/gawk-5.3.2
  make install
  ln -sv gawk.1 /usr/share/man/man1/awk.1
  install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2
#-----------------------------------------------------------#

  popd
rm -rf gawk-5.3.2

tput setaf 2
echo "[gawk-5.3.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *findutils-4.10.0*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [findutils-4.10.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf findutils-4.10.0
pushd findutils-4.10.0
  ./configure --prefix=/usr --localstatedir=/var/lib/locate
  make
  chown -R tester .
  su tester -c "PATH=$PATH make check"
  make install
#-----------------------------------------------------------#

  popd
rm -rf findutils-4.10.0

tput setaf 2
echo "[findutils-4.10.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *groff-1.23.0*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [groff-1.23.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf groff-1.23.0.tar.gz
pushd groff-1.23.0
  PAGE=A4 ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf groff-1.23.0

tput setaf 2
echo "[groff-1.23.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *grub-2.12*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [grub-2.12]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf grub-2.12.tar.xz
pushd grub-2.12
  unset {C,CPP,CXX,LD}FLAGS
  echo depends bli part_gpt > grub-core/extra_deps.lst

  ./configure --prefix=/usr     \
              --sysconfdir=/etc \
              --disable-efiemu  \
              --disable-werror

  make
  make install
  mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
#-----------------------------------------------------------#

  popd
rm -rf grub-2.12

tput setaf 2
echo "[grub-2.12] is compiled !!!"
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
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf gzip-1.14

tput setaf 2
echo "[gzip-1.14] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *iproute2-6.15.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [iproute2-6.15.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf iproute2-6.15.0.tar.xz
pushd iproute2-6.15.0
  sed -i /ARPD/d Makefile
  rm -fv man/man8/arpd.8
  make NETNS_RUN_DIR=/run/netns
  make SBINDIR=/usr/sbin install
  install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.15.0
#-----------------------------------------------------------#

  popd
rm -rf iproute2-6.15.0

tput setaf 2
echo "[iproute2-6.15.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *kbd-2.8.0*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [kbd-2.8.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf kbd-2.8.0.tar.xz
pushd kbd-2.8.0
  patch -Np1 -i ../kbd-2.8.0-backspace-1.patch

  sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
  sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

  ./configure --prefix=/usr --disable-vlock
  make
  make install
  cp -R -v docs/doc -T /usr/share/doc/kbd-2.8.0
#-----------------------------------------------------------#

  popd
rm -rf kbd-2.8.0

tput setaf 2
echo "[kbd-2.8.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *libpipeline-1.5.8*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libpipeline-1.5.8]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libpipeline-1.5.8.tar.gz
pushd libpipeline-1.5.8
  ./configure --prefix=/usr
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf libpipeline-1.5.8

tput setaf 2
echo "[libpipeline-1.5.8] is compiled !!!"
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
  ./configure --prefix=/usr
  make
  chown -R tester .
  su tester -c "PATH=$PATH make check"
  make install
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
  ./configure --prefix=/usr
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf patch-2.8

tput setaf 2
echo "[patch-2.8] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *tar-1.35*                         #
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
  FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
  make
  make check
  make install
  make -C doc install-html docdir=/usr/share/doc/tar-1.35
#-----------------------------------------------------------#

  popd
rm -rf tar-1.35

tput setaf 2
echo "[tar-1.35] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *vim-9.1.1497*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [vim-9.1.1497]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf vim-9.1.1497.tar.gz
pushd vim-9.1.1497
  echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
  ./configure --prefix=/usr
  make

  chown -R tester .
  sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak
  su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
    &> vim-test.log

  make install
  ln -sv vim /usr/bin/vi
  for L in  /usr/share/man/{,*/}man1/vim.1; do
      ln -sv vim.1 $(dirname $L)/vi.1
  done
  ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.1497

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
#-----------------------------------------------------------#

  popd
rm -rf vim-9.1.1497

tput setaf 2
echo "[vim-9.1.1497] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *markupsafe-3.0.2*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [markupsafe-3.0.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf markupsafe-3.0.2.tar.gz
pushd markupsafe-3.0.2
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist Markupsafe
#-----------------------------------------------------------#

  popd
rm -rf markupsafe-3.0.2

tput setaf 2
echo "[markupsafe-3.0.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *jinja2-3.1.6*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [jinja2-3.1.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf jinja2-3.1.6.tar.gz
pushd jinja2-3.1.6
  pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
  pip3 install --no-index --find-links dist Jinja2
#-----------------------------------------------------------#

  popd
rm -rf jinja2-3.1.6

tput setaf 2
echo "[jinja2-3.1.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *systemd-257.6*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [systemd-257.6]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf systemd-257.6.tar.gz
pushd systemd-257.6
  sed -e 's/GROUP="render"/GROUP="video"/' \
      -e 's/GROUP="sgx", //'               \
      -i rules.d/50-udev-default.rules.in

  mkdir -pv build
  pushd build
    meson setup ..                \
          --prefix=/usr           \
          --buildtype=release     \
          -D default-dnssec=no    \
          -D firstboot=false      \
          -D install-tests=false  \
          -D ldconfig=false       \
          -D sysusers=false       \
          -D rpmmacrosdir=no      \
          -D homed=disabled       \
          -D userdb=false         \
          -D man=disabled         \
          -D mode=release         \
          -D pamconfdir=no        \
          -D dev-kvm-mode=0660    \
          -D nobody-group=nogroup \
          -D sysupdate=disabled   \
          -D ukify=disabled       \
          -D docdir=/usr/share/doc/systemd-257.6
    ninja
    echo 'NAME="Linux From Scratch"' > /etc/os-release
    ninja test
    ninja install
    tar -xf ../../systemd-man-pages-257.6.tar.xz \
        --no-same-owner --strip-components=1     \
        -C /usr/share/man
    systemd-machine-id-setup
    systemctl preset-all
#-----------------------------------------------------------#

  popd
rm -rf systemd-257.6

tput setaf 2
echo "[systemd-257.6] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *dbus-1.16.2*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [dbus-1.16.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf dbus-1.16.2.tar.xz
pushd dbus-1.16.2
  mkdir -v build
  pushd build
    meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
    ninja
    ninja test
    ninja install
    ln -sfv /etc/machine-id /var/lib/dbus
#-----------------------------------------------------------#

  popd
rm -rf dbus-1.16.2

tput setaf 2
echo "[dbus-1.16.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *man-db-2.13.1*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [man-db-2.13.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf man-db-2.13.1.tar.xz
pushd man-db-2.13.1
  ./configure --prefix=/usr                         \
              --docdir=/usr/share/doc/man-db-2.13.1 \
              --sysconfdir=/etc                     \
              --disable-setuid                      \
              --enable-cache-owner=bin              \
              --with-browser=/usr/bin/lynx          \
              --with-vgrind=/usr/bin/vgrind         \
              --with-grap=/usr/bin/grap
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf man-db-2.13.1

tput setaf 2
echo "[man-db-2.13.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *procps-ng-4.0.5*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [procps-ng-4.0.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf procps-ng-4.0.5.tar.xz
pushd procps-ng-4.0.5
  ./configure --prefix=/usr                           \
              --docdir=/usr/share/doc/procps-ng-4.0.5 \
              --disable-static                        \
              --disable-kill                          \
              --enable-watch8bit                      \
              --with-systemd
  make
  chown -R tester .
  su tester -c "PATH=$PATH make check"
  make install
#-----------------------------------------------------------#

  popd
rm -rf procps-ng-4.0.5

tput setaf 2
echo "[procps-ng-4.0.5] is compiled !!!"
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
  ./configure --bindir=/usr/bin     \
              --libdir=/usr/lib     \
              --runstatedir=/run    \
              --sbindir=/usr/sbin   \
              --disable-chfn-chsh   \
              --disable-login       \
              --disable-nologin     \
              --disable-su          \
              --disable-setpriv     \
              --disable-runuser     \
              --disable-pylibmount  \
              --disable-liblastlog2 \
              --disable-static      \
              --without-python      \
              ADJTIME_PATH=/var/lib/hwclock/adjtime \
              --docdir=/usr/share/doc/util-linux-2.41.1
  make
  touch /etc/fstab
  chown -R tester .
  su tester -c "make -k check"
  
#-----------------------------------------------------------#

  popd
rm -rf util-linux-2.41.1

tput setaf 2
echo "[util-linux-2.41.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        **                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile []. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf 
pushd 
  
#-----------------------------------------------------------#

  popd
rm -rf 

tput setaf 2
echo "[] is compiled !!!"
tput sgr0
