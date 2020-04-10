#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

source misc_functions.sh

ORIGINAL_PACKAGE='zfs-dkms-git'
MY_PACKAGE='zfs-dkms-git-any'

function patch_func {
  cp "${ORIGINAL_PACKAGE}"/* "${MY_PACKAGE}"

  ### Make it compile on any platform & add patch
  sed -E -e "s/^pkgname=.+/pkgname=${MY_PACKAGE}/" \
         -e '/^[ ]*depends=.+/d' \
         -e "s/^arch=.+/arch=(\'any\')/" \
         -e 's/^conflicts=.+/conflicts=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)/' \
         -e 's/^provides=.+/provides=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)/' \
         -e 's/^replaces=.+/replaces=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)/' \
         -e '/^license=/i depends=\("'zfs-utils-git-any'" "'dkms'"\)' \
         -e 's/%-dkms/%-dkms-any/g' \
         "${ORIGINAL_PACKAGE}/PKGBUILD" > "${MY_PACKAGE}/PKGBUILD"
}

check_for_new_version
