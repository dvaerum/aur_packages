#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

source misc_functions.sh

ORIGINAL_PACKAGE='mkinitcpio-sd-zfs'
MY_PACKAGE='mkinitcpio-sd-zfs-any'

function patch_func {
  cp "${ORIGINAL_PACKAGE}"/* "${MY_PACKAGE}"

  ### Make it compile on any platform & add patch
  sed -E -e "s/^pkgname=.+/pkgname=${MY_PACKAGE}/" \
         -e "s/^arch=.+/arch=(\'any\')/" \
         "${ORIGINAL_PACKAGE}/PKGBUILD" > "${MY_PACKAGE}/PKGBUILD"
}

check_for_new_version
