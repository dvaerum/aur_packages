#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

source misc_functions.sh

ORIGINAL_PACKAGE='zfs-utils-git'
MY_PACKAGE='zfs-utils-git-any'

function patch_func {
  cp "${ORIGINAL_PACKAGE}"/* "${MY_PACKAGE}"

  ### Make it compile on any platform & add patch
  sed -E -e "s/^pkgname=.+/pkgname=${MY_PACKAGE}/" \
         -e '/^[ ]*provides=.+/d' \
         -e '/^[ ]*conflicts=.+/d' \
         -e "s/^arch=.+/arch=(\'any\')/" \
         -e '/^optdepends=/i conflicts=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)' \
         -e '/^optdepends=/i provides=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)' \
         -e '/^optdepends=/i replaces=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-git}'"\)' \
         "${ORIGINAL_PACKAGE}/PKGBUILD" > "${MY_PACKAGE}/PKGBUILD"
}

check_for_new_version
