#!/bin/bash

set -eu

pushd /sources


#?###########################################################
#?                                                          #
#                        *efivar-39*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [efivar-39]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf efivar-39.tar.gz
pushd efivar-39
  make ENABLE_DOCS=0
  make install ENABLE_DOCS=0 LIBDIR=/usr/lib
  install -vm644 docs/efivar.1 /usr/share/man/man1 &&
  install -vm644 docs/*.3      /usr/share/man/man3
#-----------------------------------------------------------#

  popd
rm -rf efivar-39

tput setaf 2
echo "[efivar-39] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *popt-1.19*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [popt-1.19]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf popt-1.19.tar.gz
pushd popt-1.19
  ./configure --prefix=/usr --disable-static &&
  make
  make install
  install -v -m755 -d /usr/share/doc/popt-1.19 &&
  install -v -m644 doxygen/html/* /usr/share/doc/popt-1.19
#-----------------------------------------------------------#

  popd
rm -rf popt-1.19

tput setaf 2
echo "[popt-1.19] is compiled !!!"
tput sgr0



#?###########################################################
#?                                                          #
#                      *efibootmgr-18*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [efibootmgr-18]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf efibootmgr-18.tar.gz
pushd efibootmgr-18
  make EFIDIR=LFS EFI_LOADER=grubx64.efi
  make install EFIDIR=LFS
#-----------------------------------------------------------#

  popd
rm -rf efibootmgr-18

tput setaf 2
echo "[efibootmgr-18] is compiled !!!"
tput sgr0



#?###########################################################
#?                                                          #
#                      *libaio-0.3.113*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libaio-0.3.113]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libaio-0.3.113
pushd libaio-0.3.113
  sed -i '/install.*libaio.a/s/^/#/' src/Makefile
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf libaio-0.3.113

tput setaf 2
echo "[libaio-0.3.113] is compiled !!!"
tput sgr0



#?###########################################################
#?                                                          #
#                       *LVM2.2.03.33*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [LVM2.2.03.33]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf LVM2.2.03.33.tgz
pushd LVM2.2.03.33
  tput setaf 4
  echo "WARNING !!! DON'T FORGET TO RECOMPILE THE KERNEL WITH THE SPECIFIC OPTION BEFORE CONTINUE. Press any key to continue..."
  tput sgr0
  read -n 1 -s -r -p ""
  echo ""

  PATH+=:/usr/sbin                \
  ./configure --prefix=/usr       \
              --enable-cmdlib     \
              --enable-pkgconfig  \
              --enable-udev_sync  &&
  make
  make -C tools install_tools_dynamic &&
  make -C udev  install               &&
  make -C libdm install
  LC_ALL=en_US.UTF-8 make check_local
  make install
  make install_systemd_units

  sed -e '/locking_dir =/{s/#//;s/var/run/}' \
      -i /etc/lvm/lvm.conf
#-----------------------------------------------------------#

  popd
rm -rf LVM2.2.03.33

tput setaf 2
echo "[LVM2.2.03.33] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *fuse-3.17.3*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [fuse-3.17.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf fuse-3.17.3.tar.gz
pushd fuse-3.17.3
    tput setaf 4
    echo "WARNING !!! DON'T FORGET TO RECOMPILE THE KERNEL WITH THE SPECIFIC OPTION BEFORE CONTINUE. Press any key to continue..."
    tput sgr0
    read -n 1 -s -r -p ""
    echo ""

  sed -i '/^udev/,$ s/^/#/' util/meson.build &&

  mkdir build &&
  cd    build &&

  meson setup --prefix=/usr --buildtype=release .. &&
  ninja

  ninja install                  &&
  chmod u+s /usr/bin/fusermount3 &&

  cd ..                          &&
  cp -Rv doc/html -T /usr/share/doc/fuse-3.17.3 &&
  install -v -m644   doc/{README.NFS,kernel.txt} \
                    /usr/share/doc/fuse-3.17.3
#-----------------------------------------------------------#

  popd
rm -rf fuse-3.17.3

tput setaf 2
echo "[fuse-3.17.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libpng-1.6.50*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libpng-1.6.50]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libpng-1.6.50.tar.xz
pushd libpng-1.6.50
  gzip -cd ../libpng-1.6.47-apng.patch.gz | patch -p1
  ./configure --prefix=/usr --disable-static &&
  make
  make install &&
  mkdir -v /usr/share/doc/libpng-1.6.50 &&
  cp -v README libpng-manual.txt /usr/share/doc/libpng-1.6.50
#-----------------------------------------------------------#

  popd
rm -rf libpng-1.6.50

tput setaf 2
echo "[libpng-1.6.50] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *which-2.23*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [which-2.23]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf which-2.23.tar.gz
pushd which-2.23
  ./configure --prefix=/usr &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf which-2.23

tput setaf 2
echo "[which-2.23] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                  *freetype-2.13.3 PASS 1*                 #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [freetype-2.13.3 PASS 1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf freetype-2.13.3.tar.xz
pushd freetype-2.13.3
  tar -xf ../freetype-doc-2.13.3.tar.xz --strip-components=2 -C docs
  sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&

  sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
      -i include/freetype/config/ftoption.h  &&

  ./configure --prefix=/usr --enable-freetype-config --disable-static &&
  make
  make install
  cp -v -R docs -T /usr/share/doc/freetype-2.13.3 &&
  rm -v /usr/share/doc/freetype-2.13.3/freetype-config.1
#-----------------------------------------------------------#

  popd
rm -rf freetype-2.13.3

tput setaf 2
echo "[freetype-2.13.3 PASS 1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *docutils-0.21.2*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [docutils-0.21.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf docutils-0.21.2.tar.gz
pushd docutils-0.21.2
  for f in /usr/bin/rst*.py; do
    rm -fv /usr/bin/$(basename $f .py)
  done
  pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
  pip3 install --no-index --find-links dist --no-user docutils
#-----------------------------------------------------------#

  popd
rm -rf docutils-0.21.2

tput setaf 2
echo "[docutils-0.21.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *pcre2-10.45*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [pcre2-10.45]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf pcre2-10.45.tar.bz2
pushd pcre2-10.45
  ./configure --prefix=/usr                       \
              --docdir=/usr/share/doc/pcre2-10.45 \
              --enable-unicode                    \
              --enable-jit                        \
              --enable-pcre2-16                   \
              --enable-pcre2-32                   \
              --enable-pcre2grep-libz             \
              --enable-pcre2grep-libbz2           \
              --enable-pcre2test-libreadline      \
              --disable-static                    &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf pcre2-10.45

tput setaf 2
echo "[pcre2-10.45] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *icu4c-77_1*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [icu4c-77_1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf icu4c-77_1.tgz
pushd icu
  cd source                 &&
  ./configure --prefix=/usr &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf icu

tput setaf 2
echo "[icu4c-77_1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *libxml2-2.14.5*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libxml2-2.14.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libxml2-2.14.5.tar.xz
pushd libxml2-2.14.5
  ./configure --prefix=/usr     \
              --sysconfdir=/etc \
              --disable-static  \
              --with-history    \
              --with-icu        \
              PYTHON=/usr/bin/python3 \
              --docdir=/usr/share/doc/libxml2-2.14.5 &&
  make

  tar xf ../xmlts20130923.tar.gz
  make check > check.log
  grep -E '^Total|expected|Ran' check.log

  make install
  rm -vf /usr/lib/libxml2.la &&
  sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config
#-----------------------------------------------------------#

  popd
rm -rf libxml2-2.14.5

tput setaf 2
echo "[libxml2-2.14.5] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                         *lzo-2.10*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [lzo-2.10]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf lzo-2.10.tar.gz
pushd lzo-2.10
  ./configure --prefix=/usr    \
              --enable-shared  \
              --disable-static \
              --docdir=/usr/share/doc/lzo-2.10 &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf lzo-2.10

tput setaf 2
echo "[lzo-2.10] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *nettle-3.10.2*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [nettle-3.10.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf nettle-3.10.2.tar.gz
pushd nettle-3.10.2
  ./configure --prefix=/usr --disable-static &&
  make
  make install &&
  chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
  install -v -m755 -d /usr/share/doc/nettle-3.10.2 &&
  install -v -m644 nettle.{html,pdf} /usr/share/doc/nettle-3.10.2
#-----------------------------------------------------------#

  popd
rm -rf nettle-3.10.2

tput setaf 2
echo "[nettle-3.10.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *libarchive-3.8.1*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libarchive-3.8.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libarchive-3.8.1.tar.xz
pushd libarchive-3.8.1
  ./configure --prefix=/usr --disable-static &&
  make
  make install
  ln -sfv bsdunzip /usr/bin/unzip
#-----------------------------------------------------------#

  popd
rm -rf libarchive-3.8.1

tput setaf 2
echo "[libarchive-3.8.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *docbook-xml-4.5*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [docbook-xml-4.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
mkdir -v docbook-xml-4.5
pushd docbook-xml-4.5
  unzip ../docbook-xml-4.5.zip

  install -v -d -m755 /usr/share/xml/docbook/xml-dtd-4.5         &&
  install -v -d -m755 /etc/xml                                   &&
  cp -v -af --no-preserve=ownership docbook.cat *.dtd ent/ *.mod \
      /usr/share/xml/docbook/xml-dtd-4.5

  if [ ! -e /etc/xml/docbook ]; then
      xmlcatalog --noout --create /etc/xml/docbook
  fi &&

  xmlcatalog --noout --add "public"                            \
      "-//OASIS//DTD DocBook XML V4.5//EN"                     \
      "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                            \
      "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN"    \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                            \
      "-//OASIS//DTD XML Exchange Table Model 19990315//EN"    \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                              \
      "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod"    \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                                \
      "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod"      \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                            \
      "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN"    \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                           \
      "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN"     \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                                \
      "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod"      \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "public"                                         \
      "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod"              \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "rewriteSystem"        \
      "http://www.oasis-open.org/docbook/xml/4.5" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5" \
      /etc/xml/docbook &&

  xmlcatalog --noout --add "rewriteURI"           \
      "http://www.oasis-open.org/docbook/xml/4.5" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5" \
      /etc/xml/docbook

  if [ ! -e /etc/xml/catalog ]; then
      xmlcatalog --noout --create /etc/xml/catalog
  fi &&

  xmlcatalog --noout --add "delegatePublic" \
      "-//OASIS//ENTITIES DocBook XML"      \
      "file:///etc/xml/docbook"             \
      /etc/xml/catalog                      &&

  xmlcatalog --noout --add "delegatePublic" \
      "-//OASIS//DTD DocBook XML"           \
      "file:///etc/xml/docbook"             \
      /etc/xml/catalog                      &&

  xmlcatalog --noout --add "delegateSystem" \
      "http://www.oasis-open.org/docbook/"  \
      "file:///etc/xml/docbook"             \
      /etc/xml/catalog                      &&

  xmlcatalog --noout --add "delegateURI"    \
      "http://www.oasis-open.org/docbook/"  \
      "file:///etc/xml/docbook"             \
      /etc/xml/catalog

  for DTDVERSION in 4.1.2 4.2 4.3 4.4
  do
    xmlcatalog --noout --add "public"                                  \
      "-//OASIS//DTD DocBook XML V$DTDVERSION//EN"                     \
      "http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd" \
      /etc/xml/docbook

    xmlcatalog --noout --add "rewriteSystem"              \
      "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5"         \
      /etc/xml/docbook
    
    xmlcatalog --noout --add "rewriteURI"                 \
      "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
      "file:///usr/share/xml/docbook/xml-dtd-4.5"         \
      /etc/xml/docbook
    
    xmlcatalog --noout --add "delegateSystem"              \
      "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
      "file:///etc/xml/docbook"                            \
      /etc/xml/catalog
    
    xmlcatalog --noout --add "delegateURI"                 \
      "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
      "file:///etc/xml/docbook"                            \
      /etc/xml/catalog
  done
#-----------------------------------------------------------#

  popd
rm -rf docbook-xml-4.5

tput setaf 2
echo "[docbook-xml-4.5] is compiled !!!"
tput sgr0

#?###########################################################
#?                                                          #
#                 *docbook-xsl-nons-1.79.2*                 #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [docbook-xsl-nons-1.79.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf docbook-xsl-nons-1.79.2.tar.bz2
pushd docbook-xsl-nons-1.79.2
  patch -Np1 -i ../docbook-xsl-nons-1.79.2-stack_fix-1.patch
  tar -xf ../docbook-xsl-doc-1.79.2.tar.bz2 --strip-components=1

  install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

  cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
          highlighting html htmlhelp images javahelp lib manpages params  \
          profiling roundtrip slides template tests tools webhelp website \
          xhtml xhtml-1_1 xhtml5                                          \
      /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

  ln -s VERSION /usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/VERSION.xsl &&

  install -v -m644 -D README \
                      /usr/share/doc/docbook-xsl-nons-1.79.2/README.txt &&

  install -v -m644    RELEASE-NOTES* NEWS* \
                      /usr/share/doc/docbook-xsl-nons-1.79.2

  cp -v -R doc/* /usr/share/doc/docbook-xsl-nons-1.79.2

  if [ ! -d /etc/xml ]; then install -v -m755 -d /etc/xml; fi &&
  if [ ! -f /etc/xml/catalog ]; then
      xmlcatalog --noout --create /etc/xml/catalog
  fi &&

  xmlcatalog --noout --add "rewriteSystem"                        \
            "http://cdn.docbook.org/release/xsl-nons/1.79.2"     \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteSystem"                        \
            "https://cdn.docbook.org/release/xsl-nons/1.79.2"    \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                           \
            "http://cdn.docbook.org/release/xsl-nons/1.79.2"     \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                           \
            "https://cdn.docbook.org/release/xsl-nons/1.79.2"    \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteSystem"                        \
            "http://cdn.docbook.org/release/xsl-nons/current"    \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteSystem"                        \
            "https://cdn.docbook.org/release/xsl-nons/current"   \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                           \
            "http://cdn.docbook.org/release/xsl-nons/current"    \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                           \
            "https://cdn.docbook.org/release/xsl-nons/current"   \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteSystem"                        \
            "http://docbook.sourceforge.net/release/xsl/current" \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                           \
            "http://docbook.sourceforge.net/release/xsl/current" \
            "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog

  xmlcatalog --noout --add "rewriteSystem"                          \
            "http://docbook.sourceforge.net/release/xsl/<version>" \
            "/usr/share/xml/docbook/xsl-stylesheets-<version>"     \
            /etc/xml/catalog &&

  xmlcatalog --noout --add "rewriteURI"                             \
            "http://docbook.sourceforge.net/release/xsl/<version>" \
            "/usr/share/xml/docbook/xsl-stylesheets-<version>"     \
            /etc/xml/catalog
#-----------------------------------------------------------#

  popd
rm -rf docbook-xsl-nons-1.79.2

tput setaf 2
echo "[docbook-xsl-nons-1.79.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *libxslt-1.1.43*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libxslt-1.1.43]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libxslt-1.1.43.tar.xz
pushd libxslt-1.1.43
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/libxslt-1.1.43 &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf libxslt-1.1.43

tput setaf 2
echo "[libxslt-1.1.43] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *glib-2.84.3*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [glib-2.84.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf glib-2.84.3.tar.xz
pushd glib-2.84.3
  export GLIB_LOG_LEVEL=4
  patch -Np1 -i ../glib-skip_warnings-1.patch
  mkdir -v build
  pushd build

    meson setup ..                  \
          --prefix=/usr             \
          --buildtype=release       \
          -D introspection=disabled \
          -D glib_debug=disabled    \
          -D man-pages=enabled      \
          -D sysprof=disabled       &&
    ninja
    ninja install
    tar xf ../../gobject-introspection-1.84.0.tar.xz &&

    meson setup gobject-introspection-1.84.0 gi-build \
                --prefix=/usr --buildtype=release     &&
    ninja -C gi-build
    ninja -C gi-build test
    ninja -C gi-build install
    meson configure -D introspection=enabled &&
    ninja
    ninja install
    popd
#-----------------------------------------------------------#

  popd
rm -rf glib-2.84.3

tput setaf 2
echo "[glib-2.84.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *libunistring-1.3*                    #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libunistring-1.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libunistring-1.3.tar.xz
pushd libunistring-1.3
  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/libunistring-1.3 &&
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf libunistring-1.3

tput setaf 2
echo "[libunistring-1.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libidn2-2.3.8*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libidn2-2.3.8]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libidn2-2.3.8.tar.gz
pushd libidn2-2.3.8
  ./configure --prefix=/usr --disable-static &&
  make
  make check
  make install
#-----------------------------------------------------------#

  popd
rm -rf libidn2-2.3.8

tput setaf 2
echo "[libidn2-2.3.8] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libpsl-0.21.5*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libpsl-0.21.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libpsl-0.21.5.gz
pushd libpsl-0.21.5
  mkdir -v build
  pushd build

    meson setup --prefix=/usr --buildtype=release &&
    ninja
    ninja install
    popd
#-----------------------------------------------------------#

  popd
rm -rf libpsl-0.21.5

tput setaf 2
echo "[libpsl-0.21.5] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *libtasn1-4.20.0*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libtasn1-4.20.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libtasn1-4.20.0.tar/gz
pushd libtasn1-4.20.0
  ./configure --prefix=/usr --disable-static &&
  make
  make check
  make install
  make -C doc/reference install-data-local
#-----------------------------------------------------------#

  popd
rm -rf libtasn1-4.20.0

tput setaf 2
echo "[libtasn1-4.20.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *p11-kit-0.25.5*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [p11-kit-0.25.5]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf p11-kit-0.25.5.tar.xz
pushd p11-kit-0.25.5
  sed '20,$ d' -i trust/trust-extract-compat &&

  cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF

  mkdir -v p11-build
  pushd p11-build

    meson setup ..            \
          --prefix=/usr       \
          --buildtype=release \
          -D trust_paths=/etc/pki/anchors &&
    ninja

    LC_ALL=C ninja test

    ninja install &&
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
            /usr/bin/update-ca-certificates
    ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
    popd
#-----------------------------------------------------------#

  popd
rm -rf p11-kit-0.25.5

tput setaf 2
echo "[p11-kit-0.25.5] is compiled !!!"
tput sgr0



#?###########################################################
#?                                                          #
#                        *nspr-4.37*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [nspr-4.37]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf nspr-4.37.tar.gz
pushd nspr-4.37
  pushd nspr

    sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in &&
    sed -i 's|$(LIBRARY) ||'  config/rules.mk         &&

    ./configure --prefix=/usr   \
                --with-mozilla  \
                --with-pthreads \
                $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
    make
    make install
    popd
#-----------------------------------------------------------#

  popd
rm -rf nspr-4.37

tput setaf 2
echo "[nspr-4.37] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                 *sqlite-autoconf-3500300*                 #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [sqlite-autoconf-3500300]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf sqlite-autoconf-3500300.tar.gz
pushd sqlite-autoconf-3500300
  unzip -q ../sqlite-doc-3500300.zip

  ./configure --prefix=/usr     \
              --disable-static  \
              --enable-fts{4,5} \
              CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                        -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                        -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                        -D SQLITE_SECURE_DELETE=1"         &&
  make
  make install
  install -v -m755 -d /usr/share/doc/sqlite-3.50.3 &&
  cp -v -R sqlite-doc-3500300/* /usr/share/doc/sqlite-3.50.3
#-----------------------------------------------------------#

  popd
rm -rf sqlite-autoconf-3500300

tput setaf 2
echo "[sqlite-autoconf-3500300] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                        *nss-3.114*                        #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [nss-3.114]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf nss-3.114.tar.gz
pushd nss-3.114
  patch -Np1 -i ../nss-standalone-1.patch &&

  cd nss &&

  make BUILD_OPT=1                      \
    NSPR_INCLUDE_DIR=/usr/include/nspr  \
    USE_SYSTEM_ZLIB=1                   \
    ZLIB_LIBS=-lz                       \
    NSS_ENABLE_WERROR=0                 \
    $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
    $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)
  
  cd ../dist                                                          &&

  install -v -m755 Linux*/lib/*.so              /usr/lib              &&
  install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib              &&

  install -v -m755 -d                           /usr/include/nss      &&
  cp -v -RL {public,private}/nss/*              /usr/include/nss      &&

  install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&

  install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig
  ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
#-----------------------------------------------------------#

  popd
rm -rf nss-3.114

tput setaf 2
echo "[nss-3.114] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *make-ca-1.16.1*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [make-ca-1.16.1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf make-ca-1.16.1.tar.gz
pushd make-ca-1.16.1
  make install &&
  install -vdm755 /etc/ssl/local
  /usr/sbin/make-ca -g
  systemctl enable update-pki.timer
  export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt
  mkdir -pv /etc/profile.d &&
  cat > /etc/profile.d/pythoncerts.sh << "EOF"
# Begin /etc/profile.d/pythoncerts.sh

export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt

# End /etc/profile.d/pythoncerts.sh
EOF
#-----------------------------------------------------------#

  popd
rm -rf make-ca-1.16.1

tput setaf 2
echo "[make-ca-1.16.1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *wget-1.25.0*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [wget-1.25.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf wget-1.25.0.tar.gz
pushd wget-1.25.0
  ./configure --prefix=/usr      \
              --sysconfdir=/etc  \
              --with-ssl=openssl &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf wget-1.25.0

tput setaf 2
echo "[wget-1.25.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *openssh-10.0p1*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [openssh-10.0p1]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf openssh-10.0p1.tar.gz
pushd openssh-10.0p1
  install -v -g sys -m700 -d /var/lib/sshd &&

  groupadd -g 50 sshd        &&
  useradd  -c 'sshd PrivSep' \
          -d /var/lib/sshd  \
          -g sshd           \
          -s /bin/false     \
          -u 50 sshd

  ./configure --prefix=/usr                            \
              --sysconfdir=/etc/ssh                    \
              --with-privsep-path=/var/lib/sshd        \
              --with-default-path=/usr/bin             \
              --with-superuser-path=/usr/sbin:/usr/bin \
              --with-pid-dir=/run                      &&
  make

  make install &&
  install -v -m755    contrib/ssh-copy-id /usr/bin     &&

  install -v -m644    contrib/ssh-copy-id.1 \
                      /usr/share/man/man1              &&
  install -v -m755 -d /usr/share/doc/openssh-10.0p1     &&
  install -v -m644    INSTALL LICENCE OVERVIEW README* \
                      /usr/share/doc/openssh-10.0p1

  tar -xf ../blfs-systemd-units-20241211.tar.xz
  pushd blfs-systemd-units-20241211
    make install-sshd
    popd
#-----------------------------------------------------------#

  popd
rm -rf openssh-10.0p1

tput setaf 2
echo "[openssh-10.0p1] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *curl-8.15.0*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [curl-8.15.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf curl-8.15.0.tar.xz
pushd curl-8.15.0
  ./configure --prefix=/usr    \
              --disable-static \
              --with-openssl   \
              --with-ca-path=/etc/ssl/certs &&
  make

  make install &&

  rm -rf docs/examples/.deps &&

  find docs \( -name Makefile\* -o  \
              -name \*.1       -o  \
              -name \*.3       -o  \
              -name CMakeLists.txt \) -delete &&

  cp -v -R docs -T /usr/share/doc/curl-8.15.0
#-----------------------------------------------------------#

  popd
rm -rf curl-8.15.0

tput setaf 2
echo "[curl-8.15.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *libuv-v1.51.0*                      #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [libuv-v1.51.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf libuv-v1.51.0.tar.gz
pushd libuv-v1.51.0
  unset ACLOCAL
  sh autogen.sh                              &&
  ./configure --prefix=/usr --disable-static &&
  make
  make man -C docs
  make install
  install -Dm644 docs/build/man/libuv.1 /usr/share/man/man1
#-----------------------------------------------------------#

  popd
rm -rf libuv-v1.51.0

tput setaf 2
echo "[libuv-v1.51.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *nghttp2-1.66.0*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [nghttp2-1.66.0]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf nghttp2-1.66.0.tar.xz
pushd nghttp2-1.66.0
  ./configure --prefix=/usr     \
              --disable-static  \
              --enable-lib-only \
              --docdir=/usr/share/doc/nghttp2-1.66.0 &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf nghttp2-1.66.0

tput setaf 2
echo "[nghttp2-1.66.0] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                       *cmake-4.0.3*                       #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [cmake-4.0.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf cmake-4.0.3.tar.gz
pushd cmake-4.0.3
  sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

  ./bootstrap --prefix=/usr        \
              --system-libs        \
              --mandir=/share/man  \
              --no-system-jsoncpp  \
              --no-system-cppdap   \
              --no-system-librhash \
              --docdir=/share/doc/cmake-4.0.3 &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf cmake-4.0.3

tput setaf 2
echo "[cmake-4.0.3] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                    *graphite2-1.3.14*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [graphite2-1.3.14]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf graphite2-1.3.14.tgz
pushd graphite2-1.3.14
  sed -i '/cmptest/d' tests/CMakeLists.txt
  sed -i '/cmake_policy(SET CMP0012 NEW)/d' CMakeLists.txt &&
  sed -i 's/PythonInterp/Python3/' CMakeLists.txt          &&
  find . -name CMakeLists.txt | xargs sed -i 's/VERSION 2.8.0 FATAL_ERROR/VERSION 4.0.0/'
  sed -i '/Font.h/i #include <cstdint>' tests/featuremap/featuremaptest.cpp

  mkdir -v build
  pushd build

    cmake -D CMAKE_INSTALL_PREFIX=/usr .. &&
    make
    make docs
    make install
    install -v -d -m755 /usr/share/doc/graphite2-1.3.14 &&

    cp      -v -f    doc/{GTF,manual}.html \
                        /usr/share/doc/graphite2-1.3.14 &&
    cp      -v -f    doc/{GTF,manual}.pdf \
                        /usr/share/doc/graphite2-1.3.14
    popd
#-----------------------------------------------------------#

  popd
rm -rf graphite2-1.3.14

tput setaf 2
echo "[graphite2-1.3.14] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                     *harfbuzz-11.3.2*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [harfbuzz-11.3.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf harfbuzz-11.3.2.tar.xz
pushd harfbuzz-11.3.2
  mkdir -v build
  pushd build

    meson setup ..             \
          --prefix=/usr        \
          --buildtype=release  \
          -D graphite2=enabled &&
    ninja
    ninja install
#-----------------------------------------------------------#

  popd
rm -rf harfbuzz-11.3.2

tput setaf 2
echo "[harfbuzz-11.3.2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                 *freetype-2.13.3 PASS 2*                  #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [freetype-2.13.3]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf freetype-2.13.3.tar.xz
pushd freetype-2.13.3
  tar -xf ../freetype-doc-2.13.3.tar.xz --strip-components=2 -C docs
  sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&

  sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
      -i include/freetype/config/ftoption.h  &&

  ./configure --prefix=/usr --enable-freetype-config --disable-static &&
  make
  make install
  cp -v -R docs -T /usr/share/doc/freetype-2.13.3 &&
  rm -v /usr/share/doc/freetype-2.13.3/freetype-config.1
#-----------------------------------------------------------#

  popd
rm -rf freetype-2.13.3

tput setaf 2
echo "[freetype-2.13.3 PASS 2] is compiled !!!"
tput sgr0


#?###########################################################
#?                                                          #
#                      *dosfstools-4.2*                     #
#?                                                          #
#?###########################################################

tput setaf 4
echo "You are about to compile [dosfstools-4.2]. Press any key to continue..."
tput sgr0
read -n 1 -s -r -p ""
echo ""

#-----------------------------------------------------------#
tar -xf dosfstools-4.2.tar.gz
pushd dosfstools-4.2
  tput setaf 4
  echo "WARNING !!! DON'T FORGET TO RECOMPILE THE KERNEL WITH THE SPECIFIC OPTION BEFORE CONTINUE. Press any key to continue..."
  tput sgr0
  read -n 1 -s -r -p ""
  echo ""

  ./configure --prefix=/usr            \
              --enable-compat-symlinks \
              --mandir=/usr/share/man  \
              --docdir=/usr/share/doc/dosfstools-4.2 &&
  make
  make install
#-----------------------------------------------------------#

  popd
rm -rf dosfstools-4.2

tput setaf 2
echo "[dosfstools-4.2] is compiled !!!"
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
  tput setaf 4
  echo "WARNING !!! DON'T FORGET TO RECOMPILE THE KERNEL WITH THE SPECIFIC OPTION FOR GRUB IN LFS-SYSTEMD BEFORE CONTINUE. Press any key to continue..."
  tput sgr0
  read -n 1 -s -r -p ""
  echo ""

  unset {C,CPP,CXX,LD}FLAGS
  mkdir -pv /usr/share/fonts/unifont &&
  gunzip -c ../unifont-16.0.01.pcf.gz > /usr/share/fonts/unifont/unifont.pcf
  echo depends bli part_gpt > grub-core/extra_deps.lst

  ./configure --prefix=/usr        \
              --sysconfdir=/etc    \
              --disable-efiemu     \
              --with-platform=efi  \
              --target=x86_64      \
              --disable-werror     &&
  make
  make install &&
  mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
  make -C grub-core install
  install -vm755 grub-mkfont /usr/bin/ &&
  install -vm644 ascii.h widthspec.h *.pf2 /usr/share/grub/
  install -vm755 grub-mount /usr/bin/
#-----------------------------------------------------------#

  popd
rm -rf grub-2.12

tput setaf 2
echo "[grub-2.12] is compiled !!!"
tput sgr0


cat >> /etc/fstab << EOF
/dev/sda1 /boot/efi vfat codepage=437,iocharset=iso8859-1 0 1
EOF

cat > /boot/grub/grub.cfg << EOF
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd0,2)

insmod efi_gop
insmod efi_uga
if loadfont /boot/grub/fonts/unicode.pf2; then
  terminal_output gfxterm
fi

menuentry "GNU/Linux, Linux 6.15.6-mayoub" {
  linux   /vmlinuz-6.15.4-mayoub root=/dev/sda3 ro
}

menuentry "Firmware Setup" {
  fwsetup
}
EOF
