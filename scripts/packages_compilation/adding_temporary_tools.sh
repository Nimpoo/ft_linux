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


